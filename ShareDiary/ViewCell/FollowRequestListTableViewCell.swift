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
    @IBOutlet weak var profileMessage: UITextView!
    
    @IBOutlet weak var followRequestPermissionButton: UIButton!
    @IBOutlet weak var followRequestRejectionButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //タップした瞬間の文字色変更
        followRequestPermissionButton.setTitleColor(UIColor.white ,for: .highlighted)
        followRequestPermissionButton.layer.cornerRadius = 15
        followRequestRejectionButton.layer.cornerRadius = 15
        userImage.layer.cornerRadius = 30
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
        //写真を設定
        setImage(userImageName:userPostData.myImageName)
                
    }
    private func setImage(userImageName:String?){
        guard let userImageName = userImageName else {return}
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(userImageName + ".jpg")
            //取得した画像の表示
            self.userImage.sd_imageIndicator =
                SDWebImageActivityIndicator.gray
            self.userImage.sd_setImage(with: imageRef)
        
    }
    
}
