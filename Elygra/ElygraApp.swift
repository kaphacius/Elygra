//
//  ElygraApp.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 05/12/2020.
//

import SwiftUI

@main
struct ElygraApp: App {
    let network = Network(withRemoteUrl: URL(string: "https://api.argyle.io/link/v1/")!)

    var body: some Scene {
        WindowGroup {
            LinkItemsList(vm: LinkItemsListVM(withNetwork: network))
        }
    }
}
