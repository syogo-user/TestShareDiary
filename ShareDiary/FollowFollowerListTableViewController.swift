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
        if Auth.auth().currentUser != nil {
            if  let myUid = Auth.auth().currentUser?.uid {
                //ログイン済み
                var postRef : DocumentReference
                
                //TODO 修正中
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
                                    //フォローボタンから遷移した場合
                                    let followArray = document["follow"] as! [String]
                                    //初期化
                                    self.userPostArray = []
                                    for i in 0...followArray.count-1 {
                                        let postRef2 = Firestore.firestore().collection(Const.users).whereField("uid", isEqualTo:followArray[i])
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
                                    for i in 0...followerArray.count-1 {
                                        let postRef2 = Firestore.firestore().collection(Const.users).whereField("uid", isEqualTo:followerArray[i])
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
                
                
                
                
                
                if fromButton ==  Const.Follow {
                    //フォローボタンから遷移した場合
                    
                    followOrFollowerLabel.text = "フォロー"
                } else {
                    //フォロワーボタンから遷移した場合
 
                    followOrFollowerLabel.text = "フォロワー"
                }
                
                
                
                
                
                
                

//                postRef.getDocument{
//                    (document,error) in
//                    if let error = error {
//                         print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
//                         return
//                     } else {
//                        if let document  = document ,document.exists{
//                            var array = document["otherUser"] as! [Any]
////                            for i in 0...array.count-1 {
////                                self.userPostArray.append(UserPostData(document:array[i] as! [String:Any]))
////                            }
//                            array.map{
//                                doc in
//                                self.userPostArray.append(UserPostData(document:doc as! [String:Any]))
//                            }
//                        }
//                    }
//                    self.tableView.reloadData()
//                }
            }
        }
            
        
        
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
//        cell.followRequestPermissionButton.addTarget(self,action:#selector(handleButton(_ : forEvent:)),for: .touchUpInside)
        
        
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
}
