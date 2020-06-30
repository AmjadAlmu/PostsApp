//
//  PostsViewController.swift
//  PostsApp
//
//  Created by Amjad Almuwallad on 28/06/2020.
//  Copyright © 2020 Amjad Almuwallad. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

class PostsViewController: UIViewController {

    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    
    var posts = [Post]()
    var onlinePosts = [PostObject]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var popupView: PopupController?
    
    var isOfflineMode = true
    
    private var currentPage = 0
    private var pageSize = 12
    private var shoudShowLoadingCell:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTableView.register(UINib(nibName: "LodingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")
        segmentedControlOutlet.addTarget(self, action: #selector(segmentedChanged), for: .valueChanged)
        shoudShowLoadingCell = true
        postsTableView.tableFooterView = UIView()
        loadPosts()
    }
    
    //MARK: - Model Manipulation Methods
    
    func savePostsToCoreData() {
        do {
            try context.save()
        } catch {
            print("An error in saving to core data\(error)")
        }
        postsTableView.reloadData()
    }
    
    func loadPosts() {
        if isOfflineMode {
            let request: NSFetchRequest<Post> = Post.fetchRequest()
            request.fetchLimit = pageSize
            request.fetchOffset = currentPage
            do {
                let result = try context.fetch(request)
                posts.append(contentsOf: result)
            } catch {
                print("Error in fitching")
            }
            
        } else {
            let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
            progressHUD.label.text = NSLocalizedString("progressHUD.waitLabel", comment: "")
            ServerManger.sharedInstance.getPost { [weak self] (posts) in
                progressHUD.hide(animated: true)
                if let _ = posts {
                    self?.onlinePosts = posts!
                    self?.postsTableView.reloadData()
                } else {
                    Configuration.displayAlert(self, title: "", message: NSLocalizedString("PostsViewController.UnableToload", comment: ""))
                }
            }
        }
    }
    
    @objc func segmentedChanged(sender:UISegmentedControl) {
        isOfflineMode = sender.selectedSegmentIndex == 0 ? true : false
        refreshData()
    }
    
    func refreshData() {
        currentPage = 0
        posts.removeAll()
        loadPosts()
        postsTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailsViewController" {
            let detailsVC = segue.destination as! PostDetailsViewController
            if let selectedPost = sender as? Post {
                detailsVC.selectedPost = selectedPost
                detailsVC.isOfflineMode = isOfflineMode
                detailsVC.delegate = self
            }
        }
    }
    
    //MARK: - paging calles
    private func fetchNextPage() {
        currentPage += 1
        fetchData()
    }
    
    private func detectLoadingCell(indexPath:IndexPath) {
        guard isLoadingIndexPath(indexPath) else {
            return
        }
        fetchNextPage()
    }
    
    func getCellsCount() -> Int {
        return self.shoudShowLoadingCell ? self.posts.count + 1 : self.posts.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoadingIndexPath(indexPath) {
            cell.backgroundColor = UIColor.clear
        }
        detectLoadingCell(indexPath: indexPath)
    }
    
    private func isLoadingIndexPath(_ indexPath:IndexPath)-> Bool {
        guard shoudShowLoadingCell else { return false }
        if isOfflineMode {
            return indexPath.row == self.posts.count
        } else {
            return indexPath.row == self.onlinePosts.count
        }
        
    }
    
    private func fetchData() {
        loadPosts()
    }
    
    //MARK: - Actions
    @IBAction func addNewPost(_ sender: Any) {
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
    }
    
}

extension PostsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isOfflineMode ? posts.count : onlinePosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingIndexPath(indexPath) {
            return tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        if isOfflineMode {
            let cureentPost = posts[indexPath.row]
            cell.postTitleLabel.text = cureentPost.title ?? NSLocalizedString("Post_TitleNotAvailable", comment: "")
        } else {
            let cureentPost = onlinePosts[indexPath.row]
            cell.postTitleLabel.text = cureentPost.title ?? NSLocalizedString("Post_TitleNotAvailable", comment: "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let currentPost = posts[indexPath.row]
            Configuration.displayAlertWithHandler(self, title: "", message: NSLocalizedString("PostsViewController.DeletePost", comment: "")) {[weak self] (_) in
                guard let isOfflineModeValue = self?.isOfflineMode else {
                    return
                }
                if isOfflineModeValue {
                    self?.context.delete(currentPost)
                    self?.posts.remove(at: indexPath.row)
                    self?.savePostsToCoreData()
                } else {
                    ServerManger.sharedInstance.deletePost(postId: Int(currentPost.id)) { [weak self] (statusCode) in
                        if let _ = statusCode {
                            Configuration.displayAlert(self, title: "", message: NSLocalizedString("PostsViewController.DeletePostSuccess", comment: ""))
                            self?.posts.remove(at: indexPath.row)
                            self?.postsTableView.reloadData()
                        } else {
                            Configuration.displayAlert(self, title: nil, message: NSLocalizedString("PostsViewController.DeletePostUnSuccess", comment: ""))
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetailsViewController", sender: posts[indexPath.row])
    }
}


extension PostsViewController: AddPostPopUpControllerDelegate {
    func addnewPost(with post: PostObject) {
        if isOfflineMode {
            let newPost = Post(context: context)
            newPost.id = Int32.random(in: 1..<10000)
            newPost.title = post.title
            newPost.details = post.details
            posts.append(newPost)
            savePostsToCoreData()
        } else {
            let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
            progressHUD.label.text = NSLocalizedString("progressHUD.waitLabel", comment: "")
            ServerManger.sharedInstance.addPost(with: post) { [weak self] (statusCode) in
                progressHUD.hide(animated: true)
                if let _ = statusCode {
                    Configuration.displayAlert(self, title: "", message: NSLocalizedString("PostsViewController.AddPostSuccess", comment: ""))
                    self?.postsTableView.reloadData()
                } else {
                    Configuration.displayAlert(self, title: nil, message: NSLocalizedString("PostsViewController.AddPostUnSuccess", comment: ""))
                }
            }
        }
        popupView?.dismiss()
    }
}


extension PostsViewController: PostDetailsViewControllerDelegate {
    func refreshTable() {
        refreshData()
    }
}
