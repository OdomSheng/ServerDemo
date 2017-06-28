import Foundation

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let server = HTTPServer()

var routes = Routes()
let dataManager = DataManager()

/// Fetch user info
routes.add(method: .get, uri: "/getUserInfo") { (request, response) in
    
    response.setHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
    
    guard let username = request.queryParams.first?.1 else {
        response.completed()
        return
    }
    
    let user = dataManager.fetchUserWith(username: username)
    
    do {
        try response.setBody(json: user)
    } catch _ {
        response.setBody(string: "Decode user failure.")
        response.completed()
    }
    response.completed()
    
}

/// Fetch user list
routes.add(method: .get, uri: "/getUserList") { (request, response) in
    
    response.setHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
    
    let users = dataManager.fetchAllUser()
    
    let json = ["list": users]
    
    do {
        try response.setBody(json: json)
    } catch _ {
        response.setBody(string: "Decode user failure.")
    }
    response.completed()
    
}

/// Images
routes.add(method: .get, uri: "/images/**") { (request, response) in
    request.path = request.urlVariables[routeTrailingWildcardKey] ?? ""
    
    let handler = StaticFileHandler(documentRoot: "./Images")
    handler.handleRequest(request: request, response: response)
}

/// Upload avatar
routes.add(method: .post, uri: "/uploadAvatar") { (request, response) in
    response.setHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
    guard let spec = request.postFileUploads?.first else {
        response.completed()
        return
    }
    let fileName = spec.fileName
    let file = File(spec.tmpFileName)
    let imagesDir = Dir(Dir.workingDir.path + "Images/")
    do {
        try imagesDir.create()
        let _ = try file.moveTo(path: imagesDir.path + fileName, overWrite: true)
        let finalURL = "http://" + server.serverName + ":\(server.serverPort)" + "/images/\(fileName)"
        let dictionary = ["url": finalURL]
        try response.setBody(json: dictionary)
    } catch let error {
        print("Upload file failed by error: \(error)")
    }
    response.completed()
    defer {
        file.close()
    }
}

/// Add new user
routes.add(method: .post, uri: "/uploadNewUser") { (request, response) in
    let params = request.postParams
    response.setHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
    var responseJson = ["isSuccess": false]
    
    var user = User()
    
    params.forEach { (key, value) in
        if key == "username" {
            user.username = value
        } else if key == "password" {
            user.password = value
        } else if key == "avatar" {
            user.avatar = value
        } else {
            user.age = Int(value) ?? 0
        }
    }
    
    responseJson["isSuccess"] = dataManager.insert(user: user)
    
    do {
        try response.setBody(json: responseJson)
    } catch let error {
        print("Set response failed by error: \(error)")
    }
    
    response.completed()
}

server.addRoutes(routes)

server.serverName = "localhost"
server.serverPort = 8282

do {
    try server.start()
} catch let error {
    print("Server error occured: \(error)")
}
