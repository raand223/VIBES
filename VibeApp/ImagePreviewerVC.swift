

import UIKit

class ImagePreviewerVC: UIViewController {

    @IBOutlet weak var image: UIImageView!
    var resturantImage: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()

       image.image = resturantImage
    }

}
