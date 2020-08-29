//
//  TimeLineViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase

class TimeLineViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    let refreshCtl = UIRefreshControl()
    // Firestoreのリスナー
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        //画面下部の境界線を消す
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil {
            guard let myUid = Auth.auth().currentUser?.uid else {return}
            // ログイン済み
            //listenerがnilでないとき return
            guard listener == nil  else{return}
            // listener未登録なら、登録してスナップショットを受信する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // ここでusersから自分がフォローしている人のuidを取得する
                let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)
                postUserRef.addSnapshotListener() {
                    (querySnapshot2,error) in
                    if let error = error {
                        print("DEBUG: snapshotの取得が失敗しました。\(error)")
                        return
                    } else {
                        let document = querySnapshot2?.data()
                        guard let doc = document else{return}
                        if let docFollow = doc["follow"] {
                            let followArray = docFollow as! [String]
                            self.postArray = []
                            // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                            querySnapshot!.documents.forEach { documentA in
                                let postData = PostData(document: documentA)
                                print("DEBUG: document取得 \(documentA.documentID)")
                                
                                if followArray.count == 0 {
                                    //followArrayが0の場合
                                    if postData.uid == myUid {
                                        self.postArray.append(postData)
                                    }
                                }else {
                                    //followArrayに値がある場合
                                    for followUid in followArray{
                                        //フォローしているuidまたは自分のuidの場合postArrayに設定
                                        if postData.uid == followUid || postData.uid == myUid {
                                            self.postArray.append(postData)
                                            break
                                        }
                                    }
                                }
                            }
                            // TableViewの表示を更新する
                            self.tableView.reloadData()
                        }else{
                            //followがnil
                            self.postArray = []
                            // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                            querySnapshot!.documents.forEach { documentA in
                                let postData = PostData(document: documentA)
                                //フォローしているuidまたは自分のuidの場合postArrayに設定
                                if  postData.uid == myUid {
                                    self.postArray.append(postData)
                                }
                                
                            }
                            // TableViewの表示を更新する
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                self.postArray = []
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        //セルを選択した時に選択状態の表示にしない（セルを選択した時に選択状態の表示にしない）
        //(つまりセルが選択された時にUITableViewCellSelectedBackgroundを使用しない)
        cell.selectionStyle = .none
        
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のいいねボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(tapLikeButton(_:forEvent:)), for: .touchUpInside)
        //コメントボタンを押下時
        cell.commentButton.addTarget(self, action:#selector(tapCommnetButton(_:forEvent:)), for: .touchUpInside)
        //自作のデリゲート
        cell.postTableViewCellDelegate = self
        
        return cell
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 800 //セルの高さ
        return UITableView.automaticDimension
    }
    //セルを選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //詳細画面に遷移する
        let detailViewController = self.storyboard?.instantiateViewController(identifier: "DitailViewController") as! DitailViewController
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath.row]
        
        detailViewController.postData = postData
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
    }
    // セル内のいいねボタンがタップされた時に呼ばれるメソッド
    @objc func tapLikeButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    @objc func refresh( sender: UIRefreshControl){
        tableView.reloadData()
        //通信終了後、endRefreshingを実行することでロードインジケータ（くるくる）が終了する
        sender.endRefreshing()
    }
    //コメントボタン押下時
    @objc func tapCommnetButton(_ sender: UIButton, forEvent event: UIEvent){
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        //詳細画面に遷移する
        let detailViewController = self.storyboard?.instantiateViewController(identifier: "DitailViewController") as! DitailViewController
        detailViewController.postData = postData
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension TimeLineViewController:PostTableViewCellDelegate{
    //PostTablViewCellの投稿写真をタップしたときに呼ばれる
    func imageTransition(_ sender:UITapGestureRecognizer) {
        //タップしたUIImageViewを取得
        let tappedUIImageView = sender.view! as? UIImageView
        //  UIImage を取得
        guard let tappedImageView = tappedUIImageView  else {return}
        let tappedImage = tappedImageView.image!
        
        let fullsizeImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullsizeImageViewController") as! FullsizeImageViewController
        fullsizeImageViewController.modalPresentationStyle = .fullScreen
        fullsizeImageViewController.image = tappedImage
        self.present(fullsizeImageViewController, animated: true, completion: nil)
    }
}
