//
//  ResturantDetailsTableViewController.swift
//  VibeApp
//
//  Created by Yazeedo on 26/03/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import ParallaxHeader
import SnapKit
class ResturantDetailsTableViewController: UITableViewController {

    var resturant:Details!
    weak var headerImageView: UIView?
    
    @IBOutlet weak var resturantNameLabel: UILabel!
    @IBOutlet weak var resturantTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

     setupHeaderImage()
        updateContents()
    }

    func updateContents() {
        resturantNameLabel.text = resturant.resturantName
        resturantTypeLabel.text = resturant.resturantType
    }
    func setupHeaderImage() {
        
        
        let imageView = UIImageView()
        imageView.image = resturant.photo!
        imageView.contentMode = .scaleAspectFit
        
        //setup blur vibrant view
        imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: 1).enable()
        
       // headerImageView = imageView
        
        tableView.parallaxHeader.view = imageView
        tableView.parallaxHeader.height =  176
        tableView.parallaxHeader.minimumHeight = 150
        tableView.parallaxHeader.mode = .bottom
        tableView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            //update alpha of blur view on top of image view
            parallaxHeader.view.blurView.alpha = 1 - parallaxHeader.progress
        }
        
        // Label for vibrant text
        let vibrantLabel = UILabel()
        vibrantLabel.numberOfLines = 0
        vibrantLabel.text = "\n\n\(resturant.resturantName)"
        vibrantLabel.font = UIFont.systemFont(ofSize: 35.0)
        vibrantLabel.sizeToFit()
        vibrantLabel.textAlignment = .center
        imageView.blurView.vibrancyContentView?.addSubview(vibrantLabel)
        //add constraints using SnapKit library
        vibrantLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        
        
    }
}
