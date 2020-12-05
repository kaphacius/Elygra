//
//  LinkItem.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 05/12/2020.
//

import Foundation

struct LinkItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case isDisabled = "is_disabled"
        case loginUrl = "login_url"
    }

    let id: String
    let name: String
    let isDisabled: Bool
    let loginUrl: URL?
}
