//
//  SettingViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/10/03.
//  Copyright © 2020 syogo-user. All rights reserved.
//
import UIKit
import Firebase
class SettingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mailAddressButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var accountDeleteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        self.mailAddressButton.addTarget(self, action: #selector(tapMailAddressButton(_:)), for: .touchUpInside)
        self.passwordButton.addTarget(self, action: #selector(tapPasswordButton(_:)), for: .touchUpInside)
        self.accountDeleteButton.addTarget(self,action:#selector(tapAccountDeleteButton(_:)),for:.touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let mailAddress = Auth.auth().currentUser?.email else {return}
        self.titleLabel.text = "アカウント設定"
        self.titleLabel.textColor = UIColor.white
        self.mailAddressButton.setTitle("メールアドレス： \(mailAddress)" , for: .normal)
        self.mailAddressButton.setTitleColor(UIColor.white, for: .normal)
        self.passwordButton.setTitle("パスワード： ●●●●●●●●" , for: .normal)
        self.passwordButton.setTitleColor(UIColor.white, for: .normal)
        self.accountDeleteButton.setTitleColor(UIColor.white, for: .normal)
        
//        self.accountDeleteButtonSetting()

    }
//    //アカウント削除ボタン表示の切り替え
//    private func accountDeleteButtonSetting(){
//        //アカウント削除ボタンは非表示で初期化する
//        self.accountDeleteButton.isHidden = true
//
//        guard let myUid = Auth.auth().currentUser?.uid else {return}
//        let userRef = Firestore.firestore().collection(Const.users).document(myUid)
//        userRef.getDocument() {
//            (querySnapshot,error) in
//            if let error = error {
//                print("DEBUG: snapshotの取得が失敗しました。\(error)")
//                return
//            } else {
//                if let document = querySnapshot!.data(){
//                    let administratorFlg  = document["administratorFlg"] as? Bool ?? false
//                    //管理者権限かどうかでボタンの表示を設定
//                    if administratorFlg == true {
//                        //管理者の場合、表示
//                        self.accountDeleteButton.isHidden = false
//                    }else {
//                        //管理者出ない場合、非表示
//                        self.accountDeleteButton.isHidden = true
//                    }
//                }
//            }
//        }
//
//    }
    
    //メールアドレスボタン押下時
    @objc private func tapMailAddressButton(_ sender : UIButton){        
        let mailAddressChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MailAddressChangeViewController") as! MailAddressChangeViewController
        mailAddressChangeViewController.accountDeleteFlg = false //メールアドレスからの場合はfalse
        self.navigationController?.pushViewController(mailAddressChangeViewController, animated: true)
    }
    //パスワードボタン押下時
    @objc private func tapPasswordButton(_ sender : UIButton){
        let passwordChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordChangeViewController") as! PasswordChangeViewController
        self.navigationController?.pushViewController(passwordChangeViewController, animated: true)
    }
    //アカウント削除ボタン押下時
    @objc private func tapAccountDeleteButton(_ sender:UIButton){
        //TODO　後で以下の3行のコメントを別のボタンに設定する
//        let mailAddressChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MailAddressChangeViewController") as! MailAddressChangeViewController
//        mailAddressChangeViewController.accountDeleteFlg = true //アカウント削除からの場合はtrue
//        self.navigationController?.pushViewController(mailAddressChangeViewController, animated: true)
        
        //ダイアログ表示
        let dialog = UIAlertController(title: "アカウントを削除します。よろしいですか？\n（削除後に新規アカウントを作成する場合、\n同じアドレスは30日間使用できません。）", message: nil, preferredStyle: .actionSheet)
        //OKボタン
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //削除フラグの設定
            self.accountDeleteFlgSet()
        }))
        //キャンセルボタン
        dialog.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { action in}))
        self.present(dialog,animated: true,completion: nil)
    }
    //削除フラグ設定
    private func accountDeleteFlgSet(){
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        let docData = [
            "accountDeleteState":1,
            "accountDeleteDate":FieldValue.serverTimestamp()
            ] as [String : Any]
        //メッセージの保存
        let userRef = Firestore.firestore().collection(Const.users).document(myUid)
        userRef.updateData(docData)
    }
    
}
