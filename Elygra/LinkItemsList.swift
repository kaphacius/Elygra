//
//  ContentView.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 05/12/2020.
//

import SwiftUI

struct LinkItemsList: View {
    @ObservedObject var vm: LinkItemsListVM

    var body: some View {
        VStack {
            TextField("Search...", text: $vm.searchString)
            List {
                ForEach(vm.linkItemVMs, content: LinkItemView.init)
            }
        }
    }
}

struct LinkItemView: View {
    let vm: LinkItemVM

    var body: some View {
        HStack {
            Text(vm.name)
        }
    }
}
