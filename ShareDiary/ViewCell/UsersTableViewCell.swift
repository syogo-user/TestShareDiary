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
    @IBOutlet weak var profileMessage: UITextView!
    
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //タップした瞬間の文字色変更
        followRequestButton.setTitleColor(UIColor.white ,for: .highlighted)
        userImage.layer.cornerRadius = 30
        followRequestButton.layer.cornerRadius = 15
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUserPostData(_ userPostData:UserPostData){
        //userNameをセット
        self.userName.text = userPostData.userName
        self.profileMessage.text = userPostData.profileMessage
        self.profileMessage.isEditable = false//編集不可
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
