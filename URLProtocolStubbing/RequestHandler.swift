//
//  RequestHandler.swift
//  URLProtocolStubbing
//
//  Created by Yannic Borgfeld on 16.08.21.
//

import Foundation

public class RequestHandler {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        session.dataTask(with: URLRequest(url: url)) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
}
