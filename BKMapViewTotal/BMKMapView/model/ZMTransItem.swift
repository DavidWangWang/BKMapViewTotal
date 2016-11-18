//
//  ZMTransItem.swift
//  BKMapViewTotal
//
//  Created by 王宁 on 2016/11/18.
//  Copyright © 2016年 zhemi. All rights reserved.
//

import UIKit

class ZMTransItem: NSObject {
   
    // 经纬度数组
    var coordinateArr:[CLLocationCoordinate2D]?

    // 地区名称数组
    var addressNamesArr:[String]?
    //标注数组
    var annotationViewArr:[BMKAnnotationView]?
    
    
    //swift必须实现的方法前面+ require
    required override init() {
        super.init()
        coordinateArr = [CLLocationCoordinate2D]()
        addressNamesArr = [String]()
        //实例化标注数组
        annotationViewArr = [BMKAnnotationView]()
    }
}
