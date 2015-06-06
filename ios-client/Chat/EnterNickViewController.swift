//
//  EnterNickViewController.swift
//  Chat
//
//  Created by Red5 on 4/22/15.
//
//

import UIKit

class EnterNickViewController: UIViewController {

    @IBOutlet weak var enterNickTxt: UITextField!
    @IBOutlet weak var enterNickErrorMsg: UILabel!
  
    
    let socket = SocketIOClient(socketURL: "localhost:8080")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.socket.connect()
        //println(self.socket)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func validateEnterNick () -> Bool {
        if enterNickTxt.text.isEmpty {
            enterNickErrorMsg.text =  "Nickname cannot be blank\n"
            enterNickErrorMsg.hidden = false
            return false
        }
        
        return true
    }
    
    func emitNick (callback: (Bool) -> Bool) {
        
        self.socket.emitWithAck("new user", enterNickTxt.text) (timeout: 0) { data in
            //println(data)
            if (data![0] as Int == 0) {
                self.enterNickErrorMsg.text = "Username is already taken!"
                self.enterNickErrorMsg.hidden = false
                callback(false)
            } else {
                self.enterNickErrorMsg.hidden = true
                callback(true)
            }

        }

    }
   
    @IBAction func sendNick(sender: AnyObject) {
    
        if (validateEnterNick()) {
            
            emitNick() { data in

                if data {
                    self.performSegueWithIdentifier("EnterNickSuccessSegue", sender: self)
                }
                return true
            }

        }
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "EnterNickSuccessSegue") {
            var nextViewController = (segue.destinationViewController as ChatViewController)
            nextViewController.socket = self.socket
        }
    }



    
}
