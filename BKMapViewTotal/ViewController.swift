//
//  ViewController.swift
//  BKMapViewTotal
//
//  Created by 王宁 on 2016/11/17.
//  Copyright © 2016年 zhemi. All rights reserved.
//

import UIKit

/**开发百度地图App 需要配置
 
 <key>LSApplicationQueriesSchemes</key>
 <array>
 <string>baidumap</string>
 </array>
 */
let ScreenWidth = UIScreen.mainScreen().bounds.size.width
let ScreenHeight = UIScreen.mainScreen().bounds.size.height

class ViewController: UIViewController,BMKMapViewDelegate,CLLocationManagerDelegate {
    
    //每隔一段时间记录一下当前的位置和经纬度
    var vim:(name:String,coordinate:CLLocationCoordinate2D) = ("", CLLocationCoordinate2D.init(latitude: 200, longitude: 100))
    //地理编码
    private lazy  var geocoder:CLGeocoder = {
        
        return CLGeocoder()
    }()
    
    private lazy var bkLM:BMKLocationService = {
       
        let bkLM = BMKLocationService()
        bkLM.delegate = self;
        return bkLM
    }()
    private lazy var LM:CLLocationManager = {
        
        let lm = CLLocationManager()
        lm.delegate = self
        //精准程度越高，越耗电
        lm.desiredAccuracy=kCLLocationAccuracyBest
        
        let systemVersion = UIDevice.currentDevice().systemVersion
//        let doubleVersion:Double = Double(systemVersion)!
        let doubleVersion =  (systemVersion as NSString).doubleValue
        //字符串转整型
        if doubleVersion>=8.0{
            //ios 8.0前后台定位授权
            lm.requestAlwaysAuthorization()
        }
        if doubleVersion>=9.0{
//            //ios 8.0前后台定位授权
            if #available(iOS 9.0, *) { 
            
             lm.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
//                lm.requestAlwaysAuthorization()
            }
        }
   
        return lm
    }()
    
    private lazy var transItem:ZMTransItem = {
        
        return ZMTransItem()
    }()
    
    
    
    var _mapView: BMKMapView?
    var pointAnnotation: BMKPointAnnotation?
    var animatedAnnotation: BMKPointAnnotation?
    
    private lazy var coordinateArr: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    private lazy var titelArr:[String] = [String]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        addPointAnnotation()
        insertAddress()
        //开始定位
        self.LM.startUpdatingLocation()
        //bd定位
        self.bkLM.startUserLocationService()
    }
    
    //更新位置后的回调
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location  = locations.first
//        print(location?.coordinate.latitude)
//        print(location?.coordinate.longitude)
        
//        _mapView?.showsUserLocation = true
//        _mapView!.userTrackingMode = BMKUserTrackingMode.init(1)

        
        //每隔一段时间更新下当前的位置和经纬度信息。反地理编码拿到名称
        let reverGeo = CLGeocoder()
        
        reverGeo.reverseGeocodeLocation(location!) { (placemarks, error) in
            
            if error==nil{
                
                let placeMarks = placemarks!.first
                let name = placeMarks?.name
                self.vim.name = name!
                self.vim.coordinate = (location?.coordinate)!
            }
        }
//       print(vim)
        //获取一次
//        self.LM.stopUpdatingLocation()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(type: .Custom)
        view.addSubview(btn)
        btn.frame = CGRect(x: 0, y: 10, width: 30, height: 30)
        btn.backgroundColor = UIColor.greenColor()
        btn.addTarget(self, action: #selector(self.btnClick), forControlEvents: .TouchUpInside)
        
        //添加坐标点，添加内容
        let coordinate1 = CLLocationCoordinate2D.init(latitude: 39.96, longitude: 116.34)
        coordinateArr.append(coordinate1)
       //做的时候经纬度。已经保存在这个model的coordinateArr中了
        transItem.coordinateArr?.append(coordinate1)
        
        let coordinate2 = CLLocationCoordinate2D.init(latitude: 40.00, longitude:116.39 )
        coordinateArr.append(coordinate2)
        transItem.coordinateArr?.append(coordinate2)

        
        let coordinate3 = CLLocationCoordinate2D.init(latitude: 39.90, longitude:116.32 )
        coordinateArr.append(coordinate3)
        transItem.coordinateArr?.append(coordinate3)

        
        _mapView = BMKMapView(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: self.view.frame.height-50))
        _mapView?.showsUserLocation = true
        self.view.addSubview(_mapView!)
        _mapView!.zoomLevel = 12
 
        //添加底部的collectionView
