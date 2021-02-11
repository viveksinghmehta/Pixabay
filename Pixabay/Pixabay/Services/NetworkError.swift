//
//  NetworkError.swift
//  Pixabay
//
//  Created by WishACloud on 11/02/21.
//

import Foundation


enum NetworkError: Error {
    case NoStatusCode
    case CouldNotDecodeModel
    case CouldNotGetResponse
}


extension NetworkError: LocalizedError {
    
    public var localizedDescription: String {
        switch self {
        case .NoStatusCode:
            return "No status code found"
        case .CouldNotDecodeModel:
            return "Could not decode the model"
        case .CouldNotGetResponse:
            return "Could not get the response for server"
        }
    }
    
}



