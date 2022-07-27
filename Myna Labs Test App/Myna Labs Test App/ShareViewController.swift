//
//  ShareViewController.swift
//  Myna Labs Test App
//
//  Created by Михаил Апанасенко on 26.07.22.
//

import UIKit
import Gifu
import Photos

class ShareViewController: UIViewController {
    private let networkService = NetworkService.shared
    private let gif: Gif
    private var currentDataTask: URLSessionTask?

    private let imageView: GIFImageView = {
        let imageView = GIFImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    private let copyLinkButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy Link", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    private let saveGifButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save Gif", for: .normal)
        button.backgroundColor = .orange
        return button
    }()
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = .red
        return button
    }()

    private var containerViewTopConstraint: NSLayoutConstraint!
    private var isContainerViewHidden: Bool = true

    init(gif: Gif) {
        self.gif = gif
        super.init(nibName: nil, bundle: nil)

        activityIndicator.startAnimating()
        if let data = gif.images.original.data {
            activityIndicator.stopAnimating()
            imageView.animate(withGIFData: data)
        } else {
            let dataTask = networkService.loadImage(url: gif.images.original.url) { [weak self] result in
                switch result {
                case .success(let data):
                    self?.currentDataTask = nil
                    self?.gif.images.original.data = data
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.imageView.animate(withGIFData: data)
                        self?.imageView.setNeedsLayout()
                        self?.imageView.layoutIfNeeded()
                    }
                case .failure(let error):
                    print(error)
                }
            }
            currentDataTask = dataTask
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        let rightBarButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareButtonTapped)
        )
        navigationItem.setLeftBarButton(leftBarItem, animated: true)
        navigationItem.setRightBarButton(rightBarButton, animated: true)
        navigationController?.tabBarController?.tabBar.backgroundColor = .black

        view.backgroundColor = .black
        copyLinkButton.addTarget(self, action: #selector(copyLinkButtonTapped), for: .touchUpInside)
        saveGifButton.addTarget(self, action: #selector(saveGifButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        [
            activityIndicator,
            imageView,
            containerView
        ].forEach { view.addSubview($0) }

        containerView.addSubview(stackView)

        [
            copyLinkButton,
            saveGifButton,
            cancelButton
        ].forEach { stackView.addArrangedSubview($0) }

        containerViewTopConstraint = containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor),

            containerViewTopConstraint,
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

        ])
    }

    @objc private func closeButtonTapped() {
        currentDataTask?.cancel()
        navigationController?.popViewController(animated: true)
    }

    @objc private func shareButtonTapped() {
        if isContainerViewHidden {
            containerViewTopConstraint.constant = -containerView.frame.height
            isContainerViewHidden.toggle()
        } else {
            containerViewTopConstraint.constant = 0
            isContainerViewHidden.toggle()
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func copyLinkButtonTapped() {
        UIPasteboard.general.string = gif.bitlyUrl
        copyLinkButton.setTitle("Link copied", for: .normal)
        copyLinkButton.backgroundColor = .green
        copyLinkButton.isUserInteractionEnabled = false
    }

    @objc private func saveGifButtonTapped() {
        guard let data = gif.images.original.data else { return }

        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data, options: nil)
        })
    }
}
