//
//  ImageLoader.swift
//  samsungProject
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    @discardableResult
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        let nsURL = url as NSURL
        if let cached = cache.object(forKey: nsURL) {
            DispatchQueue.main.async { completion(cached) }
            return nil
        }

        let task = session.dataTask(with: url) { [weak self] data, response, _ in
            guard
                let self,
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode),
                let data,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            self.cache.setObject(image, forKey: nsURL)
            DispatchQueue.main.async { completion(image) }
        }

        task.resume()
        return task
    }
}

