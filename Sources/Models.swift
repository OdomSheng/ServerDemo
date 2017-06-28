import Foundation
import PerfectLib

class User: JSONConvertibleObject {
    
    static let registerName = "user"
    
    var username = ""
    var password = ""
    var avatar = ""
    var age = 0
    
    override func setJSONValues(_ values: [String : Any]) {
        self.username = getJSONValue(named: "username", from: values, defaultValue: "")
        self.password = getJSONValue(named: "password", from: values, defaultValue: "")
        self.avatar = getJSONValue(named: "avatar", from: values, defaultValue: "")
        self.age = getJSONValue(named: avatar, from: values, defaultValue: 0)
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            "username": username,
            "password": password,
            "avatar": avatar,
            "age": age
        ]
    }
    
}
