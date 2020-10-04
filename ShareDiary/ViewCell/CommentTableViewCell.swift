//
//  CommentTableViewCell.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/07/05.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerComment: UITextView!
    @IBOutlet weak var myComment: UITextView!
    @IBOutlet weak var partnerCommentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myCommentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var partnerCreatedAt: UILabel!
    @IBOutlet weak var myCreatedAt: UILabel!
    //影
    
    @IBOutlet weak var userImageShadowView: UIView!
    @IBOutlet weak var partnerCommentShadowView: UIView!
    @IBOutlet weak var partnerCommentShadowWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var myCommentShadowView: UIView!
    @IBOutlet weak var myCommentShadowWidthConstraint: NSLayoutConstraint!
    
    var message = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.partnerComment.layer.cornerRadius = 20
        self.userImageView.layer.cornerRadius = 25
        self.myComment.layer.cornerRadius = 20
        self.backgroundColor = Const.lightOrangeColor
    }
    override func layoutSubviews() {
        //描画されるときに呼び出される
        print("DEBUG layoutSub:\(myComment.text!) :height:\(myComment.frame.height), width:\(myComment.frame.width)")
        super.layoutSubviews()
        print("DEBUG layoutSub:\(myComment.text!) :height:\(myComment.frame.height), width:\(myComment.frame.width)")
        //写真の影
        self.userImageShadowView.bounds = self.userImageView.bounds
        self.userImageShadowView.layer.cornerRadius = 25
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCommentData(_ commentData:CommentData){
        setComment(commentData:commentData)
    }
    //コメントの設定
    private func setComment(commentData:CommentData){
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        //ユーザ名
        let stringAttributesUserName:[NSAttributedString.Key:Any] = [
            .foregroundColor : UIColor.lightGray,
            .font :UIFont.boldSystemFont(ofSize: 12)
        ]
        let stringUserName = NSAttributedString(string:"\(commentData.userName)\n",attributes: stringAttributesUserName)
        //メッセージ
        let stringAttributesMessage:[NSAttributedString.Key:Any] = [
            .foregroundColor : UIColor.darkGray,
            .font :UIFont.systemFont(ofSize: 15)
        ]
        let stringMessage = NSAttributedString(string:commentData.message,attributes: stringAttributesMessage)
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(stringUserName)
        mutableAttributedString.append(stringMessage)

        if myUid == commentData.uid{

            //自分の場合
            self.partnerComment.isHidden = true
            self.partnerCreatedAt.isHidden = true
            self.userImageView.isHidden = true
            self.myComment.isHidden = false
            self.myCreatedAt.isHidden = false
                        
            //影
            self.partnerCommentShadowView.isHidden = true
            self.userImageShadowView.isHidden = true
            self.myCommentShadowView.isHidden = false
            
            self.myComment.attributedText = mutableAttributedString
            self.myCreatedAt.text = dateFormatterForDateLabel(date: commentData.createdAt.dateValue())
            //コメントの横幅調整
            var width = frameWidthTextView(text:commentData.message).width + 10
            //ユーザ名だけの横幅よりも小さかった場合（名前が2行に分割されて計算されたことがあったため追記）
            if width <= frameWidthTextView(text: commentData.userName).width {
                //幅をユーザ名文字分の横幅にする
                width = frameWidthTextView(text: commentData.userName).width
            }
            self.myCommentWidthConstraint.constant = width
            print("DEBUG setComment:\(myComment.text!) :height:\(myComment.frame.height), width:\(myComment.frame.width)")
            
            //影
            self.myCommentShadowView.bounds = self.myComment.bounds
            self.myCommentShadowWidthConstraint.constant = width
        } else {
            //相手の場合

            self.partnerComment.isHidden = false
            self.partnerCreatedAt.isHidden = false
            self.userImageView.isHidden = false
            self.myComment.isHidden = true
            self.myCreatedAt.isHidden = true
            //影
            self.partnerCommentShadowView.isHidden = false
            self.userImageShadowView.isHidden = false
            self.myCommentShadowView.isHidden = true
            
            self.partnerComment.attributedText = mutableAttributedString
            self.partnerCreatedAt.text =  dateFormatterForDateLabel(date: commentData.createdAt.dateValue())
            //コメントの横幅調整
            var width = frameWidthTextView(text:commentData.userName + commentData.message).width + 10
            //ユーザ名だけの横幅よりも小さかった場合（名前が2行に分割されて計算されたことがあったため追記）
            if width <= frameWidthTextView(text: commentData.userName).width {
                //幅をユーザ名文字分の横幅にする
                width = frameWidthTextView(text: commentData.userName).width
            }
            self.partnerCommentWidthConstraint.constant = width

            //画像の表示
            setImageShow(userUid:commentData.uid)
            
            //影
            self.partnerCommentShadowView.bounds = self.partnerComment.bounds
            self.partnerCommentShadowWidthConstraint.constant = width
        }

    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    //横幅計算
    private func frameWidthTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)//最大値
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func setImageShow(userUid:String){
        let postRef = Firestore.firestore().collection(Const.users).document(userUid)
        postRef.getDocument{
            (document ,error) in
            if error != nil {
                print("DEBUG: snapshotの取得が失敗しました。")
                return
            }
            //userNameとuserImageViewを設定
            guard let document = document else {return}
            if let userData = document.data() {
                let myImageName = userData["myImageName"] as? String
                self.setImage(userImageName:myImageName)
            }
        }
    }
    
    //画像の設定
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
