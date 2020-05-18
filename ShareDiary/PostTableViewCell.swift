//
//  PostTableViewCell.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import FirebaseUI
class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postUserImageView: UIImageView!
    @IBOutlet weak var postUserLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contetImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        
        //投稿者のプロフィール写真
//        postUserImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
//        postUserImageView.sd_setImage(with: imageRef)
        
        //投稿者の名前
        self.postUserLabel.text = ""
        if let documentUserName = postData.documentUserName {
            self.postUserLabel.text = "\(documentUserName)"
        }
        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        // いいね数の表示
        let likeNumber = postData.likes.count
        likeNumberLabel.text = "\(likeNumber)"
        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }
        // コンテントの表示
        self.contentTextView.text = ""
        if let content = postData.content{
            self.contentTextView.text! = content
        }
        //文字入力不可設定
        self.contentTextView.isEditable = false
        // 画像の表示
        contetImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef2 = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        contetImageView.sd_setImage(with: imageRef2)

        
    }
}
