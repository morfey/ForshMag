//
//  FavouriteVC.swift
//  ForshMag
//
//  Created by  Tim on 17.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class FavouriteVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post] ()
    var controller: NSFetchedResultsController<Favourite>!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        attemptFetch()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var post: Post!
        post = posts[indexPath.row]
        switch (post.postType) {
        case "w4":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
                if let mediaId = post.postMediaId {
                    if let img = FeedVC.imageCache.object(forKey: "\(mediaId)" as NSString) {
                        cell.configureCell(post: post, img: img)
                        return cell
                    } else {
                        cell.configureCell(post: post)
                        return cell
                    }
                } else {
                    cell.configureCell(post: post)
                    return cell
                }
            } else {
                return PostCell()
            }
            
        case "w":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellw") as? PostCellw {
                if let mediaId = post.postMediaId {
                    if let img = FeedVC.imageCache.object(forKey: "\(mediaId)" as NSString) {
                        cell.configureCell(post: post, img: img)
                        return cell
                    } else {
                        cell.configureCell(post: post)
                        return cell
                    }
                } else {
                    cell.configureCell(post: post)
                    return cell
                }
            } else {
                return PostCellw()
            }
        case "w2":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellw2") as? PostCellw2 {
                if let mediaId = post.postMediaId {
                    if let img = FeedVC.imageCache.object(forKey: "\(mediaId)" as NSString) {
                        cell.configureCell(post: post, img: img)
                        return cell
                    } else {
                        cell.configureCell(post: post)
                        return cell
                    }
                } else {
                    cell.configureCell(post: post)
                    return cell
                }
            } else {
                return PostCellw2()
            }
        default:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
                cell.configureCell(post: post)
                return cell
            } else {
                return PostCell()
            }
        }
    }
    
    func getFavourites(ids: [Int]) {
        let parameters = ["include": 5230] as [String : Any]
        Alamofire.request("http://forshmag.me/wp-json/wp/v2/posts/", method: .get, parameters: parameters).responseJSON { response in
            if let json = response.result.value! as? Array<Dictionary<String, Any>> {
                for post in json {
                    var postTemp: Dictionary<String, Any> = [:]
                    if let link = post["id"] as? Int{
                        postTemp["id"] =  link
                    }
                    if let title = post["title"] as? Dictionary<String, Any> {
                        if let rendered = title["rendered"] as? String{
                            postTemp["title"] = rendered
                        }
                    }
                    if let acf = post["acf"] as? Dictionary<String, Any> {
                        if let thumb = acf["thumb-size"] as? String {
                            postTemp["type"] = thumb
                        }
                    }
                    if let mediaId = post["featured_media"] as? Int {
                        postTemp["mediaId"] = mediaId
                    }
                    if let categories = post["categories"] as? Array<Int> {
                        postTemp["categories"] = categories[0]
                    }
                    let post = Post(title: postTemp["title"]! as! String, category: postTemp["categories"] as! Int, url: postTemp["id"] as! Int, type: postTemp["type"]! as! String, mediaId: postTemp["mediaId"] as? Int)
                    self.posts.append(post)
                }
                
            }
            self.tableView.reloadData()
        }
    }
    
    func attemptFetch(){
        let fetchRequest: NSFetchRequest<Favourite> = Favourite.fetchRequest()
        let idSort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [idSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print(error)
        }
        var ids: [Int] = []
        if let obj = controller.fetchedObjects {
            for i in obj {
                ids.append(Int(i.id))
                print(Int(i.id))
            }
        }
        //getFavourites(ids: ids)
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PostVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
