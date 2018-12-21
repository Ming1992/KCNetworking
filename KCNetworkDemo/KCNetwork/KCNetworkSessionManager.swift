//
//  KCNetworkSessionManager.swift
//  KCNetworkDemo
//
//  Created by liaozhenming on 2018/12/20.
//  Copyright © 2018 ©2018 STAIONING BLOCK CHAIN Inc. All rights reserved.
//

import UIKit

enum KCRequestType: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

typealias KCNetworkSessionResponseBlock = (KCNetworkResponseItem)->()  //接口返回的数据Block

class KCNetworkSessionManager: NSObject {
    
    @discardableResult class func sendRequest(_ URLString: String, parameters: Dictionary<String,Any>? = nil, type: KCRequestType = .GET, encrypt: Bool = false, executed:Bool = true, responseBlock: KCNetworkSessionResponseBlock?) -> URLSessionDataTask{
        
        let request = KCNetworkRequestSerializer.serizlizer.request(URLString, parameters: parameters, requestType: type, encrypt: encrypt)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            let item = KCNetworkResponseSerializer.response(data, response: response, error: error)
            
            #if DEBUG
            print("请求->", URLString)
            print("参数->", parameters ?? [:])
            item.public_printLog()
            #endif
            
            if responseBlock != nil {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    responseBlock!(item)
                }
            }
        }
        
        if executed {
            //  立即执行
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            dataTask.resume()
        }
        return dataTask
    }
}
