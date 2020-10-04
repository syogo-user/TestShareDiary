
//
//  PasswordChangeViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/10/03.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
class PasswordChangeViewController: UIViewController {
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordCheck: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        let rightFooBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTap))
        self.navigationItem.setRightBarButtonItems([rightFooBarButtonItem], animated: true)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    //保存ボタン押下時
    @objc private func saveButtonTap(){
        guard let user = Auth.auth().currentUser else{return}
        guard let email = user.email else{return}
        var credential: AuthCredential

        if let currentPassword = self.currentPassword.text ,let newPassword = self.newPassword.text, let newPasswordCheck = self.newPasswordCheck.text{
            //パスワードチェック
            if currentPassword.isEmpty || newPassword.isEmpty || newPasswordCheck.isEmpty {
                let dialog  =  UIAlertController(title: "必要項目を入力してください", message: nil, preferredStyle: .actionSheet)
                //OKボタン
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                return
            }
            //パスワード桁数
            if currentPassword.count < 6 || newPassword.count < 6 || newPasswordCheck.count < 6{
                //アラート
                let dialog  =  UIAlertController(title: "パスワードは6桁以上で入力してください", message: nil, preferredStyle: .actionSheet)
                //OKボタン
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                return
            }
            
            if newPassword != newPasswordCheck {
                //新しいパスワード２つが一致しない場合
                //アラート
                let dialog  =  UIAlertController(title: "新しいパスワードが一致しません", message: nil, preferredStyle: .actionSheet)
                //OKボタン
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                return
            }
            
            SVProgressHUD.show()
            //再認証を行う
            credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            // Prompt the user to re-provide their sign-in credentials
            user.reauthenticate(with: credential) { result ,error in
                if let error = error {
                    // An error happened.
                    print("DEBUG:認証に失敗しました\(error)")
                    let dialog  =  UIAlertController(title: "認証に失敗しました", message: nil, preferredStyle: .alert)
                    //OKボタン
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog,animated: true,completion: nil)
                    SVProgressHUD.dismiss()
                    return
                } else {
                    // User re-authenticated.
                    print("DEBUG:再認証成功")
                    //パスワード更新
                    self.updatePassword(user:user)
                }
            }
        }
    }
    
    //パスワード更新
    private func updatePassword(user:User){
        user.updatePassword(to: self.newPassword.text!){error in
            if let error  = error {
                print("DEBUG:認証に失敗しました \(error)")
                let dialog  =  UIAlertController(title: "パスワードの更新に失敗しました", message:nil, preferredStyle: .alert)
                //OKボタン
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                SVProgressHUD.dismiss()
                return
            }else{
                print("DEBUG:パスワード更新完了")
                //HUDを消す
                SVProgressHUD.dismiss()
                //前の画面に戻る
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func dismissKeyboard(){
        self.view.endEditing(true)
    }
    

}
