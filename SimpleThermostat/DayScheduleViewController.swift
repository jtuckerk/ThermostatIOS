//
//  DayScheduleViewController.swift
//  SimpleThermostat
//
//  Created by Tucker Kirven on 3/26/15.
//  Copyright (c) 2015 Tucker Kirven. All rights reserved.
//

import Foundation
import UIKit

class DayScheduleViewController: UIViewController {
    
    var awaySetPoint = 68
    var homeSetPoint = 68
    
    @IBOutlet weak var dayLabelTop: UIView!
    @IBOutlet weak var doneButton: UIButton!
    var currentSegment: UILabel? = nil
    var lastView: [UILabel] = []
    var homeAwayLabels: [UILabel] = []
    var tempLabels: [UILabel] = []
    
    var touchMask = false
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var greyView: UIView = UIView()
    var tempSetView: UIView = UIView()
    
    var homeAwaySwitch = UISwitch()
    
    @IBOutlet var timeView: UIView!
    @IBOutlet var DayLabel: UILabel!
    
    @IBOutlet weak var bigView: UIView!
    @IBOutlet weak var tempViewBig: UIView!
    
    var setPointSetLabel = UILabel()
    var awaySetPointSetLabel = UILabel()
    var setPointLabel = UILabel()
    var awaySetPointLabel = UILabel()
    
    var plusButton = UIButton()
    var minusButton = UIButton()
    
    var awayMinusButton = UIButton()
    var awayPlusButton = UIButton()
    func homeAwayToggle(sender:UISwitch){
        if homeAwaySwitch.on {
            setPointSetLabel.text = "   Home Temperature"
            setPointLabel.text = String(homeSetPoint) + "°"
            
        }else {
            setPointSetLabel.text = "   Away Temperature"
            setPointLabel.text = String(awaySetPoint) + "°"
        }
    }
    
    func plusClick(sender:UIButton!) {
        if homeAwaySwitch.on {
            homeSetPoint+=1
            setPointLabel.text = String(homeSetPoint) + "°"
        } else {
            awaySetPoint+=1
            setPointLabel.text = String(awaySetPoint) + "°"
        }
    }
    func minusClick(sender:UIButton!){
        if homeAwaySwitch.on{
            homeSetPoint-=1
            setPointLabel.text = String(homeSetPoint) + "°"
        }else{
            awaySetPoint-=1
            setPointLabel.text = String(awaySetPoint) + "°"
        }
    }
    func awayPlusClick(sender:UIButton!) {
        awaySetPoint+=1
        awaySetPointLabel.text = String(awaySetPoint) + "°"
    }
    func awayMinusClick(sender:UIButton!){
        awaySetPoint-=1
        awaySetPointLabel.text = String(awaySetPoint) + "°"
    }
    
    @IBAction func doneClick(sender: AnyObject) {
        if !touchMask {
            var homeArray = Array<[String:AnyObject]>()
            
            for n in 0...(tempLabels.count-1){
                var temp: AnyObject = tempLabels[n].text!.toInt()! as AnyObject
                var status: AnyObject = homeAwayLabels[n].text! as AnyObject
                //var seg = ["setPoint":temp, "status":status] as [String:AnyObject]
                
                homeArray.append(["setPoint":temp , "status":status ] )
            }
            //print(homeArray)
            appDelegate.sched!.setSegments(day, homeTemp: 0,awayTemp: 0,sched: homeArray)
            
            appDelegate.connection!.sendSchedule()
        }
    }
    var segmentsInTempView = Dictionary<String, UILabel>()
    var segmentsInView = Dictionary<String, UILabel>()
    var times = Dictionary<String, UILabel>()
    
    var day = ""
    
