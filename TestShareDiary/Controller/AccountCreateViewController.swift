//
//  AcountCreateViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/08/16.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import SafariServices

class AccountCreateViewController: UIViewController,SFSafariViewControllerDelegate{

    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var newAccountCreateButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var termsOfServiceButton: UIButton!//利用規約
    
    var mailAddress = ""
    var password = ""
    var checkBoxCheck = false //true：チェックあり　false：チェックなし
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backImage.image = UIImage(named: "yozora")
        self.backImage.contentMode = .scaleAspectFill
        self.newAccountCreateButton.layer.cornerRadius = 15
        
        //メールアドレス欄
        self.mailAddressTextField.layer.cornerRadius = 15
        self.mailAddressTextField.layer.borderWidth = 0.1
        self.mailAddressTextField.layer.borderColor = UIColor.white.cgColor
        self.mailAddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        //画面遷移時メールアドレスが入力されていたら
        if mailAddress != ""{
            self.mailAddressTextField.text = mailAddress
        }
        //パスワード欄
        self.passwordTextField.layer.cornerRadius = 15
        self.passwordTextField.layer.borderWidth = 0.1
        self.passwordTextField.layer.borderColor = UIColor.white.cgColor
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード(6桁以上)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        //画面遷移時パスワードが入力されていたら
        if password != "" {
            self.passwordTextField.text = password
        }
        //パスワード（確認用）欄
        self.passwordCheckTextField.layer.cornerRadius = 15
        self.passwordCheckTextField.layer.borderWidth = 0.1
        self.passwordCheckTextField.layer.borderColor = UIColor.white.cgColor
        self.passwordCheckTextField.attributedPlaceholder = NSAttributedString(string: "パスワード(確認用)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        //ニックネーム欄
        self.nickNameTextField.layer.cornerRadius = 15
        self.nickNameTextField.layer.borderWidth = 0.1
        self.nickNameTextField.layer.borderColor = UIColor.white.cgColor
        self.nickNameTextField.attributedPlaceholder = NSAttributedString(string: "ニックネーム(10文字まで)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        //新規作成ボタン
        self.newAccountCreateButton.addTarget(self, action:#selector(tapNewAccountCreateButton(_ :)), for: .touchUpInside)
        //キャンセルボタン
        self.cancelButton.addTarget(self, action:#selector(tapCancellButton(_ :)), for: .touchUpInside)
        //チェックボックス
        self.checkBox.addTarget(self, action: #selector(changeChackBox(_ :)), for: .touchUpInside)
        //利用規約ボタン
        self.termsOfServiceButton.addTarget(self, action: #selector(tapTermsOfServiceButton(_:)), for: .touchUpInside)
        //キーボードを閉じるための処理
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //ボタンの押下時の文字色
        self.newAccountCreateButton.setTitleColor(UIColor.lightGray ,for: .highlighted)
        self.cancelButton.setTitleColor(UIColor.lightGray ,for: .highlighted)
    }
    //新規作成ボタン押下時
    @objc private func tapNewAccountCreateButton(_ sender:UIButton){
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let passwordCheck = passwordCheckTextField.text,let displayName = nickNameTextField.text {
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || passwordCheck.isEmpty || displayName.isEmpty {
                print("DEBUG: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を入力してください")
                return
            }
            if !Validation.isValidEmail(address){
                SVProgressHUD.showError(withStatus: "メールアドレスの書式で\n入力してください")
                return
            }

            //パスワード桁数
            if password.count < 6 {
                SVProgressHUD.showError(withStatus: "パスワードは6桁以上で\n入力してください")
                return
            }
            //パスワードが２つとも同じか判定
            if password != passwordCheck {
                SVProgressHUD.showError(withStatus: "パスワードは同じものを\n入力してください")
                return
            }
            //名前の文字数制限
            if displayName.count > 10 {
                SVProgressHUD.showError(withStatus: "ニックネームは10文字以内で\n入力してください")
                return
            }
            //名前がunknownの場合
            if displayName == Const.unknown {
                SVProgressHUD.showError(withStatus: "unknownは\n使用できません")
                return
            }
            //利用規約の同意
            if checkBoxCheck == false{
                SVProgressHUD.showError(withStatus: "利用規約をお読みの上、\n同意をお願いします")
                return
            }
            //HUDで処理中を表示
            SVProgressHUD.show()
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザ作成に失敗しました。")
                    return
                }
                
                // 表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    //名前の前後の空白を削除
                    let trimDisplayName = displayName.trimmingCharacters(in: .whitespaces)
                    changeRequest.displayName = trimDisplayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // プロフィールの更新でエラーが発生
                            print("DEBUG: " + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                            return
                        }
                        //usersにuidとuserNameを設定する
                        if let myid = Auth.auth().currentUser?.uid {
                            let postRef = Firestore.firestore().collection(Const.users).document(myid)
                            let postDic = [
                                "uid":myid,
                                "userName":trimDisplayName,
                                "follow":[],
                                "follower":[],
                                "followRequest":[],
                                "blockList":[],
                                "profileMessage":"",
                                "keyAccountFlg":true,
                                "administratorFlg":false,
                                "accountDeleteState":0,
                                "accountDeleteDate":"",
                                "lastLoginDate":FieldValue.serverTimestamp(),
                                "lastLogoutDate":""
                                ] as [String :Any]
                            postRef.setData(postDic)
                        }
                        print("DEBUG: [displayName = \(user.displayName!)]の設定に成功しました。")
                        SVProgressHUD.dismiss()
                        // 画面を閉じてタブ画面に戻る
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
        }
    }
        
    @objc private func tapCancellButton(_ sender :UIButton ){
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func dismissKeyboard(){
        self.view.endEditing(true)
    }
    //チェックボックス
    @objc private func changeChackBox(_ sender:CheckBox){
        //チェックのありかなしを設定
        self.checkBoxCheck = sender.isChecked
        print("DEBUG:\(checkBoxCheck)")
    }
    //利用規約ボタン押下時
    @objc private func tapTermsOfServiceButton(_ sender :UIButton){
        //Safariで利用規約を表示
        let webPage = Const.termsOfServiceURL
        let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
