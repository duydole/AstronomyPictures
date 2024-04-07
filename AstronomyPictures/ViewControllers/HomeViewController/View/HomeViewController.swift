//
//  HomeViewController.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import UIKit

enum Section {
    case main
}

class HomeViewController: UIViewController {
    
    static let cellHeight = 200.0
    
    private var collectionView: UICollectionView!
    private var emptyView: EmptyDataView!
    private let viewModel = AstronomyListViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, AstronomyCellViewModel>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupViewModel()
        configureDataSource()
    }
    
    private func setupViews() {
        
        title = "Astronomy Pictures"
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AstronomyCollectionViewCell.self, forCellWithReuseIdentifier: AstronomyCollectionViewCell.identifier)
        collectionView.register(LoadingReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LoadingReusableView.identifier)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        self.collectionView = collectionView

        emptyView = EmptyDataView()
        emptyView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.isHidden = true
        emptyView.backgroundColor = .clear
        view.addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            emptyView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupViewModel() {
        
        viewModel.didUpdateListItems = {
            DispatchQueue.main.async { [weak self] in
                self?.updateUI(with: self?.viewModel.items ?? [])
            }
        }
        
        viewModel.showEmptyView = { show in
            DispatchQueue.main.async { [weak self] in
                self?.emptyView.isHidden = !show
            }
        }
        
        viewModel.showAlertClosure = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message: message)
            }
        }
        
        viewModel.showLoadingIndicator = { isLoading in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                updateUI(with: viewModel.items)
            }
        }
        
        viewModel.loadAstronomyEntitiesFromCache()
        Task {
            await viewModel.fetchAstronomyEntities()
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, AstronomyCellViewModel>(collectionView: collectionView) { (collectionView, indexPath, viewModel) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AstronomyCollectionViewCell.identifier, for: indexPath) as! AstronomyCollectionViewCell
            cell.configure(with: viewModel)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LoadingReusableView.identifier, for: indexPath) as? LoadingReusableView
            
            return view
        }

        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, AstronomyCellViewModel>()
        initialSnapshot.appendSections([.main])
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }

    private func showError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    private func updateUI(with viewModels: [AstronomyCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AstronomyCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Actions
    
    @objc private func retryButtonTapped() {
        viewModel.didTapRetryButton()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewModel.isLoading ? CGSize(width: collectionView.bounds.width, height: 50) : .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, HomeViewController.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cellViewModel = viewModel.items[indexPath.row]
        let detailVC = AstronomyDetailViewController(viewModel: cellViewModel)
        
        present(detailVC, animated: true, completion: nil)
    }
}

