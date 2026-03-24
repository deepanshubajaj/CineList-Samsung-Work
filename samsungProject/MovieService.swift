//
//  MovieService.swift
//  samsungProject
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import Foundation

final class MovieService: MovieServicing {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchMovies(query: String, page: Int, pageSize: Int) async throws -> MoviesPage {
        var components = URLComponents(string: "https://jsonfakery.com/movies/paginated")!
        components.queryItems = [URLQueryItem(name: "page", value: String(max(1, page)))]
        let url = components.url!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(JSONFakeryMoviesResponse.self, from: data)
        let movies = apiResponse.data.map { item in
            Movie(
                id: item.id,
                title: item.originalTitle,
                year: item.year,
                posterURL: item.posterURL
            )
        }

        let hasMore = apiResponse.nextPageURL != nil || !movies.isEmpty
        return MoviesPage(movies: movies, hasMore: hasMore)
    }
}

private struct JSONFakeryMoviesResponse: Decodable {
    let data: [JSONFakeryMovie]
    let nextPageURL: String?

    private enum CodingKeys: String, CodingKey {
        case data
        case nextPageURL = "next_page_url"
    }
}

private struct JSONFakeryMovie: Decodable {
    let id: String
    let originalTitle: String
    let releaseDate: String?
    let posterPath: String?

    var year: Int? {
        guard let releaseDate else { return nil }
        let digits = releaseDate.filter { $0.isNumber }
        guard digits.count >= 4 else { return nil }
        return Int(digits.suffix(4))
    }

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: posterPath)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case originalTitle = "original_title"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
}
