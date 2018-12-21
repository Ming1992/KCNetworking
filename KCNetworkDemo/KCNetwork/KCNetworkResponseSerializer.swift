//
//  KCNetworkResponseSerializer.swift
//  KCNetworkDemo
//
//  Created by liaozhenming on 2018/12/20.
//  Copyright © 2018 ©2018 STAIONING BLOCK CHAIN Inc. All rights reserved.
//

import UIKit

class KCNetworkResponseSerializer: NSObject {
    
    class func response(_ data: Data?, response: URLResponse?, error: Error?, decrypt: Bool = false)->KCNetworkResponseItem{
        
        //  表示无数据返回
        let item = KCNetworkResponseItem()
        if data != nil {
            let result = String.init(data: data!, encoding: String.Encoding.utf8)
            item.responseString = result != nil ? result! : ""
            
            let obj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            item.result = obj
        }
        if error != nil{
            item.msg = (error?.localizedDescription)!
        }
        item.response = response
        return item
    }
}


class KCNetworkResponseItem: NSObject {
    fileprivate var result: Any?{
        didSet{
            if result is Dictionary<String,Any> {
                //  如果返回的数据对象是字典时，则处理
                let tmpDic = result as! Dictionary<String, Any>
                let code = tmpDic["code"]
                let msg = tmpDic["msg"]
                let tmpData = tmpDic["data"]
                
                if code is NSNumber {
                    self.code = (code as! NSNumber).intValue
                }
                else if code is String {
                    self.code = Int((code as! String))!
                }
                
                self.msg = msg as? String
                
                if self.code == 0 {
                    //  code为0时，则返回接口返回的数据
                    self.data = tmpData
                }
            }
        }
    }
    fileprivate var responseString: String = ""
    
    var response: URLResponse?
    
    var code: Int = 0
    var msg: String?
    var data: Any?
    
    //  获得打印语句
    func public_printLog(){
        print("返回值->", responseString)
    }
}
