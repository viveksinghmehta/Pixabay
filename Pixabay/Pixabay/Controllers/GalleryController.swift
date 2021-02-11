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
    private var page: Int = 1
    var searchedKeyword: String = ""
    private var loadMore: Bool = true
    
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
    
    
    fileprivate func loadMoreImages() {
        let parameters = [
            "q": searchedKeyword,
            "page": String(page)
        ]
        Loader.shared.addLoader(on: self, frames: view.bounds)
        NetworkService.shared.getImages(with: parameters, model: PixabayImagesModel.self) { [weak self] (response) in
            guard let weakself = self else { return }
            Loader.shared.removeLoader(from: weakself)
            switch response {
            case .success(let model):
                weakself.adddnewImages(model)
            case .failure(let error):
                print(error.localizedDescription)
                weakself.showAlert(title: "Error", msg: error.localizedDescription)
            }
        }
    }
    
    
    fileprivate func adddnewImages(_ model: PixabayImagesModel) {
        if let images = model.images {
            let firstCount = pixabayImagesModel.images?.count ?? 0
            let lastCount = firstCount + images.count
            self.pixabayImagesModel.images?.append(contentsOf: images)
            galleryCollectionView.reloadData()
//            galleryCollectionView.performBatchUpdates({
//                let indexPaths = Array((firstCount)...(lastCount)).map { IndexPath(item: $0, section: 0) }
//                self.pixabayImagesModel.images?.append(contentsOf: images)
//                self.galleryCollectionView.insertItems(at: indexPaths)
////                galleryCollectionView.reloadData()
//            }, completion: nil)
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if loadMore {
            // loading the new images when the cell will display last images
            if indexPath.row > ((20 * page) - 5) {
                page += 1
                loadMoreImages()
            }
        }
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
