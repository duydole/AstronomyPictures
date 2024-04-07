//
//  AstronomyCollectionViewCell.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import UIKit

class AstronomyCollectionViewCell: UICollectionViewCell {
    
    static let contentInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    static let cornerRadius = 12.0
    static let spacing = 12.0
    static let titleFontSize = 18.0
    static let subtitleFontSize = 14.0
    static let identifier = "AstronomyCollectionViewCell"
    
    public let imageView = UIImageView()
    private var titleLabel: UILabel!
    private var dateLabel: UILabel!
    private var viewModel: AstronomyCellViewModel?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
    }

    func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = AstronomyCollectionViewCell.cornerRadius
        imageView.backgroundColor = .systemGray
        contentView.addSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: AstronomyCollectionViewCell.titleFontSize, weight: .bold)
        titleLabel.textColor = .white
        imageView.addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .white
        dateLabel.font = UIFont.systemFont(ofSize: AstronomyCollectionViewCell.subtitleFontSize, weight: .semibold)
        imageView.addSubview(dateLabel)
        self.dateLabel = dateLabel
        
        let insets = AstronomyCollectionViewCell.contentInsets
        let spacing = AstronomyCollectionViewCell.spacing
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: spacing),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: spacing),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -spacing),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing/2),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        ])
    }
        
    // MARK: - Configure
    
    func configure(with viewModel: AstronomyCellViewModel) {
        self.viewModel = viewModel
        
        configureImage()
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.date
    }
    
    // MARK: - Private
    
    private func configureImage() {
        guard let viewModel = viewModel else { return }

        viewModel.didUpdateImage = { [weak self] urlKey in
            let updateImageBlock = {
                guard let self = self else { return }
                if urlKey == viewModel.urlKey, let image = viewModel.image {
                    self.imageView.animateSetImage(image)
                }
            }
            
            if Thread.isMainThread {
                updateImageBlock()
            } else {
                DispatchQueue.main.async(execute: updateImageBlock)
            }
        }
        
        viewModel.fetchImage()
    }
}
