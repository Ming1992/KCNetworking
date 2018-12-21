//
//  ViewController.swift
//  KCNetworkDemo
//
//  Created by liaozhenming on 2018/12/20.
//  Copyright © 2018 ©2018 STAIONING BLOCK CHAIN Inc. All rights reserved.
//

import UIKit



class KCTestUser: NSObject {

    public var Tn: String = ""
    public var avatar: String = ""
    public var card_no: String = ""
    public var email: String = ""
    public var exp: String = ""
    public var nick: String = ""
    public var openId: String = ""
    public var phone: String = ""
    public var realname: String = ""
    public var sex: String = ""
    public var uid: String = ""
    
    override func kc_loadingJson(json: Dictionary<String, Any>) {
        let nick = json["nick"] as! String
        self.nick = nick
    }
}

class KCManager<T: NSObject>: NSObject {
    
    class func test()->[T]{
        let item = T()
        print("~~~~~~")
        print(item)
        print("~~~~~~")
        return [item]
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        KCNetworking<KCTestUser>().sendRequest("https://api.m.900sui.com/api/u/Login", parameters: ["username":"18616733727","password":"123456"], responseItemBlock: { (eMsg, user) in
//            print(user.nick)
//        }, responseItemsBlock: nil)
        
        //  传参数
        KCNetworking<KCTestUser>().sendRequest("https://api.m.900sui.com/api/u/Login", parameters: ["username":"18616733727","password":"123456"], responseItemBlock: { (eMsg, user) in
            print(user.nick)
        }, responseItemsBlock:{(eMsg, users) in
            print(users)
        })
        
        //  变量
        KCNetworking<KCTestUser>().host("https://api.m.900sui.com/api").method("/u/Login").responseItemBlock { (eMsg, user) in
            
        }.start()
    }
}

