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
    @IBOutlet weak var backButton: UIButton!
    // ユーザデータを格納する配列
    var userPostArray: [UserPostData] = []
    //遷移元を知るためのフラグ
    var fromButton :String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        self.tableView.backgroundColor = Const.darkColor
        tableView.delegate = self
        tableView.dataSource = self
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "FollowFollowerListTableViewCell", bundle:nil)
        tableView.register(nib, forCellReuseIdentifier: "FollowFollowerListCell")
        backButton.addTarget(self, action: #selector(tabBackButton(_:)), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        followOrFollowerLabel.textColor = .white
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
        //プロフィール画面に遷移する
        let profileViewController = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
        // 配列からタップされたインデックスのデータを取り出す
        let userData = userPostArray[indexPath.row]
        profileViewController.userData = userData
        profileViewController.modalPresentationStyle = .fullScreen
        self.present(profileViewController, animated: true, completion: nil)
    }
    
    //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .none
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
            
        }))
        self.present(dialog,animated: true,completion: nil)
        
        
    }
    
    //データの描画
    func reloadView(){
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        //ログイン済み
        var postRef : DocumentReference
        postRef = Firestore.firestore().collection(Const.users).document(myUid)
        //自分のユーザ情報の取得
        postRef.getDocument{
            (document,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                //documentが存在しなかったらreturn
                guard let document  = document ,document.exists else {return }
                
                if self.fromButton ==  Const.Follow {
                    //フォローボタンから遷移した場合
                    //フォローが存在しない場合はreturn
                    guard let followArray = document["follow"] as? [String] else {return}
                    
                    //初期化
                    self.userPostArray = []
                    //countが0の時は配列を初期化し描画する
                    if followArray.count == 0 {
                        //followArrayに値がない場合
                        self.tableView.reloadData()
                        return
                    }
                    //userPostArrayにappendしてリロードする
                    self.appendArray(array:followArray)
                } else if self.fromButton == Const.Follower{
                    //フォロワーボタンから遷移した場合
                    //フォロワーが存在しない場合はreturn
                    guard let followerArray = document["follower"] as? [String] else{return}
                    //初期化
                    self.userPostArray = []
                    //countが0の時は配列を初期化し描画する
                    if followerArray.count == 0 {
                        //followArrayに値がない場合
                        self.tableView.reloadData()
                        return
                    }
                    //userPostArrayにappendしてリロードする
                    self.appendArray(array: followerArray)
                    
                }              
            }
        }
    }
    
    //受け取った配列をuserPostArrayに追加してリロードする
    private func appendArray(array:[String]){
        for uid in array {
            let postRef2 = Firestore.firestore().collection(Const.users).whereField("uid", isEqualTo:uid)
            postRef2.getDocuments() {
                (querySnapshot,error) in
                if let error = error {
                    print("DEBUG: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    querySnapshot!.documents.forEach{
                        document in
                        self.userPostArray.append(UserPostData(document:document))
                        //ユーザの名前順(昇順)に並び替えの処理を入れる
                        self.userPostArray.sort(by: { (a,b) -> Bool in
                            if a.userName ?? "" == b.userName ?? ""{
                                //名前が同じ場合はuidで並び替える
                                return a.uid ?? "" < b.uid ?? ""
                            }else{
                                //名前が異なる場合は名前で並び替える
                                return a.userName ?? "" < b.userName ?? ""
                            }
                        })
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func tabBackButton(_ sender :UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
