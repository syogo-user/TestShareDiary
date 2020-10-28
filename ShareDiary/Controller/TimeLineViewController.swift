//
//  TimeLineViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
class TimeLineViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate ,TabBarDelegate{
        
    @IBOutlet weak var tableView: UITableView!
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    let refreshCtl = UIRefreshControl()
    // Firestoreのリスナー
    var userListener: ListenerRegistration!
    var postListener: ListenerRegistration!
    //フォローと自分のuid配列
    var followAndMyUidArray : [String] = []
    //初回表示フラグ
//    var initialDisplayFlg :Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        //tableViewの境界線を消す
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        //リフレッシュ
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil {
            guard let myUid = Auth.auth().currentUser?.uid else {return}
            // ログイン済み
            //listenerがnilでないとき return
//            guard listener == nil  else{return}
            
            //◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆
            let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)
            userListener = postUserRef.addSnapshotListener() {
                (querySnapshot2,error) in
                if let error = error {
                    print("DEBUG: snapshotの取得が失敗しました。\(error)")
//                    if self.initialDisplayFlg {
//                        SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
//                    }
                    return
                } else {
                    let document = querySnapshot2?.data()
                    guard let doc = document else{return}
                    if let docFollow = doc["follow"] {
                        self.followAndMyUidArray = []
                        self.followAndMyUidArray = docFollow as! [String]
                        //自分のuidも追加
                        self.followAndMyUidArray.append(myUid)
                        //初期化
                        self.postArray = []
                        // TableViewの表示を更新する
                        self.tableView.reloadData()
                        //フォローしている人の配列でループ（自分含み）
                        for uid in self.followAndMyUidArray{
                            let postsRef = Firestore.firestore().collection(Const.PostPath).whereField("uid",isEqualTo:uid)//.order(by: "date", descending: true)
                            //スナップショットリスナーを追加
                            self.postListener = postsRef.addSnapshotListener(){ (querySnapshot, error) in
                                //nillの場合は処理を飛ばす
                                guard querySnapshot != nil  else{return}
                                //trueの場合は以降の処理を行わない
                                guard !(querySnapshot!.metadata.hasPendingWrites) else{return}
                                querySnapshot!.documents.forEach{
                                    document in
                                    let postData = PostData(document: document)
                                    //配列に存在するかどうか
                                    if self.postArray.firstIndex(where: {post -> Bool in return post.id == postData.id}) == nil {
                                        //存在しない場合
                                        //そのまま追加
                                        self.postArray.append(postData)
                                    }else{
                                        //存在する場合
                                        for (index,post) in self.postArray.enumerated(){
                                            print("index:\(index)")
                                            if post.id == postData.id {
                                                //存在するデータを削除してから追加
                                                self.postArray.remove(at: index)
                                                self.postArray.append(postData)
                                            }
                                        }
                                    }
                                    //日付順に入れ替える
                                    self.postArray.sort{ (d0 ,d1) -> Bool in
                                        return d0.date! > d1.date!
                                    }
                                    // TableViewの表示を更新する
                                    self.tableView.reloadData()
                                }
    
                            }
                        }
                    }
                }
            }
        }
    }
//    override func viewWillDisappear(_ animated: Bool) {
//
//        if postListener != nil {
//            postListener.remove()
//            postListener = nil
//            postArray = []
//            tableView.reloadData()
//        }
//
//        if userListener != nil{
//            userListener.remove()
//            userListener = nil
//            postArray = []
//            tableView.reloadData()
//        }
//    }
        
    
    
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
        //いいねボタンのアクションをソースコードで設定する
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
    //いいねボタンがタップされた時に呼ばれるメソッド
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
        detailViewController.scrollFlg = true //画面遷移後すぐに下にスクロールを行う
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    //タブボタンがタップされた場合
    func didSelectTab(tabBarController: TabBarController) {
        print("DEBUG:タイムラインタブがタップされました。")
        //最上部にスクロール
        let contentOffset = CGPoint(x: 0.0, y: 0.0)
        self.tableView.setContentOffset(contentOffset, animated: true)
    }
}

extension TimeLineViewController:PostTableViewCellDelegate{
    //PostTablViewCellの投稿写真をタップしたときに呼ばれる
    func imageTransition(_ sender:UITapGestureRecognizer) {
        //タップしたUIImageViewを取得
        let tappedUIImageView = sender.view! as? UIImageView
        //  UIImage を取得
        guard let tappedImageView = tappedUIImageView  else {return}
        guard let tappedImageviewImage = tappedImageView.image else {return}
        let tappedImage = tappedImageviewImage
        
        let fullsizeImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullsizeImageViewController") as! FullsizeImageViewController
        fullsizeImageViewController.modalPresentationStyle = .fullScreen
        fullsizeImageViewController.image = tappedImage
        self.present(fullsizeImageViewController, animated: true, completion: nil)
    }
}
