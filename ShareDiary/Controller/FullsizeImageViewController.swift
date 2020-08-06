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
    @IBOutlet weak var fullsizeImageview: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fullsizeImageview.image = image
        self.fullsizeImageview.contentMode = .scaleAspectFill
        self.view.backgroundColor = .black
        self.cancelButton.addTarget(self, action: #selector(tapCancelButton(_:)), for:.touchUpInside)
    }
    @objc private func tapCancelButton(_ sender :UIButton){
        //モーダルを閉じる
        print("モーダルを閉じる")
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
