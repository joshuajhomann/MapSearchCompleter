//
//  SearchViewModel.swift
//  MapSearchCompleter
//
//  Created by Joshua Homann on 10/7/23.
//
import SwiftUI
import MapKit

@Observable
final class SearchViewModel {
    private(set) var searchCompletions: [SearchCompletion] = []
    var selectedCompletion: MKLocalSearchCompletion?
    private let completer = MKLocalSearchCompleter()
    private let completerDelegate = CompleterDelegate()
    let (outputTerm, inputTerm) = AsyncStream.makeStream(of: String.self, bufferingPolicy: .bufferingNewest(1))
    private var debounce: Timer?
    func subscribe() async {
        completer.delegate = completerDelegate
        for await completions in completerDelegate.output {
            searchCompletions = completions.map { completion in
                SearchCompletion(localSearchCompletion: completion) { [weak self] in
                    self?.selectedCompletion = completion
                }
            }
        }
    }
    func search(for term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return searchCompletions = [] }
        if completer.isSearching {
            completer.cancel()
        }
        debounce?.invalidate()
        debounce = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [completer] _ in
            completer.queryFragment = term
        }
    }

    private final class CompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
        let (output, input) = AsyncStream.makeStream(of: [MKLocalSearchCompletion].self, bufferingPolicy: .bufferingNewest(1))
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            input.yield(completer.results)
        }
        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            print(error.localizedDescription)
        }
    }
}

extension SearchViewModel {
    @dynamicMemberLookup
    struct SearchCompletion: Identifiable {
        let id = UUID()
        var localSearchCompletion: MKLocalSearchCompletion
        var onTap: () -> Void
        subscript<Value>(dynamicMember dynamicMember: KeyPath<MKLocalSearchCompletion, Value>) -> Value {
            localSearchCompletion[keyPath: dynamicMember]
        }
    }
}
