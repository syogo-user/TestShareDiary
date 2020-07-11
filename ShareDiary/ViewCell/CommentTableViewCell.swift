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

    @IBOutlet weak var comment: UITextView!
    //    @IBOutlet weak var comment: UITextView!

   
    @IBOutlet weak var commentWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var createdAt: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        comment.layer.cornerRadius = 20
        userImageView.layer.cornerRadius = 25

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCommentData(_ commentData:CommentData){
        self.comment.text = commentData.message
        self.createdAt.text =  dateFormatterForDateLabel(date: commentData.createdAt.dateValue())
        //コメントの横幅調整
        let width = frameWidthTextView(text:comment.text!).width + 10
        commentWidthConstraint.constant = width
        //画像の表示
        setImageShow(userUid:commentData.uid)

        
        
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    //横幅計算
    private func frameWidthTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func setImageShow(userUid:String){
        let postRef = Firestore.firestore().collection(Const.users).document(userUid)
        postRef.getDocument{
            (document ,error) in
            if error != nil {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。")
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
        guard let userImageName = userImageName else {return}
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(userImageName + ".jpg")
            //取得した画像の表示
            self.userImageView.sd_imageIndicator =
                SDWebImageActivityIndicator.gray
            self.userImageView.sd_setImage(with: imageRef)
        
    }
}
