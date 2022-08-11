//
//  RequestHandler.swift
//  URLProtocolStubbing
//
//  Created by Yannic Borgfeld on 16.08.21.
//

import Foundation
import Combine

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

// Replace the request handler above with this one in the makeSUT method of the test to see
// that the way how we perform the request doesn't matter for the URLProtocolStub.
public class CombineRequestHandler {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    var cancellable: AnyCancellable?
    
    public func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        cancellable = session.dataTaskPublisher(for: URLRequest(url: url))
            .sink(receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .finished:
                    break
                }
            }, receiveValue: { (data, _) in
                completion(.success(data))
            })
    }
}
