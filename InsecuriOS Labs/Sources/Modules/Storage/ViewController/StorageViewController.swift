import UIKit

final class StorageViewController: BaseViewController {
    
    private let dataStorage = DataStorage()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.attributedText = "In the exercises below, you will need to intercept the methods of Keychain and NSUserDefaults, which are saved and then immediately deleted.\n\nWARNING: For the dump exercise, there is an additional key saved persistently in the Keychain. Try to capture it.".withBoldWords(["Keychain", "NSUserDefaults", "WARNING:"])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var keychainSaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Intercept Keychain", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapKeychainSaveButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var userDefaultButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Intercept NSUserDefaults", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapUserDefaultButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var keychainDumpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Keychain Dump", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapKeychainDumpButton), for: .touchUpInside)
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

extension StorageViewController {
    @objc private func didTapKeychainSaveButton() {
        dataStorage.saveAndDeleteKeychain(key: "0p5{0h-no!-y0u-got-m3!}")
        showAlert()
    }
    
    @objc private func didTapUserDefaultButton() {
        dataStorage.saveAndDeleteNSUserDefaults()
        showAlert()
    }
    
    @objc private func didTapKeychainDumpButton() {
        showAlert()
    }
    
    private func showAlert() {
        HLUtils.showAlert(title: "Did you get the string?! ;)")
    }
}

extension StorageViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(keychainSaveButton)
        view.addSubview(userDefaultButton)
        view.addSubview(keychainDumpButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            keychainSaveButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            keychainSaveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            keychainSaveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            keychainSaveButton.heightAnchor.constraint(equalToConstant: 52),
            
            userDefaultButton.topAnchor.constraint(equalTo: keychainSaveButton.bottomAnchor, constant: 16),
            userDefaultButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userDefaultButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            userDefaultButton.heightAnchor.constraint(equalToConstant: 52),
            
            keychainDumpButton.topAnchor.constraint(equalTo: userDefaultButton.bottomAnchor, constant: 16),
            keychainDumpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            keychainDumpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            keychainDumpButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    func setupAdditionalConfiguration() {
        title = "Data Storage"
        view.backgroundColor = .black
    }
}
