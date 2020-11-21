//
//  ColorChoiceViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/14.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit

class ColorChoiceViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func  viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        //CollectionViewのサイズ調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:15,left:15,bottom:15,right:15)
        self.collectionView.collectionViewLayout = layout
        self.cancelButton.addTarget(self, action: #selector(tapCancelButton(_:)), for: .touchUpInside)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Const.color.count //表示するセルの数
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        //グラデーション
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = cell.bounds
        let color = Const.color[indexPath.item]
        let color1 = color["startColor"] ?? UIColor().cgColor
        let color2 = color["endColor"] ?? UIColor().cgColor
        gradientLayer.colors = [color1,color2]
        gradientLayer.startPoint = CGPoint.init(x:0.0,y:0.0)
        gradientLayer.endPoint = CGPoint.init(x:1.0,y:1.0)
        cell.layer.insertSublayer(gradientLayer, at: 0)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = self.view.bounds.width / 3 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }    
    // cell選択時に呼ばれる関数
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //前画面への値の受け渡し
        let preVC = self.presentingViewController as! PostViewController
        preVC.backgroundColorArrayIndex = indexPath.item
        self.dismiss(animated: true, completion:nil)
    }
    @objc func tapCancelButton(_ sender:UIButton){
        dismiss(animated: true, completion: nil)
    }
    
}
