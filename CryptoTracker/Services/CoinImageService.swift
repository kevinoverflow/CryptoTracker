//
//  CoinImageService.swift
//  CryptoTracker
//
//  Created by Kevin Hoàng on 02.03.22.
//

import Foundation
import UIKit

class CoinImageService {
    
    static let shared = CoinImageService()
        
    func getImage(for coin: Coin, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        if let savedImage = ACFileManager.shared.getImage(imageName: coin.id) {
            completion(.success(savedImage))
        } else {
            downloadImage(coin: coin) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let image):
                    completion(.success(image))
                }
            }
        }
    }
    
    func downloadImage(coin: Coin, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        guard let url = URL(string: coin.image) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.transportError(error)))
            }
            
            if let response = response as? HTTPURLResponse, !(response.statusCode >= 200 && response.statusCode < 300) {
                completion(.failure(.serverError(statusCode: response.statusCode)))
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            if let image = UIImage(data: data) {
                ACFileManager.shared.saveImage(image: image, imageName: coin.id)
                completion(.success(image))
                return
            }
        }
        task.resume()
    }
}
