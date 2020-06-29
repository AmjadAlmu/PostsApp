//
//  AddPostPopUpController.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 29/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//

import UIKit
import CoreData

protocol AddPostPopUpControllerDelegate {
    func addnewPost(with post: Post)
}

class AddPostPopUpController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    
    var delegate: AddPostPopUpControllerDelegate?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var isToUpdatePost = false
    var postIdToUpdate: Int32!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTextView.layer.cornerRadius = 8
        detailsTextView.layer.borderColor = UIColor.gray.cgColor
        detailsTextView.layer.borderWidth = 0.1
        
        sendButtonOutlet.layer.cornerRadius = 8
        checkTextFieldData()
    }
    
    func checkTextFieldData() {
        if titleTextField.text!.isEmpty || detailsTextView.text!.isEmpty {
            sendButtonOutlet.isEnabled =  false
            sendButtonOutlet.backgroundColor = Configuration.purpleColor().withAlphaComponent(0.70)
        } else {
            sendButtonOutlet.isEnabled =  true
            sendButtonOutlet.backgroundColor = Configuration.purpleColor()
        }
    }
    
    class func instance() -> AddPostPopUpController {
        let storyboard = UIStoryboard(name: "PopUp", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "AddPostPopUpController") as! AddPostPopUpController
    }
    
    //MARK: - Actions
    
    @IBAction func sendPostAction(_ sender: UIButton) {
        let newPost = Post(context: context)
        guard let title = titleTextField.text, let details = detailsTextView.text else {
            Configuration.displayAlert(self, title: nil, message: NSLocalizedString("AddPostPopUpController.sendPostAlert", comment: ""))
            return
        }
        if isToUpdatePost {
            newPost.id = postIdToUpdate
        }
        newPost.title = title
        newPost.details = details
        delegate?.addnewPost(with: newPost)
    }
    
}

extension AddPostPopUpController: PopupContentViewController {
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 30 , height:330)
    }
}

extension AddPostPopUpController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkTextFieldData()
    }
}

extension AddPostPopUpController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkTextFieldData()
        return true
    }
}
