//
//  SearchResultView.swift
//  MapSearchCompleter
//
//  Created by Joshua Homann on 10/7/23.
//

import SwiftUI
import MapKit

struct SearchResultView: View {
    @State private var viewModel = SearchResultViewModel()
    var search: SearchResultViewModel.SearchType
    var body: some View {
        Map {
            ForEach(viewModel.mapItems) { item in
                Annotation(item.name ?? "", coordinate: item.placemark.coordinate) {
                    Image(systemName: "mappin.circle").foregroundStyle(.tint)
                }
            }
        }
        .task { await viewModel.search(search) }
    }
}
