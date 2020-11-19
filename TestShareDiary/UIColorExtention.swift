//
//  UIColorExtention.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/07/11.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgbColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
}
