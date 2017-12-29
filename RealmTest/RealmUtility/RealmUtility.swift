//
//  RealmUtility.swift
//  RealmTest
//
//  Created by 小七 on 2017/12/13.
//  Copyright © 2017年 Seven. All rights reserved.
//  Realm数据库单例工具

import Foundation
import RealmSwift

class RealmUtility: NSObject {
    
    //MARK: - 单例实例
    /// 获取RealmUtility的实例
    static var `default`: RealmUtility  = RealmUtility()
    private override init() {
        super.init()
    }
    
    //MARK: - 创建数据库
    /// 创建数据库
    ///
    /// - Parameters:
    ///   - dataBaseName: 数据库名字
    ///   - isReadOnly: 是否是只读
    /// - Returns: Realm实例
    @discardableResult
    public func creatDB(_ dataBaseName: String, isReadOnly: Bool = false) -> Realm? {
        let realm = openDB(dataBaseName, isReadOnly: isReadOnly)
        return realm
    }
    
    /// 打开数据库
    ///
    /// - Parameter name: 数据库名字
    /// - isReadOnly: 是否是只读
    /// - Returns: Realm实例
    @discardableResult
    private func openDB(_ dataBaseName: String, isReadOnly: Bool = false) -> Realm? {
        guard let dbPath = getCreatDatabasePath(dataBaseName) else {
            return nil
        }
        var config = Realm.Configuration()
        config.fileURL = dbPath
        config.readOnly = isReadOnly
        Realm.Configuration.defaultConfiguration = config
        do {
            let realm = try Realm.init(configuration: config)
            return realm
        }catch let error {
            mPrint("打开或者创建数据库失败:\n\(error.localizedDescription)")
            return nil
        }
    }
    
    
    /// 设置通过Realm()获取数据库的配置
    ///
    /// - Parameters:
    ///   - realmName: 数据库的名字
    ///   - isReadOnly: 是否是这是只读
    public func setDefaltRealmConfiguration(_ realmName: String,isReference: Bool = false, isReadOnly: Bool = false) -> Bool{
        var realmPath: URL?
        if isReference {
            realmPath = getReferenceDatabasePaeh(realmName)
        }else {
            realmPath = getCreatDatabasePath(realmName)
        }
        if realmPath == nil {
            return false
        }
        var config = Realm.Configuration()
        config.fileURL = realmPath
        config.readOnly = isReadOnly
        Realm.Configuration.defaultConfiguration = config
        return true
    }
    
    /// 打开预植的数据库
    ///
    /// - Parameters:
    ///   - dataBaseName: 数据库名字
    ///   - isReadOnly: 是否是只读
    /// - Returns: Realm实例
    @discardableResult
    public func openReferenceDB(_ dataBaseName: String, isReadOnly: Bool = true) -> Realm? {
        guard let dbPath = getReferenceDatabasePaeh(dataBaseName) else {
            return nil
        }
        var config = Realm.Configuration()
        config.fileURL = dbPath
        config.readOnly = isReadOnly
        Realm.Configuration.defaultConfiguration = config
        do {
            let realm = try Realm.init(configuration: config)
            return realm
        }catch let error {
            mPrint("打开或者创建数据库失败:\n\(error.localizedDescription)")
            return nil
        }
    }
    
