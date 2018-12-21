//
//  KCNetworkRequestSerializer.swift
//  KCNetworkDemo
//
//  Created by liaozhenming on 2018/12/20.
//  Copyright © 2018 ©2018 STAIONING BLOCK CHAIN Inc. All rights reserved.
//

import UIKit

class KCNetworkRequestSerializer: NSObject {
    
    fileprivate var allHTTPHeaderFields: Dictionary<String,String> = [:]
    
    static var serizlizer = KCNetworkRequestSerializer.init()
    
    public func request(_ URLString: String, parameters: Dictionary<String,Any>?, requestType: KCRequestType, encrypt: Bool = false) -> URLRequest {
        
        var url = URL.init(string: URLString)
        var request = URLRequest.init(url: url!)
        
        switch requestType {
        case .GET:
            let tmp_URLString = URLString + "?" + self.getRequestParameterString(parameters: parameters, encrypt: encrypt)
            url = URL.init(string: tmp_URLString)
            request = URLRequest.init(url: url!)
        case .POST:
            request.httpBody = self.getRequestParameterData(parameters: parameters, encrypt: encrypt)
        case .PUT:
            let tmp_URLString = URLString + "?" + self.getRequestParameterString(parameters: parameters, encrypt: encrypt)
            url = URL.init(string: tmp_URLString)
            request = URLRequest.init(url: url!)
        case .DELETE:
            request.httpBody = self.getRequestParameterData(parameters: parameters)
        }
        request.httpMethod = requestType.rawValue
        request.timeoutInterval = 15.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    public func addValue(_ value: String, forHTTPHeaderField headerField: String) {
        self.allHTTPHeaderFields[headerField] = value
    }
    
    //  MARK: fileprivate func methods
    fileprivate func getRequestParameterString(parameters: Dictionary<String,Any>?, encrypt: Bool = false)->String{
        if parameters == nil {
            return ""
        }
        var parameterString = ""
        for key in (parameters?.keys)! {
            if parameterString.count != 0 {
                parameterString += "&"
            }
            parameterString += (key + "=")
            let value = parameters![key]
            if value is String {
                parameterString += (value as! String)
            }
            else if value is Bool {
                parameterString += "\(value as! Bool)"
            }
            else if value is Int {
                parameterString += "\(value as! Int)"
            }
            else if value is Double {
                parameterString += "\(value as! Double)"
            }
            else if value is Float {
                parameterString += "\(value as! Float)"
            }
        }
        return parameterString
    }
    
    fileprivate func getRequestParameterData(parameters: Dictionary<String,Any>?, encrypt: Bool = false)->Data{
        if parameters == nil {
            return Data.init()
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters!, options: .prettyPrinted)
        return jsonData!
    }
}
