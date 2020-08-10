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
    
    @IBOutlet weak var userTableView: UITableView!
    //投稿データを格納する配列
    var postArray :[PostData] = []
    var diaryDate :String = ""
    
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
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let postRef =  Firestore.firestore().collection(Const.PostPath)
            .whereField("selectDate", isEqualTo: diaryDate).whereField("uid", isEqualTo: myUid)
        postRef.getDocuments() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                self.postArray = []
                querySnapshot?.documents.forEach{
                    (document) in
                    let postData = PostData(document: document)
                    self.postArray.append(postData)
                    //投稿した日付（date）の（降順）で順番を並び替える 日付は必ず値が入るので強制アンラップで良い。
                    self.postArray.sort(by: { (a,b) -> Bool in
                        return a.date! > b.date!
                    })
                }
                self.userTableView.reloadData()
            }
        }
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        tableView.estimatedRowHeight = 800 //セルの高さ
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        cell.postTableViewCellDelegate = self
        return cell
    }
    
    //セルを選択時
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         //詳細画面に遷移する
         let detailViewController = self.storyboard?.instantiateViewController(identifier: "DitailViewController") as! DitailViewController
         // 配列からタップされたインデックスのデータを取り出す
         let postData = postArray[indexPath.row]
         
         detailViewController.postData = postData
         self.navigationController?.pushViewController(detailViewController, animated: true)
         
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
extension MyDiaryFromCalendar:PostTableViewCellDelegate{
    //PostTablViewCellの投稿写真をタップしたときに呼ばれる
    func imageTransition(_ sender:UITapGestureRecognizer) {
        //タップしたUIImageViewを取得
        let tappedImageView = sender.view! as! UIImageView
        //  UIImage を取得
        let tappedImage = tappedImageView.image!
        
        let fullsizeImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullsizeImageViewController") as! FullsizeImageViewController
        fullsizeImageViewController.modalPresentationStyle = .fullScreen
        fullsizeImageViewController.image = tappedImage
        self.present(fullsizeImageViewController, animated: true, completion: nil)
    }
    
}
