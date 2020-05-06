//
//  FriendListViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SlideMenuControllerSwift

class FriendListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    var userPostArray: [UserPostData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //検索バーのインスタンスを取得する
        let searchBar: UISearchBar = UISearchBar()
        searchBar.placeholder = "ユーザ名で検索"
        searchBar.layer.shadowOpacity = 0.2
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "UsersTableViewCell", bundle:nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
                
        /* スライドメニュー */
        //NavigationBarが半透明かどうか
        navigationController?.navigationBar.isTranslucent = false
        //NavigationBarの色を変更します
        navigationController?.navigationBar.barTintColor = UIColor(red: 129/255, green: 212/255, blue: 78/255, alpha: 1)
        //NavigationBarに乗っている部品の色を変更します
        navigationController?.navigationBar.tintColor = UIColor.white
        //バーの左側にボタンを配置します(ライブラリ特有)
        addLeftBarButtonWithImage(UIImage(named: "menu")!)
    }
    
//    //検索バーで文字編集中（文字をクリアしたときも実行される）
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)  {
////        if searchText != "" {
////            let predicate = NSPredicate(format:"category == %@",searchText)
////            taskArray = realm.objects(Task.self).filter(predicate)
////        } else{
////            taskArray = realm.objects(Task.self)
////        }
////
////        tableView.reloadData()
//    }
    
    //検索ボタンがタップされた時に実行される
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let postRef = Firestore.firestore().collection(Const.users).whereField("userName", isEqualTo:searchBar.text!)
        
        postRef.getDocuments() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                self.userPostArray = querySnapshot!.documents.map {
                    document in
                    //print("\(document.documentID) => \(document.data())")
                    let userPostData = UserPostData(document:document)
                    return userPostData
                }
                searchBar.endEditing(true)
                self.tableView.reloadData()
            }
        }

        
//        let predicate = NSPredicate(format:"category == %@",searchBar.text!)
//        taskArray = realm.objects(Task.self).filter(predicate)
        //キーボード閉じる
        searchBar.endEditing(true)
//
        //リロード
        tableView.reloadData()
        
    }
    
//    //セルの高さを返すメソッド
//    func tableView(_ table: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return  60
//    }
    
    
    //データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView , numberOfRowsInSection section:Int ) -> Int{
        return userPostArray.count
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView : UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        //Cell に値を設定する
        cell.setUserPostData(userPostArray[indexPath.row])
        
        //セル内のボタンのアクションをソースコードで設定する
        cell.followRequestButton.addTarget(self,action:#selector(handleButton(_ : forEvent:)),for: .touchUpInside)
        
        
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
        print("フォロー申請")
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        //タッチした座標
        let point = touch!.location(in:self.tableView)
        //タッチした座標がtableViewのどのindexPath位置か
        let indexPath = tableView.indexPathForRow(at: point)
        //配列からタップされたインデックスのデータを取り出す
        let userPostData = userPostArray[indexPath!.row]
        

        //ログインしている自分のuidを取得する
        if  let myUid = Auth.auth().currentUser?.uid {
            //FirebaseのFollowRequestの相手の配下に自分のuidを設定する
            
            let postRef = Firestore.firestore().collection(Const.Follow).document(userPostData.uid!)
            
            let postDic = [
                "oherUserUid":myUid
            ]
            postRef.getDocument {
                (document,error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    if let document  = document ,document.exists{
                        var array  = document["ohereUser"] as! [Any]
                        array.append(postDic)
                        let data  = [
                            "ohereUser" : array
                        ]
                        print("submitButton")
                        postRef.updateData(data)
                    } else {
                        var array: [Any] = []
                        array.append(postDic)
                        let data  = [
                            "ohereUser" : array
                        ]
                        postRef.setData(data)
                    }
                }
            }
            print("★")
        }

        
        
        
        
        
    }
}
