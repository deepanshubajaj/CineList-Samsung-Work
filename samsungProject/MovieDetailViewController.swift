//
//  MovieDetailViewController.swift
//  samsungProject
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import UIKit

final class MovieDetailViewController: UIViewController {
    private let movie: Movie

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()
    private var imageTask: URLSessionDataTask?

    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        imageTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Details"
        view.backgroundColor = .systemBackground

        configureViews()
        configureLayout()
        render()
        
        // Enable tapping the poster to open full screen
        posterImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPoster))
        posterImageView.addGestureRecognizer(tap)
    }

    private func configureViews() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 20
        posterImageView.backgroundColor = .tertiarySystemFill

        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(posterImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        view.addSubview(stackView)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.0),
        ])
    }

    private func render() {
        titleLabel.text = movie.title
        var lines: [String] = ["ID: \(movie.id)"]
        if let year = movie.year {
            lines.insert("Year: \(year)", at: 0)
        }
        if let posterURL = movie.posterURL {
            lines.append("Poster: \(posterURL.absoluteString)")
        }
        subtitleLabel.text = lines.joined(separator: "\n")

        guard let url = movie.posterURL else { return }
        imageTask = ImageLoader.shared.loadImage(from: url) { [weak self] image in
            guard let self, let image else { return }
            self.posterImageView.image = image
        }
    }
    
    @objc private func didTapPoster() {
        guard let image = posterImageView.image else { return }
        FullScreenImageViewController.present(from: self, image: image)
    }
}
