//
//  Socket.swift
//  SimpleThermostat
//
//  Created by Tucker Kirven on 1/30/15.
//  Copyright (c) 2015 Tucker Kirven. All rights reserved.
//

import UIKit


class JTKSocket: NSObject {
    var socketQueue: dispatch_queue_t
    var listenSocket: GCDAsyncSocket //GCDAsyncSocket *listenSocket;
    var connectedSockets:NSMutableArray    // NSMutableArray *connectedSockets;
    
    init(socketQueue: dispatch_queue_t, listenSocket: GCDAsyncSocket, connectedSockets:NSMutableArray){
        self.socketQueue = socketQueue
        self.listenSocket = listenSocket
        self.connectedSockets = connectedSockets
    }
    
    
}
