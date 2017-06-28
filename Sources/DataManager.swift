import Foundation
import MySQL

fileprivate struct DBConstants {
    
    static let host = "127.0.0.1"
    static let port = 3306
    static let user = "root"
    static let password = "Sheng"
    static let database = "test"
    
}

class DataManager {
    
    func fetchAllUser() -> [User] {
        var users = [User]()
        
        let mysql = MySQL()
        let connected = mysql.connect(host: DBConstants.host, user: DBConstants.user, password: DBConstants.password)
        guard connected else {
            print(mysql.errorMessage())
            return []
        }
        
        defer {
            mysql.close()
        }
        
        guard mysql.selectDatabase(named: DBConstants.database) else {
            print("Select database failed, error code: \(mysql.errorCode()), message: \(mysql.errorMessage())")
            return []
        }
        
        guard mysql.query(statement: "SELECT * FROM user") else {
            print("MySQL query failed.")
            return []
        }
        
        guard let results = mysql.storeResults() else {
            print("MySQL query failed.")
            return []
        }
        
        results.forEachRow { (row) in
            guard let username = row[0], let password = row[1], let avatar = row[2] else {
                return
            }
            let age = Int(row[3] ?? "0") ?? 0
            let user = User()
            user.username = username
            user.password = password
            user.avatar = avatar
            user.age = age
            users.append(user)
        }
        
        return users
    }
    
    func fetchUserWith(username: String) -> User? {
        let mysql = MySQL()
        let connected = mysql.connect(host: DBConstants.host, user: DBConstants.user, password: DBConstants.password)
        guard connected else {
            print(mysql.errorMessage())
            return nil
        }
        
        defer {
            mysql.close()
        }
        
        guard mysql.selectDatabase(named: DBConstants.database) else {
            print("Select database failed, error code: \(mysql.errorCode()), message: \(mysql.errorMessage())")
            return nil
        }
        
        guard mysql.query(statement: "SELECT * FROM user WHERE username='" + username + "'") else {
            print("MySQL query failed.")
            return nil
        }
        
        guard let results = mysql.storeResults(), let row = results.next() else {
            print("MySQL query failed.")
            return nil
        }
        guard let username = row[0], let password = row[1], let avatar = row[2] else {
            return nil
        }
        let age = Int(row[3] ?? "0") ?? 0
        let user = User()
        user.username = username
        user.password = password
        user.avatar = avatar
        user.age = age
        return user
    }
    
    func insert(user: User) -> Bool {
        let mysql = MySQL()
        let connected = mysql.connect(host: DBConstants.host, user: DBConstants.user, password: DBConstants.password)
        
        defer {
            mysql.close()
        }
        
        guard connected else {
            print(mysql.errorMessage())
            return false
        }
        
        guard mysql.selectDatabase(named: DBConstants.database) else {
            print("Select database failed, error code: \(mysql.errorCode()), message: \(mysql.errorMessage())")
            return false
        }
        
        let statement = "INSERT INTO user VALUES ('" + user.username + "', '" + user.password + "', '" + user.avatar + "', " + "\(user.age))"
        
        return mysql.query(statement: statement)
    }
    
}
