//
//  ViewController.swift
//  SwiftTest
//
//  Created by Binfeng Peng - Vendor on 2019/3/13.
//  Copyright © 2019年 Binfeng Peng - Vendor. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // 懒加载:使用的时候一定不为空,只会初始化一次
    lazy var nameLabel = UILabel()
    
    var redView = UIView()
    var blueView = UIView()
    
    
    
    // 通过有返回值的闭包来实现懒加载
    lazy var ageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameLabel.frame = CGRect(x: 10, y: 100, width: 200, height: 100)
        self.view.addSubview(self.nameLabel)
        self.view.addSubview(self.ageLabel)
        self.nameLabel.text = "name"
        self.ageLabel.text = "age"

        // VFL
        let constraintArrayH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[ageLabel]-60-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["ageLabel" : self.ageLabel])
        let constraintArrayV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-160-[redView(200)]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["redView":self.ageLabel])
        
        self.view.addConstraints(constraintArrayH)
        self.view.addConstraints(constraintArrayV)
        
        demo()
        demo2()
        self.demo3()
        
        print("single1: \(HttpTool.shareInstance)")
        print("single2: \(HttpTool.shareInstance)")
        
        print("single3: \(HttpTool.shareHttpTool())")
        print("single4: \(HttpTool.shareHttpTool())")
        
        HttpTool.loadData { (result) in
            print(result)
        }
        
        HttpTool.loadData(userName: "小米") { (msg) in
            print(msg)
        }
        
        HttpTool.shareHttpTool().block = {
            [weak self](result: String) in
            
            self?.nameLabel.text = result + ": ok!"
            self?.ageLabel.text = result + ": 20"
        }
        
        // SnapKit
        self.view.addSubview(redView)
        self.view.addSubview(blueView)
        redView.backgroundColor = UIColor.red
        blueView.backgroundColor = UIColor.blue
        
        redView.snp.makeConstraints { (make) in
//            make.left.equalTo(ageLabel).offset(20)
//            make.top.equalTo(ageLabel).offset(20)
//            make.width.greaterThanOrEqualTo(1);
//            make.height.greaterThanOrEqualTo(1);
            make.edges.equalTo(UIEdgeInsets(top: 600, left: 100, bottom: 200, right: 100))
        }
        
        blueView.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-20)
//            make.centerY.equalToSuperview();
            make.center.equalToSuperview();
            make.width.equalTo(ageLabel.snp.width);
            make.height.equalTo(ageLabel.snp.height);
//            make.height.equalTo(100);
//            make.width.equalTo(200);
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        HttpTool.shareHttpTool().tap()
    }

    /** 1.没有参数没有返回值的闭包 */
    func demo() {
        //声明
        let closure: () -> () = {
            () -> () in print("我是一个没有参数没有返回值的闭包")
        }
        
        //执行闭包
        closure()
    }
    
    /** 2.有参数没有返回值的闭包 */
    func demo2() -> Void {
        let closure = {
            (a: Int, b: Int) -> () in
            let res = a + b
            print(res)
        }
        
        closure(2, 3)
    }
    
    /** 3.有参数有返回值的闭包 */
    func demo3() {
        let closure = {
            (a: Int, b: Int) -> Int in
            let res = a + b
            return res
        }
        
        let res = closure(2, 3)
        print(res)
    }
    
    /** 闭包的循环调用 -- weak self 当self被系统回收时,self的地址会自动指向nil */
    func closureInOC() {
        weak var weakSelf = self
        HttpTool.loadData { (result) in
            print(weakSelf?.view ?? "2")
        }
    }
}

