//
//  HttpTool.swift
//  SwiftTest
//
//  Created by Binfeng Peng - Vendor on 2019/3/13.
//  Copyright © 2019年 Binfeng Peng - Vendor. All rights reserved.
//

import UIKit

// 闭包可作为函数的参数来调用,执行回调
class HttpTool: NSObject {
    
    //单例 --  方法1
    static let shareInstance = HttpTool()
    
    //单例 --  方法2
    class func shareHttpTool()->HttpTool{
        struct Singleton{
            static var single:HttpTool?
        }
        
        DispatchQueue.once {
            Singleton.single = HttpTool()
        }

        return Singleton.single!
    }
    
    //定义一个闭包函数
    var block: ((String)->Void)?
    
    func tap() {
        if (self.block != nil) {
            self.block!("上个页面回来的")
        }
    }
    
    //static也可以声明类方法 但是static和class只能用一个
    
    // 只有闭包参数
    class func loadData(finishedCallBack: @escaping (String) -> ()) {
        //1.在全局队列中做耗时操作
        DispatchQueue.global().async {            //在全局队列中休眠
            Thread.sleep(forTimeInterval: 1)            //2.在主队列中回调数据
            DispatchQueue.main.async {                //执行闭包
                finishedCallBack("哈哈哈哈哈哈哈哈哈")
            }
        }
    }
    
    // 一个非闭包的参数
    static func loadData(userName: String, finishedCallBack: @escaping (String) -> ()) {
        //1.在全局队列中做耗时操作
        DispatchQueue.global().async {            //在全局队列中休眠
            Thread.sleep(forTimeInterval: 1)            //2.在主队列中回调数据
            DispatchQueue.main.async {                //执行闭包
                finishedCallBack("嘎嘎嘎嘎嘎嘎嘎: " + userName)
            }
        }
    }
}


public extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    public class func once(file: String = #file, function: String = #function, line: Int = #line, block:()->Void) {
        let token = file + ":" + function + ":" + String(line)
        once(token: token, block: block)
    }
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
