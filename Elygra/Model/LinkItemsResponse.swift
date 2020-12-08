//
//  LinkItemsResponse.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 05/12/2020.
//

import Foundation

struct LinkItemsResponse: Decodable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: Array<LinkItem>

    var nextOffset: Int? {
        next
            .flatMap(\.[queryParam: LinkItemsResource.offset])
            .flatMap(Int.init)
    }

    var prevOffset: Int? {
        previous
            .flatMap(\.[queryParam: LinkItemsResource.offset])
            .flatMap(Int.init)
    }
}

extension URL {
    subscript(queryParam p: String) -> String? {
         URLComponents(string: absoluteString)
        .flatMap(\.queryItems)
        .flatMap { items in items.first(where: { $0.name == p }) }
        .flatMap(\.value)
    }
}
