//
//  KCNetwork.swift
//  KCNetworkDemo
//
//  Created by liaozhenming on 2018/12/20.
//  Copyright © 2018 ©2018 STAIONING BLOCK CHAIN Inc. All rights reserved.
//

import UIKit

class KCNetworking<T:NSObject>: NSObject {
    
    public typealias KCNetworkResponseItemBlock<T> = ((String?,T)->())
    public typealias KCNetworkResponseItemsBlock<T> = ((String?,[T])->())

    fileprivate var _host: String = ""
    fileprivate var _method: String = ""
    fileprivate var _parameters: Dictionary<String,Any> = [:]
    fileprivate var _encrypt: Bool = false
    fileprivate var _requestType: KCRequestType = .GET
    fileprivate var dataTask: URLSessionDataTask?
    fileprivate var _responseItemBlock: KCNetworkResponseItemBlock<T>?
    fileprivate var _responseItemsBlock: KCNetworkResponseItemsBlock<T>?
    
    @discardableResult func sendRequest(_ URLString: String, parameters: Dictionary<String,Any>? = nil, type: KCRequestType = .GET, encrypt: Bool = false, executed: Bool = true, responseItemBlock: KCNetworkResponseItemBlock<T>? = nil, responseItemsBlock: KCNetworkResponseItemsBlock<T>? = nil) -> URLSessionDataTask{
        
        let dataTask = KCNetworkSessionManager.sendRequest(URLString, parameters: parameters, type: type, executed:executed) { (responItem) in
            if responseItemBlock != nil {
                let item = T()
                if responItem.data != nil && responItem.data is Dictionary<String,Any>{
                    item.kc_loadingJson(json: responItem.data as! Dictionary<String, Any>)
                }
                responseItemBlock!(responItem.msg,item)
            }
            if responseItemsBlock != nil {
                var items:Array<T> = []
                if responItem.data != nil {
                    if responItem.data is Array<Dictionary<String,Any>>{
                        let tmpArray = responItem.data as! Array<Dictionary<String,Any>>
                        for tmpItem in tmpArray {
                            let item = T()
                            item.kc_loadingJson(json: tmpItem)
                            items.append(item)
                        }
                    }
                    else if responItem.data is Dictionary<String,Any>{
                        let tmpDictionary = responItem.data as! Dictionary<String,Any>
                        let item = T()
                        item.kc_loadingJson(json: tmpDictionary)
                        items.append(item)
                    }
                }
                responseItemsBlock!(responItem.msg,items)
            }
        }
        return dataTask
    }
    
    @discardableResult func sendRequest(_ host: String, method: String, parameters: Dictionary<String,Any>? = nil,type: KCRequestType = .GET, encrypt: Bool = false, executed: Bool = true, responseItemBlock: KCNetworkResponseItemBlock<T>? = nil, responseItemsBlock: KCNetworkResponseItemsBlock<T>? = nil) -> URLSessionDataTask{
        
        let url = host + method
        return self.sendRequest(url, parameters: parameters, type: type, responseItemBlock: responseItemBlock, responseItemsBlock: responseItemsBlock)
    }
    
    func start(){
        
        if self.dataTask == nil {
            self.dataTask = self.sendRequest(self._host, method: self._method, parameters: self._parameters, type: self._requestType, encrypt: self._encrypt, executed: false, responseItemBlock: self._responseItemBlock, responseItemsBlock: self._responseItemsBlock)
        }
        self.dataTask?.resume()
    }
}

extension KCNetworking {
    public func host(_ host:String)-> Self{
        self._host = host
        return self
    }
    
    public func method(_ method: String)-> Self {
        self._method = method
        return self
    }
    
    public func parameters(_ parameters: Dictionary<String,Any>)-> Self {
        self._parameters = parameters
        return self
    }
    
    public func encrypt(_ encrypt: Bool)-> Self {
        self._encrypt = encrypt
        return self
    }
    
    public func requestType(_ requestType: KCRequestType)-> Self {
        self._requestType = requestType
        return self
    }
    
    public func responseItemBlock(_ responseItemBlock: @escaping KCNetworkResponseItemBlock<T>)-> Self {
        self._responseItemBlock = responseItemBlock
        return self
    }
    
    public func responseItemsBlock(_ responseItemsBlock: @escaping KCNetworkResponseItemsBlock<T>)-> Self {
        self._responseItemsBlock = responseItemsBlock
        return self
    }
}

extension NSObject {
    @objc func kc_loadingJson(json: Dictionary<String, Any>) {
        
    }
}
