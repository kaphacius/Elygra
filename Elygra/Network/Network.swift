//
//  Network.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 05/12/2020.
//

import Foundation
import Combine

enum Errors: Error {
    case URLError(Error)
    case parsingError
    case urlBuildFailed
}

typealias ELResult<T> = Result<T, Errors>
typealias ELJust<T> = Just<ELResult<T>>

class Network {
    private let remoteURL: URL

    init(withRemoteUrl url: URL) {
        self.remoteURL = url
    }

    func load<T>(resource r: Resource) -> AnyPublisher<ELResult<T>, Never> where T : Decodable {
        guard let url = r.url,
              let fullUrl = URL(string: url.absoluteString, relativeTo: remoteURL) else {
            return Just<ELResult<T>>(.failure(.urlBuildFailed)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: fullUrl)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .map(Result.success)
            .catch { ELJust<T>(.failure(.URLError($0))).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }
}
