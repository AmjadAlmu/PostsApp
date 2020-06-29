//
//  Configuration.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 28/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//

import UIKit

class Configuration {
    init() {}
    
    //MARK: - Main URL Path
    static let SERVER_URL = "https://my-json-server.typicode.com/AmjadAlmu/PostsAppDB"
    static let LOGIN_ENDPOINT = "/users"
    static let VERIFY_SMS_ENDPOINT = "/auths"
    static let POSTS_ENDPOINT = "/posts"
    
    //MARK: - Application Colors
    class func purpleColor() -> UIColor {
        return UIColor(red: 0.54, green: 0.29, blue: 0.48, alpha: 1.00)
    }
    
    class func displayAlertWithHandler(_ viewController: UIViewController?, title: String?, message: String, handler: @escaping (UIAlertAction) -> Void ) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: UIAlertAction.Style.default, handler: handler)
        let cancelButton = UIAlertAction(title: NSLocalizedString("alert_cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    class func displayAlert(_ viewController: UIViewController?, title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        viewController?.present(alert, animated: true, completion: nil)
    }

}
