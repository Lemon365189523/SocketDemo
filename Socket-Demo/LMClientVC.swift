//
//  LMClientVC.swift
//  Socket-Demo
//
//  Created by Macx on 2017/5/3.
//  Copyright © 2017年 lemon. All rights reserved.
//

import UIKit


class LMClientVC: UIViewController,GCDAsyncSocketDelegate {
    @IBOutlet weak var msgLB: UILabel!

    @IBOutlet weak var inputPortTF: UITextField!
    @IBOutlet weak var inputIPTF: UITextField!
    
    var clientSocket: GCDAsyncSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func receiveMsg(_ sender: UIButton) {
        
    }
    

    @IBAction func connetnServer(_ sender: UIButton) {
        if (inputPortTF.text?.isEmpty)! == false && inputIPTF.text?.isEmpty == false{
            
            clientSocket = GCDAsyncSocket()
            clientSocket.delegate = self
            clientSocket.delegateQueue = DispatchQueue.global()
            do {
                try clientSocket.connect(toHost: inputIPTF.text!, onPort: 8080)
            } catch {
                print("error")
            }
            
        }else{
            msgLB.text = "端口或IP不能为空"
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        //链接成功
        print("链接成功->端口:" + host + " port:" + String(port))
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        //与服务器断开
        print("断开服务器")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        //获取客户端发来的数据
        let readClientDataString: NSString? = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
        print(readClientDataString ?? "nil")
        
        DispatchQueue.main.async {
            
            guard  let str = readClientDataString else{
                self.msgLB.text = ""
                return
            }
            self.msgLB.text = String(str)
        }
        
        self.sendMsgWithString(msg: "OK")
        
    }
    
    func sendMsgWithString(msg: String){
        clientSocket.write(msg.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withTimeout: -1, tag: 0)
        
        // 每次读完数据后，都要调用一次监听数据的方法
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
}
