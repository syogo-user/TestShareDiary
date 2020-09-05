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

protocol PostTableViewCellDelegate {
    func imageTransition(_ sender:UITapGestureRecognizer)
}


class PostTableViewCell: UITableViewCell {
        
    @IBOutlet weak var postUserImageView: UIImageView!
    @IBOutlet weak var postUserLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentsView: GradationView!
    @IBOutlet weak var shadowView: UIView!
    
    //グラデーションレイヤー
//    var gradientLayer = CAGradientLayer()
    //投稿写真の選択された枚数
    var imageMaxNumber = 0
    //ドキュメントID
    var postDocumentId = ""
    //デリゲート
    var postTableViewCellDelegate :PostTableViewCellDelegate?
    //写真の配置に使用する変数を定義
    let xPosition :CGFloat  = 30.0 //x
    let yPosition :CGFloat  = 500.0 //y
    let pictureWidth :CGFloat = 828 //幅
    let pictureHeight :CGFloat = 550 //高さ
    let constantValue1 :CGFloat = 20.0 //制約
    let constantValue2 :CGFloat = 50.0 //制約
    let adjustmentValue :CGFloat = 15 //調整
    let contentLabelBottomConstraint1:CGFloat = 240 //contentLabelから下の長さ
    let contentLabelBottomConstraint2:CGFloat = 390 //contentLabelから下の長さ
    let contentLabelBottomConstraint3:CGFloat = 350 //contentLabelから下の長さ
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.contentsView.layer.insertSublayer(gradientLayer, at: 0)
        self.postUserImageView.layer.cornerRadius = 20
        self.contentsView.layer.cornerRadius = 25
        self.contentsView.layer.masksToBounds = true
        //影
        self.shadowView.backgroundColor = .clear 
//        self.shadowView.layer.masksToBounds = false
//        self.shadowView.layer.shadowColor = UIColor.black.cgColor
//        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 10) // 影の方向(ここでは右下)
//        self.shadowView.layer.shadowOpacity = 0.5 // 影の濃さ
//        self.shadowView.layer.shadowRadius = 10 // 影のぼかし量
//        self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
//        self.shadowView.layer.shouldRasterize = true
//        shadowView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    override func layoutSubviews() {
        //描画されるときに呼び出される
        super.layoutSubviews()
        contentsView.frame = self.bounds
//        gradientLayer.frame = self.contentsView.layer.bounds
        //写真を削除
        self.removeUIImageSubviews(parentView: self)
        //投稿写真の枚数分ループする (1,2,3,4)
        //投稿された写真の表示
        if imageMaxNumber > 0{
            for i in 1...imageMaxNumber{
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postDocumentId + "\(i).jpg")
                imageSet(imageRef:imageRef ,index: i, maxCount: imageMaxNumber)
            }
        }
    }
    override func updateConstraints() {
        super.updateConstraints()
    }
        
    //image:選択した写真,index：選択した何枚目,maxCount：選択した全枚数
    private func imageSet(imageRef:StorageReference,index:Int,maxCount:Int){
        //imageViewの初期化
        let imageView = UIImageView()
        //タップイベント追加
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTransition(_:))))
        //画像のアスペクト比　sacaleAspectFil：写真の比率は変わらない。imageViewの枠を超える。cliptToBounds をtrueにしているため枠は超えずに、比率も変わらない。
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        //スクリーンの縦横サイズを取得
        let screenWidth :CGFloat = self.frame.size.width
        let screenHeight :CGFloat = self.frame.size.height / 2
        
        //画像の縦横サイズを取得
        let imageWidth :CGFloat = pictureWidth
        let imageHeight :CGFloat = pictureHeight
        
        //画像の枚数によってサイズと配置場所を設定する
        switch maxCount {
        case 1:
            //画像１枚の場合
            imageCount1(imageRef:imageRef,imageView: imageView,screenWidth: screenWidth,screenHeight: screenHeight,imageWidth: imageWidth,imageHeight: imageHeight)
        case 2:
            //画像２枚の場合
            imageCount2(imageRef:imageRef,imageView: imageView,screenWidth: screenWidth,screenHeight: screenHeight,imageWidth: imageWidth,imageHeight: imageHeight,index:index)
        case 3:
            //画像３枚の場合
            imageCount3(imageRef:imageRef,imageView: imageView,screenWidth: screenWidth,screenHeight: screenHeight,imageWidth: imageWidth,imageHeight: imageHeight,index:index)
        case 4:
            //画像４枚の場合
            imageCount4(imageRef:imageRef,imageView: imageView,screenWidth: screenWidth,screenHeight: screenHeight,imageWidth: imageWidth,imageHeight: imageHeight,index:index)

        default: break
            
        }
        
    }
    //写真を削除
    private func removeUIImageSubviews(parentView: UIView){
        let subviews = parentView.subviews
        for subview in subviews {
            if let subview = subview as? UIImageView{
                //UIImageViewが存在していたら削除する
                subview.removeFromSuperview()
            }
        }
    }
    //フルサイズの写真をモーダルで表示
    @objc func imageTransition(_ sender:UITapGestureRecognizer){
        postTableViewCellDelegate?.imageTransition(sender)
    }
    
    private func imageCount1(imageRef:StorageReference,imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat){
        //画像サイズをスクリーンサイズ幅に合わせる
        let scale:CGFloat = screenWidth/imageWidth
        let rect :CGRect = CGRect(x:xPosition,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = rect
        imageView.sd_setImage(with: imageRef)
        
        // UIImageViewのインスタンスをビューに追加
        self.addSubview(imageView)
        //AutoLayout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
        imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant:constantValue1).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale  ).isActive = true
    }
    
    private func imageCount2(imageRef:StorageReference,imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat,index:Int){
        switch index {
        case 1:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
            imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant:constantValue2).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 2:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition + (imageWidth * scale) ,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
            imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant:constantValue2).isActive = true
            imageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        default:
            break
        }
        
    }
    private func imageCount3(imageRef:StorageReference,imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat,index:Int){
        switch index {
        case 1:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
            imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant:constantValue1).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2).isActive = true
        case 2:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition + (imageWidth * scale) ,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
            imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant:constantValue1).isActive = true
            imageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 3:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition + (imageHeight * scale / 2) ,width: imageWidth * scale  ,height : imageHeight * scale / 2)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
            imageView.topAnchor.constraint(equalTo:contentLabel.bottomAnchor, constant:constantValue1 + (imageHeight * scale / 2) ).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 3 * 2  ).isActive = true
        default:
            break
        }
    }
    private func imageCount4(imageRef:StorageReference,imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat,index:Int){
        switch index {
        case 1:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
            imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant:constantValue1).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 2:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition + (imageWidth * scale) ,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
            imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant:constantValue1).isActive = true
            imageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 3:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition + (imageHeight * scale) ,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
            imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant:constantValue1 + (imageHeight * scale / 2)).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 4:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition + (imageWidth * scale) ,y:yPosition + (imageHeight * scale) ,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から「constant」pt下
            imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant:constantValue1 + (imageHeight * scale / 2)).isActive = true
            imageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        default:
            break
        }
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
        if let selectDate = postData.selectDate {
            self.dateLabel.text = selectDate
        }
        // コンテントの表示
        self.contentLabel.text = ""
        if let content = postData.content{
            self.contentLabel.text! = content
        }

        imageMaxNumber  = postData.contentImageMaxNumber
        postDocumentId = postData.id

        if imageMaxNumber == 2 {
            //写真の枚数が2枚のとき
            contentLabelBottomConstraint.constant = contentLabelBottomConstraint1
        } else if imageMaxNumber == 3{
            contentLabelBottomConstraint.constant = contentLabelBottomConstraint2
        }else {
            contentLabelBottomConstraint.constant = contentLabelBottomConstraint3
        }
        //プロフィール写真を設定
        setPostImage(uid:postData.uid)
        //背景色を設定
        contentsView.setBackgroundColor(colorIndex:postData.backgroundColorIndex)
    }
    
    private func setPostImage(uid:String){
        let userRef = Firestore.firestore().collection(Const.users).document(uid)
        
        userRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
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
//    private func setBackgroundColor(colorIndex:Int){
//        //背景色を変更する
//        let color = Const.color[colorIndex]
//        let color1 = color["startColor"] ?? UIColor.white.cgColor
//        let color2 = color["endColor"] ?? UIColor.white.cgColor
//        //CAGradientLayerにグラデーションさせるカラーをセット
//        gradientLayer.colors = [color1,color2]
//        gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
//        gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
//    }


}