    /// 获取当前默认的数据
    ///
    /// - Returns: 返回默认的Realm的数据库实例
    @discardableResult
    public func getDefaultRealm() -> Realm? {
        do {
            return try Realm()
        }catch let error {
            mPrint("获取默认的Realm的数据库失败:\n\(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: - 增
    /// 创建表 || 更新表
    ///
    /// - Parameters:
    ///   - type: 表向对应的对象
    ///   - value: 值
    ///   - update: 是否是更新, 如果是"true", Realm会查找对象并更新它, 否则添加对象
    ///   - result: 最后添加对象是成功, 如果成功将对象返回
    public func creatObject(_ type: RealmSwift.Object.Type, value: Any? = nil, update: Bool = false, result: ((RealmSwift.Object?, Error?) -> Void)? = nil){
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                let object = (value == nil) ? realm?.create(type) : realm?.create(type, value: value!, update: update)
                result?(object, nil)
            }
        } catch let error {
            mPrint("获取默认的Realm的数据库失败:\n\(error.localizedDescription)")
            result?(nil, error)
        }
    }
    
   
    /// 添加数据 || 根据主键更新数据
    ///
    /// - Parameters:
    ///   - object: 要添加的数据
    ///   - update: 是否更新, 如果是true
    ///   - result: 添加数据的状态
    public func addObject(_ object: RealmSwift.Object, update: Bool = false, result: ((Error?) -> Void)? = nil) {
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                realm?.add(object, update: update)
                result?(nil)
            }
        } catch let error {
            mPrint("添加数据失败:\n \(error.localizedDescription)")
            result?(error)
        }
    }
    
    //MARK: - 删
    /// 删除数据
    ///
    /// - Parameters:
    ///   - object: 要删除的对象
    ///   - result: 删除的状态
    public func deleteObject(_ object: RealmSwift.Object, result: ((Error?) -> Void)? = nil) {
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                realm?.delete(object)
                result?(nil)
            }
        } catch let error {
            mPrint("添加数据失败:\n \(error.localizedDescription)")
            result?(error)
        }
    }
    
    
    /// 删除当前数据库中所有的数据
    ///
    /// - Parameter result: 删除的状态
    public func deleteAllObject(result: ((Error?) -> Void)? = nil) {
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                realm?.deleteAll()
                result?(nil)
            }
        } catch let error {
            mPrint("添加数据失败:\n \(error.localizedDescription)")
            result?(error)
        }
    }
    
    /// 删除当前打开的数据库
    ///
    /// - Parameter dataBaseName: 数据库的名字
    /// - Returns: 删除的状态
    @discardableResult
    public func deleteCreatDBFile() -> Bool {
       return  autoreleasepool { () -> Bool in
            let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
            let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("note"),
                realmURL.appendingPathExtension("management")
            ]
            for URL in realmURLs {
                do {
                    try FileManager.default.removeItem(at: URL)
                    return true
                } catch {
                    // 错误处理
                    return false
                }
            }
            return false
        }
    }
    
    //MARK: - 改
    /// 根据主键进行更新
    ///
    /// - Parameters:
    ///   - object: 要更新的对象
    ///   - update: 是否根据主键更新, 如果是"false"则是添加数据
    ///   - result: 更新数据的结果
    public func updateObject(_ object: RealmSwift.Object, update: Bool = true, result: ((Error?) -> Void)? = nil) {
        addObject(object, update: update, result: result)
    }
    
    
    /// 根据主键进行更新
    ///
    /// - Parameters:
    ///   - type: 要更新的对象类型
    ///   - value: 要更新的值, 例如: ["id": 1, "price": 9000.0]
    ///   - update: 是否根据主键进行更新, 如果为"false"则为创建表
    ///   - result: 更新的结果
    public func updateObject(_ type: RealmSwift.Object.Type, value: Any? = nil, update: Bool = true, result: ((RealmSwift.Object?, Error?) -> Void)? = nil) {
        creatObject(type, value: value, update: update, result: result)
    }
    
    
    /// 直接更新对象
    ///
    /// - Parameters:
    ///   - property: 要更改的属性
    ///   - value: 更改的值
    /// - Returns: 更改的结果
    @discardableResult
    public func updateObject( property: inout Any, value: Any) -> Bool {
        let realm = getDefaultRealm()
        do {
            try realm?.write {
                 property = value
            }
            return true
        } catch let error {
            mPrint("直接更新对象属性错误: \(error.localizedDescription)")
            return false
        }
    }
    
    
    /// 更改表中所有的字段的值
    ///
    /// - Parameters:
    ///   - type: 表的对象类型
    ///   - key: 要更改的字段名
    ///   - value: 更改的值
    /// - Returns: 返回更改结果
    public func updateObjects(type: RealmSwift.Object.Type, key: String, value: Any) -> Bool {
        let objects = getObjects(type: type)
        do {
            try getDefaultRealm()?.write {
                objects?.setValue(value, forKeyPath: key)
            }
            return true
        } catch let error {
            mPrint("更改一个表中的所有数据错误: \(error.localizedDescription)")
            return false
        }
    }
    
    
    /// 根据主键进行对某个对象中的数据进行更新
    ///
    /// - Parameters:
    ///   - type: 表类型
    ///   - primaryKey: 主键
    ///   - key: 要更改属性
    ///   - value: 更改的值
    /// - Returns: 更改的状态
    public func updateObject(type: RealmSwift.Object.Type, primaryKey: Any, key: String, value: Any) -> Bool {
        let object = getObjectWithPrimaryKey(type: type, primaryKey: primaryKey)
        do {
            try getDefaultRealm()?.write {
                object?.setValue(value, forKeyPath: key)
            }
            return true
        } catch let error {
            mPrint("更新数据出错: \(error.localizedDescription)")
            return false
        }
    }
    
    //MARK: - 查
    /// 查找一个表中的所有的数据
    ///
    /// - Parameter type: 对象类型
    /// - Returns: 查到的数据
    public func getObjects(type: RealmSwift.Object.Type) -> RealmSwift.Results<RealmSwift.Object>?{
         return getDefaultRealm()?.objects(type)
    }
    
    /// 根据主键查找某个对象
    ///
    /// - Parameters:
    ///   - type: 对象类型
    ///   - primaryKey: 主键
    /// - Returns: 查到的数据
    public func getObjectWithPrimaryKey(type: RealmSwift.Object.Type, primaryKey: Any) -> RealmSwift.Object? {
        return getDefaultRealm()?.object(ofType: type, forPrimaryKey: primaryKey)
    }
    
    
    /// 使用断言字符串查询
    ///
    /// - Parameters:
    ///   - type: 对象类型
    ///   - filter: 过滤条件
    /// - Returns: 查询到的数据
    /// - example:
    ///   - var tanDogs = realm.objects(Dog.self).filter("color = 'tan' AND name BEGINSWITH 'B'")
    public func getObject(type: RealmSwift.Object.Type, filter: String) -> RealmSwift.Results<RealmSwift.Object>? {
        return getObjects(type: type)?.filter(filter)
    }
    
    
    /// 使用谓词进行查询
    ///
    /// - Parameters:
    ///   - type: 对象类型
    ///   - predicate: 谓词对象
    /// - Returns: 查询到的数据
    /// - example:
    ///   - let predicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "B")
    ///   - tanDogs = realm.objects(Dog.self).filter(predicate)
    public func getObject(type: RealmSwift.Object.Type, predicate: NSPredicate) -> RealmSwift.Results<RealmSwift.Object>? {
        return getObjects(type: type)?.filter(predicate)
    }


    /// 对查询的数据进行排序,请注意, 不支持 将多个属性用作排序基准，此外也无法链式排序（只有最后一个 sorted 调用会被使用）。 如果要对多个属性进行排序，请使用 sorted(by:) 方法，然后向其中输入多个 SortDescriptor 对象。
    ///
    /// - Parameters:
    ///   - type: 对象类型
    ///   - filter: 过滤条件
    ///   - sortedKey: 需要排序的字段
    /// - Returns: 最后的结果
    public func getObject(type: RealmSwift.Object.Type, filter: String, sortedKey: String) -> RealmSwift.Results<RealmSwift.Object>? {
        return getObject(type: type, filter: filter)?.sorted(byKeyPath: sortedKey)
    }
    
    
    /// 对查询的数据进行排序, 请注意, 不支持 将多个属性用作排序基准，此外也无法链式排序（只有最后一个 sorted 调用会被使用）。 如果要对多个属性进行排序，请使用 sorted(by:) 方法，然后向其中输入多个 SortDescriptor 对象。
    ///
    /// - Parameters:
    ///   - type: 队形类型
    ///   - predicate: 谓词对象
    ///   - sortedKey: 排序的字段
    /// - Returns: 排序后的数据
    public func getObject(type: RealmSwift.Object.Type, predicate: NSPredicate, sortedKey: String) -> RealmSwift.Results<RealmSwift.Object>? {
        return getObject(type: type, predicate: predicate)?.sorted(byKeyPath: sortedKey)
    }
    
    
}

extension RealmUtility {
    /// 在创建数据库的时候要保存的数据库路径, 保存在caches 文件中
    ///
    /// - Paramter fileName: 数据库名字
    /// - Returns: 数据库保存的路径
    private func getCreatDatabasePath(_ fileName: String) -> URL? {
        let cachesPaeh = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        guard var filePath = cachesPaeh else {
            return nil
        }
        filePath = filePath + "/DB/\(fileName)"
        
        do {
            if !FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
        }catch let error {
            mPrint("创建数据库文件夹:\(error.localizedDescription)")
            return nil
        }
        let path = filePath + "/\(fileName).realm"
        mPrint(path)
        return URL.init(string: path)
    }
    
    
    /// 获取引用的数据的路径
    ///
    /// - Parameter fileName: 数据库的名字
    /// - Returns: 本地引用的数据库的路径
    private func getReferenceDatabasePaeh(_ fileName: String) -> URL? {
        let path = Bundle.main.path(forResource: fileName, ofType: "realm")
        let url = path != nil ? URL.init(string: path!) : nil
        return url
    }
    
}
