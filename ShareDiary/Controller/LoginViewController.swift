//
//  LoginViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/24.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.cornerRadius = 15
        self.createAccountButton.layer.cornerRadius = 15
        self.backImage.image = UIImage(named: "yozora")
        self.backImage.contentMode = .scaleAspectFill
        
        //メールアドレス欄
        self.mailAddressTextField.layer.cornerRadius = 15
        self.mailAddressTextField.layer.borderWidth = 0.1   
        self.mailAddressTextField.layer.borderColor = UIColor.white.cgColor
        self.mailAddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        //パスワード欄
        self.passwordTextField.layer.cornerRadius = 15
        self.passwordTextField.layer.borderWidth = 0.1
        self.passwordTextField.layer.borderColor = UIColor.white.cgColor
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //ボタンの押下時の文字色
        loginButton.setTitleColor(UIColor.lightGray ,for: .highlighted)
        createAccountButton.setTitleColor(UIColor.lightGray ,for: .highlighted)
        loginButton.addTarget(self, action: #selector(tapLoginButton(_:)), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(tapcreateAccountButton(_:)), for: .touchUpInside)
    }

 
    @objc private func tapLoginButton(_ sender :UIButton){
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力してください")
                return
            }
            //HUDで処理中を表示
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus:"サインインに失敗しました。")
                    return
                }
                //HUDを消す
                SVProgressHUD.dismiss()
                // 画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc private func tapcreateAccountButton(_ sender :UIButton){
        //アカウント作成画面に遷移
        let accountCreateViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcountCreateViewController") as! AccountCreateViewController

        accountCreateViewController.mailAddress = self.mailAddressTextField.text ?? ""
        accountCreateViewController.password = self.passwordTextField.text ?? ""
        accountCreateViewController.modalPresentationStyle = .fullScreen
        self.present(accountCreateViewController, animated: true, completion: nil)
    }
    @objc private func dismissKeyboard(){
        self.view.endEditing(true)
    }
}
