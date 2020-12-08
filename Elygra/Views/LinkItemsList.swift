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
        NavigationView {
            ZStack {
                navigationLink
                VStack {
                    searchBar
                    list
                }
                .padding()
            }
            .navigationTitle(vm.presentingLoginScreen ? "Back" : vm.title)
        }.navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $vm.presentingAlert, content: {
            Alert(title: Text("No Login URL for this one"))
        })
    }

    var navigationLink: some View {
        NavigationLink(
            destination: WebViewWrapper(url: vm.presentingLoginUrl)
                .navigationTitle(vm.presentingTitle)
                .onDisappear(perform: vm.onAppear),
            isActive: $vm.presentingLoginScreen) { EmptyView() }
    }

    var searchBar: some View {
        HStack(spacing: 20.0) {
            SearchBar(searchString: $vm.searchString)
            Spacer()
            Button("Previous", action: vm.onPrevTap)
                .disabled(vm.canPrev == false)
            Button("Next", action: vm.onNextTap)
                .disabled(vm.canNext == false)
                .padding(.trailing, 15.0)
        }.padding()
    }

    var list: some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if vm.linkItemVMs.isEmpty {
                Text("No results...")
                    .font(.largeTitle)
            } else {
                List {
                    ForEach(vm.linkItemVMs, content: { ivm in
                        LinkItemView(vm: ivm)
                            .onTapGesture {
                                vm.onItemTap(with: ivm)
                            }
                    })
                }
            }
        }.animation(.none)
        .frame(maxHeight: .infinity)
    }
}

struct LinkItemView: View {
    let vm: LinkItemVM

    var body: some View {
        HStack {
            Text(vm.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            if vm.hasLogin {
                Image(systemName: "chevron.right")
            }
        }.contentShape(Rectangle())
    }
}
