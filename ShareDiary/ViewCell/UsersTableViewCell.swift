//
//  UsersTableViewCell.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/05.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!        
    @IBOutlet weak var followRequestButton: UIButton!
    @IBOutlet weak var profileMessage: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = 30
        //セルをタップ時、ラベルが重なっているため、ラベルが反応しないように設定
        profileMessage.isUserInteractionEnabled=false
        //ボタンの設定
        buttonSet()
    }
    
    private func buttonSet(){
        //文字色
        followRequestButton.setTitleColor(UIColor.white, for: .normal)
        followRequestButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        // 角丸
        followRequestButton.layer.cornerRadius = followRequestButton.bounds.midY
        //影
        followRequestButton.layer.shadowColor = Const.buttonStartColor.cgColor
        followRequestButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        followRequestButton.layer.shadowOpacity = 0.2
        followRequestButton.layer.shadowRadius = 10
        // グラデーション
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = followRequestButton.bounds
        gradientLayer.cornerRadius = followRequestButton.bounds.midY
        gradientLayer.colors = [Const.buttonStartColor.cgColor, Const.buttonEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        followRequestButton.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUserPostData(_ userPostData:UserPostData){
        //userNameをセット
        self.userName.text = userPostData.userName
        self.profileMessage.isEnabled = false//編集不可
        
        //ボタンのテキスト変更
        if let myid = Auth.auth().currentUser?.uid {
            self.followRequestButton.setTitle("フォロー申請", for: .normal)
            self.followRequestButton.isEnabled = true
            self.followRequestButton.isHidden =  false
            // 写真の設定
            setImage(userImageName:userPostData.myImageName)
            if let followRequestArray = userPostData.followRequest {
                for followRequest in followRequestArray{
                    //フォローリクエストに今ログインしている自分のuidがあったら
                    if followRequest == myid {
                        self.followRequestButton.setTitle("申請済", for: .normal)
                        self.followRequestButton.isEnabled = true
                        self.followRequestButton.isHidden =  false
                    }
                }
            }
            
            if let followerArray = userPostData.follower {
                for follower in followerArray {
                    //フォロワーに今ログインしている自分のuidがあったら
                    if follower == myid {
                        self.followRequestButton.setTitle("フォロー済", for: .normal)
                        self.followRequestButton.isEnabled = false
                        self.followRequestButton.isHidden =  false
                    }
                }
            }
            //自分の場合
            if userPostData.uid == myid{
                self.followRequestButton.isEnabled = false
                self.followRequestButton.isHidden = true
            }
            
            //プロフィール表示処理
            profileShow(myid:myid,userPostData:userPostData)            
        }
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
        //画像の取得
        guard let userImageName = userImageName else {return}
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(userImageName + ".jpg")
            //取得した画像の表示
            self.userImage.sd_imageIndicator =
                SDWebImageActivityIndicator.gray
            self.userImage.sd_setImage(with: imageRef)
    }
    
}
