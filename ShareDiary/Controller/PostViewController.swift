//
//  PostViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/26.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import SVProgressHUD
import DKImagePickerController


class PostViewController: UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var imagePictureArray :[UIImage] = []
    //投稿ボタン
    @IBOutlet weak var postButton: UIButton!
    //キャンセルボタン
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var backgroundColorArrayIndex = 0
    //入力している文字の色
    var typeingColor = UIColor.black
    //選択された日付（デフォルトは今日）
    var selectDate = Date()
    //写真の配置に使用する変数を定義
    let xPosition :CGFloat  = 30.0 //x
    let yPosition :CGFloat  = 500.0 //y
    let pictureWidth :CGFloat = 828 //幅
    let pictureHeight :CGFloat = 550 //高さ
    let constantValue1 :CGFloat = 20.0 //制約
    let constantValue2 :CGFloat = 50.0 //制約
    let adjustmentValue :CGFloat = 15 //調整
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectDate = Date()
        typeingColor = inputTextView.tintColor

        //キーボード表示
        self.inputTextView.becomeFirstResponder()
        //ツールバーのインスタンスを作成
        let toolBar = UIToolbar()
        //ツールバーに配置するアイテムのインスタンスを作成
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let imageButton:UIBarButtonItem = UIBarButtonItem(title:"画像", style: UIBarButtonItem.Style.plain ,target: self, action: #selector(tapImageButton(_:)))
        let colorButton:UIBarButtonItem = UIBarButtonItem(title:"背景色", style: UIBarButtonItem.Style.plain ,target: self, action: #selector(tapColorButton(_:)))
        let dateButton:UIBarButtonItem = UIBarButtonItem(title:"日付",style: UIBarButtonItem.Style.plain,target:self,action:#selector(tapDateButton(_:)))
        //アイテムを配置
        toolBar.setItems([imageButton,flexibleItem,dateButton,flexibleItem,colorButton],animated: true)
        //ツールバーのサイズを指定
        toolBar.sizeToFit()
        //デリゲートを設定
        inputTextView.delegate = self
        inputTextView.inputAccessoryView = toolBar
        cancelButton.addTarget(self, action: #selector(tapCancelButton(_:)), for: .touchUpInside)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //投稿ボタンを非活性
        if inputTextView.text == ""{
            postButton.isEnabled = false
        }
        print("DEBUG:",backgroundColorArrayIndex)
        //選択された日付をラベルに表示(初期表示は本日)
        dateLabel.text = CommonDate.dateFormat(date:selectDate)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        //遷移前の画面から受け取ったIndexで色を決定する
        let color = Const.color[backgroundColorArrayIndex]
        let color1 = color["startColor"] ?? UIColor().cgColor
        let color2 = color["endColor"] ?? UIColor().cgColor
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1,color2]
        gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
        gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
        //サブレイヤーがある場合は削除してからinsertSublayerする
        if self.view.layer.sublayers![0] is CAGradientLayer{
            self.view.layer.sublayers![0].removeFromSuperlayer()
            self.view.layer.insertSublayer(gradientLayer, at: 0)
        }else {
            self.view.layer.insertSublayer(gradientLayer, at:0)
        }        
        //文字の色変化
        typeingColor  = UIColor.gray
        inputTextView.textColor = typeingColor
        //テキストにフォーカスを当てる
        inputTextView.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }
    
    @objc func tapCancelButton(_ sender:UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tapImageButton(_ sender:UIButton){
        
        let pickerController = ImageSelectViewController()
        //        pickerController.maxSelectableCount = 4
        
        //imagePictureArray配列を初期化
        self.imagePictureArray = []
        
        //写真がviewにある場合は削除
        removeUIImageSubviews(parentView:self.view)
        
        pickerController.didSelectAssets = {
            [unowned self] (assets:[DKAsset])in
            var index = 1
            //選択した画像を取得
            for asset in assets{
                asset.fetchFullScreenImage(completeBlock: {(image,info) in
                    //画像を設定
                    self.imageSet(image: image,index: index,maxCount:assets.count)
                    index = index + 1
                })
                
            }
        }
        self.present(pickerController, animated: true) {}
    }
    //image:選択した写真,index：選択した何枚目,maxCount：選択した全枚数
    private func imageSet(image:UIImage?,index:Int,maxCount:Int){
        guard let image = image else{return}
        //写真を配列に追加★
        self.imagePictureArray.append(image)
        
        //imageViewの初期化
        let imageView = UIImageView(image:image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        //スクリーンの縦横サイズを取得
        let screenWidth :CGFloat = view.frame.size.width
        let screenHeight :CGFloat = view.frame.size.height / 2
        //画像の縦横サイズを取得
        let imageWidth :CGFloat = pictureWidth
        let imageHeight :CGFloat = pictureHeight
        //画像の枚数によってサイズと配置場所を設定する
        switch maxCount {
        case 1:
            //画像１枚の場合
            imageCount1(imageView: imageView,screenWidth: screenWidth,screenHeight: screenHeight,imageWidth: imageWidth,imageHeight: imageHeight)
        case 2:
            //画像２枚の場合
            imageCount2(imageView: imageView,screenWidth: screenWidth,screenHeight: screenHeight,imageWidth: imageWidth,imageHeight: imageHeight,index:index)
        case 3:
            //画像３枚の場合
            imageCount3(imageView: imageView,screenWidth: screenWidth,screenHeight: screenHeight,imageWidth: imageWidth,imageHeight: imageHeight,index:index)
        case 4:
            //画像４枚の場合
            imageCount4(imageView: imageView,screenWidth: screenWidth,screenHeight: screenHeight,imageWidth: imageWidth,imageHeight: imageHeight,index:index)
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
    
    private func imageCount1(imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat){
        //画像サイズをスクリーンサイズ幅に合わせる
        let scale:CGFloat = screenWidth/imageWidth
        // ImageView frame をCGRectで作った矩形に合わせる
        let rect :CGRect = CGRect(x:xPosition,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
        imageView.frame = rect
        //画像の中心を設定
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)
        //AutoLayout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
        imageView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant:constantValue1).isActive = true
        imageView.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale  ).isActive = true
    }
    
    private func imageCount2(imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat,index:Int){
        switch index {
        case 1:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            //画像の中心を設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant:constantValue1).isActive = true
            imageView.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 2:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition + (imageWidth * scale) ,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            //画像の中心を設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant:constantValue1).isActive = true
            imageView.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        default:
            break
        }
        
    }
    private func imageCount3(imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat,index:Int){
        switch index {
        case 1:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            //画像の中心を設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant:constantValue1).isActive = true
            imageView.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2).isActive = true
        case 2:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition + (imageWidth * scale) ,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            //画像の中心を設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant:constantValue1).isActive = true
            imageView.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 3:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition + (imageHeight * scale / 2) ,width: imageWidth * scale  ,height : imageHeight * scale / 2)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo:inputTextView.bottomAnchor, constant:constantValue1 + (imageHeight * scale / 2) ).isActive = true
            imageView.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 3 * 2  ).isActive = true
        default:
            break
        }
    }
    private func imageCount4(imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat,index:Int){
        switch index {
        case 1:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            //画像の中心を設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant:constantValue1).isActive = true
            imageView.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 2:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition + (imageWidth * scale) ,y:yPosition,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            //画像の中心を設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant:constantValue1).isActive = true
            imageView.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 3:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition,y:yPosition + (imageHeight * scale) ,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            //画像の中心を設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant:constantValue1 + (imageHeight * scale / 2)).isActive = true
            imageView.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 4:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:xPosition + (imageWidth * scale) ,y:yPosition + (imageHeight * scale) ,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            //画像の中心を設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant:constantValue1 + (imageHeight * scale / 2)).isActive = true
            imageView.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - adjustmentValue ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        default:
            break
        }
    }
    
    
    @objc func tapColorButton(_ sender:UIButton){
        print("DEBUG:背景色選択ボタンがタップされました")
        let colorChoiceViewController = self.storyboard?.instantiateViewController(withIdentifier: "ColorChoiceViewController")
        colorChoiceViewController?.modalPresentationStyle = .fullScreen
        self.present(colorChoiceViewController!, animated: true, completion: nil)
    }
    
    @objc func tapDateButton(_ sender:UIButton){
        print("DEBUG:日付選択ボタンがタップされました")
        let dateSelectViewController = self.storyboard?.instantiateViewController(withIdentifier:"DateSelectViewController")
        dateSelectViewController?.modalPresentationStyle = .fullScreen
        self.present(dateSelectViewController!,animated: true,completion:nil)
    }
    //投稿ボタン押下時
    @IBAction func postButton(_ sender: Any) {
        
        //連續タップ防止のために一度ボタンを非活性とする
        postButton.isEnabled = false
        
        //テキストが空の時は投稿できないようにする
        guard self.inputTextView.text != "" else {return}
        
        //HUD
        SVProgressHUD.show()
        
        // 画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        
        
        guard let myUid = Auth.auth().currentUser?.uid else {
            return
        }
        let documentUserName = Auth.auth().currentUser?.displayName
        let strDate = CommonDate.dateFormat(date:selectDate)
        
        //投稿するデータをまとめる
        let postDic = [
            "uid":myUid,
            "documentUserName": documentUserName!,
            "content": self.inputTextView.text!,
            "selectDate":strDate,
            "date": FieldValue.serverTimestamp(),
            "backgroundColorIndex":self.backgroundColorArrayIndex,
            "contentImageMaxNumber":imagePictureArray.count,
            ] as [String : Any]
        // Storageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        
        if imagePictureArray.count > 0 {
            var fileNumber = 1
            //投稿する写真を選択している場合
            for imagePicture in imagePictureArray.enumerated() {
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + "\(fileNumber).jpg")
                // 画像をJPEG形式に変換する
                let imageData = imagePicture.element.jpegData(compressionQuality: 0.75)
                if let imageData = imageData {
                    imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                        if error != nil {
                            // 画像のアップロード失敗
                            print("DEBUG:\(error!)")
                            SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                            // 投稿処理をキャンセルし、先頭画面に戻る
                            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                            return
                        }else {
                            //写真のアップロード成功
                            // FireStoreに投稿データを保存する
                            postRef.setData(postDic)
                            
                            
                            //配列の最後になったら
                            if imagePicture.offset == self.imagePictureArray.count - 1 {
                                SVProgressHUD.dismiss()
                                //先頭画面に戻る
                                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                            }
                        }
                        
                    }
                }
                fileNumber  = fileNumber + 1
            }
        }else{
            // FireStoreに投稿データを保存する
            //写真を投稿しない場合
            postRef.setData(postDic)
            SVProgressHUD.dismiss()
            //先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
            
        }
    }
    //テキストを入力すると呼び出される
    func textViewDidChange(_ textView: UITextView) {
        //テキストが空の時は投稿ボタンを非活性とする
        if inputTextView.text == "" {
            postButton.isEnabled = false
        }else{
            postButton.isEnabled = true
        }
    }

}


