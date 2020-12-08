//
//  LinkItemsListVMTests.swift
//  ElygraTests
//
//  Created by Yurii Zadoianchuk on 07/12/2020.
//

import XCTest
@testable import Elygra

class LinkItemsListVMTests: XCTestCase {
    func testSimpleSearch() {
        let mn = MockNetwork(responses: [
            LinkItemsResponse(count: 0, next: nil, previous: nil, results: [])
        ])

        let vm = LinkItemsListVM(withNetwork: mn)
        vm.searchString = "test"

        expectToEventually(
            mn.lastResource.flatMap({ $0 as? LinkItemsResource }) != nil,
            timeout: 1.0
        )

        guard let resource = mn.lastResource.flatMap({ $0 as? LinkItemsResource }) else {
            XCTAssert(false, "Search failed in \(#function)")
            return
        }

        XCTAssert(resource.search == "test", "Search string was not correct")
        XCTAssert(resource.offset == 0, "Search offset was not correct")
        XCTAssert(vm.isLoading == false, "VM still loading after search completed")
        XCTAssert(vm.linkItemVMs.isEmpty, "VM has link items")
    }

    func testInputSearch() {
        let mn = MockNetwork(responses: [
            LinkItemsResponse(count: 0, next: nil, previous: nil, results: []),
            LinkItemsResponse(count: 0, next: nil, previous: nil, results: [])
        ])

        let vm = LinkItemsListVM(withNetwork: mn)
        vm.searchString = "a"
        vm.searchString += "m"
        Thread.sleep(forTimeInterval: 0.1)
        vm.searchString += "a"
        Thread.sleep(forTimeInterval: 1.0)
        vm.searchString += "zon"
        Thread.sleep(forTimeInterval: 1.0)

        expectToEventually(
            mn.numberOfRequests == 2,
            timeout: 3.0
        )

        XCTAssert(mn
                    .lastResource
                    .flatMap({ $0 as? LinkItemsResource })
                    .map(\.search) == "amazon",
                  "Search string was not full")
        XCTAssert(mn.numberOfRequests == 2, "Number of search requests was not correct")
    }

    func testNoPages() {
        let mn = MockNetwork(responses: [
            LinkItemsResponse(count: 0, next: nil, previous: nil, results: [])
        ])

        let vm = LinkItemsListVM(withNetwork: mn)
        vm.searchString = "test"

        expectToEventually(
            mn.lastResource.flatMap({ $0 as? LinkItemsResource }) != nil,
            timeout: 1.0
        )

        XCTAssert(vm.canNext == false, "VM has next page")
        XCTAssert(vm.canPrev == false, "VM has prev page")

        vm.onNextTap()
        vm.onPrevTap()

        expectToEventually(
            mn.numberOfRequests == 1,
            timeout: 1.0
        )

        XCTAssert(mn.numberOfRequests == 1, "Performed pagination when there were no pages")
    }

    func testMultiplePages() {
        let url = URL(string: "localhost?offset=15")!

        let mn = MockNetwork(responses: [
            LinkItemsResponse(count: 0, next: url, previous: nil, results: []),
            LinkItemsResponse(count: 0, next: url, previous: url, results: []),
            LinkItemsResponse(count: 0, next: nil, previous: url, results: []),
            LinkItemsResponse(count: 0, next: url, previous: url, results: [])
        ])

        let vm = LinkItemsListVM(withNetwork: mn)
        vm.searchString = "test"

        expectToEventually(
            mn.numberOfRequests == 1,
            timeout: 2.0
        )

        XCTAssert(vm.canNext == true, "VM has no next page")
        XCTAssert(vm.canPrev == false, "VM has prev page")

        vm.onNextTap()

        expectToEventually(
            vm.canNext && vm.canPrev
        )

        XCTAssert(vm.canNext == true, "VM has no next page")
        XCTAssert(vm.canPrev == true, "VM has no prev page")

        vm.onNextTap()

        expectToEventually(
            vm.canNext == false && vm.canPrev
        )

        XCTAssert(vm.canNext == false, "VM has next page")
        XCTAssert(vm.canPrev == true, "VM has no prev page")

        vm.onPrevTap()

        expectToEventually(
            vm.canNext && vm.canPrev
        )

        XCTAssert(vm.canNext == true, "VM has no next page")
        XCTAssert(vm.canPrev == true, "VM has no prev page")
    }
}
