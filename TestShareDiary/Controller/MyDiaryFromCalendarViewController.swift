//
//  MyDiaryFromCalendar.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/22.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
class MyDiaryFromCalendarViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var userTableView: UITableView!
    //投稿データを格納する配列
    var postArray :[PostData] = []
    var diaryDate :String = ""
    let cellHeight :CGFloat = 800
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userTableView.backgroundColor = Const.lightOrangeColor        
        self.userTableView.delegate = self
        self.userTableView.dataSource = self
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        self.userTableView.register(nib, forCellReuseIdentifier: "tableCell")
        //画面の境界線を消す
        self.userTableView.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //投稿の取得し描画
        reload()
    }
    private func reload(){
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let postRef =  Firestore.firestore().collection(Const.PostPath)
            .whereField("selectDate", isEqualTo: diaryDate).whereField("uid", isEqualTo: myUid)
        postRef.getDocuments() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                self.postArray = []
                querySnapshot?.documents.forEach{
                    (document) in
                    let postData = PostData(document: document)
                    self.postArray.append(postData)
                    //投稿した日付（date）の（降順）で順番を並び替える 日付は必ず値が入るので強制アンラップで良い。
                    self.postArray.sort(by: { (a,b) -> Bool in
                        return a.date! > b.date!
                    })
                }
                self.userTableView.reloadData()
            }
        }
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        tableView.estimatedRowHeight = cellHeight //セルの高さ
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        cell.postTableViewCellDelegate = self
        //いいねボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(tapLikeButton(_:forEvent:)), for: .touchUpInside)

        //コメントボタンを押下時
        cell.commentButton.addTarget(self, action:#selector(tapCommnetButton(_:forEvent:)), for: .touchUpInside)
        return cell
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
    //コメントボタン押下時
    @objc func tapCommnetButton(_ sender: UIButton, forEvent event: UIEvent){
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.userTableView)
        let indexPath = userTableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        //詳細画面に遷移する
        let detailViewController = self.storyboard?.instantiateViewController(identifier: "DitailViewController") as! DitailViewController
        detailViewController.postData = postData
        detailViewController.scrollFlg = true //画面遷移後すぐに下にスクロールを行う
        self.navigationController?.pushViewController(detailViewController, animated: true)

    }
    //いいねボタンがタップされた時に呼ばれるメソッド
    @objc func tapLikeButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.userTableView)
        let indexPath = userTableView.indexPathForRow(at: point)
        
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
        //再描画
        reload()
    }
}
extension MyDiaryFromCalendarViewController:PostTableViewCellDelegate{
    //PostTablViewCellの投稿写真をタップしたときに呼ばれる
    func imageTransition(_ sender:UITapGestureRecognizer) {
        //タップしたUIImageViewを取得
        let tappedImageView = sender.view! as! UIImageView
        //  UIImage を取得
        let tappedImage = tappedImageView.image!
        
        let fullsizeImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullsizeImageViewController") as! FullsizeImageViewController
        fullsizeImageViewController.modalPresentationStyle = .fullScreen
        fullsizeImageViewController.image = tappedImage
        self.present(fullsizeImageViewController, animated: true, completion: nil)
    }
    
}
