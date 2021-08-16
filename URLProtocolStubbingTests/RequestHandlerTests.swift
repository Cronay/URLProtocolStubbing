//
//  RequestHandlerTests.swift
//  URLProtocolStubbingTests
//
//  Created by Yannic Borgfeld on 16.08.21.
//

import XCTest
import URLProtocolStubbing

class RequestHandlerTests: XCTestCase {

    override func tearDown() {
        URLProtocolStub.removeStubs()
    }
    
    func test_get_makesGetRequestWithURL() {
        let url = URL(string: "http://specific-url.com")!
        let sut = makeSUT()
        
        let exp = expectation(description: "Request was made")
        URLProtocolStub.requestObserver = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_get_completesWithErrorOnNetworkError() {
        let sut = makeSUT()
        URLProtocolStub.stubbedError = NSError(domain: "error", code: 0)
        let exp = expectation(description: "Wait for request completion")

        sut.get(from: anyURL()) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Expected failure, but received \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_get_completesWithDataOnSuccessfulResponse() {
        let data = Data("result data".utf8)
        let sut = makeSUT()
        URLProtocolStub.stubbedResult = (data, anyHTTPResponse())
        let exp = expectation(description: "Wait for request completion")
        
        sut.get(from: anyURL()) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, data)
            default:
                XCTFail("Expected success, but received \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // - Helpers
    
    private func makeSUT() -> RequestHandler {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = RequestHandler(session: session)
        return sut
    }
    
    private func anyHTTPResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "http://any-url.com")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil)!
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private class URLProtocolStub: URLProtocol {
        
        static var stubbedError: Error?
        static var stubbedResult: (data: Data, response: URLResponse)?
        
        static var requestObserver: ((URLRequest) -> Void)?
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            
            if let result = URLProtocolStub.stubbedResult {
                client?.urlProtocol(self, didReceive: result.response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: result.data)
            }
            
            if let error = URLProtocolStub.stubbedError {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
            
            URLProtocolStub.requestObserver?(request)
        }
        
        override func stopLoading() {}
        
        static func removeStubs() {
            stubbedError = nil
            stubbedResult = nil
            requestObserver = nil
        }
    }
}
