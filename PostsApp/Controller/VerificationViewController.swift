//
//  VerificationViewController.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 28/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData

class VerificationViewController: UIViewController {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var codeTestField: UITextField!
    @IBOutlet weak var verifyButtonOutlet: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImage.image = logoImage.image!.withRenderingMode(.alwaysTemplate)
        codeTestField.layer.borderWidth = 0.5
        codeTestField.layer.borderColor = UIColor.lightGray.cgColor
        codeTestField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        checkTextFieldData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkTextFieldData()
    }
    
    func checkTextFieldData() {
        if codeTestField.text!.isEmpty {
            verifyButtonOutlet.isEnabled =  false
            verifyButtonOutlet.backgroundColor = Configuration.purpleColor().withAlphaComponent(0.70)
        } else {
            verifyButtonOutlet.isEnabled =  true
            verifyButtonOutlet.backgroundColor = Configuration.purpleColor()
        }
    }
    
    @IBAction func verifyAction(_ sender: UIButton) {
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD.label.text = NSLocalizedString("progressHUD.waitLabel", comment: "")
        ServerManger.sharedInstance.verifylogin(code: codeTestField.text!, mobileNumber: ServerManger.sharedInstance.mainUser.phoneNumber!) { [weak self] (statusCode) in
            progressHUD.hide(animated: true)
            if let _ = statusCode {
                self?.performSegue(withIdentifier: "ShowMainNav", sender: nil)
                let user:MainUser=NSEntityDescription.insertNewObject(forEntityName: "MainUser", into: self!.context) as! MainUser
                user.access_token = ServerManger.sharedInstance.mainUser.accessToken
                do {
                    try self?.context.save()
                    print("Saved!")
                } catch let error {
                    print("Core Data Error: \(error)")
                }
            } else {
                Configuration.displayAlert(self, title: nil, message: NSLocalizedString("VerificationViewController.UnableToVerify", comment: ""))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
