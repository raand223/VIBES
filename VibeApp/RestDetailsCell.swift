
import UIKit

class RestDetailsCell: UITableViewCell {
    
    
    //@IBOutlet weak var tweetsLbl: UILabel!
    
    @IBOutlet weak var restBGImage: UIImageView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var feelingLbl: UILabel!
    @IBOutlet weak var typeOfRest: UILabel!
    @IBOutlet weak var resturantName: UILabel!
    @IBOutlet weak var ratePercent: UILabel!
    @IBOutlet weak var RatingResult: UILabel!
    @IBOutlet weak var FeelingEmoji: UILabel!
    @IBOutlet weak var likedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add corner radius on `contentView`
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        restBGImage.image = nil
        distanceLbl.text = nil
        typeOfRest.text = nil
        resturantName.text = nil
        ratePercent.text = nil
        RatingResult.text = nil
        FeelingEmoji.text = nil
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.insetBy(dx: 10, dy: 10)
        
    }
    
    func configureCell(resturant: Details){
        resturantName.attributedText = NSMutableAttributedString(string: resturant.resturantName, attributes: LabelTextAttributes)
        
        restBGImage.image = resturant.photo
        typeOfRest.attributedText = NSMutableAttributedString(string: resturant.resturantType, attributes: LabelTextAttributes)
        if resturant.distance == 0.0 {
            distanceLbl.text = "1.5 كم"
        }else{
             distanceLbl.attributedText = NSMutableAttributedString(string: "\(String(round(resturant.distance * 10) / 10)) كم", attributes: LabelTextAttributes)
        }
       
        RatingResult.text = resturant.feeling
        ratePercent.text = "\(String(resturant.feelingRating))%"
        
        
        
       let isLiked = LikedResturant.shared.resturantList.contains { (details) -> Bool in
            details.resturantId == resturant.resturantId
        }
        
        likedImage.isHidden = !isLiked
        
        
        switch resturant.feeling {
        case "منبهر":
            FeelingEmoji.text = "😍"
        case "سعيد":
            FeelingEmoji.text = "😂"
        case "راضي":
            FeelingEmoji.text = "😌"
        case "نادم":
            FeelingEmoji.text = "🙁"
        case "مستاء":
            FeelingEmoji.text = "😢"
        case "غاضب":
            FeelingEmoji.text = "😡"
        default:
            FeelingEmoji.text = "😐"
            break
        }
    }
    
    let LabelTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.white,
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: 0
    ]
    
    
}




