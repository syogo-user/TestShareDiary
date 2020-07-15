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

class FriendSearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    //検索文字列
    var inputText :String = ""
    // ユーザデータを格納する配列
    var userPostArray: [UserPostData] = []
    
    var searchbar :UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Const.darkColor


//        if let navigationBarFrame = navigationController?.navigationBar.bounds {
//            //検索バーのインスタンスを取得する
//            let searchBar: UISearchBar = UISearchBar()
//            searchBar.delegate = self
//            searchBar.placeholder = "ユーザ名で検索"
//            searchBar.layer.shadowOpacity = 0.2
//            self.navigationItem.titleView = searchBar
//            navigationItem.titleView?.frame = searchBar.frame
//            self.searchBar = searchBar
//        }
        
        //検索バーのインスタンスを取得する
        let searchBar: UISearchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 45)
        searchBar.placeholder = "ユーザ名で検索"
        self.searchbar = searchBar

        self.view.addSubview(searchbar)
        searchBar.disableBlur()
        searchBar.backgroundColor = Const.darkColor
        searchBar.searchBarStyle = .prominent
        searchBar.barTintColor = .white
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "UsersTableViewCell", bundle:nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
                
        /* スライドメニュー */
//        //NavigationBarが半透明かどうか
//        navigationController?.navigationBar.isTranslucent = false
        //NavigationBarの色を変更します
//        navigationController?.navigationBar.barTintColor = UIColor(red: 129/255, green: 212/255, blue: 78/255, alpha: 1)
        
//        let gradientLayer = CAGradientLayer()
//        if let navFrame = self.navigationController?.navigationBar.frame {
//            gradientLayer.frame = navFrame
//
//            //遷移前の画面から受け取ったIndexで色を決定する
//            let color = Const.color[0]
//            let color1 = color["startColor"] ?? UIColor().cgColor
//            let color2 = color["endColor"] ?? UIColor().cgColor
//            //３色にするか迷う
//            //CAGradientLayerにグラデーションさせるカラーをセット
//            gradientLayer.colors = [color1,color2]
//            gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
//            gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
//            navigationController?.navigationBar.layer.insertSublayer(gradientLayer, at:0)
//        }
        //バーの左側にボタンを配置します(ライブラリ特有)
//        navigationController?.addLeftBarButtonWithImage(UIImage(named: "menu")!)
        //openLeft()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 10000
        self.searchbar.text = ""
        self.userPostArray = []
        self.tableView.reloadData()
        //画面下部の境界線を消す
        tableView.tableFooterView = UIView()

    }
     
     

    //検索バーで文字編集中（文字をクリアしたときも実行される）
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)  {
        //文字が空の場合userPostArrayを空にする
        if  searchText.isEmpty {
            self.userPostArray  = []
            self.tableView.reloadData()
        }


    }
    
    //検索ボタンがタップされた時に実行される
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        inputText =  searchBar.text!
        inputText = inputText.trimmingCharacters(in: .whitespaces)

        
        self.userPostArray  = []
        //自分のuid取得
        if (Auth.auth().currentUser?.uid) != nil {
            


            //ユーザからデータを取得
//            let postRef = Firestore.firestore().collection(Const.users)
//            postRef.whereField("userName", isGreaterThanOrEqualTo: inputText).whereField("userName", isLessThanOrEqualTo: "IN")
//            postRef.whereField("userName", isEqualTo:inputText)
            let postRef = Firestore.firestore().collection(Const.users).whereField("userName", isEqualTo:inputText)
            postRef.getDocuments() {
                (querySnapshot,error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    self.userPostArray = querySnapshot!.documents.map {
                        document in
                        let userPostData = UserPostData(document:document)
                        return userPostData
                    }
                    searchBar.endEditing(true)
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
         return .none
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView:UITableView,commit editingStyle:UITableViewCell.EditingStyle,forRowAt indexPath:IndexPath){
    }
 
    //セル内の「フォロー申請」ボタンがタップされた時に呼ばれるメソッド
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
                print("申請キャンセル")
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
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    self.userPostArray = querySnapshot!.documents.map {
                        document in
                        //print("\(document.documentID) => \(document.data())")
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
