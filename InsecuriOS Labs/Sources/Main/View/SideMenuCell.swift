import UIKit

final class SideMenuCell: UITableViewCell {
    static let identifier = "SideMenuCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyViewCode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with option: TabOption, isSelected: Bool = false) {
        titleLabel.text = option.rawValue
        iconImageView.image = UIImage(systemName: option.icon)?.withRenderingMode(.alwaysTemplate)
        
        if isSelected {
            backgroundColor = .PURPLE
            imageView?.tintColor = .white
        } else {
            backgroundColor = .SIDE
            containerView.backgroundColor = .clear
            iconImageView.tintColor = .white
        }
    }
}

extension SideMenuCell: ViewCode {
    func buildViewHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
    }
    
    func setupAdditionalConfiguration() {
        backgroundColor = .SIDE
        layer.cornerRadius = 8
        selectionStyle = .none
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 48),
            containerView.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
