//
//  ViewController.swift
//  RealmTest
//
//  Created by 小七 on 2017/12/12.
//  Copyright © 2017年 Seven. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

class ViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Rx_RealmUtillit.creatDB("7DB").subscribe().disposed(by: disposeBag)
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        Rx_RealmUtillit.getDefaultRealm().subscribe(onNext: { (realm) in
            mPrint("realmPath:", realm?.configuration.fileURL)
        }).disposed(by: disposeBag)
        
        let dog = Dog(value: ["id": 10, "name": "jss"])
        Rx_RealmUtillit.addObject(dog).subscribe(onNext: { (error) in
            
        }).disposed(by: disposeBag)
        
    }
    
    
}

