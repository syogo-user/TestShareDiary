//
//  ProfileViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import FirebaseUI
import CLImageEditor

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLImageEditorDelegate{
    @IBOutlet weak var nickNameTextField: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var profileMessage: UITextView!
    @IBOutlet weak var imageChoiceButton: UIButton!
    @IBOutlet weak var changeProfileButton: UIButton!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var follower: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var lockImage: UIImageView!
    
    //画面遷移によってプロフィール画面を表示した場合に使用する変数 //nilのときはタブ遷移時
    var userData :UserPostData?

    var publicFlg = false //true:公開 false:非公開
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        self.profileMessage.backgroundColor = Const.darkColor
        self.line.backgroundColor = Const.navigationButtonColor        
        self.myImage.layer.cornerRadius = 100
        self.profileMessage.layer.cornerRadius = 15
        self.changeProfileButton.layer.cornerRadius = 15
        self.imageChoiceButton.layer.cornerRadius = 15
        self.changeProfileButton.addTarget(self, action: #selector(changeProfile(_:)), for: .touchUpInside)
        self.imageChoiceButton.addTarget(self, action: #selector(tapImageChoiceButton(_:)), for: .touchUpInside)
        self.closeButton.addTarget(self, action: #selector(closeProfile(_:)), for: .touchUpInside)
        self.follow.addTarget(self, action: #selector(tapFollow(_:)), for: .touchUpInside)
        self.follower.addTarget(self, action: #selector(tapFollower(_:)), for: .touchUpInside)
        //ボタンの設定
        buttonSet()
        //文字サイズをラベルの大きさに合わせて調整
        nickNameTextField.adjustsFontSizeToFitWidth = true
    }
    
    //ボタンの設定
    private func buttonSet(){
        //文字色
        self.imageChoiceButton.setTitleColor(UIColor.white, for: .normal)
        self.imageChoiceButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.changeProfileButton.setTitleColor(UIColor.white, for: .normal)
        self.changeProfileButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        // 角丸
        self.imageChoiceButton.layer.cornerRadius = changeProfileButton.bounds.midY
        self.changeProfileButton.layer.cornerRadius = changeProfileButton.bounds.midY
        //影
        self.imageChoiceButton.layer.shadowColor = Const.buttonStartColor.cgColor
        self.imageChoiceButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.imageChoiceButton.layer.shadowOpacity = 0.2
        self.imageChoiceButton.layer.shadowRadius = 10
        self.changeProfileButton.layer.shadowColor = Const.buttonStartColor.cgColor
        self.changeProfileButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.changeProfileButton.layer.shadowOpacity = 0.2
        self.changeProfileButton.layer.shadowRadius = 10
        // グラデーション
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageChoiceButton.bounds
        gradientLayer.cornerRadius = imageChoiceButton.bounds.midY
        gradientLayer.colors = [Const.buttonStartColor.cgColor, Const.buttonEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.imageChoiceButton.layer.insertSublayer(gradientLayer, at: 0)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = changeProfileButton.bounds
        gradientLayer2.cornerRadius = changeProfileButton.bounds.midY
        gradientLayer2.colors = [Const.buttonStartColor.cgColor, Const.buttonEndColor.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1, y: 1)
        self.changeProfileButton.layer.insertSublayer(gradientLayer2, at: 0)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        //この画面にはフォロー・フォロワー画面、検索画面、プロフィールタブからの画面遷移がある
        super.viewWillAppear(animated)
        self.nickNameTextField.text = ""
        self.profileMessage.text = ""
        self.follow.setTitle("フォロー：", for: .normal)
        self.follower.setTitle("フォロワー：", for: .normal)
                
        //戻るボタンの戻るの文字を削除　クローズボタンの表示・非表示
        if let nav = navigationController {
            //検索画面からプッシュ遷移（ナビゲーションがある＝プッシュ遷移）
            nav.navigationBar.topItem!.title = ""
            closeButton.isHidden = true
        } else {
            //フォロー・フォロワーのリストからモーダル(ナビゲーションがnil=モーダル遷移)
            closeButton.isHidden = false
        }
        
        guard  let myUid = Auth.auth().currentUser?.uid else { return}
        var uid :String
        if self.userData?.uid == myUid || self.userData == nil{
            //自分のプロフィールを表示
            //変更ボタンと写真の追加ボタンを表示にする
            imageChoiceButton.isHidden = false
            changeProfileButton.isHidden = false
            uid = myUid
        }else {
            //自分以外のプロフィールを表示
            //変更ボタンと写真の追加ボタンを非表示にする
            imageChoiceButton.isHidden = true
            changeProfileButton.isHidden = true
            guard let otherUid  = self.userData?.uid else {return}
            uid = otherUid
        }
        //自分もしくは自分以外の人のユーザ情報を取得
        let postUserRef = Firestore.firestore().collection(Const.users).document(uid)
        postUserRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                guard let document = querySnapshot!.data() else {return}
                self.nickNameTextField.text = document["userName"] as? String ?? ""

                let myImageName = document["myImageName"] as? String ?? ""
                let myFollow = document["follow"] as? [String] ?? []
                let myFollower = document["follower"] as? [String] ?? []
                let keyAccountFlg = document["keyAccountFlg"] as? Bool ?? true
                self.follow.setTitle("フォロー： \(myFollow.count)", for: .normal)
                self.follower.setTitle("フォロワー：\(myFollower.count)", for: .normal)
                //鍵画像の表示・非表示

                if keyAccountFlg {
                    //鍵画像表示　鍵アカウント
                    self.lockImage.isHidden = false//表示
                    //自分の表示の場合は表示するそれ以外は非公開と表示する
                    if self.userData?.uid == myUid || self.userData == nil{
                        self.profileMessage.text = document["profileMessage"] as? String ?? ""
                        self.publicFlg = true //公開
                    }else {
                        //自分以外の人を表示する場合
                        //プロフィールメッセージを変数に保持
                        let profileMessage = document["profileMessage"] as? String ?? ""
                        //ログインしている自分のフォローしている人を取得
                        let postMyUserRef = Firestore.firestore().collection(Const.users).document(myUid)
                        postMyUserRef.getDocument() {
                            (querySnapshot,error) in
                            if let error = error {
                                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                                self.publicFlg = false //非公開
                                return
                            } else {
                                guard let document = querySnapshot!.data() else {return}
                                //自分がフォローしている人の中に表示しようとしているuidがあるかを判定
                                let myFollow = document["follow"] as? [String] ?? []
                                if myFollow.firstIndex(of: uid) != nil{
                                    //フォローしている場合プロフィールを表示
                                    self.profileMessage.text = profileMessage
                                    self.publicFlg = true //公開
                                }else{
                                    //フォローしていない場合 非公開
                                    self.profileMessage.text = "【非公開】"
                                    self.publicFlg = false //非公開
                                }
                            }
                        }

                    }
                }else{
                    //鍵画像非表示　鍵アカウントではない
                    self.lockImage.isHidden = true//非表示
                    self.profileMessage.text = document["profileMessage"] as? String ?? ""
                    self.publicFlg = true //公開
                }
                
                //画像の取得
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(myImageName + ".jpg")
                //画像がなければデフォルトの画像表示
                if myImageName == "" {
                    self.myImage.image = UIImage(named: "unknown")
                }else{
                    //取得した画像の表示
                    self.myImage.sd_imageIndicator =
                        SDWebImageActivityIndicator.gray
                    self.myImage.sd_setImage(with: imageRef)
                }
            }
        }
        

    }
    //フォローボタン押下時
    @objc private func tapFollow(_ sender:UIButton){
        //公開・非公開
        if publicFlg{
            //公開
            var uid = ""
            if let userDataUid = self.userData?.uid {
                //nilでない場合 userDataのuidを渡す
                uid = userDataUid
            }else{
                //nilの場合 自分のユーザIDを渡す
                guard let myUid = Auth.auth().currentUser?.uid else {return}
                uid = myUid
            }
            
            let followFollowerListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowFollowerListTableViewController") as! FollowFollowerListTableViewController
            followFollowerListTableViewController.fromButton = Const.Follow
            followFollowerListTableViewController.fromProfileUid = uid //uidを渡す
            followFollowerListTableViewController.modalPresentationStyle = .fullScreen
            self.present(followFollowerListTableViewController, animated: true, completion: nil)
        }else{
            //非公開
            let dialog = UIAlertController(title: "【非公開】です", message: nil, preferredStyle: .actionSheet)
            //OKボタン
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(dialog, animated: true, completion: nil)
        }
        
        
        
    }
    //フォローボタン押下時
    @objc private func tapFollower(_ sender:UIButton){
        //公開・非公開
        if publicFlg{
            //公開
            var uid = ""
            if let userDataUid = self.userData?.uid {
                //nilでない場合 userDataのuidを渡す
                uid = userDataUid
            }else{
                //nilの場合 自分のユーザIDを渡す
                guard let myUid = Auth.auth().currentUser?.uid else {return}
                uid = myUid
            }
            let followFollowerListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowFollowerListTableViewController") as! FollowFollowerListTableViewController
            followFollowerListTableViewController.fromButton = Const.Follower
            followFollowerListTableViewController.fromProfileUid = uid//uidを渡すb
            followFollowerListTableViewController.modalPresentationStyle = .fullScreen
            self.present(followFollowerListTableViewController, animated: true, completion: nil)
        }else{
            //非公開
            let dialog = UIAlertController(title: "【非公開】です", message: nil, preferredStyle: .actionSheet)
            //OKボタン
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(dialog, animated: true, completion: nil)
        }

    }
//    private func publicJudg() -> Bool{
//        //自分のフォローしている人を配列で取得
//        
//        
//        //相手が鍵でない場合　->true
//        //相手が鍵の場合
//             //フォローしている人の場合 -> true
//             //フォローしている人でない場合
//                    //自分のUIDの場合　-> true
//                    //自分のUIDではない場合　->false
//        
//        return
//    }

    @objc private func tapImageChoiceButton(_ sender:UIButton){
        //写真選択
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
            //CLImageEditorにimageを渡して加工画面を起動する
            let editor = CLImageEditor(image:image)!
            editor.delegate = self
            picker.present(editor,animated: true,completion: nil)
        }
    }
    //CLImageEditorで加工が終わった時に呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        myImageSave(image:image)
        self.dismiss(animated: true, completion: nil)
    }
    
    //fireStorageに写真を保存
    private func myImageSave (image:UIImage){
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        var myImageNumber = 0
        var myImageName = ""
        //imageNumber取得
        let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)

        postUserRef.getDocument{(querySnapshot,error) in
            if let error = error {
                print("DEBUG:imageNumberの取得に失敗しました。\(error)")
            }
            guard let data  = querySnapshot?.data() else { return}
            var oldImageName = ""
            if let myImageNameFirebase = data["myImageName"] as? String {
                //myImageNameから番号だけを取得する
                myImageNumber = self.getNumber(myImageName:myImageNameFirebase)
                oldImageName = myImageNameFirebase
            }
            //修正　異なる写真が表示される
            myImageNumber = myImageNumber + 1
            
            myImageName = myUid + "\(myImageNumber)"
            
            //写真を保存し表示する
            self.saveImageFirebase(myImageNumber:myImageNumber, myImageName:myImageName, image:image, myUid:myUid,oldImageName:oldImageName)
 
        }
        
    }
    //myImageNameからmyImageNumberを切り出す
    private func getNumber(myImageName:String) -> Int {
        var myImageNumber = 0
        var start:String.Index = myImageName.startIndex
        start = myImageName.index(start,offsetBy: 28)
        let end :String.Index = myImageName.endIndex
        let myImageNumberString = String(myImageName[start..<end])
        myImageNumber = Int(myImageNumberString) ?? 0
        
        return myImageNumber
    }
    
    //写真をfireStorageに保存し表示する
    private func saveImageFirebase (myImageNumber:Int,myImageName:String,image:UIImage,myUid:String,oldImageName:String){
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(myImageName + ".jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        //HUDで処理中を表示
        SVProgressHUD.show()
        imageRef.putData(imageData,metadata: metadata){ (metadata,error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
            }
            //写真のファイル名をusersに保存する
            let data = [
                "myImageName":myImageName
            ]
            let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)
            postUserRef.updateData(data)
            //保存した写真の表示
            self.myImage.sd_imageIndicator =
                SDWebImageActivityIndicator.gray
            self.myImage.sd_setImage(with: imageRef)
            
            //HUDを消す
             SVProgressHUD.dismiss()
            //変更前の写真データを削除する
            self.imageDelete(oldImageName:oldImageName)
        }
    }
    
    //写真の削除
    private func imageDelete(oldImageName:String) {
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(oldImageName + ".jpg")
        imageRef.delete{
            error in
            if let  error = error {
                print("DEBUG:\(error)")
            }else {
                print("DEBUG:\(oldImageName)を削除しました")
            }
        }
    }

    
    //プロフィール変更画面に遷移
    @objc private func changeProfile(_ sender:UIButton){
        let profileEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileEditViewController") as! ProfileEditViewController
        self.navigationController?.pushViewController(profileEditViewController, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func closeProfile(_ sender:UIButton){
        //画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
}
