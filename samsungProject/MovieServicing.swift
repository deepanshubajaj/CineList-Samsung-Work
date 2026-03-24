//
//  MovieServicing.swift
//  samsungProject
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import Foundation

struct MoviesPage: Sendable {
    let movies: [Movie]
    let hasMore: Bool
}

protocol MovieServicing {
    func searchMovies(query: String, page: Int, pageSize: Int) async throws -> MoviesPage
}
