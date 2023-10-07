//
//  SearchView.swift
//  MapSearchCompleter
//
//  Created by Joshua Homann on 10/7/23.
//
import SwiftUI
import MapKit

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var term = ""
    @State private var searchText: String?
    var body: some View {
        NavigationStack {
            if viewModel.searchCompletions.isEmpty {
                ContentUnavailableView("No suggestions", systemImage: "questionmark.square.dashed")
            } else {
                List(viewModel.searchCompletions) { completion in
                    VStack(alignment: .leading) {
                        Text(completion.title)
                        Text(completion.subtitle).font(.caption).foregroundStyle(.secondary)
                    }
                    .onTapGesture(perform: completion.onTap)
                }
                .navigationDestination(item: $viewModel.selectedCompletion) { completion in
                    SearchResultView(search: .completion(completion))
                }
                .navigationDestination(item: $searchText) { text in
                    SearchResultView(search: .naturalLanguage(term: text))
                }
            }
        }
        .searchable(text: $term)
        .onSubmit(of: .search) { searchText = term }
        .onChange(of: term) { _, _ in viewModel.search(for: term) }
        .task { await viewModel.subscribe() }
    }
}
