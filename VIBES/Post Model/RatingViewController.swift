//
//  RatingViewController.swift
//  VibeApp
//

//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class RatingViewController: UIViewController {

    @IBOutlet weak var HappyRate: UILabel!
    @IBOutlet weak var HappyProgress: UIProgressView!
    @IBOutlet weak var impressedRate: UILabel!
    @IBOutlet weak var impressedProgress: UIProgressView!
    @IBOutlet weak var cofortbleRate: UILabel!
    @IBOutlet weak var cofrtbleProgress: UIProgressView!
    @IBOutlet weak var angreRate: UILabel!
    @IBOutlet weak var angryProgress: UIProgressView!
    @IBOutlet weak var contrtutionProgress: UIProgressView!
    @IBOutlet weak var contrtutionLabel: UILabel!
    @IBOutlet weak var sadRate: UILabel!
    @IBOutlet weak var sadProgress: UIProgressView!
    var resturantRating:Rating!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let total:Double = resturantRating.angry + resturantRating.happy + resturantRating.comfortable + resturantRating.contirition + resturantRating.sad + resturantRating.impressed
        
        if total != 0 {
        HappyRate.text = "\(String(Int(resturantRating.happy/total * 100)))%"
        HappyProgress.progress = Float(resturantRating.happy/total)
        
        impressedRate.text = "\(String(Int(resturantRating.impressed/total * 100)))%"
        impressedProgress.progress = Float(resturantRating.impressed/total)
        
        cofortbleRate.text = "\(String(Int(resturantRating.comfortable/total * 100)))%"
        cofrtbleProgress.progress = Float(resturantRating.comfortable/total)
        
        angreRate.text = "\(String(Int(resturantRating.angry/total * 100)))%"
        angryProgress.progress = Float(resturantRating.angry/total)
        
        contrtutionLabel.text = "\(String(Int(resturantRating.contirition/total * 100)))%"
        contrtutionProgress.progress = Float(resturantRating.contirition/total)
        
        sadRate.text = "\(String(Int(resturantRating.sad/total * 100)))%"
        sadProgress.progress = Float(resturantRating.sad/total)
        
        }else {
            HappyRate.text = "\(String(Int(0)))%"
            HappyProgress.progress = Float(0)
            
            impressedRate.text = "\(String(Int(0)))%"
            impressedProgress.progress = Float(0)
            
            cofortbleRate.text = "\(String(Int(0)))%"
            cofrtbleProgress.progress = Float(0)
            
            angreRate.text = "\(String(Int(0)))%"
            angryProgress.progress = Float(0)
            
            contrtutionLabel.text = "\(String(Int(0)))%"
            contrtutionProgress.progress = Float(0)
            
            sadRate.text = "\(String(Int(0)))%"
            sadProgress.progress = Float(0)
        }
    }
    
   

}
