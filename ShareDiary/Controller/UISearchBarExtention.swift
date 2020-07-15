//
//  File.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/07/14.
//  Copyright © 2020 syogo-user. All rights reserved.
//
import UIKit
extension UISearchBar {
//    var textField: UITextField? {
//        return value(forKey: "_searchField") as? UITextField
//    }
    
    func disableBlur() {
        backgroundImage = UIImage()
        isTranslucent = true
    }
    
}