//        self.view.addSubview(collectinSuperView)
    }
    
    

    private lazy var collectinSuperView:ZMBottomBMKMapCollectionView = {
        let collectinSuperView = ZMBottomBMKMapCollectionView.bottombmkMapCollectionView()
        self.view.addSubview(collectinSuperView)
        collectinSuperView.frame = CGRect(x: 10, y: ScreenHeight-20-54 , width: ScreenWidth-20, height: 54)
        collectinSuperView.delegate = self
        return collectinSuperView;
    }()
    /**
      将数据添加进去之后 再去刷新下面的条。
     
     
     */
    private lazy  var dataSource:[AnyObject] = {
        var array = [AnyObject]()
//        for _ in (0..<4){
//            array.append("Niki")
//        }
        return array
    }()
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _mapView?.viewWillAppear()
        _mapView?.delegate = self // 此处记得不用的时候需要置nil，否则影响内存的释放
        
    }
    
    @objc func btnClick()->Void{
      
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _mapView?.viewWillDisappear()
        _mapView?.delegate = nil // 不用时，置nil
    }
    
    //添加标注
    func addPointAnnotation() {
        
        for i in (0..<3) {
            //实现了BMKAnomation协议。
            let wnPointAnnotation = BMKPointAnnotation()
            wnPointAnnotation.coordinate = transItem.coordinateArr![i]
            wnPointAnnotation.title = transItem.addressNamesArr![i]
            _mapView!.addAnnotation(wnPointAnnotation)
        }
       }
    
     //填充titelArr
    func insertAddress() -> Void {
        //串行队列
    let serialQueue = dispatch_queue_create("com.appcoda.imagesQueue", DISPATCH_QUEUE_SERIAL)

        for i in (0..<3) {
            dispatch_async(serialQueue, { 
                let cllocation2D = self.coordinateArr[i]
                let location = CLLocation(latitude: cllocation2D.latitude, longitude: cllocation2D.longitude)
                let curGeocoder = CLGeocoder()
                curGeocoder .reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) in
                    let placeMark = placeMarks?.first
                    //                self.titelArr.append((placeMark?.name!)!)
                    //swift中都是值拷贝，不是指针拷贝，所以如果数据特别大建议转NSMutableArray/Dictinoary
                    self.transItem.addressNamesArr?.append((placeMark?.name)!)
                    //真正做的时候外面已经把model数组传递进来了，不需要此时再去刷新
                    //                self.dataSource.append((placeMark?.name)!)
                    if  self.transItem.addressNamesArr!.count == self.coordinateArr.count{
                        self.addPointAnnotation()
                        //此时同时存在经纬度和街道名称了。此时去刷新下面的条目的内容
                        self.collectinSuperView.reloadData( self.transItem.addressNamesArr!)
                        self.scrollToIndex(0)
                    }
                })
            })
       }
    }
    /**
     
     当addAnnotation后回调这个代理方法
     *根据anntation生成对应的View
     *@param mapView 地图View
     *@param annotation 指定的标注
     *@return 生成的标注View
     */
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        // 普通标注
      
        let AnnotationViewID = "renameMark"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(AnnotationViewID) as! BMKPinAnnotationView?
//        if annotationView == nil {
            annotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: AnnotationViewID)
            // 设置颜色
            annotationView!.pinColor = UInt(BMKPinAnnotationColorPurple)
            // 从天上掉下的动画
            annotationView!.animatesDrop = true
            // 设置可拖曳
            annotationView!.draggable = true
