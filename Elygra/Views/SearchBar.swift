//
//  SearchBar.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 08/12/2020.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchString: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 6)
            TextField("Search...", text: $searchString)
        }
        .padding(7)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
