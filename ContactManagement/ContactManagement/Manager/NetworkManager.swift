//
//  Networker.swift
//  Quotes
//
//  Created by Sam Meech-Ward on 2020-05-23.
//  Copyright © 2020 meech-ward. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case badResponse
    case badStatusCode(Int)
    case badData
}

class Network {
    
    static let shared = Network()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func getQuote(urlApi: String, completion: @escaping (Data?, Error?) -> (Void)) {
        guard let url = URL(string: urlApi) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badStatusCode(httpResponse.statusCode))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badData)
                }
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
    
    func getImage(imageURL: String ,completion: @escaping (Data?, Error?) -> (Void)) {
        guard let url = URL(string: imageURL) else {
            DispatchQueue.main.async {
                completion(nil, NetworkError.badData)
            }
            return
        }
        
        let task = session.downloadTask(with: url) { (localUrl: URL?, response: URLResponse?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badStatusCode(httpResponse.statusCode))
                }
                return
            }
            
            guard let localUrl = localUrl else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badData)
                }
                return
            }
            
            do {
                let data = try Data(contentsOf: localUrl)
                DispatchQueue.main.async {
                    completion(data, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
