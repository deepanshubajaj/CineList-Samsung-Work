//
//  MoviesViewModel.swift
//  samsungProject
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import Foundation

@MainActor
final class MoviesViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(message: String)
    }

    private let service: MovieServicing
    private let pageSize: Int

    var canLoadMore: Bool {
        hasMorePages && !isLoadingPage
    }

    var isLoadingMore: Bool {
        isLoadingPage && currentPage > 0
    }
    
    private(set) var movies: [Movie] = []
    private(set) var currentQuery: String = ""
    private(set) var currentPage: Int = 0

    private var hasMorePages: Bool = true
    private var isLoadingPage: Bool = false
    private var currentSearchToken = UUID()
    private var seenMovieIDs = Set<String>()

    private(set) var state: State = .idle {
        didSet { didUpdateState?(state) }
    }
    
    var didUpdateMovies: (() -> Void)?
    var didUpdateState: ((State) -> Void)?

    init(service: MovieServicing = MovieService(), pageSize: Int = 20) {
        self.service = service
        self.pageSize = pageSize
    }
    
    func loadInitial() async {
        await search(query: currentQuery)
    }

    func reload() async {
        await search(query: currentQuery)
    }

    func search(query: String) async {
        let token = UUID()
        currentSearchToken = token

        currentQuery = query
        state = .loading

        currentPage = 0
        hasMorePages = true
        isLoadingPage = false
        seenMovieIDs = []
        movies = []
        didUpdateMovies?()

        await loadPage(page: 1, token: token)
    }

    func loadNextPageIfNeeded(currentIndex: Int) {
        guard currentIndex >= movies.count - 10 else { return }
        Task { await loadNextPage() }
    }

    func loadNextPage() async {
        guard hasMorePages, !isLoadingPage else { return }
        await loadPage(page: currentPage + 1, token: currentSearchToken)
    }

    private func loadPage(page: Int, token: UUID) async {
        guard !isLoadingPage else { return }
        isLoadingPage = true
        if page > 1 {
            didUpdateMovies?()
        }
        defer {
            isLoadingPage = false
            didUpdateMovies?()
        }

        do {
            let pageResult = try await service.searchMovies(query: currentQuery, page: page, pageSize: pageSize)
            guard currentSearchToken == token else { return }

            let newMovies = pageResult.movies.filter { seenMovieIDs.insert($0.id).inserted }
            if page == 1 {
                movies = newMovies
            } else {
                movies.append(contentsOf: newMovies)
            }

            currentPage = page
            hasMorePages = pageResult.hasMore && !newMovies.isEmpty
            state = .loaded
        } catch {
            guard currentSearchToken == token else { return }
            hasMorePages = false
            state = .error(message: "Failed to fetch movies. Please try again.")
        }
    }
}
