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
    
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            return value(forKey: "_searchField") as? UITextField
        }
    }
}
