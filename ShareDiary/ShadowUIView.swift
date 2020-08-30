//
//  ShadowUIView.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/08/30.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import Foundation
import UIKit
class ShadowUIView :UIView{
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    private func setupShadow() {
        self.layer.cornerRadius = 25
        self.layer.shadowOffset = CGSize(width: 5, height: 5)//影の方向　右下
        self.layer.shadowRadius = 4// 影のぼかし量
        self.layer.shadowOpacity =  0.5 // 影の濃さ
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 3, height: 3)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
