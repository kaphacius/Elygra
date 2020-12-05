//
//  Network.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 05/12/2020.
//

import Foundation
import Combine

enum Errors: Error {
    case URLError(URLError)
    case parsingError
    case urlBuildFailed
}

class Network {
    private let remoteURL: URL

    init(withRemoteUrl url: URL) {
        self.remoteURL = url
    }

    func load<T>(resource r: Resource) -> AnyPublisher<T, Error> where T : Decodable {
        guard let url = r.url else {
            return Fail<T, Error>(error: Errors.urlBuildFailed).eraseToAnyPublisher() }

        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError(Errors.URLError)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
