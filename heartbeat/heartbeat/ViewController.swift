//
//  ViewController.swift
//  heartbeat
//
//  Created by DX173-XL on 2015-12-21.
//  Copyright © 2015 Pivotal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var heartView: HeartVectorView!
    var infoView: HeartbeatInfoView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenRect : CGRect = UIScreen.mainScreen().bounds
        //Due to orientation weirdness, this can be wrong unless you check
        let screenWidth : CGFloat = min(screenRect.width, screenRect.height)
        let screenHeight : CGFloat = max(screenRect.width, screenRect.height)
        let container : UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        
        self.heartView = HeartVectorView.init(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 200))
        self.heartView.center = container.center
        container.addSubview(self.heartView)
        view.addSubview(container)
        
        self.infoView = HeartbeatInfoView.init(frame: CGRect(x: 10.0, y: self.heartView.frame.maxY + 100, width: container.frame.width-20.0, height: 100.0))
        container.addSubview(self.infoView)
        
        NSNotificationCenter.defaultCenter()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self.infoView, selector: "didReceiveHeartbeat", name: "io.pivotal.ios.push.heartbeatmonitorReceivedHeartbeat", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self.heartView, selector: "beatHeart", name: "io.pivotal.ios.push.heartbeatmonitorReceivedHeartbeat", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self.infoView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func incrementHeartbeatInfo() {
//        if (self.info != nil) {
//            NSLog("calling increment()")
//            self.info.increment()
//        }
//        NSLog("Called incrementHeartbeatInfo()")
//    }

}

