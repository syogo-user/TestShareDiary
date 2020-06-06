//
//  FollowListTableViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/09.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase

class FollowRequestListTableViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{

    // ユーザデータを格納する配列
    var userPostArray: [UserPostData] = []
    

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "FollowRequestListTableViewCell", bundle:nil)
        tableView.register(nib, forCellReuseIdentifier: "FollowRequestListCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser != nil {
            reloadView()
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowRequestListCell", for: indexPath) as! FollowRequestListTableViewCell
        //Cell に値を設定する
        cell.setUserPostData(userPostArray[indexPath.row])
        
        //セル内のボタンのアクションをソースコードで設定する
        cell.followRequestPermissionButton.addTarget(self,action:#selector(handleButton(_ : forEvent:)),for: .touchUpInside)
        cell.followRequestRejectionButton.addTarget(self,action:#selector(rejectionButton(_ : forEvent:)),for: .touchUpInside)
        
        return cell
    }
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath ){
//         //InputViewControllerに画面遷移
//         performSegue(withIdentifier:"cellSegue",sender:nil)
    }
    
    
     //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
         return .delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView:UITableView,commit editingStyle:UITableViewCell.EditingStyle,forRowAt indexPath:IndexPath){
    }
    
    //セル内の「承認」ボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton,forEvent event:UIEvent){

        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        //タッチした座標
        let point = touch!.location(in:self.tableView)
        //タッチした座標がtableViewのどのindexPath位置か
        let indexPath = tableView.indexPathForRow(at: point)
        //配列からタップされたインデックスのデータを取り出す
        let userPostData = userPostArray[indexPath!.row]
        
        // ＜＜AさんがBさんフォローリクエストを承認＞＞（ログインしている自分はAさん）
        //ログインしている自分(Aさん)のuidを取得する
        if  let myUid = Auth.auth().currentUser?.uid {
            //フォローリクエストが承認されたuidを取得(Bさん)
            let otherUserUid = userPostData.uid!
            
                        
            let db = Firestore.firestore()
            //トランザクション開始
            
            let batch = db.batch()
            
            //(Aさん)のフォロワーの配列に（Bさん）のuidとuserNameを設定する
            let followerPostRef = db.collection(Const.users).document(myUid)
            // 更新データを作成する
            var followerUpdateValue: FieldValue
            followerUpdateValue = FieldValue.arrayUnion([otherUserUid])
            batch.updateData(["follower": followerUpdateValue],forDocument: followerPostRef)
            //followerPostRef.updateData(["follower": followerUpdateValue])
            print("★★★★★★★★★★★★★★★★★★★★★")
            
            //(Bさん)のフォローの配列に（Aさん)のuidとuserNameを設定する
            let followPostRef = db.collection(Const.users).document(otherUserUid)
            // 更新データを作成する
            var followUpdateValue: FieldValue
            followUpdateValue = FieldValue.arrayUnion([myUid])
            batch.updateData(["follow":followUpdateValue],forDocument: followPostRef)
            //followPostRef.updateData(["follow":followUpdateValue])
            print("★★★★★★★★★★★★★★★★★★★★★")
            
            //(Aさん)のフォローリクエスト配列の(Bさん)を削除する。
            let followRequestPostRef = db.collection(Const.users).document(myUid)
            // 更新データを作成する
            var followRequestUpdateValue: FieldValue
            followRequestUpdateValue = FieldValue.arrayRemove([otherUserUid])
            batch.updateData(["followRequest":followRequestUpdateValue],forDocument: followRequestPostRef)
            //followRequestPostRef.updateData(["followRequest":followRequestUpdateValue])
            print("★★★★★★★★★★★★★★★★★★★★★")
            //トランザクション終了
            //コミット
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch \(err)")
                } else {
                    print("Batch write succeeded.")
                }
            }
                           
            //(Aさん)のフォローリクエストを再取得した画面の再描画する
            reloadView()


            print("承認")
            self.tableView.reloadData()
            
        }
        
    }
    
    
    //セル内の拒否ボタンがタップされた時に呼ばれるメソッド
    @objc func rejectionButton(_ sender: UIButton,forEvent event:UIEvent){
        print("拒否")
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        //タッチした座標
        let point = touch!.location(in:self.tableView)
        //タッチした座標がtableViewのどのindexPath位置か
        let indexPath = tableView.indexPathForRow(at: point)
        //配列からタップされたインデックスのデータを取り出す
        let userPostData = userPostArray[indexPath!.row]
        
        // ＜＜AさんがBさんがフォローリクエストを削除＞＞（ログインしている自分はAさん）
        //ログインしている自分(Aさん)のuidを取得する
         if  let myUid = Auth.auth().currentUser?.uid {
            //フォローリクエストが承認されたuidを取得(Bさん)
            let otherUserUid = userPostData.uid!
            let db = Firestore.firestore()
            //(Aさん)のフォローリクエスト配列の(Bさん)を削除する。
            let followRequestPostRef = db.collection(Const.users).document(myUid)
            // 更新データを作成する
            var followRequestUpdateValue: FieldValue
            followRequestUpdateValue = FieldValue.arrayRemove([otherUserUid])
            followRequestPostRef.updateData(["followRequest":followRequestUpdateValue])
            //再描画
            reloadView()
        }
    }
    
    //再描画
    func reloadView(){
        if  let myUid = Auth.auth().currentUser?.uid {
            let postRef = Firestore.firestore().collection(Const.users).document(myUid)
            postRef.getDocument{
                (document,error) in
                if let error = error {
                     print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                     return
                 } else {
                    if let document  = document ,document.exists{
                        let followRequestArray = document["followRequest"] as! [String]
                        //初期化
                        self.userPostArray = []
                        if followRequestArray.count != 0 {
                            //followRequestArrayに値がある場合
                            for followRequest in followRequestArray {
                                let postRef2 = Firestore.firestore().collection(Const.users).whereField("uid", isEqualTo:followRequest)
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
                        } else {
                            //followRequestArrayに値がない場合
                            self.userPostArray = []
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
