
import UIKit

class HomeViewController: UIViewController {
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func forSquareButtonTapped(_ sender: Any) {
        count = 0
    }

    @IBAction func googlePlaceApiButtonTapped(_ sender: Any) {
        count = 1
    }
    
}

