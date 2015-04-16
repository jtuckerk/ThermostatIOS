//
//  WiredController.swift
//  SimpleThermostat
//
//  Created by Tucker Kirven on 3/25/15.
//  Copyright (c) 2015 Tucker Kirven. All rights reserved.
//

import Foundation
import UIKit

class WiredController: NSObject {
    
    var socketQueue:dispatch_queue_t!
    var listenSocket:GCDAsyncSocket!
    var connectedSockets:NSMutableArray!
    var status = "Not Connected"
    var sentCount = 0
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var incomingMessageQueue = [String]()
    func bigSendTest(){
        sendMsg(["type": "bigSend"])
        
        for socket in connectedSockets
        {
            socket.readDataWithTimeout(-1, tag: 60)
        }
    }
    func sendSchedule(){
        var commandStr = "setSchedule"
        var dict:Dictionary<String,Array<[String:AnyObject]>> = appDelegate.sched!.scheduleDict
        dict["Friday"]![0] = dict["Friday"]![0]
        var messageObj = ["type": commandStr, "schedule": dict]
        sendMsg(messageObj)
        
        
    }
    func sendDay(day: String){
        var commandStr = "setDay"
        var dayObj: Array<[String:AnyObject]> = appDelegate.sched!.scheduleDict[day]!
        dayObj[0] = dayObj[0]
        var messageObj = ["type": commandStr, "schedule": dayObj, "day": day]
        sendMsg(messageObj)
    }
    func getSchedule(){
        var commandStr = "getSchedule"
        
        var messageObj = ["type": commandStr]
        sendMsg(messageObj)

        for socket in connectedSockets
        {
           socket.readDataWithTimeout(-1, tag: 1)
        }
    }
    func getTemp(){
        var messageObj = ["type": "getTemp"]
        sendMsg(messageObj)
        for socket in connectedSockets
        {
            socket.readDataWithTimeout(-1, tag: 1)
        }
    }
    func setTemp(temp:Int){
        var messageObj = ["type": "setTemp", "temp":temp]
        sendMsg(messageObj)
    }
    func setTime(timeDHMS: Array<Int>){
        var messageObj = ["type": "setTime", "time":timeDHMS]
        sendMsg(messageObj)
    }
    func getHVACstatus(){
        var messageObj = ["type": "getHVACstatus"]
        sendMsg(messageObj)
        for socket in connectedSockets
        {
            socket.readDataWithTimeout(-1, tag: 1)
        }
    }
    
    func sendMsg(msgObj: AnyObject){
        var msgString = JSONStringify(msgObj, prettyPrinted: false)
        var msgData:NSData = msgString.dataUsingEncoding(NSUTF8StringEncoding)!
        var sock:GCDAsyncSocket
        
        //print("Sent" + msgString + "\n")
        
        //message.text = ("writing \(msg) to \(socket) \n")
        
        for socket in connectedSockets
        {
           
            sentCount++
            //status = "sent count is " + String(sentCount)
            //print("Sent" + msgString + "\n")
           
            //message.text = ("writing \(msg) to \(toString(socket)) \n")
            socket.writeData(msgData, withTimeout: -1, tag: 0) //need to add timeout and tag?
            
        }
        
    }
    func socket(sender: GCDAsyncSocket!,  didReadData data:NSData!, withTag tag:CLong){
        
        if tag == 1{
            var string1 = NSString(data: data, encoding: NSUTF8StringEncoding)
            status = string1!
            
            parseMultMsg(status)
            while (incomingMessageQueue.count != 0){
                var msgDict = JSONParseDictionary(incomingMessageQueue.last!) as [String:AnyObject]
                println("message parsed as \(incomingMessageQueue.last!)")
                incomingMessageQueue.removeLast()
                if msgDict.count != 0 {
                    var type = msgDict["type"]! as String
                    var msgDict = msgDict as  [String:AnyObject]
                    
                    
                    switch type{
                    case "getSchedule":
                        gotSchedule(msgDict)
                    case "getTemp":
                        gotTemp(msgDict)
                    case "getHVACstatus":
                        gotHVACstatus(msgDict)
                    default:
                        print("no function")
                    }
                    
                    
                }else{
                    NSLog("incomplete or corrupt message: " + string1!)
                }
            }
        }

    }
    func parseMultMsg(str: String){
        var size = countElements(str)

        if (str != "" && ( str[str.startIndex] != "{" || str[advance(str.startIndex, size-1)] != "}")){
            print( "corrupt message")
        }
        else{
            var start = 0
            var end = 0
            var count = 0
            for c in str{
                if (c == "{"){
                    count += 1
                }
                if (c == "}"){
                    count -= 1
                }
                end += 1
                if count == 0{
                //push string
                    //print "pushing: " + msg[start:end]
                    var startIndex1 = advance(str.startIndex, start)
                    var endIndex1 = advance(str.startIndex, end)
                    var range = Range(start: startIndex1, end: endIndex1)
                    incomingMessageQueue += [str[range]]
                    //self.incomingMsgQueue.put(msg[start:end])
                    start = end
                }
            }
        }
        
    }
    func gotTemp(msgObj: [String:AnyObject]  ){
        var temp = msgObj["obj"] as Int
        appDelegate.sched!.currentHomeTemp = temp
        
    }
    
