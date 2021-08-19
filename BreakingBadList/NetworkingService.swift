//
//  NetworkingService.swift
//  BreakingBadList
//
//  Created by Brian Lara on 8/19/21.
//

import Foundation

class NetworkingService{

static let shared = NetworkingService()

// MARK: - Initialization

    private init () {}

    func fetchData(url: String, completion: @escaping (String?, Any?) -> Void) {
        
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.timeoutIntervalForRequest = 120.0;
        defaultConfiguration.timeoutIntervalForResource = 120.0;
        
        let sessionWithOutDelegate = URLSession(configuration: defaultConfiguration)
        guard let requestURL = URL(string: url.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)) else { return }

        let task = sessionWithOutDelegate.dataTask(with: requestURL) { (data, response, error) in
            
            if let error = error {
                completion(error.localizedDescription, nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 200 {

                    if let _data = data {
                       completion(nil, _data)
                    }
                    
                } else if httpResponse.statusCode == 204 {
                    
                    completion("\(httpResponse.statusCode) + Resource not found", nil)
                    return
                    
                } else {

                    completion("\(httpResponse.statusCode) + Server Error", nil)
                    return
                }
            }
        }
        
        task.resume()
    }

}
