//
//  ZMBottomBMKMapCollectionView.swift
//  BKMapViewTotal
//
//  Created by 王宁 on 2016/11/18.
//  Copyright © 2016年 zhemi. All rights reserved.
//

import UIKit

private let cellIdentity = "cell"

@objc protocol ZMBottomBMKMapCollectionViewDelegate:NSObjectProtocol{
    
    //把滚动到此刻的索引值传递给delegate
    optional func scrollToIndex(index:Int)->Void
    //点击的对应的数组中的元素的跳转
    func touchPointAt(index:Int)->Void
    
}




class ZMBottomBMKMapCollectionView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var dataSourceArray:[AnyObject] = {
        
        return [AnyObject]()
    }()
    
    
    weak var delegate:ZMBottomBMKMapCollectionViewDelegate?

    //通过[model]刷新数据
    func reloadData(dataArray:[AnyObject]) -> Void {
        
        self.dataSourceArray = dataArray
        self.collectionView.reloadData()
    }
    
    func scrollToRightPosition(index:Int) -> Void {
        
        let point = CGPoint.init(x: self.collectionView.frame.size.width*(CGFloat)(index), y: 0)
        self.collectionView.setContentOffset(point, animated: true)
    }
    
    class func bottombmkMapCollectionView()->ZMBottomBMKMapCollectionView{
        
        return NSBundle.mainBundle().loadNibNamed("ZMBottomBMKMapCollectionView", owner: nil, options: nil)?.first as!ZMBottomBMKMapCollectionView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.registerNib(UINib.init(nibName: "ZMBottomMapCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentity)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = collectionView.collectionViewLayout as!UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height)
        
    }
}

extension ZMBottomBMKMapCollectionView:UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentity, forIndexPath: indexPath) as! ZMBottomMapCollectionViewCell
        cell.navItemBlock = {
            (index:Int)
            in
            self.delegate?.touchPointAt(indexPath.row)
        }
        
        return cell
    }
}

//滚动的时候把索引值传递给代理对象
extension ZMBottomBMKMapCollectionView{
    
    //停止减速的时候，此时不存在不拖动改变的情况
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentIndex = collectionView.contentOffset.x/collectionView.frame.size.width
        delegate?.scrollToIndex!(Int(currentIndex))
    }
    
}







