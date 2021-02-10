//
//  GalleryController.swift
//  Pixabay
//
//  Created by WishACloud on 11/02/21.
//

import UIKit

class GalleryController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    
    //MARK:- Properties
    var pixabayImagesModel: PixabayImagesModel!
    private let identifier: String = "images"
    private let page: Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewInit()
    }
    
    
    
    fileprivate func collectionViewInit() {
        galleryCollectionView.register(UINib(nibName: "ImagesCell", bundle: nil), forCellWithReuseIdentifier: identifier)
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        if let layout = galleryCollectionView?.collectionViewLayout as? PinterestLayout {
          layout.delegate = self
        }
    }

    

}

extension GalleryController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PinterestLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pixabayImagesModel.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ImagesCell else { return UICollectionViewCell() }
        cell.imageData = pixabayImagesModel.images?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullScreen = ImageViewerController()
        fullScreen.selectedImageIndex = indexPath.row
        fullScreen.pixabayImagesModel = pixabayImagesModel
        navigationController?.pushViewController(fullScreen, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
      return CGSize(width: itemSize, height: itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let height = pixabayImagesModel.images?[indexPath.row].previewHeight else {
            return 0.0
        }
        return CGFloat(height)
    }
    
    
}
