//
//  PostDetailsViewController.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 28/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

protocol PostDetailsViewControllerDelegate {
    func refreshTable()
}

class PostDetailsViewController: UIViewController {

    @IBOutlet weak var detailsTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var popupView: PopupController?
    var selectedPost: Post!
    var isOfflineMode: Bool!
    
    var delegate: PostDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Model Manipulation Methods
    
    func savePostsToCoreData() {
        do {
            try context.save()
            Configuration.displayAlert(self, title: nil, message: NSLocalizedString("PostDetailsViewController.UpdateAlert", comment: ""))
        } catch {
            print("An error in saving to core data\(error)")
        }
        delegate?.refreshTable()
        detailsTableView.reloadData()
    }
    
    
    @IBAction func editPost(_ sender: Any) {
        popupView = PopupController
            .create(self)
            .customize(
                [
                    .layout(.center),
                    .animation(.fadeIn),
                    .scrollable(false),
                    .backgroundStyle(.blackFilter(alpha: 0.7))
                ]
        )
            .didShowHandler { popup in
        }
        .didCloseHandler { _ in
        }
        let addPostPopup = AddPostPopUpController.instance()
        addPostPopup.delegate = self
        popupView = popupView?.show(addPostPopup)
        addPostPopup.titleTextField.text = selectedPost.title ?? NSLocalizedString("Post_TitleNotAvailable", comment: "")
        addPostPopup.detailsTextView.text = selectedPost.details ?? NSLocalizedString("Details_DetailsNotAvailable", comment: "")
        addPostPopup.postIdToUpdate = selectedPost.id
        addPostPopup.isToUpdatePost = true
        addPostPopup.sendButtonOutlet.setTitle(NSLocalizedString("PostDetailsViewController.UpdateButton", comment: ""), for: .normal)
    }
    
}

extension PostDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleTableViewCell
            cell.titleLable.text = selectedPost.title ?? NSLocalizedString("Post_TitleNotAvailable", comment: "")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath) as! DetailsTableViewCell
            cell.detailsLabel.text = selectedPost.details ?? NSLocalizedString("Details_DetailsNotAvailable", comment: "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension PostDetailsViewController: AddPostPopUpControllerDelegate {
    func addnewPost(with post: Post) {
        if isOfflineMode {
            let fetchRequest =
                    NSFetchRequest<NSManagedObject>(entityName: "Post")
            fetchRequest.predicate = NSPredicate(format:"id == %d", post.id)
            let result = try? context.fetch(fetchRequest)
            if let updatedPost = result?.first {
                updatedPost.setValue(post.details, forKey: "details")
                updatedPost.setValue(post.title, forKey: "title")
                popupView?.dismiss()
                savePostsToCoreData()
            }
        } else {
            let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
            progressHUD.label.text = "Please wait"
            ServerManger.sharedInstance.updatePost(with: post) { [weak self] (statusCode) in
                progressHUD.hide(animated: true)
                if let _ = statusCode {
                    self?.delegate?.refreshTable()
                    self?.popupView?.dismiss()
                    Configuration.displayAlert(self, title: nil, message: NSLocalizedString("PostDetailsViewController.UpdateAlert", comment: ""))
                    self?.selectedPost = post
                    self?.detailsTableView.reloadData()
                } else {
                    Configuration.displayAlert(self, title: nil, message: NSLocalizedString("PostDetailsViewController.UpdateAlertFill", comment: ""))
                }
            }
        }
    }
}