    override func viewDidLoad() {
        DayLabel.text = day
        super.viewDidLoad()
        appDelegate.currVC = self
        makeSegments()
        createTempViews()
        makeTime()
        
        doneButton.backgroundColor = JTKColors().orangeLight
        dayLabelTop.backgroundColor = JTKColors().orangeDark
        self.view.backgroundColor = JTKColors().backgroundColor
        
        var array24Hour = appDelegate.sched!.getSegments(day)
        var segments = bigView.subviews as [UILabel]
        for n in 0...(segments.count-1){
            
            segments[n].text = array24Hour[n]["status"] as? String
            print(n)
            tempLabels[n].text = String(array24Hour[n]["setPoint"] as Int)
            
            if (array24Hour[n]["status"] as String == "Home"){
                segments[n].backgroundColor = JTKColors().softGreen
            }else{
                segments[n].backgroundColor = JTKColors().lightGrey
            }
            
        }
        createTempSetPopup()
        
    }
    func createTempSetPopup(){
        
        var viewDict = Dictionary<String, UIView>()
        
        view.addSubview(greyView)
        view.addSubview(tempSetView)
        
        
        var greyViewStringH: String = "H:|[greyView]|"
        var greyViewStringV: String = "V:|[greyView]|"
        var tempViewStringH: String = "H:|-16-[tempView]-16-|"
        
        greyView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tempSetView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        viewDict.updateValue(greyView, forKey: "greyView")
        viewDict.updateValue(tempSetView, forKey: "tempView")
        
        
        let greyConstraintH:Array = NSLayoutConstraint.constraintsWithVisualFormat(greyViewStringH,
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: viewDict)
        let greyConstraintV:Array = NSLayoutConstraint.constraintsWithVisualFormat(greyViewStringV,
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: viewDict)
        let tempConstraintH:Array = NSLayoutConstraint.constraintsWithVisualFormat(tempViewStringH,
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: viewDict)
        
        let xCenterConstraint = NSLayoutConstraint(item: tempSetView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let yCenterConstraint = NSLayoutConstraint(item: tempSetView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: -100)
        let heightConstraint = NSLayoutConstraint(item: tempSetView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1/5, constant: 1)
        
        
        
        self.view.addConstraint(xCenterConstraint)
        self.view.addConstraint(yCenterConstraint)
        self.view.addConstraints(tempConstraintH)
        self.view.addConstraint(heightConstraint)
        
        
        
        tempSetView.layer.cornerRadius = 5
        tempSetView.layer.masksToBounds = true
        tempSetView.layer.borderColor = UIColor.blackColor().CGColor
        tempSetView.layer.borderWidth = 2
        greyView.backgroundColor = UIColor.grayColor()
        greyView.alpha = 9/10
        tempSetView.backgroundColor = JTKColors().orangeLight
        
        
        view.addConstraints(greyConstraintH)
        view.addConstraints(greyConstraintV)
        
        
        tempSetView.hidden = true
        greyView.hidden = true
        
        createTempSetInternals()
    }
    
    func createTempSetInternals(){
        var strings = Array<String>()
        strings.append("H:|-10-[away]-10-[switch]-10-[home][plus]")
        strings.append("V:|-8-[home][setPoint]")
        strings.append("V:|-8-[away][setPoint]")
        strings.append("H:|-4-[setPoint][minus]")
        strings.append("H:|-4-[setPointLabel][minus]")
        strings.append("V:|-8-[switch][setPoint][setPointLabel]-4-|")
        strings.append("V:|-4-[plus]-0-[minus]-4-|")
        strings.append("H:[plus]-4-|")
        strings.append("H:[minus]-4-|")
        
        var homeLabel = UILabel()
        homeLabel.text = "Home"
        var awayLabel = UILabel()
        awayLabel.text = "Away"
        awayLabel.textAlignment = NSTextAlignment.Right
       
        setPointSetLabel.text = "   Home Temperature"
        setPointSetLabel.textAlignment = NSTextAlignment.Center
        
        setPointLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        setPointSetLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        setPointLabel.text = "68°"
        setPointLabel.font = UIFont(name: setPointLabel.font.fontName, size: 50)
        setPointLabel.textAlignment = NSTextAlignment.Center
        
        var views = ["switch": homeAwaySwitch,
            "setPointLabel":setPointSetLabel,
            "setPoint":setPointLabel,
            "plus":plusButton,
            "minus":minusButton,
            "home":homeLabel,
            "away":awayLabel]
        
        homeAwaySwitch.state
        homeAwaySwitch.on = true
        homeAwaySwitch.addTarget(self, action:"homeAwayToggle:", forControlEvents: .TouchUpInside)
        plusButton.setImage(UIImage(named: "PlusImage"), forState: .Normal)
        plusButton.addTarget(self, action: "plusClick:", forControlEvents: UIControlEvents.TouchUpInside)
        minusButton.setImage(UIImage(named: "MinusImage"), forState: .Normal)
        minusButton.addTarget(self, action: "minusClick:", forControlEvents: UIControlEvents.TouchUpInside)
        plusButton.setImage(UIImage(named: "MinusImage"), forState: .Highlighted)
        minusButton.setImage(UIImage(named: "PlusImage"), forState: .Highlighted)
        plusButton.layer.cornerRadius = 3
        plusButton.layer.borderWidth = 1
        minusButton.layer.cornerRadius = 3
        minusButton.layer.borderWidth = 1
        
        for view1 in views{
            view1.1.setTranslatesAutoresizingMaskIntoConstraints(false)
            tempSetView.addSubview(view1.1)
        }
        for constraint in Range(start: 0, end: strings.count){
            let constraintArr:Array = NSLayoutConstraint.constraintsWithVisualFormat(strings[constraint],
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: views)
            
            tempSetView.addConstraints(constraintArr)
        }
        var pmHeight = NSLayoutConstraint(item: plusButton, attribute: .Height, relatedBy: .Equal, toItem:minusButton, attribute: .Height, multiplier: 1, constant: 0.0)
        var pWidth = NSLayoutConstraint(item: plusButton, attribute: .Width, relatedBy: .Equal, toItem:plusButton, attribute: .Height, multiplier: 1, constant: 0.0)
        var mWidth = NSLayoutConstraint(item: minusButton, attribute: .Width, relatedBy: .Equal, toItem:plusButton, attribute: .Width, multiplier: 1, constant: 0.0)
        var hwWidth = NSLayoutConstraint(item: homeLabel, attribute: .Width, relatedBy: .Equal, toItem:awayLabel, attribute: .Width, multiplier: 1, constant: 0.0)
        
        tempSetView.addConstraint(hwWidth)
        tempSetView.addConstraint(pmHeight)
        tempSetView.addConstraint(mWidth)
        tempSetView.addConstraint(pWidth)
        
    }
    
    func makeTime(){
        
        var Label1am_H: String = "H:[l1am]-0-|"
        var Label7am_H: String = "H:[l7am]-0-|"
        var Label12pm_H: String = "H:[l12pm]-0-|"
        var Label5pm_H: String = "H:[l5pm]-0-|"
        var Label11pm_H: String = "H:[l11pm]-0-|"
        var Hstrings = [Label1am_H, Label7am_H, Label12pm_H, Label5pm_H, Label11pm_H]
        
        var Label1am_V: String = "V:|[l1am]"
        var Label7am_V: String = "V:|[l7am]"
        var Label12pm_V: String = "V:|[l12pm]"
        var Label5pm_V: String = "V:|[l5pm]"
        var Label11pm_V: String = "V:|[l11pm]"
        var Vstrings = [Label1am_V, Label7am_V, Label12pm_V, Label5pm_V, Label11pm_V]
        
        var l1am: UILabel = UILabel()
        l1am.text = "1am -"
        l1am.font = UIFont(name: l1am.font.fontName, size: 14)
        var l7am: UILabel = UILabel()
        l7am.text = "7am -"
        l7am.font = UIFont(name: l7am.font.fontName, size: 17)
        var l12pm: UILabel = UILabel()
        l12pm.text = "12pm -"
        var l5pm: UILabel = UILabel()
        l5pm.text = "5pm -"
        l5pm.font = UIFont(name: l5pm.font.fontName, size: 17)
        var l11pm: UILabel = UILabel()
        l11pm.text = "11am -"
        l11pm.font = UIFont(name: l11pm.font.fontName, size: 14)
        
        var labels = [l1am, l7am, l12pm, l5pm, l11pm]
        
        times.updateValue(l1am, forKey: "l1am")
        times.updateValue(l7am, forKey: "l7am")
        times.updateValue(l12pm, forKey: "l12pm")
        times.updateValue(l5pm, forKey: "l5pm")
        times.updateValue(l11pm, forKey: "l11pm")
        
        //self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        timeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        for label:UILabel in labels {
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            timeView.addSubview(label)
        }
        
        for H in Range(start: 0, end: Hstrings.count){
            let constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat(Hstrings[H],
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: times)
            let constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat(Vstrings[H],
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: times)
            timeView.addConstraints(constraint_H)
            
            timeView.addConstraints(constraint_V)
        }
        var heightConstraint1 = NSLayoutConstraint(item: l1am, attribute: .Height, relatedBy: .Equal, toItem:timeView, attribute: .Height, multiplier: 2/24, constant: 0.0)
        
        var heightConstraint2 = NSLayoutConstraint(item: l7am, attribute: .Height, relatedBy: .Equal, toItem:timeView, attribute: .Height, multiplier: 14/24, constant: 0.0)
        var heightConstraint3 = NSLayoutConstraint(item: l12pm, attribute: .Height, relatedBy: .Equal, toItem:timeView, attribute: .Height, multiplier: 24/24, constant: 0.0)
        var heightConstraint4 = NSLayoutConstraint(item: l5pm, attribute: .Height, relatedBy: .Equal, toItem:timeView, attribute: .Height, multiplier: 34/24, constant: 0.0)
        var heightConstraint5 = NSLayoutConstraint(item: l11pm, attribute: .Height, relatedBy: .Equal, toItem:timeView, attribute: .Height, multiplier: 46/24, constant: 0.0)
        
        
        timeView.addConstraint(heightConstraint1)
        timeView.addConstraint(heightConstraint2)
        timeView.addConstraint(heightConstraint3)
        timeView.addConstraint(heightConstraint4)
        timeView.addConstraint(heightConstraint5)
    }
    
