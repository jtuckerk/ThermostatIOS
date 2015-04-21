//
//  ScheduleViewController.swift
//  SimpleThermostat
//
//  Created by Tucker Kirven on 3/25/15.
//  Copyright (c) 2015 Tucker Kirven. All rights reserved.
//

import Foundation

import UIKit



class scheduleViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var thermostatButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    func dayOfWeekSend(sender: AnyObject) {
        appDelegate.connection!.getSchedule()

        self.performSegueWithIdentifier("dayOfWeek", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.currVC = self
        
        self.view.backgroundColor = JTKColors().backgroundColor
        constructDayButtons()
        
        scheduleButton.backgroundColor = JTKColors().orangeLight
        thermostatButton.backgroundColor = JTKColors().orangeDark
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "dayOfWeek"{
        var controller: DayScheduleViewController = segue.destinationViewController as DayScheduleViewController
        var identifier1 = segue.identifier
        var sender1 = sender!.currentTitle
        controller.day = sender1!!
        }
    }
    
    func constructDayButtons(){
        
        backgroundView.backgroundColor = JTKColors().backgroundColor
        
        var views = [String:UIButton]()
        var constraintStrings = ["V:|"]
        for day in daysOfWeek {
            var button = UIButton()
            button.backgroundColor = JTKColors().orangeLight
            button.setTitle(day, forState: .Normal)
            button.layer.cornerRadius = 10
            
            button.addTarget(self, action: "dayOfWeekSend:", forControlEvents: UIControlEvents.TouchUpInside)
            
            backgroundView.addSubview(button)
            
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            views.updateValue(button, forKey: day)
            
            var topDist = 5
           
            
            if day == "Monday"{
                topDist = 20
            }
            
            constraintStrings[0] += "-" + String(topDist) + "-[" + day + "]"
            constraintStrings.append("H:|-60-[" + day + "]-60-|")
        }
        
        constraintStrings[0] += "-20-|"
        for const in constraintStrings {
            let constraint:Array = NSLayoutConstraint.constraintsWithVisualFormat(const,
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: views)
            
            backgroundView.addConstraints(constraint)
        }
        
        for viewA in backgroundView.subviews {
            var heightConstrainEqual = NSLayoutConstraint(item: viewA, attribute: .Height, relatedBy: .Equal, toItem: backgroundView.subviews[0], attribute: .Height, multiplier: 1.0, constant: 0.0)
            
            backgroundView.addConstraint(heightConstrainEqual)
        }
    }
   
}
