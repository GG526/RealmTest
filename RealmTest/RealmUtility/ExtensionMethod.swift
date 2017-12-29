//
//  ExtensionMethod.swift
//  RealmTest
//
//  Created by 小七 on 2017/12/15.
//  Copyright © 2017年 Seven. All rights reserved.
//

import Foundation


/// 创建数据库的名字
///
/// - db: db
public enum dataBaseName: String {
    case db = "db"
}

/// 在run debug的状态打印所需要的信息
///
/// - Parameter items: 所要打印的内容
public func mPrint(_ items: Any...) {
    #if DEBUG
    debugPrint(items)
    #endif
}
