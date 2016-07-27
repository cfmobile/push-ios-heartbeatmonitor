//
//  HeartbeatInfoView.swift
//  heartbeat
//
//  Copyright (C) 2016 Pivotal Software, Inc. All rights reserved. 
//  
//  This program and the accompanying materials are made available under 
//  the terms of the under the Apache License, Version 2.0 (the "License”); 
//  you may not use this file except in compliance with the License. 
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

class HeartbeatInfoView: UIView {
    
    var numHeartbeats = 0
    var lastHeartbeat = NSDate.init(timeIntervalSince1970: 0)
    var url : String = ""
    
    let numHeartbeatsLabel = UILabel.init()
    let dateFormatter = NSDateFormatter.init()
    let lastHeartbeatLabel = UILabel.init()
    let urlLabel = UILabel.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        self.setupView(frame)
        readHeartbeatData()
        updateLastHeartbeatText()
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateLastHeartbeatText", userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(frame: CGRect){
        let labelHeight : CGFloat = 20.0
        let fontSize : CGFloat = 14.0
        let textColor = UIColor.grayColor()
        
        numHeartbeatsLabel.frame = CGRect(origin: CGPointZero, size: CGSize(width: frame.width, height: labelHeight))
        numHeartbeatsLabel.font = numHeartbeatsLabel.font.fontWithSize(fontSize)
        numHeartbeatsLabel.textColor = textColor
        numHeartbeatsLabel.text = "Received \(numHeartbeats) heartbeats."
        numHeartbeatsLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(numHeartbeatsLabel)
        
        lastHeartbeatLabel.frame = CGRect(origin: CGPoint(x: 0.0, y: numHeartbeatsLabel.frame.maxY), size: CGSize(width: frame.width, height: labelHeight))
        lastHeartbeatLabel.font = lastHeartbeatLabel.font.fontWithSize(fontSize)
        lastHeartbeatLabel.textColor = textColor
        lastHeartbeatLabel.text = "Last Heartbeat received \(dateFormatter.stringFromDate(lastHeartbeat))."
        lastHeartbeatLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(lastHeartbeatLabel)
        
        urlLabel.frame = CGRect(origin: CGPoint(x: 0.0, y: lastHeartbeatLabel.frame.maxY), size: CGSize(width: frame.width, height: labelHeight))
        urlLabel.font = urlLabel.font.fontWithSize(fontSize)
        urlLabel.textColor = textColor
        urlLabel.textAlignment = NSTextAlignment.Center
        getServiceUrl()
        self.addSubview(urlLabel)
    }
    
    func didReceiveHeartbeat() {
        NSLog("received heartbeat notification")
        increment()
    }
    
    func increment(){
        NSLog("Incrementing heartbeats")
        numHeartbeats += 1
        lastHeartbeat = NSDate()
        persistHeartbeatData(numHeartbeats, lastReceivedTimestamp: lastHeartbeat.timeIntervalSince1970)
        updateLastHeartbeatText()
    }
    
    func updateLastHeartbeatText(){
        numHeartbeatsLabel.text = "Received \(numHeartbeats) heartbeats."
        var heartbeatText = "Waiting for first heartbeat..."
        let timeSince : NSTimeInterval = abs(lastHeartbeat.timeIntervalSinceNow)
        if (timeSince < 60) {
            heartbeatText = "Last heartbeat was moments ago."
        } else if (numHeartbeats > 0) {
            heartbeatText = "Last heartbeat was \(dateFormatter.stringFromDate(lastHeartbeat))."
        }
        lastHeartbeatLabel.text = heartbeatText
    }
    
    
    func readHeartbeatData(){
        if let myDict: NSDictionary = dictionaryFromDocumentsPlist("/HeartbeatData"){
            numHeartbeats = myDict["Count"] as! Int
            lastHeartbeat = NSDate(timeIntervalSince1970: myDict["LastReceivedTimestamp"] as! NSTimeInterval)
        } else {
            NSLog("No existing Heartbeat Data found")
        }
    }
    
    func persistHeartbeatData(count: Int, lastReceivedTimestamp: NSTimeInterval) {
        let myDict: NSDictionary = NSDictionary.init(objects: [count, lastReceivedTimestamp], forKeys: ["Count","LastReceivedTimestamp"])
        writeDictionaryToPlist("/HeartbeatData", dict: myDict)
    }
    
    
    func getServiceUrl(){
        let myDict: NSDictionary? = dictionaryFromBundledPlist("Pivotal")
        if (myDict != nil){
            if let tempUrl = myDict!["pivotal.push.serviceUrl"] as! String?{
                url = tempUrl
                urlLabel.text = "Monitoring \(url)"
            } else {
                urlLabel.text = "Service url was empty"
            }
        }
        
    }
    
    func dictionaryFromBundledPlist(filename: String) -> NSDictionary? {
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        return myDict
    }
    
    func dictionaryFromDocumentsPlist(filename: String) -> NSDictionary? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        var path : String?
        if (paths.count > 0){
            let documentsDirectory = paths[0] as! String
            path = documentsDirectory.stringByAppendingString("\(filename).plist")
        }
        
        var myDict: NSDictionary?
        if path != nil {
            myDict = NSDictionary(contentsOfFile: path!)
        }
        
        return myDict
    }
    
    func writeDictionaryToPlist(filename: String, dict: NSDictionary) {
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        var path : String = ""
        if (paths.count > 0){
            let documentsDirectory = paths[0] as! String
            path = documentsDirectory.stringByAppendingString("\(filename).plist")
        }
        
        let success = dict.writeToFile(path, atomically: true)
        if (success){
            NSLog("successful write!")
        } else {
            NSLog("Failed to write data")
        }
    
    }

}
