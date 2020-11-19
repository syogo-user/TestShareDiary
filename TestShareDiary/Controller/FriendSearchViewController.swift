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
import SVProgressHUD

class FriendSearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    //検索文字列
    var inputText :String = ""
    // ユーザデータを格納する配列
    var userPostArray: [UserPostData] = []
    var searchbar :UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = Const.darkColor
        
        //検索バーのインスタンスを取得する
        let searchBar: UISearchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 45)
        searchBar.placeholder = "ニックネームで検索"
        searchBar.backgroundColor = Const.darkColor
        searchBar.searchBarStyle = .prominent
        searchBar.barTintColor = .white
        searchBar.disableBlur()
        self.searchbar = searchBar
        self.view.addSubview(searchbar)
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "UsersTableViewCell", bundle:nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
                
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        //recognizerによってCellの選択ができなくなってしまうのを防ぐためにcancelsTouchesInViewを設定
        //falseでタップを認識するようになる
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchbar.text = ""
        self.userPostArray = []
        self.tableView.reloadData()
        //検索欄にフォーカスをあてる
        self.searchbar.becomeFirstResponder()
        //画面下部の境界線を消す
        self.tableView.tableFooterView = UIView()
    }
            
    //検索バーで文字編集中（文字をクリアしたときも実行される）
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)  {
        //文字が空の場合userPostArrayを空にする
        if  searchText.isEmpty {
            self.userPostArray  = []
            self.tableView.reloadData()
        }
        searchBar.textField?.textColor = UIColor.white
    }
    
    //検索ボタンがタップされた時に実行される
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        inputText =  searchBar.text!
        inputText = inputText.trimmingCharacters(in: .whitespaces)
        self.userPostArray  = []
        //HUDで処理中を表示
        SVProgressHUD.show()
        //自分のuid取得
        if (Auth.auth().currentUser?.uid) != nil {
            //ユーザからデータを取
            //前方一致検索
            let userRef = Firestore.firestore().collection(Const.users)
            let ref = userRef.order(by: "userName").start(at: [inputText]).end(at: [inputText + "\u{f8ff}"])
            ref.getDocuments() {
                (querySnapshot,error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "検索に失敗しました")
                    print("DEBUG: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    self.userPostArray = querySnapshot!.documents.map {
                        document in
                        let userPostData = UserPostData(document:document)
                        return userPostData
                    }
                    searchBar.endEditing(true)
                    //HUDを消す
                     SVProgressHUD.dismiss()
                    self.tableView.reloadData()

                }
            }
        }
        //キーボード閉じる
        searchBar.endEditing(true)
    }
    //データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView , numberOfRowsInSection section:Int ) -> Int{
        return userPostArray.count
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.cellHeight
    }
    //各セルの内容を返すメソッド
    func tableView(_ tableView : UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        //Cell に値を設定する
        cell.setUserPostData(userPostArray[indexPath.row])
        //セル内のボタンのアクションをソースコードで設定する
        cell.followRequestButton.addTarget(self,action:#selector(tapFolloRequestwButton(_ : forEvent:)),for: .touchUpInside)
        return cell
    }
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath ){
        //プロフィール画面に遷移する
        let profileViewController = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
        // 配列からタップされたインデックスのデータを取り出す
        let userData = userPostArray[indexPath.row]
        profileViewController.userData = userData
        //選択後の色をすぐにもとに戻す
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(profileViewController, animated: true)
        
    }
    //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .none
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView:UITableView,commit editingStyle:UITableViewCell.EditingStyle,forRowAt indexPath:IndexPath){
    }
    
    //セル内の「フォロー申請」ボタンがタップされた時に呼ばれるメソッド
    @objc func tapFolloRequestwButton(_ sender: UIButton,forEvent event:UIEvent){
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
            //相手（Aさん）のuidのドキュメントを取得する
            let usersRef = Firestore.firestore().collection(Const.users).document(userPostData.uid!)//userPostData.uidはAさんのuid
            // 更新データを作成する
            var updateValue: FieldValue
            if sender.titleLabel?.text == "フォロー申請" {
                //<<BさんがAさんにフォローリクエストする>>
                //AさんのfollowRequestに自分（Bさん）のuidを追加する
                updateValue = FieldValue.arrayUnion([myUid])
                
            } else {
                //ボタンのラベルが「申請済」の場合
                //申請のキャンセル
                //<<BさんがAさんへのフォローリクエストをキャンセルする>>
                //AさんのfollowRequestから自分（Bさん）のuidを削除する
                updateValue = FieldValue.arrayRemove([myUid])
            }
            //データ更新
            usersRef.updateData(["followRequest":updateValue])
            
            //再描画のためにデータを取得
            let postRef = Firestore.firestore().collection(Const.users).whereField("userName", isEqualTo:inputText)
            postRef.getDocuments() {
                (querySnapshot,error) in
                if let error = error {
                    print("DEBUG: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    self.userPostArray = querySnapshot!.documents.map {
                        document in
                        let userPostData = UserPostData(document:document)
                        return userPostData
                    }
                    self.tableView.reloadData()
                }
            }
            
        }        
    }
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
}
