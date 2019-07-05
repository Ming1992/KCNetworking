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
    
    func kc_loadingJson(json: Dictionary<String, Any>) {
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
    
    @IBOutlet weak var img_item: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        KCNetworking<KCTestUser>().sendRequest("https://api.m.900sui.com/api/u/Login", parameters: ["username":"18616733727","password":"123456"], responseItemBlock: { (eMsg, user) in
//            print(user.nick)
//        }, responseItemsBlock: nil)
        
        //  传参数
//        KCNetworking<KCTestUser>().sendRequest("https://api.m.900sui.com/api/u/Login", parameters: ["username":"18616733727","password":"123456"], responseItemBlock: { (eMsg, user) in
//            print(user.nick)
//        }, responseItemsBlock:{(eMsg, users) in
//            print(users)
//        })
        
        //  变量
//        KCNetworking<KCTestUser>().host("https://api.m.900sui.com/api").method("/u/Login").responseItemBlock { (eMsg, user) in
//
//        }.start()
        
//        let request = KCNetworking<KCTestUser>().host("https://api.m.900sui.com/api").method("/u/Login").responseItemBlock { (eMsg, user) in
//
//            }
//        request.start()
//        request.cancel()
        
//        KCNetworking<KCTestUser>().host("https://api.m.900sui.com/api").method("/u/Login").responseItemBlock { (eMsg, user) in
//
//            }.cancel()
        

        
//        KCNetworkSessionManager.downloadRequest("http://img.shutung.com:81/2018/07/10/5b4481465d1ca.jpg")

        //  下载图片数据
//        KCNetworkSessionManager.downloadRequest("http://img.shutung.com:81/2018/07/10/5b4481465d1ca.jpg", parameters: nil, progressBlock: { (progress) in
//            print(progress)
//        }) { (cacheFile) in
//
//            let image = UIImage.init(contentsOfFile: cacheFile)
//
//            self.img_item.image = image
//        }
        
//        KCNetworkSessionManager.downloadRequest("http://img.shutung.com:81/2018/07/10/5b4481465d1ca.jpg",finishedBlock:{ (cacheFile) in
//            let image = UIImage.init(contentsOfFile: cacheFile)
//            self.img_item.image = image
//        })
        
        //  上传数据
        
//        let filePath = Bundle.main.resourcePath?.appending("/1-1.jpg")
//        self.img_item.image = UIImage.init(contentsOfFile: filePath!)
//
//        let url = "http://upload.shutung.com:81/util/uploadimg?type=1"
        
//        KCNetworkSessionManager.uploadFileRequest(url, filePath: filePath!)
        
        return
        
        let operationQueue = OperationQueue.init()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = "测试线程队列"
        let operation1 = BlockOperation.init()
        operation1.addExecutionBlock {
            self.test1("任务1")
        }
        
        let operation2 = BlockOperation.init()
        operation2.addExecutionBlock {
            self.test1("任务2")
        }
        
        let operation3 = BlockOperation.init()
        operation3.addExecutionBlock {
            self.test1("任务3")
        }
        
        let operation4 = BlockOperation.init()
        operation4.addExecutionBlock {
            self.test1("任务4")
        }
        operationQueue.addOperations([operation1,operation2,operation3,operation4], waitUntilFinished: false)
    }
    
    func test1(_ testId: String){
        
        for index in 0..<10 {
            print(testId+":\(index)")
        }
//        print(OperationQueue.current?.name)
    }
}

