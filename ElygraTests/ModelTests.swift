//
//  ElygraTests.swift
//  ElygraTests
//
//  Created by Yurii Zadoianchuk on 05/12/2020.
//

import XCTest
@testable import Elygra

class ModelTests: XCTestCase {
    func testLinkItemParsing() throws {
        guard let urlPath = mockJsonPath(with: "LinkItem") else {
            XCTAssert(false, "Mock for \(#function) not found")
            return
        }

        do {
            let data = try Data(contentsOf: urlPath)
            let li = try JSONDecoder().decode(LinkItem.self, from: data)

            XCTAssert(li.id == "amazon_warehouse", "Property id of LinkItem does not match")
            XCTAssert(li.name == "Amazon Warehouse", "Property name of LinkItem does not match")
            XCTAssert(li.isDisabled == false, "Property is_disabled of LinkItem does not match")
            XCTAssert(li.loginUrl.map(\.absoluteString) == "https://www.amazon.work", "Property login_url of LinkItem does not match")
        } catch (let e) {
            XCTAssert(false, "Reading mock json in \(#function) failed with \(e)")
        }
    }

    func testLinkItemsResponseParsing() throws {
        guard let urlPath = mockJsonPath(with: "LinkItemsResponse") else {
            XCTAssert(false, "Mock for \(#function) not found")
            return
        }

        do {
            let data = try Data(contentsOf: urlPath)
            let lir = try JSONDecoder().decode(LinkItemsResponse.self, from: data)

            XCTAssert(lir.count == 6038, "Property count of LinkItemsResponse does not match")
            XCTAssert(lir.next.map(\.absoluteString) == "https://api.argyle.io/link/v1/link-items?limit=15&offset=30&search=a", "Property next of LinkItemsResponse does not match")
            XCTAssert(lir.previous.map(\.absoluteString) == "https://api.argyle.io/link/v1/link-items?limit=15&search=a", "Property previous of LinkItemsResponse does not matc")
            XCTAssert(lir.results.count == 15, "Property results.count of LinkItemsResponse does not match")
        } catch (let e) {
            XCTAssert(false, "Reading mock json in \(#function) failed with \(e)")
        }
    }

}

extension ModelTests {
    func mockJsonPath(with name: String) -> URL? {
        Bundle.main.path(forResource: name, ofType: "json")
            .flatMap { URL(fileURLWithPath: $0) }
    }
}
