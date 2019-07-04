//
//  KCNetwork.swift
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

//  String类的扩展
extension String {
    //  增加一个URL编码的方法
    public func URLEncode()->String?{
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.init(charactersIn: "!*'();:@&=+$,/?%#[]~").inverted)
    }
}

//  Dictionary类的扩展
extension Dictionary where Key == String, Value == CustomStringConvertible {
    //  增加一个URL编码的方法
    public func URLEncode()->String{
        var paramsArray = Array<String>()
        self.forEach { (key,value) in
            let kv = (key.URLEncode() ?? "") + "=" + (value.description.URLEncode() ?? "")
            paramsArray.append(kv)
        }
        return paramsArray.joined(separator: "&")
    }
    public func URLData()->Data {
        return self.URLEncode().data(using: .utf8)!
    }
    
    public func URLJsonData()->Data{
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return jsonData!
    }
}

//  NSObjectProtocol的扩展
extension NSObjectProtocol{
    //  增加一个Json加载的方法
    func kc_loadingJson(json: Dictionary<String, Any>){}
}


//  MARK: KCNetworking Class
class KCNetworking<T:NSObject>: NSObject {
    
    //  请求结果为一个对象回调
    public typealias KCNetworkResponseItemBlock<T> = ((String?,T)->())
    //  请求结果为一个对象组回调
    public typealias KCNetworkResponseItemsBlock<T> = ((String?,[T])->())

    fileprivate var _host: String = ""
    fileprivate var _method: String = ""
    fileprivate var _parameters: Dictionary<String,CustomStringConvertible> = [:]
    fileprivate var _encrypt: Bool = false
    fileprivate var _requestType: KCRequestType = .GET
    fileprivate var _responseItemBlock: KCNetworkResponseItemBlock<T>?
    fileprivate var _responseItemsBlock: KCNetworkResponseItemsBlock<T>?
    fileprivate var _httpHeaderField:Dictionary<String,String> = ["Content-Type":"application/json"]
    fileprivate var _executed: Bool = true
    
    fileprivate var dataTask: URLSessionDataTask?
    
    //  MARK: 发送请求
    //发送请求-完整链接+参数
    @discardableResult func sendRequest(_ URLString: String, parameters: Dictionary<String,CustomStringConvertible>? = nil, type: KCRequestType = .GET, encrypt: Bool = false, executed: Bool = true, responseItemBlock: KCNetworkResponseItemBlock<T>? = nil, responseItemsBlock: KCNetworkResponseItemsBlock<T>? = nil) -> URLSessionDataTask{
        
        let request = URLRequest.request(URLString: URLString, parameters: parameters, requestType: type,headerFields: self._httpHeaderField, encrypt: encrypt)
        let dataTask = KCNetworkSessionManager.sendRequest(request, executed: executed, responseBlock: { (responItem) in
            
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
        })
        return dataTask
    }
    
    //  发送请求-主机地址+方法名+参数
    @discardableResult func sendRequest(_ host: String, method: String, parameters: Dictionary<String,CustomStringConvertible>? = nil,type: KCRequestType = .GET, encrypt: Bool = false, executed: Bool = true, responseItemBlock: KCNetworkResponseItemBlock<T>? = nil, responseItemsBlock: KCNetworkResponseItemsBlock<T>? = nil) -> URLSessionDataTask{
        
        let url = host + method
        return self.sendRequest(url, parameters: parameters, type: type, responseItemBlock: responseItemBlock, responseItemsBlock: responseItemsBlock)
    }
    
    //  请求启动
    func start(){
        if self.dataTask == nil {
            self.dataTask = self.sendRequest(self._host, method: self._method, parameters: self._parameters, type: self._requestType, encrypt: self._encrypt, executed: false, responseItemBlock: self._responseItemBlock, responseItemsBlock: self._responseItemsBlock)
        }
        self.dataTask?.resume()
    }
    
    //  请求取消
    func cancel(){
        self.dataTask?.cancel()
    }
}

//  KCNetworking的扩展是为了链式操作
extension KCNetworking {
    public func host(_ host:String)-> Self{
        self._host = host
        return self
    }
    
    public func method(_ method: String)-> Self {
        self._method = method
        return self
    }
    
