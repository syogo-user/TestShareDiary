//
//  MyDiaryFromCalendar.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/22.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
class MyDiaryFromCalendar: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    //投稿データを格納する配列
    var postArray :[PostData] = []
    var diaryDate :String = ""
    
    
    @IBOutlet weak var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.delegate = self
        userTableView.dataSource = self
        //戻るボタンの戻るの文字を削除
        navigationController!.navigationBar.topItem!.title = ""

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        userTableView.register(nib, forCellReuseIdentifier: "tableCell")
        //画面下部の境界線を消す
        userTableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 投稿の取得

        //TODO どこかでpostArrayを初期化する
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let postRef =  Firestore.firestore().collection(Const.PostPath)
            .whereField("selectDate", isEqualTo: diaryDate)
        postRef.getDocuments() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                querySnapshot?.documents.forEach{
                    (document) in
                    let postData = PostData(document: document)
                    self.postArray.append(postData)
                }
                self.userTableView.reloadData()
            }
            
        }
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        return cell
    }
    //Dateを時間なしの文字列に変換
    func dateFormat(date:Date?) -> String {
        var strDate:String = ""
        
        if let day = date {
            let format  = DateFormatter()
            format.locale = Locale(identifier: "ja_JP")
            format.dateStyle = .short
            format.timeStyle = .none
            strDate = format.string(from:day)
        }
        return strDate
    }
    
    
    
}
