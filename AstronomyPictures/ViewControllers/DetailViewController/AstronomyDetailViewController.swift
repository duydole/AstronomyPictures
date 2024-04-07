//
//  AstronomyDetailViewController.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation
import UIKit

class AstronomyDetailViewController: UIViewController {
    
    public let viewModel: AstronomyCellViewModel
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()
    

    init(viewModel: AstronomyCellViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupViews()
        setupViewModel()
    }
    
    func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped)))
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        let image = ImageMemoryCacheManager.shared.image(forKey: viewModel.urlKey)
        imageView.image = image

        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        imageView.addSubview(titleLabel)
        titleLabel.text = viewModel.title
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified
        descriptionLabel.textColor = UIColor.white
        imageView.addSubview(descriptionLabel)
        descriptionLabel.text = viewModel.explanation
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: imageView.bottomAnchor, constant: -24)
        ])
        
        view.backgroundColor = .black

    }
    
    func setupViewModel() {
        viewModel.didUpdateImage = { urlKey in
            DispatchQueue.main.async { [weak self] in 
                guard let self = self, let image = viewModel.image else { return }
                imageView.animateSetImage(image)
            }
        }
    }
    
    @objc private func imageViewTapped() {
        dismiss(animated: true)
    }
}
