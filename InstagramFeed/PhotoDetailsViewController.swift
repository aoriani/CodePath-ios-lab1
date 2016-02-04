//
//  PhotoDetailsViewController.swift
//  InstagramFeed
//
//  Created by Andre Oriani on 2/3/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    @IBOutlet weak var bgImageView: UIImageView!
    var photo: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let photoUrl = photo {
            bgImageView.setImageWithURL(photoUrl)
            bgImageView.clipsToBounds = true
        }
    }

    
    

}