    func makeSegments(){
        var vertString: String = "V:|-1-"
        var posOffset = 2
        
        for (var i = 0 ; i < 24; i++){
            var viewNew = UILabel()
            homeAwayLabels.append(viewNew)
            viewNew.setTranslatesAutoresizingMaskIntoConstraints(false)
            bigView.addSubview(viewNew)
            var segmentName: String = "viewNew"+String(i)
            segmentsInView.updateValue(viewNew, forKey: segmentName)
            
            var viewsDictionary = [segmentName : viewNew]
            let viewNew_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[viewNew" + String(i) + "]-0-|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: viewsDictionary)
            var segmentVert = "[" + segmentName + "]"
            
            if i != 24-1{
                segmentVert += "-1-"
            }
            vertString += segmentVert
            
            
            bigView.addConstraints(viewNew_constraint_H)
            
            viewNew.text = "Home"
            
            
            viewNew.textAlignment = NSTextAlignment.Center
            var a = i/24
            viewNew.backgroundColor = JTKColors().softGreen
            viewNew.shadowColor = UIColor.clearColor()
            
        }
        
        for view in segmentsInView{
            var heightConstrainEqual = NSLayoutConstraint(item: view.1, attribute: .Height, relatedBy: .Equal, toItem: segmentsInView[segmentsInView.startIndex].1, attribute: .Height, multiplier: 1.0, constant: 0.0)
            bigView.addConstraint(heightConstrainEqual)
        }
        vertString += "-2-|"
        let viewNew_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat(vertString, options: NSLayoutFormatOptions(0), metrics: nil, views: segmentsInView)
        
