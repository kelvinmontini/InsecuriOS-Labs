import UIKit

enum SSLChallengeType {
    case urlSessionImplementation
    case alamofireImplementation
    case trustKitImplementation
}

final class SSLViewController: BaseViewController {
    
    private var currentBottomSheet: ChallengeBottomSheet?
    private var currentChallengeType: SSLChallengeType?
    
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
        presentChallengeBottomSheet(title: "URLSession Implementation", challengeType: .urlSessionImplementation) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            SSLChecker.checkSSLWithURLSessionWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapAlamofireButton() {
        presentChallengeBottomSheet(title: "Alamofire Implementation", challengeType: .alamofireImplementation) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            SSLChecker.checkSSLWithAlamofireWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapTrustKitButton() {
        presentChallengeBottomSheet(title: "TrustKit Implementation", challengeType: .trustKitImplementation) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            SSLChecker.checkSSLWithTrustKitWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    private func presentChallengeBottomSheet(
        title: String,
        challengeType: SSLChallengeType,
        numberOfIndicators: Int = 3,
        onPresented: @escaping (ChallengeBottomSheet) -> Void
    ) {
        guard currentBottomSheet == nil else { return }
        
        currentChallengeType = challengeType
        let bottomSheet = ChallengeBottomSheet(challengeTitle: title, numberOfIndicators: numberOfIndicators)
        bottomSheet.delegate = self
        bottomSheet.dataSource = self
        currentBottomSheet = bottomSheet
        
        present(bottomSheet, animated: false) {
            DispatchQueue.main.async {
                onPresented(bottomSheet)
            }
        }
    }
}

extension SSLViewController: ChallengeBottomSheetDelegate {
    func challengeBottomSheetDidDismiss() {
        currentBottomSheet = nil
        currentChallengeType = nil
    }
}

extension SSLViewController: ChallengeBottomSheetDataSource {
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, messageForState state: ChallengeState) -> String? {
        guard let challengeType = currentChallengeType else { return nil }
        
        switch state {
        case .finished(let result):
            switch result {
            case .success(let bypassSucceeded):
                if bypassSucceeded {
                    return "Congratz! SSL Pinning bypass was successful!"
                } else {
                    return "Ops, SSL Pinning protection detected you!"
                }
            case .failure:
                return "Challenge completed with an error."
            }
        default:
            return nil
        }
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
