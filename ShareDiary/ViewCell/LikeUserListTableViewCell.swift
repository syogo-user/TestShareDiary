//
//  LikeUserListTableViewCell.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/07/01.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class LikeUserListTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 30
    }

    func setUserPostData(_ likeUserUid:String){
        let postRef = Firestore.firestore().collection(Const.users).document(likeUserUid)
        postRef.getDocument{
            (document ,error) in
            if error != nil {
                print("DEBUG: snapshotの取得が失敗しました。")
                return
            }
            //userNameとuserImageViewを設定
            guard let document = document else {return}
            if let userData = document.data() {
                self.userName.text = userData["userName"] as? String ?? ""
                let myImageName = userData["myImageName"] as? String ?? ""
                self.setImage(userImageName:myImageName)
            }            
        }
    }
    private func setImage(userImageName:String?){
        if let userImageName = userImageName {
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(userImageName + ".jpg")
            //取得した画像の表示
            self.userImageView.sd_imageIndicator =
                SDWebImageActivityIndicator.gray
            self.userImageView.sd_setImage(with: imageRef)
        } else {
            //画像が設定されていない場合
            //デフォルトの写真を表示
            self.userImageView.image = UIImage(named: "unknown")
        }
    }

}
