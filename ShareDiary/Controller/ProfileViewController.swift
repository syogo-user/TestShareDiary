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
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var imageChoiceButton: UIButton!
    @IBOutlet weak var changeProfileButton: UIButton!
    @IBOutlet weak var follow: UILabel!
    @IBOutlet weak var follower: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myImage.layer.cornerRadius = 125
        logoutButton.layer.cornerRadius = 15
        profileMessage.layer.cornerRadius = 15
        changeProfileButton.addTarget(self, action: #selector(changeProfile), for: .touchUpInside)
        changeProfileButton.layer.cornerRadius = 15
        self.view.backgroundColor = Const.darkColor
        imageChoiceButton.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nickNameTextField.text = ""
        self.profileMessage.text = ""
        self.follow.text = "フォロー："
        self.follower.text = "フォロワー："
        
        guard  let myUid = Auth.auth().currentUser?.uid else { return}
        //firebaseから自分のユーザ情報の取得
        let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)
        postUserRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                guard let document = querySnapshot!.data() else {return}
                self.nickNameTextField.text = document["userName"] as? String ?? ""
                self.profileMessage.text = document["profileMessage"] as? String ?? ""
                let myImageName = document["myImageName"] as? String ?? ""
                let myFollow = document["follow"] as? [String] ?? []
                let myFollower = document["follower"] as? [String] ?? []
                self.follow.text = "フォロー： \(myFollow.count)"
                self.follower.text = "フォロワー：\(myFollower.count)"
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
    
    @IBAction func imageChoiceAction(_ sender: Any) {
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
                print("imageNumberの取得に失敗しました。\(error)")
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
                print("\(oldImageName)を削除しました")
            }
        }
    }
    //ログアウトボタン押下時
    @IBAction func handleLogout(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        loginViewController?.modalPresentationStyle = .fullScreen
        self.present(loginViewController!, animated: true, completion: nil)
        // ログイン画面から戻ってきた時のためにタイムライン画面（index = 1）を選択している状態にしておく
        tabBarController?.selectedIndex = 1
        tabBarController?.selectedIndex = 0
    }
    
    //プロフィール変更画面に遷移
    @objc private func changeProfile(){
        let profileEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileEditViewController") as! ProfileEditViewController
        self.navigationController?.pushViewController(profileEditViewController, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}