    func gotHVACstatus(msgObj: [String:AnyObject]  ){
        var HVACstatus = msgObj["obj"] as String
        //print ("got current HVAC status: \(HVACstatus)")
        appDelegate.sched!.currentHVACStatus = HVACstatus
    }
    
    func gotSchedule(msgObj: [String:AnyObject]  ){
        var sentSched = msgObj["obj"] as Dictionary<String, Array<[String:AnyObject]>>
        
        appDelegate.sched!.setSched(sentSched)
    }

    override init(){
        super.init()
        socketQueue = dispatch_queue_create("socketQueue", nil)
        
        listenSocket = GCDAsyncSocket(delegate:self, delegateQueue:socketQueue)
        
        connectedSockets = NSMutableArray(capacity: 1)
        
        
        
        var port:UInt16 = 2345;
        var err:NSError?
        
        while(!listenSocket.acceptOnPort(port, error: &err))
        {
          
            status = "Not Connected post init"
            NSLog("error starting server");
            NSLog("goofed %@",err!);
            
            return;
        }

    }
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket:GCDAsyncSocket!){
        // This method is executed on the socketQueue (not the main thread)
        
        synced(connectedSockets)
            {
                self.connectedSockets.addObject(newSocket);
                self.status = "added socket to list"
                
        }
        var host:String = newSocket.connectedHost
        
        var port: UInt16 = newSocket.connectedPort
        
        status = "Accepted client " + String(host) + ":" + String(port)
  
            
            connectionAlert()
    
       
        
    }
    
    func connectionAlert(){
        
        let alert = UIAlertController(title: "Connected!", message: "Schedule on Phone and Schedule on device conflict", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "Use Schedule on Phone", style: UIAlertActionStyle.Default)  { (UIAlertAction) -> Void in
            self.appDelegate.connection!.sendSchedule()
        self.appDelegate.didNotDisplayUpdate = false}
        let alertAction2 = UIAlertAction(title: "Use existing Device Schedule", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.appDelegate.connection!.getSchedule()
        self.appDelegate.didNotDisplayUpdate = false}
        alert.addAction(alertAction)
        alert.addAction(alertAction2)
        
        
        if appDelegate.currVC != nil{
            appDelegate.currVC!.presentViewController(alert, animated: true) { () -> Void in }
        }
    }
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err:NSError!)
    {
        if (sock != listenSocket)
        {
            status = ("client disconnected");
            
            synced(connectedSockets)
                {
                    self.connectedSockets.removeObject(sock)
            }
        }
    }
    
    func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
}

