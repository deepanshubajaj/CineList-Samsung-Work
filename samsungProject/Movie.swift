//
//  Movie.swift
//  samsungProject
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import Foundation

struct Movie: Identifiable, Hashable {
    let id: String
    let title: String
    let year: Int?
    let posterURL: URL?
}
