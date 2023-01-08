//
//  FolderTableViewCell.swift
//  Recipee
//
//  Created by Alex on 08/01/2023.
//

import UIKit
import SDWebImage

class FolderTableViewCell: UITableViewCell {
    
    static let identifier = "FolderTableViewCell"
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "folderBackground")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .appFont(of: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        contentView.addSubview(label)
        contentView.addSubview(titleImageView)
        
        NSLayoutConstraint.activate([
            titleImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            titleImageView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 0.5),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: titleImageView.bottomAnchor, multiplier: 0.5),
            titleImageView.widthAnchor.constraint(equalTo: titleImageView.heightAnchor, multiplier: 1.5),
            
            label.leadingAnchor.constraint(equalToSystemSpacingAfter: titleImageView.trailingAnchor, multiplier: 1),
            label.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 0.5),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: label.trailingAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 0.5)
        ])
    }
    
    func configure(with model: FoldersViewModel) {
        label.text = model.title
        guard model.image != "", let url = URL(string: model.image) else {
            titleImageView.image = #imageLiteral(resourceName: "folderBackground")
            return
        }
        titleImageView.sd_setImage(with: url)
    }
    
    override func prepareForReuse() {
        titleImageView.image = nil
        label.text = nil
    }
}
