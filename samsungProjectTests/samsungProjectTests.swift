//
//  samsungProjectTests.swift
//  samsungProjectTests
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import Testing
@testable import samsungProject

struct samsungProjectTests {

    struct FakeMovieService: MovieServicing {
        let pages: [Int: [Movie]]

        func searchMovies(query: String, page: Int, pageSize: Int) async throws -> MoviesPage {
            let movies = pages[page] ?? []
            let hasMore = !(pages[page + 1] ?? []).isEmpty
            return MoviesPage(movies: movies, hasMore: hasMore)
        }
    }

    @Test @MainActor func moviesViewModel_paginatesByChunk() async throws {
        let page1 = (1...3).map { index in
            Movie(id: "tt\(index)", title: "Movie \(index)", year: 2000 + index, posterURL: URL(string: "https://example.com/\(index).jpg"))
        }
        let page2 = (4...5).map { index in
            Movie(id: "tt\(index)", title: "Movie \(index)", year: 2000 + index, posterURL: URL(string: "https://example.com/\(index).jpg"))
        }

        let viewModel = MoviesViewModel(
            service: FakeMovieService(pages: [1: page1, 2: page2]),
            pageSize: 3
        )

        await viewModel.loadInitial()
        #expect(viewModel.movies == page1)
        #expect(viewModel.canLoadMore == true)

        await viewModel.loadNextPage()
        #expect(viewModel.movies == page1 + page2)
        #expect(viewModel.canLoadMore == false)
    }

}
