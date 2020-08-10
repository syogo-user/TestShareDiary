//
//  DitailViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
class DitailViewController: UIViewController {
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeUserButton: UIButton!
    @IBOutlet weak var diaryDate: UILabel!
    @IBOutlet weak var diaryText: UITextView!
    @IBOutlet weak var postDeleteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var postData :PostData?
    var commentData : [CommentData] = [CommentData]()
    private let contentInset :UIEdgeInsets = .init(top: 0, left: 0, bottom: 100, right: 0)
    private let indicateInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 100, right: 0)
    
    private lazy var inputTextView : InputTextView = {
        let view = InputTextView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "CommentTableViewCell", bundle:nil)
        tableView.register(nib, forCellReuseIdentifier: "CommentTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        //いいねボタンのアクションを設定
        likeButton.addTarget(self, action:#selector(likeButton(_:forEvent:)), for: .touchUpInside)
        
        //戻るボタンの戻るの文字を削除
        navigationController!.navigationBar.topItem!.title = ""
        self.imageView.layer.cornerRadius = 30
        
        guard let post = postData else {return}
        //画面項目を設定
        contentSet(post:post)
        
        //自分のuidではなかった時は削除ボタンを非表示
        if post.uid != Auth.auth().currentUser?.uid {
            self.postDeleteButton.isHidden = true//非表示
            self.postDeleteButton.isEnabled = false//非活性
        }else {
            self.postDeleteButton.isHidden = false//表示
            self.postDeleteButton.isEnabled = true//活性
        }
        //削除ボタン押下時
        postDeleteButton.addTarget(self, action: #selector(postDelete(_:)), for: .touchUpInside)
        //likeUserButton押下時
        likeUserButton.addTarget(self, action: #selector(likeUserShow(_:)), for: .touchUpInside)
        //テーブルビューの表示
        tableViewSet()
        //スクロールでキーボードをしまう
        self.tableView.keyboardDismissMode = .interactive
        setupNotification()
        
    }
    
    
    
    //image:選択した写真,index：選択した何枚目,maxCount：選択した全枚数
    private func imageSet(imageRef:StorageReference,index:Int,maxCount:Int){
        //        guard let image = image else{return}
        
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
        let screenWidth :CGFloat = self.view.frame.width
        let screenHeight :CGFloat = self.view.frame.height / 2
        
        //画像の縦横サイズを取得
        let imageWidth :CGFloat = 828
        let imageHeight :CGFloat = 550
        
        
        
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
        //            imageCount3(imageView: imageView,screenWidth: screenWidth,screenHeight: screenHeight,imageWidth: imageWidth,imageHeight: imageHeight,index:index)
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
        //画面遷移TODO
        //タップしたUIImageViewを取得
        let tappedImageView = sender.view! as! UIImageView
        //  UIImage を取得
        let tappedImage = tappedImageView.image!
        
        let fullsizeImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullsizeImageViewController") as! FullsizeImageViewController
        fullsizeImageViewController.modalPresentationStyle = .fullScreen
        fullsizeImageViewController.image = tappedImage
        self.present(fullsizeImageViewController, animated: true, completion: nil)        
    }
    
    private func imageCount1(imageRef:StorageReference,imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat){
        //画像サイズをスクリーンサイズ幅に合わせる
        let scale:CGFloat = screenWidth/imageWidth
        let rect :CGRect = CGRect(x:30,y:500,width: imageWidth * scale ,height : imageHeight * scale)
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = rect
        imageView.sd_setImage(with: imageRef)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)
        //AutoLayout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
        imageView.topAnchor.constraint(equalTo: diaryText.bottomAnchor, constant:20.0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: diaryText.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: diaryText.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale  ).isActive = true
    }
    
    private func imageCount2(imageRef:StorageReference,imageView:UIImageView,screenWidth :CGFloat,screenHeight :CGFloat,imageWidth :CGFloat,imageHeight :CGFloat,index:Int){
        switch index {
        case 1:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:30,y:500,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: diaryText.bottomAnchor, constant:50.0).isActive = true
            imageView.leadingAnchor.constraint(equalTo: diaryText.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - 15 ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 2:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:30 + (imageWidth * scale) ,y:500,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: diaryText.bottomAnchor, constant:50.0).isActive = true
            imageView.trailingAnchor.constraint(equalTo: diaryText.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - 15 ).isActive = true
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
            let rect :CGRect = CGRect(x:30,y:500,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: diaryText.bottomAnchor, constant:20.0).isActive = true
            imageView.leadingAnchor.constraint(equalTo: diaryText.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - 15 ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2).isActive = true
        case 2:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:30 + (imageWidth * scale) ,y:500,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: diaryText.bottomAnchor, constant:20.0).isActive = true
            imageView.trailingAnchor.constraint(equalTo: diaryText.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - 15 ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 3:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:30,y:500 + (imageHeight * scale / 2) ,width: imageWidth * scale  ,height : imageHeight * scale / 2)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo:diaryText.bottomAnchor, constant:20.0 + (imageHeight * scale / 2) ).isActive = true
            imageView.leadingAnchor.constraint(equalTo: diaryText.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: diaryText.trailingAnchor).isActive = true
            //            imageView.widthAnchor.constraint(equalToConstant: screenWidth / 2 ).isActive = true
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
            let rect :CGRect = CGRect(x:30,y:500,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: diaryText.bottomAnchor, constant:20.0).isActive = true
            imageView.leadingAnchor.constraint(equalTo: diaryText.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - 15 ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 2:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:30 + (imageWidth * scale) ,y:500,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: diaryText.bottomAnchor, constant:20.0).isActive = true
            imageView.trailingAnchor.constraint(equalTo: diaryText.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - 15 ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 3:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:30,y:500 + (imageHeight * scale) ,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: diaryText.bottomAnchor, constant:20.0 + (imageHeight * scale / 2)).isActive = true
            imageView.leadingAnchor.constraint(equalTo: diaryText.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - 15 ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        case 4:
            //画像サイズをスクリーンサイズ幅に合わせる
            let scale:CGFloat = screenWidth/imageWidth
            let rect :CGRect = CGRect(x:30 + (imageWidth * scale) ,y:500 + (imageHeight * scale) ,width: imageWidth * scale ,height : imageHeight * scale)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            imageView.sd_setImage(with: imageRef)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView)
            //AutoLayout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageViewの最上部の位置はinputTextViewの最下部の位置から20pt下
            imageView.topAnchor.constraint(equalTo: diaryText.bottomAnchor, constant:20.0 + (imageHeight * scale / 2)).isActive = true
            imageView.trailingAnchor.constraint(equalTo: diaryText.trailingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: (screenWidth / 2) - 15 ).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageHeight * scale / 2 ).isActive = true
        default:
            break
        }
        
    }
    
    
    //元々持っている；プロパティ
    override var inputAccessoryView: UIView?{
        //inputAccessoryViewにInputTextViewを設定する
        get {
            return inputTextView
        }
    }
    
    override  var canBecomeFirstResponder: Bool{
        return true
    }
    
    private func setupNotification() {
        //キーボードが出てくる時の通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //キーボードが隠れる時の通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc func keyboardWillShow(notification:NSNotification){
        print("keyboardWillShow")
        guard let userInfo =  notification.userInfo else {return}
        if let keyboadFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue{
            print("keyboadFrame:",keyboadFrame)
            let bottom = keyboadFrame.height
            //スクロールビューをキーボードの分高さを上にあげる
            let contentInset = UIEdgeInsets(top:0,left:0,bottom:bottom,right: 0)
            tableView.contentInset = contentInset
            tableView.scrollIndicatorInsets = contentInset
        }
        
        
    }
    @objc func keyboardWillHide(){
        print("keyboardWillHide")
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = indicateInset
    }
    
    //テーブルビューの表示
    private func tableViewSet(){
        guard let postDataId = postData?.id else { return }
        Firestore.firestore().collection(Const.PostPath).document(postDataId).collection("messages").addSnapshotListener { (snapshots, err) in
            
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let comment = CommentData(document:dic)
                    self.commentData.append(comment)
                    self.commentData.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date < m2Date
                    }
                    
                    self.tableView.reloadData()
                case .modified, .removed:
                    print("nothing to do")
                }
            })
            
        }
    }
    
    //画面項目の設定
    private func contentSet(post:PostData){
        //ユーザ名
        self.userName.text = post.documentUserName ?? ""
        // いいねボタンの表示
        if post.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        //いいね数の表示
        let likeNumber = post.likes.count
        self.likeUserButton.setTitle(likeNumber.description, for: .normal)  //文字列変換
        likeUserButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)//フォントサイズ
        likeUserButton.setTitleColor(.black, for: .normal)
        
        // 日時の表示
        self.diaryDate.text = ""
        if let date = post.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.diaryDate.text = dateString
        }
        // コンテントの表示
        self.diaryText.text = ""
        if let content = post.content{
            self.diaryText.text! = content
        }
        //選択された写真の枚数
        let imageMaxNumber  = post.contentImageMaxNumber
        let postDocumentId = post.id
        //投稿写真の枚数分ループする (1,2,3,4)
        //投稿された写真の表示
        if imageMaxNumber > 0{
            for i in 1...imageMaxNumber{
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postDocumentId + "\(i).jpg")
                //        contetImageView.sd_setImage(with: imageRef2)
                
                //
                imageSet(imageRef:imageRef ,index: i, maxCount: imageMaxNumber)
            }
        }
        //プロフィール写真を設定
        setPostImage(uid:post.uid)
        //背景色を設定
        setBackgroundColor(colorIndex:post.backgroundColorIndex)
        
    }
    private func reloadLikeShow(postId:String){
        let postRef = Firestore.firestore().collection(Const.PostPath).document(postId)
        
        postRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                guard let document = querySnapshot!.data() else {return}
                guard let likes = document["likes"] as? [String] else {return}
                
                guard let myid = Auth.auth().currentUser?.uid else {return}
                // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
                if likes.firstIndex(of: myid) != nil {
                    // myidがあれば、いいねを押していると認識する。
                    let buttonImage = UIImage(named: "like_exist")
                    self.likeButton.setImage(buttonImage, for: .normal)
                    //変数に設定
                    self.postData?.isLiked = true
                }else {
                    //いいねを押していない
                    let buttonImage = UIImage(named: "like_none")
                    self.likeButton.setImage(buttonImage, for: .normal)
                    //変数に設定
                    self.postData?.isLiked = false
                }
                //変数にもlikesを設定
                self.postData?.likes = likes
                //いいね数の表示
                let likeNumber = likes.count
                self.likeUserButton.setTitle(likeNumber.description, for: .normal)  //文字列変換
                self.likeUserButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)//フォントサイズ
                self.likeUserButton.setTitleColor(.black, for: .normal)
                
                
            }
        }
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
                        self.imageView.image = UIImage(named: "unknown")
                    }else{
                        //取得した画像の表示
                        self.imageView.sd_imageIndicator =
                            SDWebImageActivityIndicator.gray
                        self.imageView.sd_setImage(with: imageRef)
                    }
                }
            }
        }
    }
    //背景色設定
    private func setBackgroundColor(colorIndex:Int){
        //背景色を変更する
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.viewHeader.layer.bounds
        let color = Const.color[colorIndex]
        let color1 = color["startColor"] ?? UIColor.white.cgColor
        let color2 = color["endColor"] ?? UIColor.white.cgColor
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1,color2]
        gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
        gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
        
        if self.viewHeader.layer.sublayers![0] is CAGradientLayer {
            self.viewHeader.layer.sublayers![0].removeFromSuperlayer()
            self.viewHeader.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            self.viewHeader.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    @objc func postDelete(_ sender:UIButton){
        print("削除ボタンを押下")
        guard let post = postData else {return}
        //確認メッセージ出力
        let alert : UIAlertController = UIAlertController(title: "この投稿を削除してもよろしいですか？", message :nil, preferredStyle: UIAlertController.Style.alert)
        var count = 0
        //OKボタン押下時
        let defaultAction :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            (action :UIAlertAction! ) -> Void in
            //以下OKボタンが押された時の動作
            //・firestoreからドキュメントを削除
            let postsRef = Firestore.firestore().collection(Const.PostPath).document(post.id)
            postsRef.delete()
            //写真の枚数
            let imageMaxNumber  = post.contentImageMaxNumber
            if imageMaxNumber == 0{
                //写真の枚数が0枚だったら一つ前の画面に戻る
                self.navigationController?.popToRootViewController(animated: true)
            }else {                
                for i in 1...imageMaxNumber{
                    //・firestorageから写真を削除
                    let imageRef = Storage.storage().reference().child(Const.ImagePath).child(post.id + "\(i).jpg")
                    imageRef.delete{ error in
                        if let error = error {
                            print("DEBUG: \(error)")
                        } else {
                            print("DEBUG: 画像の削除が成功しました。")
                            //for文のiだとdeleteの中では1から順にならないことがあるためcount変数を用意
                            count = count + 1
                            if count == imageMaxNumber {
                                //最後の写真を削除し終わったら、一つ前の画面に戻る
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
            }
        })
        
        //キャンセルボタン押下時 → 何もしない
        let cancelAction : UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:nil)
        //UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        //Alertを表示
        present(alert,animated: true)
        
    }
    // いいねボタンがタップされた時に呼ばれるメソッド
    @objc func likeButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG: likeボタンがタップされました。")
        guard let postData = postData else{ return }
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
            
            //いいねの再表示
            reloadLikeShow(postId:postData.id)
        }
    }
    //likeUserButton押下時
    @objc func likeUserShow(_:UIButton) {
        //画面遷移
        let likeUserListTableViewController = storyboard?.instantiateViewController(withIdentifier: "LikeUserListTableViewController") as! LikeUserListTableViewController
        //        guard let myUid = self.postData?.uid else { return}
        //        likeUserListTableViewController.uid = myUid
        let likeUsers :[String] = self.postData?.likes ?? []
        //likeUsersからユーザ情報を取得
        //        let userPostData = getUsersData(likeUsers)
        
        //        likeUserListTableViewController.userPostData = userPostData
        likeUserListTableViewController.likeUsers = likeUsers
        
        self.present(likeUserListTableViewController, animated: true, completion: nil)
    }
    
    
    
    
    
}
//作成したデリゲートを使用する
extension DitailViewController :InputTextViewDelegate{
    //InputTextViewのsubmitButtonが押された時に実行される処理
    func tapSubmitButton(text: String) {
        guard let postDataId = postData?.id else {return }
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let messageId = randomString(length: 20)
        
        let docData = [
            "uid": myUid,
            "createdAt": Timestamp(),
            "message": text,
            ] as [String : Any]
        //入力欄をクリア
        self.inputTextView.textClear()
        
        Firestore.firestore().collection(Const.PostPath).document(postDataId).collection("messages").document(messageId).setData(docData) {(err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            print("コメントメッセージの保存に成功しました")
            
        }
        
        
    }
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    
}

extension DitailViewController :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //高さの最低基準
        self.tableView.estimatedRowHeight = 100        
        //高さをコメントに合わせる
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        
        cell.translatesAutoresizingMaskIntoConstraints = false
        //Cell に値を設定する
        cell.setCommentData(commentData[indexPath.row])
        return cell
    }
}
