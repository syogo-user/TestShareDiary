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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.partnerComment.layer.cornerRadius = 20
        self.userImageView.layer.cornerRadius = 25
        self.myComment.layer.cornerRadius = 20
        self.backgroundColor = Const.lightOrangeColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCommentData(_ commentData:CommentData){
        //ユーザ名を取得しコメントを設定
        getUserName(commentData:commentData)
    }
    private func getUserName(commentData:CommentData){
        //自分もしくは自分以外の人のユーザ名を取得
        let postUserRef = Firestore.firestore().collection(Const.users).document(commentData.uid)
        postUserRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                guard let document = querySnapshot!.data() else {return}
                let userName = document["userName"] as? String ?? ""
                //コメントの設定
                self.setComment(userName:userName,commentData:commentData)
            }
        }
    }
    private func setComment(userName:String,commentData:CommentData){
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        //ユーザ名
        let stringAttributesUserName:[NSAttributedString.Key:Any] = [
            .foregroundColor : UIColor.darkGray,
            .font :UIFont.boldSystemFont(ofSize: 13)
        ]
        let stringUserName = NSAttributedString(string:"\(userName)\n",attributes: stringAttributesUserName)
        //メッセージ
        let stringAttributesMessage:[NSAttributedString.Key:Any] = [
            .foregroundColor : UIColor.lightGray,
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
                        
            self.myComment.attributedText = mutableAttributedString
            self.myCreatedAt.text = dateFormatterForDateLabel(date: commentData.createdAt.dateValue())
            //コメントの横幅調整
            let width = frameWidthTextView(text:myComment.text!).width + 10
            self.myCommentWidthConstraint.constant = width
                                
        } else {
            //相手の場合

            self.partnerComment.isHidden = false
            self.partnerCreatedAt.isHidden = false
            self.userImageView.isHidden = false
            self.myComment.isHidden = true
            self.myCreatedAt.isHidden = true
            
            self.partnerComment.attributedText = mutableAttributedString
            self.partnerCreatedAt.text =  dateFormatterForDateLabel(date: commentData.createdAt.dateValue())
            //コメントの横幅調整
            var width = frameWidthTextView(text:partnerComment.text!).width + 10
            //ユーザ名だけの横幅よりも小さかった場合（名前が2行に分割されて計算されたことがあったため追記）
            if width <= frameWidthTextView(text: userName).width {
                //幅をユーザ名の横幅にする
                width = frameWidthTextView(text: userName).width
            }
            self.partnerCommentWidthConstraint.constant = width
            //画像の表示
            setImageShow(userUid:commentData.uid)
        }

    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    //横幅計算
    private func frameWidthTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], context: nil)
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
                let myImageName = userData["myImageName"] as? String ?? ""
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
