//
//  MovieTableViewCell.swift
//  samsungProject
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import UIKit

protocol MovieTableViewCellDelegate: AnyObject {
    func movieTableViewCellDidTapPoster(_ cell: MovieTableViewCell, image: UIImage?)
}

final class MovieTableViewCell: UITableViewCell {
    static let reuseIdentifier = "MovieTableViewCell"

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let labelsStackView = UIStackView()
    private let containerStackView = UIStackView()

    weak var delegate: MovieTableViewCellDelegate?

    private var imageTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
        configureLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        posterImageView.image = Self.placeholderImage()
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        if let year = movie.year {
            subtitleLabel.text = "\(year) • \(movie.id)"
        } else {
            subtitleLabel.text = movie.id
        }
        posterImageView.image = Self.placeholderImage()

        guard let url = movie.posterURL else { return }
        imageTask = ImageLoader.shared.loadImage(from: url) { [weak self] image in
            guard let self, let image else { return }
            self.posterImageView.image = image
        }
    }

    private func configureViews() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator

        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 12
        posterImageView.backgroundColor = .tertiarySystemFill
        posterImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPoster))
        posterImageView.addGestureRecognizer(tap)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 2

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1

        labelsStackView.axis = .vertical
        labelsStackView.spacing = 4
        labelsStackView.alignment = .fill
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)

        containerStackView.axis = .horizontal
        containerStackView.spacing = 12
        containerStackView.alignment = .center
        containerStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(posterImageView)
        containerStackView.addArrangedSubview(labelsStackView)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            posterImageView.widthAnchor.constraint(equalToConstant: 56),
            posterImageView.heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    @objc private func didTapPoster() {
        delegate?.movieTableViewCellDidTapPoster(self, image: posterImageView.image)
    }

    private static func placeholderImage() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        return UIImage(systemName: "film", withConfiguration: config)?
            .withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
    }
}
