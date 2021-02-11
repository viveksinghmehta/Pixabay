//
//  ImagesCell.swift
//  Pixabay
//
//  Created by WishACloud on 11/02/21.
//

import UIKit
import SDWebImage

class ImagesCell: UICollectionViewCell {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
//        containerView.layer.cornerRadius = 6
//        containerView.layer.masksToBounds = true
    }
    
    var imageData: ImageModel? {
        didSet {
            if let previewURL = imageData?.previewURL {
                imageView.sd_setImage(with: URL(string: previewURL), completed: nil)
            }
        }
    }

}
