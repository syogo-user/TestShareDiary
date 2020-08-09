//
//  FullsizeImageViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/08/06.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit

class FullsizeImageViewController: UIViewController {

    var image  = UIImage()
//    @IBOutlet weak var fullsizeImageview: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.fullsizeImageview.image = image
//        self.fullsizeImageview.contentMode = .scaleAspectFill
        self.view.backgroundColor = .black
        self.cancelButton.addTarget(self, action: #selector(tapCancelButton(_:)), for:.touchUpInside)
        
        
        setImage()
        
        
        
        
        
        
    }
    private func setImage(){
        // UIImageView 初期化
        let imageView = UIImageView(image:self.image)
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像の幅・高さの取得
        let imgWidth = self.image.size.width
        let imgHeight = self.image.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        let scale = screenWidth / imgWidth * 0.9
        let rect:CGRect = CGRect(x:0, y:0,
                                 width:imgWidth*scale, height:imgHeight*scale)
        
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = rect;
        
        // 画像の中心を画面の中心に設定
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        
        // 角丸にする
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.1
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)
        
//        imageView.sendSubviewToBack(cancelButton)
        // 下向きにスワイプした時のジェスチャーを作成
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeView))
        downSwipeGesture.direction = .down
        // 画面にジェスチャーを登録
        self.view.addGestureRecognizer(downSwipeGesture)
        
        // 上向きにスワイプした時のジェスチャーを作成
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeView))
        upSwipeGesture.direction = .up
        // 画面にジェスチャーを登録
        self.view.addGestureRecognizer(upSwipeGesture)
    }
    
    @objc private func tapCancelButton(_ sender :UIButton){
        //モーダルを閉じる
        print("モーダルを閉じる")
//        self.dismiss(animated: true, completion: nil)
        closeView()
    }
    
    @objc private func closeView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
