import UIKit

final class BiometricsViewController: BaseViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.attributedText = "To authenticate, tap the button below and use biometrics (Touch ID / Face ID). Your task is to bypass this authentication using patching tools.".withBoldWords(["patching"])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var objcBiometricsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Objetive-C Implementation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapObjCButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var swiftBiometricsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Swift Implementation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapSwiftButton), for: .touchUpInside)
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

extension BiometricsViewController {
    @objc private func didTapObjCButton() {
        BiometricsObjcChecker.authenticateUser { success, error in
            self.showResultMessage(success: error == nil && success)
        }
    }
    
    @objc private func didTapSwiftButton() {
        BiometricsSwiftChecker.authenticateUser { success, error in
            self.showResultMessage(success: error == nil && success)
        }
    }
    
    private func showResultMessage(success: Bool) {
        let resultMessage = success ? "Congratz! The authentication was successful!" : "Ops, something went wrong!"
        HLUtils.showAlert(title: resultMessage)
    }
}

extension BiometricsViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(objcBiometricsButton)
        view.addSubview(swiftBiometricsButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            objcBiometricsButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            objcBiometricsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            objcBiometricsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            objcBiometricsButton.heightAnchor.constraint(equalToConstant: 52),
            
            swiftBiometricsButton.topAnchor.constraint(equalTo: objcBiometricsButton.bottomAnchor, constant: 16),
            swiftBiometricsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            swiftBiometricsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            swiftBiometricsButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    func setupAdditionalConfiguration() {
        title = "Touch ID / Face ID"
        view.backgroundColor = .black
    }
}
