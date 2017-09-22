/*  Copyright (C) 2015-Present Pivotal Software, Inc. All rights reserved
 *
 *  This program and the accompanying materials are made available under
 *  the terms of the under the Apache License, Version 2.0 (the "License”);
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

import UIKit

class HeartbeatViewController: UIViewController {
    
    var heartView: HeartVectorView!
    var infoView: HeartbeatInfoView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PCF Push Heartbeat Monitor"
        
        let screenRect : CGRect = UIScreen.mainScreen().bounds
        //Due to orientation weirdness, this can be wrong unless you check
        let screenWidth : CGFloat = min(screenRect.width, screenRect.height)
        let screenHeight : CGFloat = max(screenRect.width, screenRect.height)
        let container : UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        
        self.heartView = HeartVectorView.init(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 200))
        self.heartView.center = container.center
        container.addSubview(self.heartView)
        container.backgroundColor = UIColor.whiteColor()
        view.addSubview(container)
        
        self.infoView = HeartbeatInfoView.init(frame: CGRect(x: 0.0, y: screenHeight - 100.0, width: container.frame.width, height: 100.0))
        container.addSubview(self.infoView)
        
        NSNotificationCenter.defaultCenter()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self.infoView, selector: "didReceiveHeartbeat", name: "io.pivotal.ios.push.heartbeatmonitorReceivedHeartbeat", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self.heartView, selector: "beatHeart", name: "io.pivotal.ios.push.heartbeatmonitorReceivedHeartbeat", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self.infoView, selector: "didReceiveError:", name: "io.pivotal.ios.push.heartbeatmonitorReceiveError", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self.infoView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

