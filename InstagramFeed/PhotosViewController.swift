//
//  ViewController.swift
//  InstagramFeed
//
//  Created by Andre Oriani on 2/3/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    class Profile {
        let proFilePicture:NSURL
        let username:String
        let postImage:NSURL
        
        init(user:String, imgUrl:NSURL, postImage:NSURL) {
            self.proFilePicture = imgUrl
            self.username = user
            self.postImage = postImage
        }
        
    }
    
    var posts:[Profile] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 320
        
        let uiRefreshControl = UIRefreshControl()
        uiRefreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(uiRefreshControl, atIndex: 0)
        refreshControlAction(uiRefreshControl)
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                self.posts.removeAll()
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? [String:AnyObject] {
                            if let data = responseDictionary["data"] as? [[String:AnyObject]] {
                                for image in data {
                                    var username = "Anonymous"
                                    var profileImage = NSURL(string:"http://41.media.tumblr.com/18a5ac1fc70360ea1b2ef476ec9f15f2/tumblr_mgblfiaRi21qarlxmo1_400.png")
                                    var postImage = NSURL(string: "http://www.lovethispic.com/uploaded_images/54930-Pretty-Pink-Candles.jpg")
                                    if let images = image["images"] as? [String: AnyObject] {
                                        if let standard_resolution = images["standard_resolution"] as? [String: AnyObject] {
                                            if let url = standard_resolution["url"] {
                                                postImage = NSURL(string:url as! String)                                            }
                                        }
                                    }
                                    
                                    if let user = image["user"] {
                                        username = user["username"] as! String
                                        profileImage = NSURL(string: user["profile_picture"] as!String)
                                    }
                                   
                                    let profile = Profile(user: username, imgUrl: profileImage!, postImage: postImage!)
                                    self.posts.append(profile)
                                }
                            }
                    }
                }
                self.tableView.reloadData()
                refreshControl.endRefreshing()
        });
        task.resume()

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
        cell.imgView.setImageWithURL(posts[indexPath.section].postImage)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! PhotoDetailsViewController
        let indexPath = tableView.indexPathForCell(sender as! TableViewCell)
        vc.photo = posts[(indexPath?.section)!].postImage
        vc.navigationItem.title = vc.photo?.absoluteString
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).CGColor
        profileView.layer.borderWidth = 1;
        
        // Use the section number to get the right URL
        profileView.setImageWithURL(posts[section].proFilePicture)
        
        headerView.addSubview(profileView)
        
        // Add a UILabel for the username here
        let label = UILabel(frame: CGRect(x:50, y:10, width: 170, height: 30))
        label.font.fontWithSize(CGFloat(10))
        label.text = posts[section].username
        headerView.addSubview(label)
        
        return headerView

    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

