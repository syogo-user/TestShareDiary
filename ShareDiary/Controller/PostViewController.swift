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
    
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBOutlet weak var postPicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //キーボード表示
        self.inputTextView.becomeFirstResponder()

        
        //ツールバーのインスタンスを作成
        let toolBar = UIToolbar()
        //ツールバーに配置するアイテムのインスタンスを作成
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let imageButton:UIBarButtonItem = UIBarButtonItem(title:"画像", style: UIBarButtonItem.Style.plain ,target: self, action: #selector(tapImageButton(_:)))
        //アイテムを配置
        toolBar.setItems([imageButton,flexibleItem],animated: true)

        //ツールバーのサイズを指定
        toolBar.sizeToFit()
        
        //デリゲートを設定
        inputTextView.delegate = self
        inputTextView.inputAccessoryView = toolBar
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
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            
            //選択した画像を画面のimageに設定
            postPicture.image = image
            
            //変数に写真を設定
            imagePicture = image
            print("DEBUG_PRINT: image = \(image)")
            self.dismiss(animated: true, completion: nil)
        }
    }
        
    @IBAction func postButton(_ sender: Any) {
        print("投稿されました")
        // 画像をJPEG形式に変換する
        let imageData = imagePicture.jpegData(compressionQuality: 0.75)
        // 画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
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
                }
            }
        }
        
        guard let myUid = Auth.auth().currentUser?.uid else {
            return
        }
        // FireStoreに投稿データを保存する
        let documentUserName = Auth.auth().currentUser?.displayName
        let postDic = [
            "uid":myUid,
            "documentUserName": documentUserName!,
            "content": self.inputTextView.text!,
            "date": FieldValue.serverTimestamp(),
            ] as [String : Any]
        postRef.setData(postDic)
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        // 投稿処理が完了したので先頭画面に戻る
        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    
        

}
