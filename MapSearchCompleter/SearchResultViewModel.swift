//
//  SearchResultViewModel.swift
//  MapSearchCompleter
//
//  Created by Joshua Homann on 10/7/23.
//

import SwiftUI
import MapKit

@Observable
final class SearchResultViewModel {
    private(set) var mapItems: [Item] = []
    func search(_ searchType: SearchType) async {
        let localSearch = searchType.localSearch
        do {
            mapItems = (try await localSearch.start()).mapItems.map { Item(mapItem: $0) }
        } catch {
            print(error)
        }
    }
}

extension SearchResultViewModel {
    enum SearchType {
        case naturalLanguage(term: String), completion(MKLocalSearchCompletion)
        var localSearch: MKLocalSearch {
            switch self {
            case let .completion(completion): return .init(request: .init(completion: completion))
            case let .naturalLanguage(term):
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = term
                return .init(request: request)
            }
        }
    }
    @dynamicMemberLookup
    struct Item: Identifiable {
        let id = UUID()
        var mapItem: MKMapItem
        subscript<Value>(dynamicMember dynamicMember: KeyPath<MKMapItem, Value>) -> Value {
            mapItem[keyPath: dynamicMember]
        }
    }
}

