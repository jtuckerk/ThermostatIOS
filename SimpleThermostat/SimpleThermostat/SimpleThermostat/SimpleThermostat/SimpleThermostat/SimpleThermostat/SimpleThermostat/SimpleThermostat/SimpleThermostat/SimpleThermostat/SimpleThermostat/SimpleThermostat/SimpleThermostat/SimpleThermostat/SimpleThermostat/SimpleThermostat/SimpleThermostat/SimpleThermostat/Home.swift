//
//  Home.swift
//  SimpleThermostat
//
//  Created by Tucker Kirven on 1/30/15.
//  Copyright (c) 2015 Tucker Kirven. All rights reserved.
//

import UIKit

class Home: NSObject {
    
    var name: String
    var temp: Int
    var setPoint: Int
    var message: String
    
    override init() {
        name = "Default Home Name"
        temp = 68
        setPoint = 68
        message = "no message"
    }
    init(n: String, sPoint: Int, msg: String){
        name = n
        setPoint = sPoint
        message = msg
        temp = 68
    }
   
    func increaseSetPoint(){
        ++setPoint
    }
    func decreaseSetPoint(){
        --setPoint
    }
    func nameHome(enteredName: String){
        name = enteredName
    }
    
    func sendMessage(msg: String){
        //socket code for sending message to the home
    }
    
}
