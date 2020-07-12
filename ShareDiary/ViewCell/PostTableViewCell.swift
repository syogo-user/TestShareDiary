//
//  PostTableViewCell.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postUserImageView: UIImageView!
    @IBOutlet weak var postUserLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contetImageView: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postUserImageView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
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
        likeNumberLabel.text = ""
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
        // 投稿画像の表示
        contetImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef2 = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        contetImageView.sd_setImage(with: imageRef2)

        //プロフィール写真を設定
        setPostImage(uid:postData.uid)
        //背景色を設定
        setBackgroundColor(colorIndex:postData.backgroundColorIndex ?? 0)

    }
    
    private func setPostImage(uid:String){
        let userRef = Firestore.firestore().collection(Const.users).document(uid)
        
        userRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                if let document = querySnapshot!.data(){
                    let imageName = document["myImageName"] as? String ?? ""
                    
                    //画像の取得
                    let imageRef = Storage.storage().reference().child(Const.ImagePath).child(imageName + ".jpg")
                    
                    //画像がなければデフォルトの画像表示
                    if imageName == "" {
                        self.postUserImageView.image = UIImage(named: "unknown")
                    }else{
                        //取得した画像の表示
                        self.postUserImageView.sd_imageIndicator =
                            SDWebImageActivityIndicator.gray
                        self.postUserImageView.sd_setImage(with: imageRef)
                    }
                }
            }
        }
    }
    private func setBackgroundColor(colorIndex:Int){
        //背景色を変更する
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.layer.bounds
        let color = Const.color[colorIndex]
        let color1 = color["startColor"] ?? UIColor.white.cgColor
        let color2 = color["endColor"] ?? UIColor.white.cgColor
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1,color2]
        gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
        gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
        
        if self.layer.sublayers![0] is CAGradientLayer {
            self.layer.sublayers![0].removeFromSuperlayer()
            self.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }


}
