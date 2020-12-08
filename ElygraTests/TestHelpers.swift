//
//  TestHelpers.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 08/12/2020.
//

import XCTest
import Combine
@testable import Elygra

class MockNetwork: Network {
    var resources: Array<Resource> = []
    var numberOfRequests: Int { resources.count }
    var lastResource: Resource? { resources.last }
    var responses: Array<Decodable> = []

    init(responses: Array<Decodable>) {
        self.responses = responses
        super.init(withRemoteUrl: URL(string: "localhost")!)
    }

    override func load<T>(resource r: Resource) -> AnyPublisher<ELResult<T>, Never> where T : Decodable {
        resources.append(r)
        if (r as? LinkItemsResource) != nil {
            return ELJust<T>(.success(self.responses[self.resources.count - 1] as! T))
                .eraseToAnyPublisher()
        }

        return ELJust<T>(.failure(Errors.urlBuildFailed)).eraseToAnyPublisher()
    }
}

extension XCTest {
    func expectToEventually(_ test: @autoclosure () -> Bool, timeout: TimeInterval = 1.0, message: String = "") {
        let runLoop = RunLoop.main
        let timeoutDate = Date(timeIntervalSinceNow: timeout)
        repeat {
            // 1
            if test() {
                return
            }
            // 2
            runLoop.run(until: Date(timeIntervalSinceNow: 0.01))
        } while Date().compare(timeoutDate) == .orderedAscending // 3
        // 4
        XCTFail(message)
    }
}


