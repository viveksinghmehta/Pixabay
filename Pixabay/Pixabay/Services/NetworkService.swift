//
//  NetworkService.swift
//  Pixabay
//
//  Created by Vivek Singh Mehta on 10/02/21.
//

import Foundation

typealias Parameters = [String : String]


struct Pixabay {
    static let Apikey: String = "20229689-d97db53da67b47ed5c0f0efdd"
}


class NetworkService {
    
    
    //For using the NetworkService
    static let shared = NetworkService()
    
    
    private var baseURL: URLComponents = URLComponents(string: "https://pixabay.com/api/")!
    
    
    
    func getImages<T: Codable>(with parameters: Parameters, model: T.Type, completion: @escaping(Result<T, Error>) -> Void) {
        
        //Creating the query parameters
        var queryParameters = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        //appending the api key query to the url component
        queryParameters.append(URLQueryItem(name: "key", value: Pixabay.Apikey))
        queryParameters.append(URLQueryItem(name: "per_page", value: "20"))
        baseURL.queryItems = queryParameters
        
        guard let url = baseURL.url else { return }
        let urlRequest = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                // return the error
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                //TODO:- thorw error
                return
            }
            self.decodeTheData(with: data, model, completion: completion)
            
        }
        task.resume()
    }
    
    private func decodeTheData<T: Codable>(with data: Data?, _ model: T.Type, completion: @escaping(Result<T, Error>) -> Void) {
        if let jsonData = data {
            let decoder = JSONDecoder()
            do {
                let value = try decoder.decode(T.self, from: jsonData)
                DispatchQueue.main.async {
                    completion(.success(value))
                }
            } catch let error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        } else {
            //TODO:- throw error
        }
    }
    
    
    
}
