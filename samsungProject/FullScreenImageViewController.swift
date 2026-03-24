//
//  FullScreenImageViewController.swift
//  samsungProject
//
//  Created by Deepanshu Bajaj on 09/12/25.
//

import UIKit

public final class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Private Properties
    
    private let image: UIImage
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let closeButton = UIButton(type: .system)
    
    private var closeButtonVisible = true
    
    // MARK: - Initializer
    
    public init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupScrollView()
        setupImageView()
        setupCloseButton()
        setupGestureRecognizers()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateImageViewFrameAndCenter()
    }
    
    // MARK: - Setup
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        
        // Initial frame will be set in viewDidLayoutSubviews
    }
    
    private func setupCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let symbol = UIImage(systemName: "xmark") {
            closeButton.setImage(symbol, for: .normal)
        } else {
            closeButton.setTitle("Close", for: .normal)
        }
        
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor(white: 0, alpha: 0.4)
        closeButton.accessibilityLabel = "Close"
        closeButton.layer.cornerRadius = 18
        closeButton.clipsToBounds = true
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        // Large hit area: 44x44 minimum size, but actual visible is smaller with padding
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 36),
            closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
        ])
        
        // Increase tappable area without increasing visual size
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }
    
    private func setupGestureRecognizers() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(singleTap)
        
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        recognizer.numberOfTapsRequired = 2
        recognizer.delaysTouchesBegan = true
        return recognizer
    }()
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        toggleCloseButtonVisibility()
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let pointInView = gesture.location(in: imageView)
        
        let currentZoomScale = scrollView.zoomScale
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        if currentZoomScale != minZoomScale {
            scrollView.setZoomScale(minZoomScale, animated: true)
        } else {
            let zoomRect = zoomRectForScale(scale: maxZoomScale, center: pointInView)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    private func toggleCloseButtonVisibility() {
        closeButtonVisible.toggle()
        UIView.animate(withDuration: 0.25) {
            self.closeButton.alpha = self.closeButtonVisible ? 1 : 0
        }
    }
    
    // MARK: - Zooming Helpers
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        let scrollViewSize = scrollView.bounds.size
        
        let width = scrollViewSize.width / scale
        let height = scrollViewSize.height / scale
        let originX = center.x - (width / 2.0)
        let originY = center.y - (height / 2.0)
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
    
    // MARK: - Layout Helpers
    
    private func updateImageViewFrameAndCenter() {
        let scrollSize = scrollView.bounds.size
        let imageSize = image.size

        guard imageSize.width > 0, imageSize.height > 0 else { return }

        let widthScale = scrollSize.width / imageSize.width
        let heightScale = scrollSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = minScale

        let imageWidth = imageSize.width * minScale
        let imageHeight = imageSize.height * minScale

        imageView.frame = CGRect(
            x: 0,
            y: 0,
            width: imageWidth,
            height: imageHeight
        )

        scrollView.contentSize = imageView.frame.size

        centerImageView()
    }
    
    private func centerImageView() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let horizontalInset = max(0, (scrollViewSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - contentSize.height) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalInset,
                                               left: horizontalInset,
                                               bottom: verticalInset,
                                               right: horizontalInset)
    }
    
    // MARK: - Public Static Helper
    
    public static func present(from presenter: UIViewController, image: UIImage, animated: Bool = true) {
        let vc = FullScreenImageViewController(image: image)
        presenter.present(vc, animated: animated, completion: nil)
    }
}
