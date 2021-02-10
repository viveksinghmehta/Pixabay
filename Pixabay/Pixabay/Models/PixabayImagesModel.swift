//
//  PixabayImagesModel.swift
//  Pixabay
//
//  Created by Vivek Singh Mehta on 11/02/21.
//

import Foundation


//MARK;- PixabayImagesModel
struct PixabayImagesModel: Codable {
    var total, totalHits: Int?
    var images: [ImageModel]?
    
    enum CodingKeys: String, CodingKey {
        case total, totalHits
        case images = "hits"
    }
    
}

// MARK: - Hit
struct ImageModel: Codable {
    var id: Int?
    var pageURL: String?
    var type, tags: String?
    var previewURL: String?
    var previewWidth, previewHeight: Int?
    var webformatURL: String?
    var webformatWidth, webformatHeight: Int?
    var largeImageURL: String?
    var imageWidth, imageHeight, imageSize, views: Int?
    var downloads, favorites, likes, comments: Int?
    var userID: Int?
    var user: String?
    var userImageURL: String?

    enum CodingKeys: String, CodingKey {
        case id, pageURL, type, tags, previewURL, previewWidth, previewHeight, webformatURL, webformatWidth, webformatHeight, largeImageURL, imageWidth, imageHeight, imageSize, views, downloads, favorites, likes, comments
        case userID = "user_id"
        case user, userImageURL
    }
}
