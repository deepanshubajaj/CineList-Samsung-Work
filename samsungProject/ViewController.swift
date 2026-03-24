//
//  ViewController.swift
//  samsungProject
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import UIKit

final class ViewController: UIViewController {

    private enum Section {
        case main
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let viewModel = MoviesViewModel()

    private var dataSource: UITableViewDiffableDataSource<Section, Movie>!
    private var displayedMovies: [Movie] = []

    private let emptyStateLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let footerLoadingIndicator = UIActivityIndicatorView(style: .medium)
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Movies"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupSearch()
        setupChrome()
        setupDataSource()
        bindViewModel()
        
        Task {
            await viewModel.loadInitial()
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)

        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        footerLoadingIndicator.hidesWhenStopped = true
        let footerContainer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        footerLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addSubview(footerLoadingIndicator)
        NSLayoutConstraint.activate([
            footerLoadingIndicator.centerXAnchor.constraint(equalTo: footerContainer.centerXAnchor),
            footerLoadingIndicator.centerYAnchor.constraint(equalTo: footerContainer.centerYAnchor),
        ])
        tableView.tableFooterView = footerContainer

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    private func setupChrome() {
        navigationItem.largeTitleDisplayMode = .never

        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .preferredFont(forTextStyle: .body)
        emptyStateLabel.adjustsFontForContentSizeCategory = true
        emptyStateLabel.isHidden = true
        emptyStateLabel.text = "No movies yet."
        view.addSubview(emptyStateLabel)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Movie>(tableView: tableView) { tableView, indexPath, movie in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as? MovieTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: movie)
            cell.delegate = self
            return cell
        }
    }
    
    private func bindViewModel() {
        viewModel.didUpdateMovies = { [weak self] in
            self?.applySnapshot(animated: true)
        }

        viewModel.didUpdateState = { [weak self] state in
            self?.render(state: state)
        }
    }

    private func applySnapshot(animated: Bool) {
        displayedMovies = moviesForDisplay()

        var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        snapshot.appendSections([.main])
        snapshot.appendItems(displayedMovies, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animated)

        if displayedMovies.isEmpty, viewModel.state == .loaded {
            emptyStateLabel.text = "No results."
            emptyStateLabel.isHidden = false
        } else {
            emptyStateLabel.isHidden = true
        }

        if viewModel.isLoadingMore && !displayedMovies.isEmpty {
            footerLoadingIndicator.startAnimating()
        } else {
            footerLoadingIndicator.stopAnimating()
        }
        refreshControl.endRefreshing()
    }

    private func moviesForDisplay() -> [Movie] {
        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return viewModel.movies }
        return viewModel.movies.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private func render(state: MoviesViewModel.State) {
        switch state {
        case .idle:
            loadingIndicator.stopAnimating()
        case .loading:
            loadingIndicator.startAnimating()
            emptyStateLabel.isHidden = true
        case .loaded:
            loadingIndicator.stopAnimating()
        case .error(let message):
            loadingIndicator.stopAnimating()
            emptyStateLabel.isHidden = false
            emptyStateLabel.text = message
            presentRetryAlert(message: message)
        }
    }

    private func presentRetryAlert(message: String) {
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(title: "Couldn’t Load Movies", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            Task { await self?.viewModel.reload() }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func didPullToRefresh() {
        Task {
            await viewModel.reload()
        }
    }

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadNextPageIfNeeded(currentIndex: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = displayedMovies[indexPath.row]
        navigationController?.pushViewController(MovieDetailViewController(movie: movie), animated: true)
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        applySnapshot(animated: false)
    }
}
extension ViewController: MovieTableViewCellDelegate {
    func movieTableViewCellDidTapPoster(_ cell: MovieTableViewCell, image: UIImage?) {
        guard let image = image else { return }
        FullScreenImageViewController.present(from: self, image: image)
    }
}

