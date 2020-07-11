//
//  CommentInputViewControlelrViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/07/04.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
class CommentInputViewControlelr: UIViewController {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    var postData:PostData?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0,green:0,blue:0,alpha:0.5)
        //背景をタップしたら画面を閉じるメソッドを呼ぶように設定する
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target:self,action:#selector(dismissView))
        self.view.addGestureRecognizer(tapGesture)
        submitButton.addTarget(self, action: #selector(tapSubmitButton(_:)), for: .touchUpInside)
    }
    @objc func dismissView(){
        //画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    //送信ボタン押下時
    @objc func tapSubmitButton(_ sender :UIButton){
        guard let postDataId = postData?.id else {return }
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let messageId = randomString(length: 20)
        
        let docData = [
            "uid": myUid,
            "createdAt": Timestamp(),
            "message": inputTextView.text!
            ] as [String : Any]
        
        
        
    Firestore.firestore().collection(Const.PostPath).document(postDataId).collection("messages").document(messageId).setData(docData) {(err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            print("コメントメッセージの保存に成功しました")
                
        }
        
                       
                       
    
        

//
//         if let userName = user?.displayName ,let userId = user?.uid{
//             let comments = ["userName": userName,"content":self.inputTextView.text!,"commentUserId":userId]
//             //コメントのデータを取得する
//             postRef.getDocument {
//                 (document,error) in
//                 if let error = error {
//                     print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
//                     return
//                 } else {
//                     if let document  = document ,document.exists{
//                         var array  = document["comments"] as! [Any]
//                         array.append(comments)
//                         let data  = [
//                             "comments" : array
//                         ]
//                         print("submitButton")
//                         postRef.updateData(data)
//                     }
//                 }
//
//
//             }
//          }
         //送信ボタン押下後はモーダル画面を閉じる
         self.dismiss(animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }

}
