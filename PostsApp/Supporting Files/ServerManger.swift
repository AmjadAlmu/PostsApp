//
//  ServerManger.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 28/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class ServerManger {
    
    var mainUser = User()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static let sharedInstance : ServerManger = {
        let instance = ServerManger()
        return instance
    }()
    
    func login (mobileNumber:String, completionHandler: @escaping ( ResponseCode?)  -> ()) {
        
        var url = Configuration.SERVER_URL
        url.append(Configuration.LOGIN_ENDPOINT)
        
        let userId = Int.random(in: 1..<10000) //Fake
        
        let parameters: Parameters = [
            "id": userId,
            "mobile":mobileNumber,
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON {[weak self ]response in
                if let statusCode = response.response?.statusCode {
                    switch response.result {
                    case .success(_):
                        if statusCode == ResponseCode.post_success.code {
                            self?.mainUser.phoneNumber = mobileNumber
                            self?.mainUser.id = userId
                            completionHandler(.post_success)
                        } else {
                            completionHandler(nil)
                        } 
                    case .failure(_):
                        completionHandler(nil)
                    }
                }
        }
    }
    
    func verifylogin (code:String,mobileNumber:String, completionHandler: @escaping ( ResponseCode?)  -> ()) {
        var url = Configuration.SERVER_URL
        url.append(Configuration.VERIFY_SMS_ENDPOINT)
        
        let acsessToken = NSUUID().uuidString //Fake
        let userId = Int.random(in: 1..<10000) //Fake
        
        let parameters: Parameters = [
            "id": userId,
            "mobile":mobileNumber,
            "code": code
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON {[weak self ]response in
                if let statusCode = response.response?.statusCode {
                    switch response.result {
                    case .success(_):
                        if statusCode == ResponseCode.post_success.code {
                            self?.mainUser.phoneNumber = mobileNumber
                            self?.mainUser.accessToken = acsessToken
                            completionHandler(.post_success)
                        } else {
                            completionHandler(nil)
                        }
                    case .failure(_):
                        completionHandler(nil)
                    }
                }
        }
    }
    
    func getPost (completionHandler: @escaping ( [Post]?)  -> ()) {
        var url = Configuration.SERVER_URL
        url.append(Configuration.POSTS_ENDPOINT)
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let statusCode = response.response?.statusCode {
                    switch response.result {
                    case .success(let json):
                        if statusCode == ResponseCode.get_success.code {
                            if let jsonObject = json as? [[String: Any]] {
                                var posts:[Post] = []
                                for postObject in jsonObject {
                                    let post = Post(context: self.context)
                                    guard let postId = postObject["id"] as? Int32 else {
                                        completionHandler(nil)
                                        return
                                    }
                                    post.id = postId
                                    post.title = postObject["title"] as? String
                                    post.details = postObject["Details"] as? String
                                    posts.append(post)
                                }
                                completionHandler(posts)
                            }
                        } else {
                            completionHandler(nil)
                        }
                    case .failure(_):
                        completionHandler(nil)
                    }
                }
        }
    }
    
    func addPost(with post: PostObject, completionHandler: @escaping ( ResponseCode?)  -> ()) {
        var url = Configuration.SERVER_URL
        url.append(Configuration.POSTS_ENDPOINT)
        
        let postId = Int.random(in: 1..<10000) //Fake
        
        let parameters: Parameters = [
            "id": postId,
            "title": post.title!,
            "Details": post.details!
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let statusCode = response.response?.statusCode {
                    switch response.result {
                    case .success(_):
                        if statusCode == ResponseCode.post_success.code {
                            completionHandler(.post_success)
                        } else {
                            completionHandler(nil)
                        }
                    case .failure(_):
                        completionHandler(nil)
                    }
                }
        }
    }
    
    func deletePost(postId:Int, completionHandler: @escaping ( ResponseCode?)  -> ()) {
        var url = Configuration.SERVER_URL
        url.append(Configuration.POSTS_ENDPOINT)
        url.append("/\(postId)")
        Alamofire.request(url, method: .delete, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let statusCode = response.response?.statusCode {
                    switch response.result {
                    case .success(_):
                        if statusCode == ResponseCode.get_success.code {
                            completionHandler(.get_success)
                        }
                    case .failure(_):
                        completionHandler(nil)
                    }
                }
        }
    }
    
    func updatePost(with post: PostObject, completionHandler: @escaping ( ResponseCode?)  -> ()) {
        var url = Configuration.SERVER_URL
        url.append(Configuration.POSTS_ENDPOINT)
        url.append("/\(Int(post.id))")
        
        let parameters: Parameters = [
            "id": post.id!,
            "title": post.title!,
            "Details": post.details!
        ]
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let statusCode = response.response?.statusCode {
                    switch response.result {
                    case .success(_):
                        if statusCode == ResponseCode.get_success.code {
                            completionHandler(.get_success)
                        } else {
                            completionHandler(nil)
                        }
                    case .failure(_):
                        completionHandler(nil)
                    }
                }
        }
    }
}
