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
    private var data = [Gif]()
    private lazy var dataSource = makeDataSource()
    enum Section {
        case main
    }
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Gif>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Gif>

    private let collectionView: UICollectionView = {
        let layout = GifCollectionViewFlowLayout()
        layout.numberOfColumns = 2
        layout.cellPadding = 4
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GifCollectionViewCell.self, forCellWithReuseIdentifier: Constants.gifCellId)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        view.addSubview(collectionView)
        if let layout = collectionView.collectionViewLayout as? GifCollectionViewFlowLayout {
            layout.delegate = self
        }
        collectionView.delegate = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        applySnapshot(animatingDifferences: false)
    }

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, gif) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Constants.gifCellId,
                    for: indexPath)
                as? GifCollectionViewCell
                cell?.configureCell(withGif: gif)
                cell?.sizeToFit()
                return cell
            })
        return dataSource
    }

    func applySnapshot(animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func loadData() {
        let request = GetTrendingGifsRequest(limit: Constants.limit, offset: data.count)
        networkService.getTrendingGifs(request) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.data.append(contentsOf: response.data)
                    if let layout = self?.collectionView.collectionViewLayout as? GifCollectionViewFlowLayout {
                        layout.invalidateLayout()
                        layout.clearCache()
                        layout.numberOfItems = self?.data.count ?? 0
                        layout.prepare()
                    }
                    self?.applySnapshot()
                }
                print(response.data)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegate, GifCollectionViewFlowLayoutDelegate {
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
        guard let gif = dataSource.itemIdentifier(for: indexPath) else { return }

        let shareViewController = ShareViewController(gif: gif)
        shareViewController.modalPresentationStyle = .overFullScreen
        navigationController?.pushViewController(shareViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == data.count - 10 {
            loadData()
        }
    }
}
