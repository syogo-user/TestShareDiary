//
//  File.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/11/15.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
class CheckBox :UIButton{
    let checkedImage = UIImage(named:"ico_check_on")! as UIImage
    let uncheckedImage = UIImage(named:"ico_check_off")! as UIImage
    
    var isChecked : Bool = false{
        didSet{
            if isChecked == true {
                self.setImage(checkedImage,for:UIControl.State.normal)
            }else{
                self.setImage(uncheckedImage,for:UIControl.State.normal)
            }
        }
    }
    
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender:UIButton){
        if sender == self{
            isChecked = !isChecked
        }
    }
}
