//
//  ImageViewerController.swift
//  Pixabay
//
//  Created by WishACloud on 11/02/21.
//

import UIKit
import SDWebImage

class ImageViewerController: UIViewController {

    
    @IBOutlet weak var imageViewerCollectionView: UICollectionView!
    
    var pixabayImagesModel: PixabayImagesModel!
    private let identifier: String = "fullScreenImage"
    var selectedImageIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       collectionViewInit()
    }
    
    
    fileprivate func collectionViewInit() {
        imageViewerCollectionView.register(UINib(nibName: "FullScreenImageCell", bundle: nil), forCellWithReuseIdentifier: identifier)
        imageViewerCollectionView.delegate = self
        imageViewerCollectionView.dataSource = self
        imageViewerCollectionView.scrollToItem(at: IndexPath(row: selectedImageIndex, section: 0), at: [.centeredHorizontally, .centeredVertically], animated: false)
    }

}

extension ImageViewerController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pixabayImagesModel.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? FullScreenImageCell else { return UICollectionViewCell() }
        if let largeURL = pixabayImagesModel.images?[indexPath.row].largeImageURL {
            cell.fullScreenImage.sd_setImage(with: URL(string: largeURL), completed: nil)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
}