        bigView.addConstraints(viewNew_constraint_V)
        
        
    }
    func createTempViews(){
        var vertString: String = "V:|-1-"
        var posOffset = 2
        
        for (var i = 0 ; i < 24; i++){
            var viewNew = UILabel()
            tempLabels.append(viewNew)
            viewNew.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            tempViewBig.addSubview(viewNew)
            //tempViewBig.backgroundColor = UIColor.blackColor()
            var segmentName: String = "viewNew"+String(i)
            segmentsInTempView.updateValue(viewNew, forKey: segmentName)
            
            var viewsDictionary = [segmentName : viewNew]
            let viewNew_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[viewNew" + String(i) + "]-0-|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: viewsDictionary)
            var segmentVert = "[" + segmentName + "]"
            
            if i != 24-1{
                segmentVert += "-1-"
            }
            vertString += segmentVert
            
            
            tempViewBig.addConstraints(viewNew_constraint_H)
            
            viewNew.text = "68"
            
            
            
            viewNew.textAlignment = NSTextAlignment.Center
            var a = i/24
            viewNew.backgroundColor = JTKColors().orangeLight
            viewNew.textColor = UIColor.blackColor()
            
        }
        
        for view in segmentsInTempView{
            var heightConstrainEqual = NSLayoutConstraint(item: view.1, attribute: .Height, relatedBy: .Equal, toItem: segmentsInTempView[segmentsInTempView.startIndex].1, attribute: .Height, multiplier: 1.0, constant: 0.0)
            tempViewBig.addConstraint(heightConstrainEqual)
        }
        vertString += "-2-|"
        let viewNew_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat(vertString, options: NSLayoutFormatOptions(0), metrics: nil, views: segmentsInTempView)
        
        tempViewBig.addConstraints(viewNew_constraint_V)
        
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent){
        if !touchMask{
            for touch:AnyObject in touches{
                lastView = []
                currentSegment = nil
                for segments in bigView.subviews as [UILabel]{
                    if (segments.frame.contains(touch.locationInView(bigView))){
                        currentSegment = segments
                        lastView.append(segments)
                        toggleSliver(segments)
                    }
                }
                
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        if !touchMask{
            for touch:AnyObject in touches{
                for segments in bigView.subviews as [UILabel]{
                    if (segments.frame.contains(touch.locationInView(bigView))){
                        
                        if(currentSegment != segments){
                            
                            if(lastView.last != segments){
                                if currentSegment == nil{
                                    lastView.append(segments)
                                    currentSegment = segments
                                    toggleSliver(segments)
                                }else{
                                    lastView.append(currentSegment!)
                                    currentSegment = segments
                                    toggleSliver(segments)
                                }
                            }else {
                                lastView.removeLast()
                                toggleSliver(currentSegment!)
                                currentSegment = segments
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if !touchMask{
            for touch:AnyObject in touches{
                for segments in bigView.subviews as [UILabel]{
                    if (segments.frame.contains(touch.locationInView(bigView))){
                        if lastView.last != segments{
                            lastView.append(segments)
                        }
                    }
                }
                if (!lastView.isEmpty){
                    greyView.hidden = false
                    tempSetView.hidden = false
                 
                    touchMask = true
                    lastView.append(currentSegment!)
                }
            }
        }else{
            for touch:AnyObject in touches{
                if (!tempSetView.frame.contains(touch.locationInView(greyView))){
                    greyView.hidden = true
                    tempSetView.hidden = true

                    touchMask = false
                    
                    setHomeTemps()
                }
            }
        }
    }
    func setHomeTemps(){
        for view in lastView{
            for n in 0...homeAwayLabels.count-1 {
                if view == homeAwayLabels[n]{
                    if homeAwaySwitch.on {
                        tempLabels[n].text = String(homeSetPoint)
                        view.backgroundColor = JTKColors().softGreen
                        view.text = "Home"
                    }else{
                        tempLabels[n].text = String(awaySetPoint)
                        view.backgroundColor = JTKColors().lightGrey
                        view.text = "Away"
                    }
                }
            }
            
        }
    }
    
    func toggleSliver(segment:UIView){
        if(segment.backgroundColor == JTKColors().lightGrey){
            segment.backgroundColor = JTKColors().darkerGrey
            var seg = segment as UILabel
            
            //seg.textAlignment = NSTextAlignment.Left
            
        } else if (segment.backgroundColor == JTKColors().softGreen){
            segment.backgroundColor = JTKColors().darkerGreen
            var seg = segment as UILabel
            
            //seg.textAlignment = NSTextAlignment.Center
        } else if (segment.backgroundColor == JTKColors().darkerGreen){
            segment.backgroundColor = JTKColors().softGreen
            var seg = segment as UILabel
            
            //seg.textAlignment = NSTextAlignment.Center
        } else {
            segment.backgroundColor = JTKColors().lightGrey
            var seg = segment as UILabel
            
            //seg.textAlignment = NSTextAlignment.Center
        }
    }
    
}

