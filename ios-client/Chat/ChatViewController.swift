//
//  ViewController.swift
//  Chat
//
//  Created by Red5 on 4/21/15.
//
//

import UIKit

class ChatViewController: UIViewController {


    @IBOutlet weak var chatWindow: UITextView!
    @IBOutlet weak var userNames: UINavigationItem!
    @IBOutlet weak var msgTxtBox: UITextField!
    
//    let socket = SocketIOClient(socketURL: "localhost:8080")
    var socket: SocketIOClient!

    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.addHandlers()
//        self.socket.connect();
//        println(self.socket)

        // get usernames becuase segue and/or viewDidLoad did not load in time
        // for EnterNickViewController.emitNick()'s response of usernames???

        self.socket.emit("get usernames")

    }
    
    func addHandlers() {
        
        // receive chat messages
        self.socket.on("new message") { [weak self] data, ack in
            
//            println(data)
//            println("----------")
//            println(data?)
//            println("----------")
//            println(data!)
//            println("----------")
//            println(data?[0])
//            println("----------")
//            println(data![0])
            
//            switch (data!) {
//            switch (data![0]) {
//                case is NSString : println("it's a string")
//                case is NSArray : println("it's an array")
//               case is NSDictionary : println("it's a dictionary")
//                default: println("unknown")
//            }
            
//            println(data![0]["msg"])
         
            var nick = data![0]["nick"] as? NSString
            var msg = data![0]["msg"] as? NSString
            var chatText = self?.chatWindow.text
            self?.chatWindow.text = chatText! + nick! + ": " + msg! + "\n"
            println(chatText! + nick! + ": " + msg! + "\n")

        }
        
        // receive usernames
        self.socket.on("usernames") { data, ack in

//            println(data![0])
            
//            switch (data![0]) {
//                case is NSString : println("it's a string")
//                case is NSArray : println("it's an array")
//                case is NSDictionary : println("it's a dictionary")
//                default: println("unknown")
//            }
      
            self.userNames.title = (data![0] as NSArray).componentsJoinedByString(", ")

        }
        
        // receive whispers
        self.socket.on("whisper") { [weak self] data, ack in
            
            var nick = data![0]["nick"] as? NSString
            var msg = data![0]["msg"] as? NSString
            var chatText = self?.chatWindow.text
            self?.chatWindow.text = chatText! + nick! + "[whisper]: " + msg! + "\n"
        
        }
        
    }

    @IBAction func sendMessage(sender: AnyObject) {
        if (!msgTxtBox.text.isEmpty) {
            self.socket.emitWithAck("send message", msgTxtBox.text) (timeout: 0) { data in
                if (data![0] as Int == 0) {
                    var msg = data![0] as? NSString
                    var chatText = self.chatWindow.text
                    self.chatWindow.text = chatText! + "ERROR: " + msg! + "\n"
                }
            }
            msgTxtBox.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

