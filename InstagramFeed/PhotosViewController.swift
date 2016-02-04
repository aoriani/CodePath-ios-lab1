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
    
    var medias: [NSURL] = []
    
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
                self.medias.removeAll()
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? [String:AnyObject] {
                            if let data = responseDictionary["data"] as? [[String:AnyObject]] {
                                for image in data {
                                    if let images = image["images"] as? [String: AnyObject] {
                                        if let standard_resolution = images["standard_resolution"] as? [String: AnyObject] {
                                            if let url = standard_resolution["url"] {
                                                self.medias.append(NSURL(string: url as! String)!)
                                            }
                                        }
                                    }
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
        cell.imgView.setImageWithURL(medias[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medias.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! PhotoDetailsViewController
        let indexPath = tableView.indexPathForCell(sender as! TableViewCell)
        vc.photo = medias[(indexPath?.row)!]
        vc.navigationItem.title = vc.photo?.absoluteString
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

