import UIKit
import SDWebImage

class ProfileView: UIView {
    
    let imageView = UIImageView()
    let nameLabel = UILabel()
    let positionLabel = UILabel()
    
    init() {
        super.init(frame: CGRectZero)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        let defautOffset: CGFloat = 10.0
        let imageWidth: CGFloat = 100.0
        let mainScreenBounds = UIScreen.mainScreen().bounds
        
        imageView.backgroundColor = UIColor.blueColor()
        imageView.frame = CGRect(x: defautOffset, y: defautOffset, width: imageWidth, height: imageWidth)
        addSubview(imageView)
        
        nameLabel.frame = CGRect(x: 2 * defautOffset + imageWidth,
                                 y: defautOffset + 40,
                                 width: mainScreenBounds.width - (3 * defautOffset + imageWidth),
                                 height: 30)
        addSubview(nameLabel)
        
        positionLabel.frame = CGRect(x: 2 * defautOffset + imageWidth,
                                     y: defautOffset + 70,
                                     width: mainScreenBounds.width - (3 * defautOffset + imageWidth),
                                     height: 30)
        addSubview(positionLabel)
    }
    
    func updateInfoWith(name name: String?, position: String?, profileImageURL: String?) {
        nameLabel.text = name
        positionLabel.text = position
        imageView.image = nil
        if let profileImageURL = profileImageURL {
            imageView.sd_setImageWithURL(NSURL(string: profileImageURL))
        }
    }
}
