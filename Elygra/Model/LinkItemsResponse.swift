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
}
