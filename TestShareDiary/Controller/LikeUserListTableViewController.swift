//
//  LikeUserListTableViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/30.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
class LikeUserListTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    var userPostArray :[UserPostData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        self.view.backgroundColor = Const.darkColor
        self.tableView.backgroundColor = Const.darkColor
        self.tableView.dataSource = self
        self.tableView.delegate  = self
        // カスタムセルを登録する
        let nib = UINib(nibName: "LikeUserListTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        //画面下部の境界線を消す
        self.tableView.tableFooterView = UIView()
        self.backButton.addTarget(self, action: #selector(tabBackButton(_:)), for: .touchUpInside)
        //削除ステートのユーザを除外し表示する
        self.accountDeleteStateGet(myUid:myUid)
        
        
    }
}

extension LikeUserListTableViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath) as! LikeUserListTableViewCell
        cell.setUserPostData(userPostArray[indexPath.row])
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
        //選択後の色をすぐにもとに戻す
        tableView.deselectRow(at: indexPath, animated: true)
        //画面遷移
        self.present(profileViewController, animated: true, completion: nil)
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
        
    @objc func tabBackButton(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    //削除フラグのあるアカウントを取得
    private func accountDeleteStateGet(myUid:String){
        //削除ステータスが0よりも大きいもの
        let userRef = Firestore.firestore().collection(Const.users).whereField("accountDeleteState",isGreaterThan:0)
        userRef.getDocuments(){
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                var accountDeleteArray  :[String] = []
                accountDeleteArray = querySnapshot!.documents.map {
                    document -> String in
                    let userUid = UserPostData(document:document).uid ?? ""
                    return userUid
                }
                            
                //描画
                self.reload(accountDeleteArray: accountDeleteArray)
            }
        }
        
    }
    //描画
    private func reload(accountDeleteArray :[String]){
        //削除ステータスが0より大きいユーザは除外する
        for (index,userPost) in self.userPostArray.enumerated(){
            if accountDeleteArray.firstIndex(of: userPost.uid ?? "") != nil{
                self.userPostArray.remove(at:index)
            }
        }
        self.tableView.reloadData()
    }
    
}
