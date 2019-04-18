

import UIKit

class restImageCell: UICollectionViewCell {
    
    @IBOutlet weak var restImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        restImage.image = nil 
    }
    
    func configureUI(image: UIImage) {
        restImage.image = image
    }
    // test
}
