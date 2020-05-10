//
//  FollowListTableViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/09.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
class FollowListTableViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{

    // ユーザデータを格納する配列
    var userPostArray: [UserPostData] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "FollowListTableViewCell", bundle:nil)
        tableView.register(nib, forCellReuseIdentifier: "FollowListCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if Auth.auth().currentUser != nil {
            if  let myUid = Auth.auth().currentUser?.uid {
                //ログイン済み
                let postRef = Firestore.firestore().collection(Const.FollowRequest).document(myUid) 
                postRef.getDocument{
                    (document,error) in
                    if let error = error {
                         print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                         return
                     } else {
                        if let document  = document ,document.exists{
                            var array = document["otherUser"] as! [Any]
//                            for i in 0...array.count-1 {
//                                self.userPostArray.append(UserPostData(document:array[i] as! [String:Any]))
//                            }
                            array.map{
                                doc in
                                self.userPostArray.append(UserPostData(document:doc as! [String:Any]))
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowListCell", for: indexPath) as! FollowListTableViewCell
        //Cell に値を設定する
        cell.setUserPostData(userPostArray[indexPath.row])
        
        //セル内のボタンのアクションをソースコードで設定する
        cell.followRequestPermissionButton.addTarget(self,action:#selector(handleButton(_ : forEvent:)),for: .touchUpInside)
        
        
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
    
    //セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton,forEvent event:UIEvent){

        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        //タッチした座標
        let point = touch!.location(in:self.tableView)
        //タッチした座標がtableViewのどのindexPath位置か
        let indexPath = tableView.indexPathForRow(at: point)
        //配列からタップされたインデックスのデータを取り出す
        let userPostData = userPostArray[indexPath!.row]
        
        //TODO ＜＜AさんをBさんがフォロー＞＞（ログインしている自分はAさん）
        //ログインしている自分(Aさん)のuidを取得する
        if  let myUid = Auth.auth().currentUser?.uid {
            //自分のuserName
            let userName = Auth.auth().currentUser?.displayName
            //フォローリクエストが承認されたuidを取得(Bさん)
            let otherUserUid = userPostData.uid!
            let otherUserName = userPostData.userName!
            
            //TODOトランザクション開始
//            let transaction = Firestore.firestore()

            //(Bさん)のフォローの配下に（Aさん)のuidとuserNameを設定する
            let followPostRef = Firestore.firestore().collection(Const.Follow).document(otherUserUid)
            //自分（Aさん）のuidとuserNameを設定
            let followPostDic = [
                "uid":myUid,
                "userName":userName
            ]
            followPostRef.getDocument {
                (document,error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    if let document  = document ,document.exists{
                        var array  = document["otherUser"] as! [Any]
                        array.append(followPostDic)
                        let data  = [
                            "otherUser" : array
                        ]
                        followPostRef.updateData(data)
                    } else {
                        var array: [Any] = []
                        array.append(followPostDic)
                        let data  = [
                            "otherUser" : array
                        ]
                        followPostRef.setData(data)
                    }
                }
            }
            print("★★★★★★★★★★★★★★★★★★★★★")
            //(Aさん)のフォロワーの配下に（Bさん）のuidとuserNameを設定する
            let followerPostRef = Firestore.firestore().collection(Const.Follower).document(myUid)
            //（Bさん）のuidとuserNameを設定
            let followerPostDic = [
                "uid":otherUserUid,
                "userName":otherUserName
            ]
            followerPostRef.getDocument {
                (document,error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    if let document  = document ,document.exists{
                        var array  = document["otherUser"] as! [Any]
                        array.append(followerPostDic)
                        let data  = [
                            "otherUser" : array
                        ]
                        print("submitButton")
                        followerPostRef.updateData(data)
                    } else {
                        var array: [Any] = []
                        array.append(followerPostDic)
                        let data  = [
                            "otherUser" : array
                        ]
                        followerPostRef.setData(data)
                    }
                }
            }
            print("★★★★★★★★★★★★★★★★★★★★★")
            //(Aさん)のフォローリクエスト配下の(Bさん)を削除する。
            let followRequestPostRef = Firestore.firestore().collection(Const.FollowRequest).document(myUid)
            followRequestPostRef.getDocument {
                (document,error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    if let document  = document ,document.exists{
                        var array  = document["otherUser"] as! [Any]
                        //Bさんを見つける
                        var removeIndex = -1
                        for i in 0...array.count-1{
                            let dictionary = array[i] as! [String:Any]
                            if otherUserUid == dictionary["otherUserUid"] as? String{
                                removeIndex = i
                            }
                        }
                        //removeIndexが設定されていたら
                        if removeIndex >= 0 {
                            //配列の最後尾と削除する要素が同じでない場合
                            if array.count-1 != removeIndex  {

                                //配列のインデックスを詰める
                                for i in removeIndex...array.count-2{
                                    array[i] = array[i+1]
                                }
                                //あまった末尾の配列を削除する
                                array.removeLast()
                            } else{
                                //削除する
                                array.remove(at: removeIndex)
                            }
                            //更新する
                            let data  = [
                                "otherUser" : array
                            ]
                            //arrayの要素が0の場合はドキュメントごと削除する
                            if array.count == 0 {
                                //ドキュメントごと削除
                                followRequestPostRef.delete()
                            } else {
                                //ドキュメントの配下の配列を更新する
                                followRequestPostRef.updateData(data)
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            }
            print("★★★★★★★★★★★★★★★★★★★★★")
            //TODOトランザクション終了
            print("承認されたよ")
            self.tableView.reloadData()
            
        }
        
    }
    
    
    
    
    


}
