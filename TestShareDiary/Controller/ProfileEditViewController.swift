//
//  Profile ProfileEditViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/07/12.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
class ProfileEditViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var profileMessage: UITextView!
    @IBOutlet weak var keyAccountFlg: UISwitch!
    private var oldName = ""//変更前ユーザ名
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        self.userName.layer.cornerRadius = 15
        self.profileMessage.layer.cornerRadius = 15
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        let rightFooBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTap))
        self.navigationItem.setRightBarButtonItems([rightFooBarButtonItem], animated: true)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
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
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                guard let document = querySnapshot!.data() else {return}
                self.userName.text = document["userName"] as? String ?? ""
                self.profileMessage.text = document["profileMessage"] as? String ?? ""
                self.keyAccountFlg.isOn = document["keyAccountFlg"] as? Bool ?? true
                //oldName変数に変更前のユーザ名を保持しておく
                self.oldName = document["userName"] as? String ?? ""
            }
        }
    }
    //保存ボタン押下時
    @objc private func saveButtonTap(){

        guard let myUid = Auth.auth().currentUser?.uid else {return}
        
        //名前が空の場合
        if self.userName.text ?? "" == "" {
            let dialog = UIAlertController(title: "名前が空です", message: nil, preferredStyle: .actionSheet)
            //OKボタン
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(dialog, animated: true, completion: nil)
            return
        } else if self.userName.text!.count > 10 {
            let dialog = UIAlertController(title: "ニックネームは10文字以内で入力してください", message: nil, preferredStyle: .actionSheet)
            //OKボタン
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(dialog, animated: true, completion: nil)
            return
        }
        
        let userName = self.userName.text!
        let message = self.profileMessage.text ?? ""
        let keyFlg = self.keyAccountFlg.isOn //鍵アカ
        let docData = [
            "userName":userName,
            "profileMessage":message,
            "keyAccountFlg":keyFlg
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
                    print("DEBUG: " + error.localizedDescription)
                    return
                }
                print("DEBUG: [displayName = \(user.displayName!)]の設定に成功しました。")
                //投稿データの名前も変更
                self.getDocumentUserName(oldName:self.oldName ,newName:userName)
            }
        }
        //前の画面に戻る
        self.navigationController?.popViewController(animated: true)
    }
    
    //投稿データの名前を取得
    private func getDocumentUserName(oldName:String,newName:String){

        //メッセージの保存
        let docRef = Firestore.firestore().collection(Const.PostPath).whereField("documentUserName", isEqualTo: oldName)
        //古いユーザ名の投稿のIDを取得する
        docRef.getDocuments(){
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                querySnapshot!.documents.forEach{
                    document in
                    //投稿データのユーザ名を更新
                    self.documentUserNameUpdate(docId: PostData(document: document).id, oldName: oldName, newName: newName)
                }
            }
        }

    }
    //投稿データのユーザ名を更新
    private func documentUserNameUpdate(docId:String,oldName:String,newName:String){
        let docData = [
            "documentUserName":newName
            ] as [String : Any]
        let docRef = Firestore.firestore().collection(Const.PostPath).document(docId)
        docRef.updateData(docData)    
    }
    
    @objc private func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
}
