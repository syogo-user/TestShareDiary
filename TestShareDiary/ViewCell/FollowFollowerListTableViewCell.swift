//
//  FollowFollwerListTableViewCell.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/10.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class FollowFollowerListTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileMessage: UILabel!
    @IBOutlet weak var rejectedButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        //タップした瞬間の文字色変更
        rejectedButton.setTitleColor(UIColor.white ,for: .highlighted)
        rejectedButton.layer.cornerRadius = 15
        userImage.layer.cornerRadius = 30
        //セルをタップ時、ラベルが重なっているため、ラベルが反応しないように設定
        profileMessage.isUserInteractionEnabled = false        
        //ボタンの設定
        buttonSet()
    }
    //ボタンの設定
    private func buttonSet(){
        //文字色
        rejectedButton.setTitleColor(UIColor.white, for: .normal)
        rejectedButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        // 角丸
        rejectedButton.layer.cornerRadius = rejectedButton.bounds.midY
        //影
        rejectedButton.layer.shadowColor = Const.buttonStartColor.cgColor
        rejectedButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        rejectedButton.layer.shadowOpacity = 0.2
        rejectedButton.layer.shadowRadius = 10
        // グラデーション
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rejectedButton.bounds
        gradientLayer.cornerRadius = rejectedButton.bounds.midY
        gradientLayer.colors = [Const.buttonStartColor.cgColor, Const.buttonEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        rejectedButton.layer.insertSublayer(gradientLayer, at: 0)
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
        //相手のuidを取得
        guard let uid = userPostData.uid else {return}
        //uidが自分か相手かを判定
        if uid == myid{
            //自分のuidの場合
            self.profileMessage.text = userPostData.profileMessage //プロフィールメッセージを表示
        } else {
            //相手のuidの場合
            
            //自分のフォローしている人を取得
            let postMyUserRef = Firestore.firestore().collection(Const.users).document(myid)
            postMyUserRef.getDocument() {
                (querySnapshot,error) in
                if let error = error {
                    print("DEBUG: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    if userPostData.keyAccountFlg ?? true{
                        //鍵アカウント
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
                    } else {
                        //鍵アカウントではない
                        self.profileMessage.text = userPostData.profileMessage //プロフィールメッセージを表示
                    }
                    
                }
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