//        }
        //BMKPinAnnotationView 中也存在一个大头针模型对象，大头针模型对象中保存了当前标注的经纬度和title和subTitle
        annotationView?.annotation = annotation
        //1.将标注添加进我们的数组当中 2.使用的使用将selecte变为yes，3.刷新地图
        transItem.annotationViewArr?.append(annotationView!)
        return annotationView
    }
    
    /**
     *当mapView新添加annotation views时，调用此接口
     *@param mapView 地图View
     *@param views 新添加的annotation views
     */
    func mapView(mapView: BMKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        NSLog("didAddAnnotationViews")
    }
    
    /**
     *当选中一个annotation views时，调用此接口
     *@param mapView 地图View
     *@param views 选中的annotation views
     */
    func mapView(mapView: BMKMapView!, didSelectAnnotationView view: BMKAnnotationView!) {

        print("选中了标注回调")
        //点击标准下面的collectionView切换
        let index = self.transItem.annotationViewArr?.indexOf(view)
        //让底部的条滚动到指定位置
        collectinSuperView.scrollToRightPosition(index!)
    }
    
    /**
     *当取消选中一个annotation views时，调用此接口
     *@param mapView 地图View
     *@param views 取消选中的annotation views
     */
    func mapView(mapView: BMKMapView!, didDeselectAnnotationView view: BMKAnnotationView!) {
        NSLog("取消选中标注")
    }
    
    /**
     *拖动annotation view时，若view的状态发生变化，会调用此函数。ios3.2以后支持
     *@param mapView 地图View
     *@param view annotation view
     *@param newState 新状态
     *@param oldState 旧状态
     */
    func mapView(mapView: BMKMapView!, annotationView view: BMKAnnotationView!, didChangeDragState newState: UInt, fromOldState oldState: UInt) {
        NSLog("annotation view state change : \(oldState) : \(newState)")
    }
    
    /**
     *当点击annotation view弹出的泡泡时，调用此接口
     *@param mapView 地图View
     *@param view 泡泡所属的annotation view
     */
    func mapView(mapView: BMKMapView!, annotationViewForBubble view: BMKAnnotationView!) {
        NSLog("点击了泡泡")
//        print(view.annotation.coordinate)
//        print(view.annotation.title!())
        //swift 函数名，默认第一个标签省略。第二个以后需要写上
        ZMBKMapSchemeTool.applicationOfJump((vim.name, vim.coordinate), endArgument: (view.annotation.title!(),view.annotation.coordinate))
    }
}

// MARK: - 百度MapKit
extension ViewController:BMKLocationServiceDelegate{
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        _mapView?.updateLocationData(userLocation)
    }
}

extension ViewController:ZMBottomBMKMapCollectionViewDelegate
{
    //点击导航按钮的时候点击
    func touchPointAt(index: Int) {
      //拿到对应位置的经纬度和值
        //swift 函数名，默认第一个标签省略。第二个以后需要写上
        ZMBKMapSchemeTool.applicationOfJump((vim.name, vim.coordinate), endArgument: (transItem.addressNamesArr![index],transItem.coordinateArr![index]))
    }
    //滚动到位置。指定的标签被点击。
    func scrollToIndex(index: Int) {
//        print("滚动到指定的位置，滚对了没有啊")
        ///默认为NO,当view被点中时被设为YES,用户不要直接设置这个属性.若设置，需要在设置后调用BMKMapView的- (void)mapForceRefresh; 方法刷新地图 ,上一个View的选中状态变为NO，需要我们把去上一个选中状态变为NO
//        for item as in self.transItem.annotationViewArr as [BMKAnnotationView] {
//            if item.selected==true {
//                item.selected = false
//            }
//        }
        for anomationView in self.transItem.annotationViewArr! {
            if let paopaoView = anomationView.paopaoView {
                anomationView.selected=false
                paopaoView.removeFromSuperview()
            }
        }
        let currentBMKAnnotationView = self.transItem.annotationViewArr![index];
        print(self.transItem.addressNamesArr![index])
        print(self.transItem.annotationViewArr![index].annotation.title!())
        print(index)
        currentBMKAnnotationView.selected = true
       //地图刷新
        _mapView?.mapForceRefresh()
    }
}





