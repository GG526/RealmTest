//
//  Dog.swift
//  RealmTest
//
//  Created by 小七 on 2017/12/25.
//  Copyright © 2017年 Seven. All rights reserved.
//

import Foundation
import RealmSwift

class Dog: Object {
   @objc dynamic var id: Int = 0
   @objc dynamic var name: String?
    
}

class Cat: Object {
    @objc dynamic var name: String?
}
