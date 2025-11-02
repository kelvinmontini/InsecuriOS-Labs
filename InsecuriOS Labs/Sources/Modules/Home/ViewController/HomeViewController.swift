import UIKit

final class HomeViewController: BaseViewController {
    
    private lazy var pentestImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.attributedText = "This application was developed to study debugging, instrumentation, and reverse engineering techniques. The objective is to learn different exploitation methods.".withBoldWords(["debugging", "instrumentation", "reverse engineering"])
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "The more you learn, the more you can do."
        label.layer.opacity = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyViewCode()
    }
}

extension HomeViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(pentestImageView)
        view.addSubview(titleLabel)
        view.addSubview(footerLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            pentestImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pentestImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -72),
            pentestImageView.widthAnchor.constraint(equalToConstant: 200),
            pentestImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: pentestImageView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            
            footerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            footerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            footerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    func setupAdditionalConfiguration() {
        title = "Home"
        view.backgroundColor = .black
    }
}
