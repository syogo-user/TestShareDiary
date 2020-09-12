//
//  FollowListTableViewCell.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/09.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class FollowRequestListTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileMessage: UILabel!
    @IBOutlet weak var followRequestPermissionButton: UIButton!
    @IBOutlet weak var followRequestRejectionButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //タップした瞬間の文字色変更
        followRequestPermissionButton.setTitleColor(UIColor.white ,for: .highlighted)
        followRequestPermissionButton.layer.cornerRadius = 15
        followRequestRejectionButton.layer.cornerRadius = 15
        userImage.layer.cornerRadius = 30
        //セルをタップ時、ラベルが重なっているため、ラベルが反応しないように設定
        profileMessage.isUserInteractionEnabled=false
        //ボタンの設定
        buttonSet()
    }
    //ボタンの設定
    private func buttonSet(){
        //文字色
        followRequestPermissionButton.setTitleColor(UIColor.white, for: .normal)
        followRequestPermissionButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        followRequestRejectionButton.setTitleColor(UIColor.white, for: .normal)
        followRequestRejectionButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        // 角丸
        followRequestPermissionButton.layer.cornerRadius = followRequestPermissionButton.bounds.midY
        followRequestRejectionButton.layer.cornerRadius = followRequestPermissionButton.bounds.midY
        //影
        followRequestPermissionButton.layer.shadowColor = Const.buttonStartColor.cgColor
        followRequestPermissionButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        followRequestPermissionButton.layer.shadowOpacity = 0.2
        followRequestPermissionButton.layer.shadowRadius = 10
        followRequestRejectionButton.layer.shadowColor = Const.buttonStartColor.cgColor
        followRequestRejectionButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        followRequestRejectionButton.layer.shadowOpacity = 0.2
        followRequestRejectionButton.layer.shadowRadius = 10
        // グラデーション
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = followRequestPermissionButton.bounds
        gradientLayer.cornerRadius = followRequestPermissionButton.bounds.midY
        gradientLayer.colors = [Const.buttonStartColor.cgColor, Const.buttonEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        followRequestPermissionButton.layer.insertSublayer(gradientLayer, at: 0)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = followRequestRejectionButton.bounds
        gradientLayer2.cornerRadius = followRequestRejectionButton.bounds.midY
        gradientLayer2.colors = [Const.buttonStartColor.cgColor, Const.buttonEndColor.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1, y: 1)
        followRequestRejectionButton.layer.insertSublayer(gradientLayer2, at: 0)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func setUserPostData(_ userPostData:UserPostData){
        guard let myid = Auth.auth().currentUser?.uid else{return}
        //userNameをセット
        self.userName.text = userPostData.userName

        self.profileMessage.isEnabled = false//編集不可
        //写真を設定
        setImage(userImageName:userPostData.myImageName)
        
        //プロフィール表示処理
        profileShow(myid:myid,userPostData:userPostData)
                
    }
    
    //鍵アカウントか判定しプロフィールメッセージを表示
    private func profileShow(myid :String,userPostData:UserPostData){
        //鍵アカウント判定用変数
        let keyAccountFlg = userPostData.keyAccountFlg ?? true
        //相手のuidを取得
        guard let uid = userPostData.uid else {return}
        //uidが自分か相手かを判定
        if uid == myid{
            //自分のuidの場合
            self.profileMessage.text = userPostData.profileMessage //プロフィールメッセージを表示
        } else {
            //相手のuidの場合
            //相手が鍵アカウントかどうか
            if keyAccountFlg {
                //鍵アカウント
                //自分のフォローしている人を取得
                let postMyUserRef = Firestore.firestore().collection(Const.users).document(myid)
                postMyUserRef.getDocument() {
                    (querySnapshot,error) in
                    if let error = error {
                        print("DEBUG: snapshotの取得が失敗しました。\(error)")
                        return
                    } else {
                        guard let document = querySnapshot!.data() else {return}
                        //自分がフォローしている人の中に表示しようとしている相手のuidがあるかを判定
                        let myFollow = document["follow"] as? [String] ?? []
                        if myFollow.firstIndex(of: uid) != nil{
                            //フォローしている場合プロフィールを表示
                            self.profileMessage.text = userPostData.profileMessage
                        }else{
                            //フォローしていない場合 非公開
                            self.profileMessage.text = "【非公開】"
                        }
                    }
                }
            } else {
                //鍵アカウントではない
                self.profileMessage.text = userPostData.profileMessage //プロフィールメッセージを表示
            }
        }
    }
    
    private func setImage(userImageName:String?){
        if let userImageName = userImageName {
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(userImageName + ".jpg")
            //取得した画像の表示
            self.userImage.sd_imageIndicator =
                SDWebImageActivityIndicator.gray
            self.userImage.sd_setImage(with: imageRef)
        } else {
            //画像が設定されていない場合
            //デフォルトの写真を表示
            self.userImage.image = UIImage(named: "unknown")
        }
    }
    
}
