//
//  FeedVC.swift
//  ForshMag
//
//  Created by  Tim on 11.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import Alamofire


class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    static var imageCache: NSCache<NSString, UIImage> = NSCache ()
    
    private var posts = [Post] ()
    private var filtered = [Post] ()
    private var isFiltered = false
    private var loadMorePosts = false
    private var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 134
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.addSubview(refreshControl)
        tableView.tableFooterView?.isHidden = true
        
        refresh()
    }
    
    func refresh() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DispatchQueue.global(qos: .background).async {
            self.posts.removeAll()
            self.currentPage = 1
            self.parseJSON(page: "\(self.currentPage)")
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.refreshControl.endRefreshing()
                self.isFiltered = false
                self.tableView.reloadData()
            }
        }
    }
    
    func parseJSON (page: String) {
        let parameters = ["page": page]
        ForshMagAPI.sharedInstance.getFeed(withParameters: parameters) { feed in
            self.posts += feed
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var post: Post
        let postCell: PostCellFactory
        
        if isFiltered {
            post = filtered[indexPath.row]
        } else {
            post = posts[indexPath.row]
        }
        
        switch (post.type) {
        case "w":
            postCell = PostCellHelper.factory(for: .w)
        case "w2":
            postCell = PostCellHelper.factory(for: .w2)
        default:
            postCell = PostCellHelper.factory(for: .w4)
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: postCell().name()) as? PostCellProtocol {
            if post.mediaId != 0 {
                if let img = FeedVC.imageCache.object(forKey: "\(post.mediaId)" as NSString) {
                    cell.configureCell(post: post, img: img)
                } else {
                    ForshMagAPI.sharedInstance.imageLoader(mediaId: post.mediaId) { image in
                        cell.configureCell(post: post, img: image)
                    }
                }
                return cell as! UITableViewCell
            } else {
                cell.configureCell(post: post, img: nil)
                return cell as! UITableViewCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == self.posts.count - 2) {
            currentPage += 1
            DispatchQueue.global().async {
                self.parseJSON(page: "\(self.currentPage)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            return filtered.count
        } else {
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        var post: Post!
        if isFiltered {
            post = filtered[indexPath.row]
        } else {
            post = posts[indexPath.row]
        }
        performSegue(withIdentifier: "PostVC", sender: post)
    }
    
    
    
    // MARK: - FiltersByCategory
    
    @IBAction func filterLearn(_ sender: Any) {
        isFiltered = true
        filtered = posts.filter({$0.category == "#УЧИТЬСЯ"})
        tableView.reloadData()
    }
    
    @IBAction func filterDo(_ sender: Any) {
        isFiltered = true
        filtered = posts.filter({$0.category == "#ДЕЛАТЬ"})
        tableView.reloadData()
    }
    @IBAction func filterRest(_ sender: Any) {
        isFiltered = true
        filtered = posts.filter({$0.category == "#ОТДЫХАТЬ"})
        tableView.reloadData()
    }
    
    // MARK: -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostVC" {
            if let detailVC = segue.destination as? PostVC {
                if let post = sender as? Post {
                    detailVC.post = post
                }
            }
        }
    }
}

