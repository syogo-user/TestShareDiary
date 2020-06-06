//
//  FollowFollowerListTableViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/10.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase

class FollowFollowerListTableViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var followOrFollowerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    // ユーザデータを格納する配列
    var userPostArray: [UserPostData] = []
    
    //遷移元を知るためのフラグ
    var fromButton :String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "FollowFollowerListTableViewCell", bundle:nil)
        tableView.register(nib, forCellReuseIdentifier: "FollowFollowerListCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        if fromButton ==  Const.Follow {
            //フォローボタンから遷移した場合
            followOrFollowerLabel.text = "フォロー"
        } else {
            //フォロワーボタンから遷移した場合
            followOrFollowerLabel.text = "フォロワー"
        }
        //画面描画
        reloadView()
        //画面下部の境界線を消す
        tableView.tableFooterView = UIView()
    }
    //データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView , numberOfRowsInSection section:Int ) -> Int{
        return userPostArray.count
    }
    //各セルの内容を返すメソッド
    func tableView(_ tableView : UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowFollowerListCell", for: indexPath) as! FollowFollowerListTableViewCell
        //Cell に値を設定する
        cell.setUserPostData(userPostArray[indexPath.row])
        
        //セル内のボタンのアクションをソースコードで設定する
        cell.rejectedButton.addTarget(self,action:#selector(rejectButtonAction(_ : forEvent:)),for: .touchUpInside)
        
        
        return cell
    }
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath ){

    }
        
        
     //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
         return .delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView:UITableView,commit editingStyle:UITableViewCell.EditingStyle,forRowAt indexPath:IndexPath){
    }
    
    
    //rejectButtonActionが押された時に呼ばれるメソッド
    @objc func rejectButtonAction (_ sender: UIButton,forEvent event:UIEvent){
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        //タッチした座標
        let point = touch!.location(in:tableView)
        //タッチした座標がtableViewのどのindexPath位置か
        let indexPath = tableView.indexPathForRow(at: point)
        //配列からタップされたインデックスのデータを取り出す
        let userPostData = userPostArray[indexPath!.row]
        
        //ダイアログ表示
        let dialog = UIAlertController(title: "\(userPostData.userName!)さんのフォローを解除しますか？", message: nil, preferredStyle: .actionSheet)
        //OKボタン
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
           print("リジェクト")

            //ログインしている自分（Aさん）のuidを取得する
            if let myUid = Auth.auth().currentUser?.uid {
                let db = Firestore.firestore()
                //トランザクション開始
                let batch = db.batch()
                
                if self.fromButton ==  Const.Follow {
                    //フォローボタンから遷移した場合
                    //<<BさんがAさんをフォローするのをやめる>>
                    //自分（Bさん）のuidのドキュメントを取得する
                    let followRef = db.collection(Const.users).document(myUid)
                    var updateFollowValue: FieldValue
                    //BさんのfollowからAさんのuidを削除する
                    updateFollowValue = FieldValue.arrayRemove([userPostData.uid!])
                    batch.updateData(["follow":updateFollowValue],forDocument: followRef)

                    //Aさんのuidドキュメントを取得する
                    let followerRef = db.collection(Const.users).document(userPostData.uid!)
                    //AさんのfollowerからBさん(自分)のuidを削除する
                    var updateFollowerValue: FieldValue
                    updateFollowerValue = FieldValue.arrayRemove([myUid])
                    batch.updateData(["follower":updateFollowerValue],forDocument: followerRef)
                } else {
                    //フォロワーボタンから遷移した場合
                    //<<AさんがBさんをフォロワーから解除する>>
                    //自分（Aさん）のuidのドキュメントを取得する
                    let followerRef = db.collection(Const.users).document(myUid)
                    var updateFollowerValue: FieldValue
                    //AさんのfollowerからBさんのuidを削除する
                    updateFollowerValue = FieldValue.arrayRemove([userPostData.uid!])
                    batch.updateData(["follower":updateFollowerValue],forDocument:followerRef )
                    
                    //Bさんのuidドキュメントを取得する
                    let followRef = db.collection(Const.users).document(userPostData.uid!)
                    //BさんのfollowからAさんのuidを削除する
                    var updateFollowValue: FieldValue
                    updateFollowValue = FieldValue.arrayRemove([myUid])
                    batch.updateData(["follow":updateFollowValue],forDocument: followRef)
                }
                //トランザクション終了
                //コミット
                batch.commit() { err in
                    if let err = err {
                        print("Error writing batch \(err)")
                    } else {
                        print("Batch write succeeded.")
                    }
                }
                //画面再描画のための検索
                self.reloadView()
            }
         }))
        
        //キャンセルボタン
        dialog.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { action in
            print("キャンセル")
        }))
        self.present(dialog,animated: true,completion: nil)

       
    }
    
    //データの描画
    func reloadView(){
        if Auth.auth().currentUser != nil {
            if  let myUid = Auth.auth().currentUser?.uid {
                //ログイン済み
                var postRef : DocumentReference
                
                
                postRef = Firestore.firestore().collection(Const.users).document(myUid)
                postRef.getDocument{
                    (document,error) in
                    if let error = error {
                         print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                         return
                     } else {
                        if let document  = document ,document.exists{
                            if self.fromButton ==  Const.Follow {
                                if document["follow"] != nil {
                                    //フォローが存在する場合
                                    //フォローボタンから遷移した場合
                                    let followArray = document["follow"] as! [String]
                                    //初期化
                                    self.userPostArray = []
                                    //countが0の時は配列を初期化し描画する
                                    guard followArray.count != 0 else {
                                        //followArrayに値がない場合
                                        self.userPostArray = []
                                        self.tableView.reloadData()
                                        return
                                    }
                                    for follow in followArray {
                                        let postRef2 = Firestore.firestore().collection(Const.users).whereField("uid", isEqualTo:follow)
                                        postRef2.getDocuments() {
                                            (querySnapshot,error) in
                                            if let error = error {
                                                print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                                                return
                                            } else {
                                                querySnapshot!.documents.map{
                                                    document in
                                                    self.userPostArray.append(UserPostData(document:document))
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    }

                                }
                            } else {
                                //followerが存在する場合
                                if document["follower"] != nil {
                                    //フォロワーボタンから遷移した場合
                                    let followerArray = document["follower"] as! [String]
                                    //初期化
                                    self.userPostArray = []
                                    
                                    //countが0の時は配列を初期化し描画する
                                    guard followerArray.count != 0 else {
                                        //followArrayに値がない場合
                                        self.userPostArray = []
                                        self.tableView.reloadData()
                                        return
                                    }
                                    
                                    for follower in followerArray {
                                        let postRef2 = Firestore.firestore().collection(Const.users).whereField("uid", isEqualTo:follower)
                                        postRef2.getDocuments() {
                                            (querySnapshot,error) in
                                            if let error = error {
                                                print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                                                return
                                            } else {
                                                querySnapshot!.documents.map{
                                                    document in
                                                    self.userPostArray.append(UserPostData(document:document))
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                        }
                    }

                }
            }
        }
    }
}
