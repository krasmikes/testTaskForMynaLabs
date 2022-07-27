//
//  MainViewController.swift
//  Myna Labs Test App
//
//  Created by Михаил Апанасенко on 26.07.22.
//

import UIKit

enum Constants {
    static let spacing: CGFloat = 10
    static let gifCellId = "gifCellId"
    static let limit = 30
}

class MainViewController: UIViewController {
    private let networkService = NetworkService.shared

    private let collectionView: UICollectionView = {
        let layout = GifCollectionViewFlowLayout()
        layout.numberOfColumns = 2
        layout.cellPadding = 4
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GifCollectionViewCell.self, forCellWithReuseIdentifier: Constants.gifCellId)
        return collectionView
    }()

    private var data = [Gif]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        view.addSubview(collectionView)
        if let layout = collectionView.collectionViewLayout as? GifCollectionViewFlowLayout {
            layout.delegate = self
        }
        collectionView.delegate = self
        collectionView.dataSource = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func loadData() {
        let request = GetTrendingGifsRequest(limit: Constants.limit, offset: data.count)
        networkService.getTrendingGifs(request) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.data.append(contentsOf: response.data)
                    self?.collectionView.reloadData()
                }
                print(response.data)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, GifCollectionViewFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.gifCellId, for: indexPath) as! GifCollectionViewCell
        cell.configureCell(withGif: data[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, photoSizeAtIndexPath indexPath:IndexPath) -> CGSize {
        if let height = Int(data[indexPath.row].images.small.height),
           let width = Int(data[indexPath.row].images.small.width) {
            return CGSize(width: width, height: height)
        } else {
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let shareViewController = ShareViewController(gif: data[indexPath.row])
        shareViewController.modalPresentationStyle = .overFullScreen
        navigationController?.pushViewController(shareViewController, animated: true)
    }
}
