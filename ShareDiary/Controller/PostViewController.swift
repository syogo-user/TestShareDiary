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

class PostViewController: UIViewController ,UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var imagePicture :UIImage = UIImage()
    
    //投稿ボタン
    @IBOutlet weak var postButton: UIButton!
    //キャンセルボタン
    @IBOutlet weak var cancelButton: UIButton!
    
    //    var backgroundColor :UIColor = .white
    var backgroundColorArrayIndex = 0
    //入力している文字の色
    var typeingColor = UIColor.black
    //選択された日付（デフォルトは今日）
    var selectDate = Date()
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var inputTextViewConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet weak var postPicture: UIImageView!
    
    
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

        //スクロールビュー
         let scrollView = UIScrollView()
        scrollView.frame = self.view.bounds
        scrollView.contentSize  = CGSize(width:self.view.frame.width,height: 1000)
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        self.view.addSubview(scrollView)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //投稿ボタンを非活性
        if inputTextView.text == ""{
         postButton.isEnabled = false
        }
        //背景色を変更する
//        self.view.backgroundColor = backgroundColor
        print(getDay(selectDate))
        print(backgroundColorArrayIndex)
//        self.view.layer.removeFromSuperlayer()
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.view.bounds
            //遷移前の画面から受け取ったIndexで色を決定する
            let color = Const.color[backgroundColorArrayIndex]
            let color1 = color["startColor"] ?? UIColor().cgColor
            let color2 = color["endColor"] ?? UIColor().cgColor
            //３色にするか迷う
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
        print("画像選択ボタンがタップされました")
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    @objc func tapColorButton(_ sender:UIButton){
        print("背景色選択ボタンがタップされました")
        let colorChoiceViewController = self.storyboard?.instantiateViewController(withIdentifier: "ColorChoice")
        colorChoiceViewController?.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(colorChoiceViewController, animated: true)
        self.present(colorChoiceViewController!, animated: true, completion: nil)
    }
    
    @objc func tapDateButton(_ sender:UIButton){
        print("日付選択ボタンがタップされました")
        let dateSelectViewController = self.storyboard?.instantiateViewController(withIdentifier:"DateSelect") 
        dateSelectViewController?.modalPresentationStyle = .fullScreen
        self.present(dateSelectViewController!,animated: true,completion:nil)
//        self.navigationController?.pushViewController(dateSelectViewController, animated: true)
    }
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            
            //選択した画像を画面のimageに設定
            //imageViewの初期化
            let imageView = UIImageView(image:image)

            //スクリーンの縦横サイズを取得
            let screenWidth :CGFloat = view.frame.size.width
            let screenHeight :CGFloat = view.frame.size.height / 2
            
            //画像の縦横サイズを取得
            let imageWidth :CGFloat = image.size.width
            let imageHeight :CGFloat = image.size.height
            
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:30,y:500,width: imageWidth * scale,height: imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            //画像の中心を設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/3 * 2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            
            
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: self.inputTextView.bottomAnchor, constant:20.0).isActive = true
            
            imageView.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale ).isActive = true
            
            //変数に写真を設定
            imagePicture = image
            print("DEBUG_PRINT: image = \(image)")
            self.dismiss(animated: true, completion: nil)
        }
    }
        
    @IBAction func postButton(_ sender: Any) {

        //テキストが空の時は投稿できないようにする
        guard self.inputTextView.text != "" else {return}

        //HUD
        SVProgressHUD.show()
        // 画像をJPEG形式に変換する
        let imageData = imagePicture.jpegData(compressionQuality: 0.75)
        // 画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        
        guard let myUid = Auth.auth().currentUser?.uid else {
            return
        }
        let documentUserName = Auth.auth().currentUser?.displayName
        let strDate = dateFormat(date:selectDate)
        
        //投稿するデータをまとめる
        let postDic = [
            "uid":myUid,
            "documentUserName": documentUserName!,
            "content": self.inputTextView.text!,
            "selectDate":strDate,
            "date": FieldValue.serverTimestamp(),
            "backgroundColorIndex":self.backgroundColorArrayIndex,
            ] as [String : Any]
        // Storageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        if let imageData = imageData {
            imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    // 画像のアップロード失敗
                    print(error!)
                    SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                    // 投稿処理をキャンセルし、先頭画面に戻る
                    UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                    return
                }else {
                    //写真のアップロード成功
                    // FireStoreに投稿データを保存する
                    postRef.setData(postDic)
                    
                    SVProgressHUD.dismiss()
                    //先頭画面に戻る
                    UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                
            }
            
        } else {
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
//        self.inputTextView.translatesAutoresizingMaskIntoConstraints = true
//        self.inputTextView.sizeToFit()
//        self.inputTextView.isScrollEnabled = true
//        let resizedHeight = self.inputTextView.frame.size.height
//        self.inputTextViewConstraintHeight.constant = resizedHeight
        //@x: 20（左のマージン）
        //@y: 60（上のマージン）
        //@width: self.view.frame.width - 40(左右のマージン)
        //@height: sizeToFit()後の高さ
//        self.inputTextView.frame = CGRect(x: 20, y: 120, width: self.view.frame.width - 40, height: resizedHeight)

    }
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    //Dateを時間なしの文字列に変換
    func dateFormat(date:Date?) -> String {
        var strDate:String = ""
        
        if let day = date {
            let format  = DateFormatter()
            format.locale = Locale(identifier: "ja_JP")
            format.dateStyle = .short
            format.timeStyle = .none
            strDate = format.string(from:day)
        }
        return strDate
    }
}
