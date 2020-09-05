//
//  GradiationView.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/09/05.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
//グラデーションクラス
class GradationView:UIView{
    //クラスプロパティ(サブクラスでオーバーライド可)
    override class var layerClass: AnyClass{
        return CAGradientLayer.self// CAGradientLayerクラスのインスタンスを取得
    }
    //背景色変更
    func setBackgroundColor(colorIndex:Int){
        guard let gradientLayer = self.layer as? CAGradientLayer else{return}
        //背景色を変更する
        let color = Const.color[colorIndex]
        let color1 = color["startColor"] ?? UIColor.white.cgColor
        let color2 = color["endColor"] ?? UIColor.white.cgColor
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1,color2]
        gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
        gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
    }
}
