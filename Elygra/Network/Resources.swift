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

struct LinkItemsResource: Resource {
    let search: String
    let limit: Int
    let offset: Int

    var url: URL? {
        guard var comps = URLComponents(string: "link-items") else { return nil }

        comps.queryItems = [
            URLQueryItem(name: "search", value: search),
            URLQueryItem(name: "limit", value: String(describing: limit)),
            URLQueryItem(name: "offset", value: String(describing: offset))
        ]

        return comps.url
    }
}
