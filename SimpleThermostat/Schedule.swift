//
//  Schedule.swift
//  SimpleThermostat
//
//  Created by Tucker Kirven on 3/26/15.
//  Copyright (c) 2015 Tucker Kirven. All rights reserved.
//

import Foundation
import UIKit

class schedule: NSObject {
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var segmentsPerHour = 4
    
    var scheduleDict:[String: Array<[String:AnyObject]>]
    
    var defaultSegment = ["setPoint":68, "status":"Home"]
    
    var dayArray :Array<String> = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    //holds current values for the thermostat
    var currentHomeTemp = 68
    var currentSegment: [String: AnyObject] = ["setPoint":68, "status":"Home"]
    var currentHVACStatus = "Off"
    
    override init(){
        
        //initialize schedule structure
        scheduleDict = Dictionary<String, Array<[String:AnyObject]>>()
        scheduleDict.updateValue([], forKey: "Monday")
        scheduleDict.updateValue([], forKey: "Tuesday")
        scheduleDict.updateValue([], forKey: "Wednesday")
        scheduleDict.updateValue([], forKey: "Thursday")
        scheduleDict.updateValue([], forKey: "Friday")
        scheduleDict.updateValue([], forKey: "Saturday")
        scheduleDict.updateValue([], forKey: "Sunday")
        
        //sets each segment in schedule to home at 68 degrees
        for day in scheduleDict{
            var arr: Array<[String:AnyObject]> = []
            for(var i = 0; i<24*segmentsPerHour; ++i){
                arr.append(defaultSegment)
            }
            scheduleDict.updateValue(arr, forKey: day.0)
            
        }
        super.init()
        
    }
    
