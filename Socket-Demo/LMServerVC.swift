//
//  LMServerVC.swift
//  Socket-Demo
//
//  Created by Macx on 2017/5/3.
//  Copyright © 2017年 lemon. All rights reserved.
//

import UIKit

class LMServerVC: UIViewController, GCDAsyncSocketDelegate {

    @IBOutlet weak var portTF: UITextField!
    
    var severProt = 8080
    
    @IBOutlet weak var msgTV: UITextView!
    
    var serverSocket : GCDAsyncSocket!
    
    var startIsSuccessful = false
    
    //保存服务器的socket
    var clientSockets : [GCDAsyncSocket]!
    
    @IBOutlet weak var msgTF: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        clientSockets = Array()
        
    }

    @IBAction func openServer(_ sender: UIButton) {
        serverSocket = GCDAsyncSocket()
        
        serverSocket.delegate = self
        serverSocket.delegateQueue = DispatchQueue.global()
        
        do {
            try serverSocket.accept(onPort: UInt16(severProt))
            print("server start successful!")
        } catch  {
            print("server start error!")
        }
        
    }

    @IBAction func sendMsg(_ sender: UIButton) {
        let msg = msgTF.text!
        
        // 1.处理请求，返回数据给客户端 ok
        let serviceStr:NSMutableString = NSMutableString()
        serviceStr.append(msg)
        serviceStr.append("\n")
        if (clientSockets.count == 0){
            return
        }
        let socket = clientSockets[0]
    
        socket.write(serviceStr.data(using: String.Encoding.utf8.rawValue)!, withTimeout: -1, tag: 1)
        socket.readData(withTimeout: -1, tag:3)
    }
    
    ///MARK - Delegate
    /*
     * 有客户端的socket连接到服务器
     */
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        
        if clientSockets.contains(newSocket) {
            print("已经存在！")
            return
        }else{
            clientSockets.append(newSocket)
            
        }
        
        let serviceStr:NSMutableString = NSMutableString()
        serviceStr.append("login successful\n")
        newSocket.write(serviceStr.data(using: String.Encoding.utf8.rawValue)!, withTimeout: -1, tag: 0)
        
        // 3.监听客户端有没有数据上传
        //timeout -1 代表不超时
        //tag 标识作用，现在不用，就写0
        newSocket.readData(withTimeout: -1, tag:2)

    }
    
    /*
     * 读取客户端请求的数据
     */
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        // 1 获取客户的发来的数据 ，把 NSData 转 NSString
        let readClientDataString : NSString? = NSString(data: data, encoding:String.Encoding.utf8.rawValue)
        print(readClientDataString!)
        
        DispatchQueue.main.async { 
            let showStr:NSMutableString = NSMutableString()
            showStr.append(self.msgTV.text)
            showStr.append(readClientDataString! as String)
            showStr.append("\n")
            self.msgTV.text = showStr as String
        }
        // 3.处理请求，返回数据给客户端 ok
        let serviceStr:NSMutableString = NSMutableString()
        serviceStr.append("ok\n")
        sock.write(serviceStr.data(using: String.Encoding.utf8.rawValue)!, withTimeout: -1, tag: 0)
        
        // 4每次读完数据后，都要调用一次监听数据的方法
        sock.readData(withTimeout: -1, tag:3)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("tag:" + String(tag))
        
    }
    

}
