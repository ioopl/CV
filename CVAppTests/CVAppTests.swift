//
//  CVAppTests.swift
//  CVAppTests
//
//  Created by Umair Hasan on 21/04/2019.
//

import XCTest
import RxSwift

@testable import CVApp

class CVAppTests: XCTestCase {

    private var testViewModel: ViewModel!
    var fakeWebRequestDispatcher: FakeWebRequestDispatcher!
    var resumeRestClient: ResumeRestClient!


    override func setUp() { }

    func testDTO() {
        let expectedResumeDTO = ResumeDto(title: "My Summary")
        let fakeResumeDTO = loadFakeResumeResponse()
        print(fakeResumeDTO)
        print(expectedResumeDTO)
        XCTAssertEqual(fakeResumeDTO, expectedResumeDTO)
    }

    private func loadFakeResumeResponse() -> Observable<[ResumeDto]> {
        fakeWebRequestDispatcher.responseDataFile = File(name: "mockCV", type: "json")
        let observable = resumeRestClient.getCV()
        return observable.asObservable().self

    }
}

struct File {
    let name: String
    let type: String
}

class FakeWebRequestDispatcher: HTTPDispatcher {

    var responseDataFile: File?
    var requestBuilt: Request?
    var responseCode: Int = 200

    func dispatch(request: Request) -> Single<(HTTPURLResponse, Data)> {
        requestBuilt = request
        let response = HTTPURLResponse(url: URL(string: "www.example.com")!,
                                       statusCode: responseCode,
                                       httpVersion: nil,
                                       headerFields: ["headers": "1"])!

        let data: Data

        if let responseDataFile = responseDataFile {
            let bundle = Bundle(for: FakeWebRequestDispatcher.self)
            let filePath = bundle.url(forResource: responseDataFile.name, withExtension: responseDataFile.type)!
            data = try! Data(contentsOf: filePath)
        } else {
            data = Data()
        }

        return Single.just((response, data))
    }
}

public protocol HTTPDispatcher {
    func dispatch(request: Request) -> Single<(HTTPURLResponse, Data)>
}

public struct Request {
    public let resource: Resource
    public let timeout: Int

    private init(resource: Resource,
                 timeout: Int,
                 acceptHeader: AcceptHeader) {
        self.resource = resource
        self.timeout = timeout
    }
}

public struct Resource {
    public let endpoint: Endpoint
    public let method: RequestMethod

    public init(endpoint: Endpoint,
                method: RequestMethod) {
        self.endpoint = endpoint
        self.method = method
    }
}

extension Resource: Equatable {
    public static func == (lhs: Resource, rhs: Resource ) -> Bool {
        return lhs.endpoint.asString() == rhs.endpoint.asString()
            && lhs.method == rhs.method
    }
}

public enum RequestMethod {
    case get
    case post
    case delete
    case put

    private static let getMethod = "GET"
    private static let postMethod = "POST"
    private static let deleteMethod = "DELETE"
    private static let putMethod = "PUT"

    public func asString() -> String {
        switch self {
        case .get:
            return RequestMethod.getMethod
        case .post:
            return RequestMethod.postMethod
        case .delete:
            return RequestMethod.deleteMethod
        case .put:
            return RequestMethod.putMethod

        }
    }
}

public enum AcceptHeader {
    case json
    case image
    case html
    case plainText
    case xml
    case pdf

    private static let jsonAcceptHeader = "application/json"
    private static let imageAcceptHeader = "image/jpg, image/jpeg, image/png"
    private static let htmlAcceptHeader = "text/html"
    private static let plainTextAcceptHeader = "text/plain"
    private static let xmlTextAcceptHeader = "application/xml, text/xml"
    private static let pdfAcceptHeader = "application/pdf"

    func asString() -> String {
        switch self {
        case .json:
            return AcceptHeader.jsonAcceptHeader
        case .image:
            return AcceptHeader.imageAcceptHeader
        case .html:
            return AcceptHeader.htmlAcceptHeader
        case .plainText:
            return AcceptHeader.plainTextAcceptHeader
        case .xml:
            return AcceptHeader.xmlTextAcceptHeader
        case .pdf:
            return AcceptHeader.pdfAcceptHeader
        }
    }
}

public struct Endpoint {
    private let url: URL

    public init?(with url: URL?) {
        guard let url = url else {
            return nil
        }
        self.url = url
    }

    public func asString() -> String {
        return url.absoluteString
    }
}