    //Gets phone time and returns a Day, Hour, Minute, Second Array DHMS
    func getTime() -> Array<Int>{
        var date: NSDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components( .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.stringFromDate(date)
        
        var day = find(dayArray, dayOfWeekString)!
        
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        return [day, hour, minute, second]
        
    }
    
    
    //takes a day and an array with segment objects containing home/away status and a
    // set point temp for each segment.
    // this implementation only supports 1 segment per hour
    func setSegments(day: String, sched: Array<[String:AnyObject]>){
        
        for i in 0...23{
            var temp = sched[i]
            
            for j in 0...(segmentsPerHour-1){
                scheduleDict[day]![i*segmentsPerHour + j] = temp
                
            }
        }
    }
    
    // Gets an of segments for a day
    func getSegments(day:String)->Array<[String:AnyObject]>{
        var arr24Hour = Array<[String:AnyObject]>()
        for (var n=0; n<scheduleDict[day]!.count-1 ; n++) {
            if(n%segmentsPerHour == 0 ){
                arr24Hour.append( scheduleDict[day]![n])
            }
        }
        
        return arr24Hour
        
    }
    
    // Gets a json representation of the current schedule held on the IOS device
    func getJsonSchedule()->String{
        let tmpSched = scheduleDict
        
        //the JSON Stringify causes issues with the sched object - assigning a value to itself ensures
        // that a copy is created so that the reference to the scheduleDict cannot be corrupted
        var tmp2 = tmpSched
        tmp2["Friday"]![0] = tmpSched["Friday"]![0]
        var stringDict =  JSONStringify(tmp2 , prettyPrinted: true)
        
        return stringDict
    }
    
    // sets schedule to a new schedule passed in
    func setSched(schedDict: Dictionary<String, Array<[String:AnyObject]>>){
        scheduleDict = schedDict
    }
    
    //gets segment at a certain time as specified by [day, hour, minute, second]
    func getTimeSegment(DHMStuple:Array<Int>)->[String:AnyObject]{
        var abTuple = getSegmentCoordinates(DHMStuple)
        var day = dayArray[abTuple[0]]
        var b = abTuple[1] as Int
        return scheduleDict[day]![b]
    }
    
    //sets segment at a certain time as specified by [day, hour, minute, second]
    func setTimeSegment(DHMStuple:Array<Int>, segment: [String:AnyObject]){
        var abTuple = getSegmentCoordinates(DHMStuple)
        setSegmentWithABtuple(abTuple, segment: segment)
    }
    
    //used to set segment for the exact array position of the time represented as an (day, segment) tuple
    func setSegmentWithABtuple(abTuple:Array<Int>, segment:[String:AnyObject]){
        var day = dayArray[abTuple[0]]
        var b = abTuple[1] as Int
        scheduleDict[day]![b] = segment
    }
    
    //sets a range of segments
    func setSegmentRange(startDHMS:Array<Int>, endDHMS:Array<Int>, segment:[String:AnyObject]){
        var startTuple = getSegmentCoordinates(startDHMS)
        var endTuple = getSegmentCoordinates(endDHMS)
        while(startTuple[0] < endTuple[0]){
            while(startTuple[1] < segmentsPerHour*24){
                self.setSegmentWithABtuple(startTuple, segment: segment)
                print(startTuple)
                startTuple[1]+=1
            }
            startTuple[1]=0
            startTuple[0]+=1
        }
        
        while(startTuple[1] <= endTuple[1]){
            self.setSegmentWithABtuple(startTuple, segment: segment)
            startTuple[1]+=1
        }
    }
    
    //used to get the coordinates of a segment in the schedule dictionary's arrays
    func getSegmentCoordinates(DHMStuple:Array<Int>)->Array<Int>{
        var day = DHMStuple[0]
        var hour = DHMStuple[1]
        var minute = DHMStuple[2]
        var second = DHMStuple[3]
        
        var a = day
        var b = hour*segmentsPerHour + Int(minute/(60/segmentsPerHour))
        return [a,b]
    }
    
    //gets the segment temp setpoint and status for current time
    func getCurrentSeg()->[String:AnyObject]{
        return getTimeSegment(getTime())
    }
    
    //Accesses the wall device using the app wired connection object to update
    // the current home temperature, status and setpoint
    func updateCurrent(){
        //appDelegate.connection!.getSchedule()
        appDelegate.connection!.getTemp()
        appDelegate.connection!.getHVACstatus()
        var tmp = getCurrentSeg()
        currentSegment["setPoint"] = tmp["setPoint"]
        currentSegment["status"] = tmp["status"]
        
    }
    
    //increases setpoint of current segment only
    func increaseSetPoint(){
        var tmp = currentSegment["setPoint"] as Int
        tmp += 1
        currentSegment["setPoint"] = tmp as AnyObject
        
    }
    
    //decreases setpoint of current segment only
    func decreaseSetPoint(){
        var tmp = currentSegment["setPoint"] as Int
        tmp -= 1
        currentSegment["setPoint"] = tmp as AnyObject
    }
    
    //sets segments for a period following the current time
    func setSetPointTemporary(){
        var endTime = getTime()
        endTime = addTime(endTime, days: 0, hours: 2, minutes: 0,seconds: 0)
        setSegmentRange(getTime(), endDHMS: endTime, segment: currentSegment)
    }
    
    // adds certain amount of time to DHMS input and returns a DHMS format time
    func addTime(timeDHMS:Array<Int>, days:Int, hours: Int, minutes: Int, seconds:Int)->Array<Int>{
        var addtime = [days,hours,minutes,seconds]
        var result = [0,0,0,0]
        var carry:Int = 0
        for n in 2...3{
            result[n]  += (timeDHMS[n] + addtime[n])
            if result[n] >= 60{
                result[n] = result[n]%60
                result[n-1] += 1
            }
        }
        result[1]  += (timeDHMS[1] + addtime[1])
        if result[1] >= 24{
            result[1] = result[1]%24
            result[0] += 1
        }
        result[0] = result[0]%7
        
        return result
    }
    
    //sets device temp - used for demo purposes only
    func setTemp(temp: Int){
        appDelegate.connection!.setTemp(temp)
    }
    
}