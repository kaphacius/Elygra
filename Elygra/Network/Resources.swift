//
//  Resources.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 05/12/2020.
//

import Foundation

protocol Resource {
    var url: URL? { get }
}

struct LinkItemsResource: Resource, Equatable {
    static let search = "search"
    static let limit = "limit"
    static let offset = "offset"
    static let defaultLimit = 15

    let search: String
    let offset: Int

    var url: URL? {
        guard var comps = URLComponents(string: "link-items") else { return nil }

        comps.queryItems = [
            URLQueryItem(name: LinkItemsResource.search, value: search),
            URLQueryItem(name: LinkItemsResource.limit, value: String(describing: LinkItemsResource.defaultLimit)),
            URLQueryItem(name: LinkItemsResource.offset, value: String(describing: offset))
        ]

        return comps.url
    }
}
