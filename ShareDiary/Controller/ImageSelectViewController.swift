//
//  ImageSelectViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/08/07.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import Foundation
import DKImagePickerController

class ImageSelectViewController :DKImagePickerController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.maxSelectableCount = 4
        self.showsCancelButton = true
        //UIのカスタマイズ
        self.UIDelegate = CustomUIDelegate()
        
    }
}
