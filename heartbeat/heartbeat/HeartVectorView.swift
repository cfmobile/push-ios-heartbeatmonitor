/*
 *  Copyright (C) 2015-Present Pivotal Software, Inc. All rights reserved.
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

class HeartVectorView: UIView {
    
    fileprivate let rightApex = CGPoint(x: 13.5, y: 0)
    fileprivate let valley = CGPoint(x: 9, y: 3)
    fileprivate let leftApex = CGPoint(x: 4.5, y: 0)
    fileprivate let leftDistal = CGPoint(x: 0, y: 4.5)
    fileprivate let tip = CGPoint(x: 9, y: 16)
    fileprivate let rightDistal = CGPoint(x: 18, y: 4.5)

    fileprivate let heartShape = CAShapeLayer()
    
    var scale : CGFloat = 10.0
    
    //Init and Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0.0
        setupComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        alpha = 0.0
        setupComponents()
    }
    
    fileprivate func setupComponents(){
        heartShape.strokeColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0).cgColor
        heartShape.fillColor = UIColor(red: 0.87, green: 0.60, blue: 0.60, alpha: 1.0).cgColor
        heartShape.path = UIBezierPath(rect: self.bounds).cgPath
        layer.addSublayer(heartShape)
    
        startUpdateLoop()
    }
    
    
    //Drawing
    
    fileprivate func bezierPathForControlPoints()->CGPath {
        let path = UIBezierPath()
        
        let points = [
            CGPoint(x: -1.955, y: 0.0), CGPoint(x: -3.83, y: 1.268),
            CGPoint(x: -0.67, y: -1.732), CGPoint(x: -2.547, y: -3),
            CGPoint(x: -2.543, y: 0), CGPoint(x: -4.5, y: 1.932),
            CGPoint(x: 0.0, y: 3.53), CGPoint(x: 3.793, y: 6.257),
            CGPoint(x: 5.207, y: -5.242), CGPoint(x: 9, y: -7.97),
            CGPoint(x: 0, y: -2.568), CGPoint(x: -1.957, y: -4.5),
        ]
        
        let relPoints = [
            CGPointRelativeTo(rightApex, relativePoint: points[0]), CGPointRelativeTo(rightApex, relativePoint: points[1]),
            CGPointRelativeTo(valley, relativePoint: points[2]), CGPointRelativeTo(valley, relativePoint: points[3]),
            CGPointRelativeTo(leftApex, relativePoint: points[4]), CGPointRelativeTo(leftApex, relativePoint: points[5]),
            CGPointRelativeTo(leftDistal, relativePoint: points[6]), CGPointRelativeTo(leftDistal, relativePoint: points[7]),
            CGPointRelativeTo(tip, relativePoint: points[8]), CGPointRelativeTo(tip, relativePoint: points[9]),
            CGPointRelativeTo(rightDistal, relativePoint: points[10]), CGPointRelativeTo(rightDistal, relativePoint: points[11]),
        ]
        
        path.move(to: rightApex)
        path.addCurve(to: valley, controlPoint1: relPoints[0], controlPoint2: relPoints[1])
        path.addCurve(to: leftApex, controlPoint1: relPoints[2], controlPoint2: relPoints[3])
        path.addCurve(to: leftDistal, controlPoint1: relPoints[4], controlPoint2: relPoints[5])
        path.addCurve(to: tip, controlPoint1: relPoints[6], controlPoint2: relPoints[7])
        path.addCurve(to: rightDistal, controlPoint1: relPoints[8], controlPoint2: relPoints[9])
        path.addCurve(to: rightApex, controlPoint1: relPoints[10], controlPoint2: relPoints[11])
        
        path.apply(CGAffineTransform(scaleX: self.scale, y: self.scale))
        
        let vWidth = (rightDistal.x - leftDistal.x)*self.scale;
        let vHeight = (tip.y - rightApex.y)*self.scale
        let xTranslate = (bounds.width - vWidth)/2
        let yTranslate = (bounds.height - vHeight)/2
        
        
        path.apply(CGAffineTransform(translationX: xTranslate, y: yTranslate))
        
        return path.cgPath
    }
    
    //Animation
    
    func beatHeart() {
        startUpdateLoop()
        animateControlPoints()
    }
    
    func animateControlPoints() {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.fromValue = 1.5
        animation.toValue = 1.0
        animation.duration = 0.5
        
        let animationTiming : CAMediaTimingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.8, 1, 1)
        animation.timingFunction = animationTiming

        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: "scale")
        self.layer.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        self.layer.contentsGravity = "center"
        
        stopUpdateLoop()
    }
    
    //UI Interaction
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beatHeart()
    }
    
    //Update Functions
    
    fileprivate lazy var displayLink : CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(HeartVectorView.updateLoop))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        return displayLink
        }()
    
    fileprivate func startUpdateLoop() {
        displayLink.isPaused = false
    }
    
    fileprivate func stopUpdateLoop() {
        displayLink.isPaused = true
    }

    func updateLoop() {
        heartShape.path = bezierPathForControlPoints()
        if (alpha < 1.0){
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 1.0
                }
            )
        }
    }
}