    public func parameters(_ parameters: Dictionary<String,CustomStringConvertible>)-> Self {
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

extension URLRequest {
    static func request(URLString:String,parameters:Dictionary<String,CustomStringConvertible>?,requestType:KCRequestType,headerFields:Dictionary<String,String>,encrypt:Bool = false)->URLRequest {
        
        var url = URL.init(string: URLString)
        var request = URLRequest.init(url: url!)
        
        switch requestType {
        case .GET,.PUT:
            let tmp_URLString = URLString + "?" + (parameters?.URLEncode())!
            url = URL.init(string: tmp_URLString)
            request = URLRequest.init(url: url!)
        case .POST,.DELETE:
            request.httpBody = parameters?.URLJsonData()
        }
        request.httpMethod = requestType.rawValue
        request.timeoutInterval = 15.0
        headerFields.forEach { (key,value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

//  MARK: KCNetworkResponseSerializer Class
class KCNetworkResponseSerializer: NSObject, URLSessionDownloadDelegate {
    
    fileprivate var progressBlock:KCNetworkSessionDownloadProgressBlock?
    fileprivate var finishedBlock:KCNetworkSessionDownloadFinishedBlock?
    
    static var serizlizer = KCNetworkResponseSerializer.init()
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
    
    //
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadTask:",downloadTask,"location:",location)
        if self.finishedBlock != nil {
            
            let requestURL = downloadTask.currentRequest?.url?.absoluteString
            let fileName = requestURL!.replacingOccurrences(of: "/", with: "_")
            let documents:String = NSHomeDirectory() + "/Documents/" + fileName
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: documents) {
                try! fileManager.removeItem(atPath: documents)
            }
            try! fileManager.moveItem(atPath: location.path, toPath: documents)
            
            self.finishedBlock!(documents)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("bytesWritten:",bytesWritten,"totalBytesWritten:",totalBytesWritten,"totalBytesExpectedToWrite:",totalBytesExpectedToWrite)
        if self.progressBlock != nil {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self.progressBlock!(progress)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
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


//  MARK: KCNetworkSessionManager Class
typealias KCNetworkSessionResponseItemBlock = (KCNetworkResponseItem)->()  //接口返回的数据Block
typealias KCNetworkSessionDownloadProgressBlock = ((Float)->())
typealias KCNetworkSessionDownloadFinishedBlock = ((String)->())
typealias KCNetworkSessionUploadFinishedBlock = (()->())

class KCNetworkSessionManager: NSObject {
    
    fileprivate var sessionQueue = OperationQueue.init()
    fileprivate var session: URLSession?
    
    static var manager = KCNetworkSessionManager.init()
    override init() {
        super.init()
        self.sessionQueue.name = "KCNetworkSessionQueue"
        //  暂时设定线程执行通道只可以为1
        self.sessionQueue.maxConcurrentOperationCount = 1
    }
    
    //  发送请求
    @discardableResult fileprivate class func sendRequest(_ request:URLRequest, executed:Bool = true, responseBlock: KCNetworkSessionResponseItemBlock?)->URLSessionDataTask {
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession.init(configuration: configuration, delegate: nil, delegateQueue: KCNetworkSessionManager.manager.sessionQueue)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            let item = KCNetworkResponseSerializer.response(data, response: response, error: error)

            print("当前线程.....",Thread.current,"主线程....",Thread.main)


            #if DEBUG
            print("请求->", request.url?.absoluteString ?? "")
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
    
    //  发送下载数据请求
    @discardableResult class func downloadRequest(_ URLString:String, parameters: Dictionary<String,Any>? = nil, progressBlock:KCNetworkSessionDownloadProgressBlock? = nil,finishedBlock:KCNetworkSessionDownloadFinishedBlock? = nil) -> URLSessionDownloadTask{
        
        if progressBlock == nil {
            let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: KCNetworkSessionManager.manager.sessionQueue)
            let dataTask = session.downloadTask(with: URL.init(string: URLString)!) { (location, response, error) in
                
                let locationPath = location!.path
                let fileName = URLString.replacingOccurrences(of: "/", with: "_")
                let documents:String = NSHomeDirectory() + "/Documents/" + fileName
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: documents) {
                    try! fileManager.removeItem(atPath: documents)
                }
                try! fileManager.moveItem(atPath: locationPath, toPath: documents)
                
                if finishedBlock != nil {
                    DispatchQueue.main.async {
                        finishedBlock!(documents)
                    }
                }
            }
            dataTask.resume()
            return dataTask
        }
        else {
            let configuration = URLSessionConfiguration.default
            let serizlizer = KCNetworkResponseSerializer.serizlizer
            serizlizer.progressBlock = progressBlock
            serizlizer.finishedBlock = finishedBlock
            let session = URLSession.init(configuration: configuration, delegate: serizlizer, delegateQueue: KCNetworkSessionManager.manager.sessionQueue)
            let dataTask = session.downloadTask(with: URL.init(string: URLString)!)
            dataTask.resume()
            return dataTask
        }
    }
    
    //  发送上传数据请求
    @discardableResult class func uploadDataRequest(_ URLString:String,from:Data,finishedBlock:KCNetworkSessionUploadFinishedBlock?=nil)->URLSessionUploadTask {
        let request = URLRequest.init(url: URL.init(string: URLString)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval.init())
        let dataTask = URLSession.shared.uploadTask(with: request, from: from) { (data, response, error) in
            
        }
        return dataTask
    }
    
    //  发送上传文件请求
    @discardableResult class func uploadFileRequest(_ URLString:String, filePath:String,finishedBlock:KCNetworkSessionUploadFinishedBlock?=nil)->URLSessionUploadTask {
        let request = URLRequest.init(url: URL.init(string: URLString)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval.init())
        let dataTask = URLSession.shared.uploadTask(with: request, fromFile: URL.init(fileURLWithPath: filePath)) { (data, response, error) in
//            print("data:",data,"response:",response,"error:",error)
        }
        dataTask.resume()
        return dataTask
    }
}


