import UIKit

final class SSLViewController: BaseViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.attributedText = "Below is a challenge to test SSL Pinning.\n\nThe SSL Pinning protection will verify the certificate from github.com.\n\nBy default, the protection will catch you, even if you don't have an intermediate certificate like Burp's, because the hash in the code may have already rotated. However, if you bypass the protection, the request will succeed.".withBoldWords(["SSL Pinning"])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var urlSessionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("URLSession Implementation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapURLSessionButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var alamofireButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Alamofire Implementation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapAlamofireButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var trustKitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("TrustKit Implementation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapTrustKitButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyViewCode()
    }
}

extension SSLViewController {
    @objc private func didTapURLSessionButton() {
        let result = SSLChecker.checkSSLWithURLSession()
        self.showResultMessage(detected: !result)
    }
    
    @objc private func didTapAlamofireButton() {
        let result = SSLChecker.checkSSLWithAlamofire()
        self.showResultMessage(detected: !result)
    }
    
    @objc private func didTapTrustKitButton() {
        let result = SSLChecker.checkSSLWithTrustKit()
        self.showResultMessage(detected: !result)
    }
    
    private func showResultMessage(detected: Bool) {
        let resultMessage = detected ? "Ops, detection got you!" : "Yay! Request was successful."
        HLUtils.showAlert(title: resultMessage)
    }
}

extension SSLViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(urlSessionButton)
        view.addSubview(alamofireButton)
        view.addSubview(trustKitButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            urlSessionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            urlSessionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            urlSessionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            urlSessionButton.heightAnchor.constraint(equalToConstant: 52),
            
            alamofireButton.topAnchor.constraint(equalTo: urlSessionButton.bottomAnchor, constant: 16),
            alamofireButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            alamofireButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            alamofireButton.heightAnchor.constraint(equalToConstant: 52),
            
            trustKitButton.topAnchor.constraint(equalTo: alamofireButton.bottomAnchor, constant: 16),
            trustKitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trustKitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trustKitButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    func setupAdditionalConfiguration() {
        title = "SSL Pinning"
        view.backgroundColor = .black
    }
}
