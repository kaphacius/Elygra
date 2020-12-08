//
//  LinkItemsListVM.swift
//  Elygra
//
//  Created by Yurii Zadoianchuk on 05/12/2020.
//

import Foundation
import SwiftUI
import Combine

struct LinkItemVM: Identifiable {
    let id: String
    let name: String
    let loginUrl: URL?

    var hasLogin: Bool { loginUrl != nil }
}

class LinkItemsListVM: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var linkItemVMs: Array<LinkItemVM> = []
    @Published var searchString: String = String()
    @Published var canPrev: Bool = false
    @Published var canNext: Bool = false
    @Published var presentingLoginScreen: Bool = false
    @Published var presentingLoginUrl: URL? = nil
    var presentingTitle: String = String()
    @Published var presentingAlert: Bool = false
    @Published var title: String = String()

    private let linkItemsSubject = PassthroughSubject<LinkItemsResource, Never>()
    private var lastResponse: LinkItemsResponse? = nil
    private var cancellables: Set<AnyCancellable> = []
    private let network: Network

    init(withNetwork n: Network) {
        self.network = n

        setUpSearch()
    }

    private func setUpSearch() {
        linkItemsSubject
            .flatMap(maxPublishers: .max(1), { r -> AnyPublisher<ELResult<LinkItemsResponse>, Never> in
                DispatchQueue.main.async { self.setLoadingState() }
                return self.network.load(resource: r)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: self.linkItemsResponseReceived)
            .store(in: &cancellables)

        $searchString
            .subscribe(on: DispatchQueue.global())
            .removeDuplicates()
            .debounce(for: 0.2, scheduler: DispatchQueue.global())
            .map { s -> LinkItemsResource in
                LinkItemsResource(search: s, offset: 0)
            }.sink(receiveValue: { r in
                self.linkItemsSubject.send(r)
            }).store(in: &cancellables)
    }

    private func setLoadingState () {
        isLoading = true
        linkItemVMs = []
        canPrev = false
        canNext = false
    }

    func onAppear() {
        presentingLoginScreen = false
        presentingLoginUrl = nil
        presentingAlert = false
        presentingTitle = String()
    }

    func onItemTap(with vm: LinkItemVM) {
        if let url = vm.loginUrl {
            presentingLoginScreen = true
            presentingLoginUrl = url
            presentingTitle = vm.name
        } else {
            presentingAlert = true
        }
    }

    func onPrevTap() {
        guard let offset = lastResponse.flatMap(\.prevOffset) else { return }
        linkItemsSubject.send(LinkItemsResource(search: searchString, offset: offset))
    }

    func onNextTap() {
        guard let offset = lastResponse.flatMap(\.nextOffset) else { return }
        linkItemsSubject.send(LinkItemsResource(search: searchString, offset: offset))
    }

    func linkItemsResponseReceived(_ r: ELResult<LinkItemsResponse>) {
        isLoading = false

        guard let response = try? r.get() else {
            return
        }

        linkItemVMs = response.results.map { li in
            LinkItemVM(
                id: li.id,
                name: li.name,
                loginUrl: li.loginUrl
            )
        }
        canPrev = response.previous != nil
        canNext = response.next != nil
        title = getTitle(with: response)

        lastResponse = response
    }

    func getTitle(with response: LinkItemsResponse) -> String {
        if response.count == 0 {
            return "No Results"
        }

        let lower: Int
        if response.previous == nil {
            lower = 1
        } else if let prevOffset = response.prevOffset {
            lower = prevOffset + LinkItemsResource.defaultLimit + 1
        } else {
            lower = 1
        }

        let upper: Int
        if (lower + LinkItemsResource.defaultLimit - 1) < response.count {
            upper = (lower + LinkItemsResource.defaultLimit - 1)
        } else {
            upper = response.count
        }

        return "Showing results \(lower) - \(upper) out of \(response.count)"
    }
}
