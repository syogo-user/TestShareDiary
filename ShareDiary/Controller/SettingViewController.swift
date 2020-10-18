//
//  SettingViewController.swift
//  ShareDiary
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        self.mailAddressButton.addTarget(self, action: #selector(tapMailAddressButton(_:)), for: .touchUpInside)
        self.passwordButton.addTarget(self, action: #selector(tapPasswordButton(_:)), for: .touchUpInside)
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

    }
    //メールアドレスボタン押下時
    @objc private func tapMailAddressButton(_ sender : UIButton){        
        let mailAddressChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MailAddressChangeViewController") as! MailAddressChangeViewController
        self.navigationController?.pushViewController(mailAddressChangeViewController, animated: true)
    }
    //パスワードボタン押下時
    @objc private func tapPasswordButton(_ sender : UIButton){
        let passwordChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordChangeViewController") as! PasswordChangeViewController
        self.navigationController?.pushViewController(passwordChangeViewController, animated: true)
    }
            
}