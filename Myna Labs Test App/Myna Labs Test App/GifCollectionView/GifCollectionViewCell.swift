//
//  GifCollectionViewCell.swift
//  Myna Labs Test App
//
//  Created by Михаил Апанасенко on 26.07.22.
//

import UIKit
import Gifu

class GifCollectionViewCell: UICollectionViewCell {
    private let networkService = NetworkService.shared
    private var gif: Gif?
    private var currentDataTask: URLSessionTask?
    private let colorSet: [UIColor] = [.blue, .green, .yellow, .cyan, .brown, .magenta, .orange]

    private let imageView: GIFImageView = {
        let imageView = GIFImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        addSubview(imageView)
        imageView.backgroundColor = colorSet.randomElement()
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(withGif gif: Gif) {
        self.gif = gif

        if let data = gif.images.small.data {
            imageView.animate(withGIFData: data)
        } else {
            let dataTask = networkService.loadImage(url: gif.images.small.url) { [weak self] result in
                switch result {
                case .success(let data):
                    self?.currentDataTask = nil
                    self?.gif?.images.small.data = data
                    DispatchQueue.main.async {
                        self?.imageView.animate(withGIFData: data)
                    }
                case .failure(let error):
                    print(error)
                }
            }
            currentDataTask = dataTask
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentDataTask?.cancel()
        imageView.image = nil
        imageView.prepareForReuse()
        imageView.backgroundColor = colorSet.randomElement()
    }
}
