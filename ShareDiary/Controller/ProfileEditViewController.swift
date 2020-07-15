//
//  Profile ProfileEditViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/07/12.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
class ProfileEditViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var profileMessage: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        userName.layer.cornerRadius = 15
        profileMessage.layer.cornerRadius = 15
        //戻るボタンの戻るの文字を削除
        navigationController!.navigationBar.topItem!.title = ""
        let rightFooBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTap))
        self.navigationItem.setRightBarButtonItems([rightFooBarButtonItem], animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard  let myUid = Auth.auth().currentUser?.uid else { return}
        self.userName.text = ""
        self.profileMessage.text = ""
        //firebaseから自分のユーザ情報の取得
        let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)
        postUserRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                guard let document = querySnapshot!.data() else {return}
                self.userName.text = document["userName"] as? String ?? ""
                self.profileMessage.text = document["profileMessage"] as? String ?? ""
            }
        }
    }
    
    @objc private func saveButtonTap(){
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        //名前が空の場合
        if self.userName.text ?? "" == "" {
            let dialog = UIAlertController(title: "名前が空です", message: nil, preferredStyle: .actionSheet)
            //OKボタン
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(dialog, animated: true, completion: nil)
            return
        }

        let userName = self.userName.text!
        let message = self.profileMessage.text ?? ""
        let docData = [
            "userName":userName,
            "profileMessage": message
        ] as [String : Any]
        //メッセージの保存
        
        let userRef = Firestore.firestore().collection(Const.users).document(myUid)
        userRef.updateData(docData)
        //表示名設定
        let user = Auth.auth().currentUser
        if let user = user {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = userName
            changeRequest.commitChanges { error in
                if let error = error {
                    // プロフィールの更新でエラーが発生
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")


            }
        }
        //前の画面に戻る
        self.navigationController?.popViewController(animated: true)
    }
    


}
