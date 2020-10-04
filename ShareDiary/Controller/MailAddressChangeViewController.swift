
//
//  MailAddressChangeViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/10/03.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
class MailAddressChangeViewController: UIViewController {

    @IBOutlet weak var mailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        let rightFooBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTap))
        self.navigationItem.setRightBarButtonItems([rightFooBarButtonItem], animated: true)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        guard let user = Auth.auth().currentUser else{return}
        //現在のメールアドレスを表示
        self.mailAddress.text = user.email
    }
    //保存ボタン押下時
    @objc private func saveButtonTap(){
        guard let user = Auth.auth().currentUser else{return}

        guard let email = user.email else {return}
        var credential: AuthCredential
        
        if let mailAddress = self.mailAddress.text ,let password = self.password.text {
            
            
            if mailAddress.isEmpty {
                //メールアドレスが空の場合
                let dialog = UIAlertController(title: "メールアドレスを入力してください", message: nil, preferredStyle: .actionSheet)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                return
            }
            //メールアドレスかをチェック
            if !Validation.isValidEmail(mailAddress){
                let dialog = UIAlertController(title: "メールアドレスの書式で入力してください", message: nil, preferredStyle: .actionSheet)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                return
            }
            if password.isEmpty{
                //パスワードが空の場合
                let dialog = UIAlertController(title: "認証を行うためパスワードを入力してください", message: nil, preferredStyle: .actionSheet)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                return
            }
            //パスワード桁数
            if password.count < 6{
                //アラート
                let dialog  =  UIAlertController(title: "パスワードは6桁以上で入力してください", message: nil, preferredStyle: .actionSheet)
                //OKボタン
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                return
            }
            
            //HUDを表示
            SVProgressHUD.show()

            //再認証を行う
            credential = EmailAuthProvider.credential(withEmail: email, password:password)
            // Prompt the user to re-provide their sign-in credentials
            user.reauthenticate(with: credential) { result ,error in
                if let error = error {
                    // An error happened.
                    print("DEBUG:\(error)")
                    let dialog  =  UIAlertController(title: "認証に失敗しました", message:nil, preferredStyle: .alert)
                    //OKボタン
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog,animated: true,completion: nil)
                    //HUDを消す
                    SVProgressHUD.dismiss()
                    return
                } else {
                    // User re-authenticated.
                    print("DEBUG:再認証成功")
                    //メールアドレス更新
                    self.updateMailAddress(user:user)
                }
            }
        }
    }
    
    //メールアドレス更新
    private func updateMailAddress(user:User){
        user.updateEmail(to: self.mailAddress.text!){ error in
            if let error = error {
                print("DEBUG:認証に失敗しました \(error)")
                let dialog  =  UIAlertController(title: "メールアドレスの更新に失敗しました", message:nil, preferredStyle: .alert)
                //OKボタン
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                //HUDを消す
                SVProgressHUD.dismiss()
                return
            }else{
                print("DEBUG:メールアドレス更新完了")
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
