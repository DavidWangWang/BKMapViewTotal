//
//  ZMBottomMapCollectionViewCell.swift
//  BKMapViewTotal
//
//  Created by 王宁 on 2016/11/18.
//  Copyright © 2016年 zhemi. All rights reserved.
//

import UIKit

typealias ClickNavBlock = (index:Int)->Void
class ZMBottomMapCollectionViewCell: UICollectionViewCell {
    
    //外界把当前cell 的index也传递进来
    var currentIndex:Int?
    
    var navItemBlock:ClickNavBlock?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //按钮点击的时候通过block
    @IBAction func navClick(sender: AnyObject) {
        self.navItemBlock?(index:currentIndex!)
    }
}
