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
    let hasLogin: Bool
}

class LinkItemsListVM: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var linkItemVMs: Array<LinkItemVM> = []
    @Published var searchString: String = String()
    @Published var canPrev: Bool = false
    @Published var canNext: Bool = false

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
            LinkItemVM(id: li.id, name: li.name, hasLogin: li.loginUrl != nil)
        }
        canPrev = response.previous != nil
        canNext = response.next != nil

        lastResponse = response
    }
}
