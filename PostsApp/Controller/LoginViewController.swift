//
//  LoginViewController.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 28/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImage.image = logoImage.image!.withRenderingMode(.alwaysTemplate)
        phoneNumberTextField.layer.borderWidth = 0.5
        phoneNumberTextField.layer.borderColor = UIColor.lightGray.cgColor
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        checkTextFieldData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkTextFieldData()
    }
    
    func checkTextFieldData() {
        if phoneNumberTextField.text!.isEmpty {
            loginButtonOutlet.isEnabled =  false
            loginButtonOutlet.backgroundColor = Configuration.purpleColor().withAlphaComponent(0.70)
        } else {
            loginButtonOutlet.isEnabled =  true
            loginButtonOutlet.backgroundColor = Configuration.purpleColor()
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD.label.text = NSLocalizedString("progressHUD.waitLabel", comment: "")
        ServerManger.sharedInstance.login(mobileNumber: phoneNumberTextField.text!) { [weak self] (statusCode) in
            progressHUD.hide(animated: true)
            if let _ = statusCode {
                self?.performSegue(withIdentifier: "ShowVerificationCode", sender: nil)
            } else {
                Configuration.displayAlert(self, title: nil, message: NSLocalizedString("LoginViewController.UnableToRegister", comment: ""))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
