import UIKit

enum StorageChallengeType {
    case interceptKeychain
    case interceptNSUserDefaults
    case keychainDump
}

final class StorageViewController: BaseViewController {
    
    private let dataStorage = DataStorage()
    private var currentBottomSheet: ChallengeBottomSheet?
    private var currentChallengeType: StorageChallengeType?
    
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
        let encrypted = "\u{29}\u{71}\u{3b}\u{39}\u{21}\u{2a}\u{76}\u{73}\u{2c}\u{6f}\u{73}\u{2c}\u{36}\u{71}\u{30}\u{21}\u{71}\u{32}\u{36}\u{6f}\u{77}\u{37}\u{21}\u{21}\u{71}\u{77}\u{77}\u{63}\u{3f}"
        presentChallengeBottomSheet(title: "Intercept Keychain", challengeType: .interceptKeychain) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.dataStorage.saveAndDeleteKeychainWithStates(
                key: encrypted,
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapUserDefaultButton() {
        presentChallengeBottomSheet(title: "Intercept NSUserDefaults", challengeType: .interceptNSUserDefaults) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.dataStorage.saveAndDeleteNSUserDefaultsWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapKeychainDumpButton() {
        presentChallengeBottomSheet(title: "Keychain Dump", challengeType: .keychainDump, numberOfIndicators: 2) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.dataStorage.keychainDumpWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    private func presentChallengeBottomSheet(
        title: String,
        challengeType: StorageChallengeType,
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

extension StorageViewController: ChallengeBottomSheetDelegate {
    func challengeBottomSheetDidDismiss() {
        currentBottomSheet = nil
        currentChallengeType = nil
    }
}

extension StorageViewController: ChallengeBottomSheetDataSource {
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, messageForState state: ChallengeState) -> String? {
        guard let challengeType = currentChallengeType else { return nil }
        
        switch state {
        case .finished(let result):
            switch result {
            case .success:
                switch challengeType {
                case .interceptKeychain:
                    return "Keychain operation completed. Did you intercept the value?"
                case .interceptNSUserDefaults:
                    return "NSUserDefaults operation completed. Did you intercept the value?"
                case .keychainDump:
                    return "The key is already stored. Did you find it?"
                }
            case .failure:
                return "Challenge completed with an error."
            }
        default:
            return nil
        }
    }
    
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, statusTextForState state: ChallengeState) -> String? {
        guard let challengeType = currentChallengeType else { return nil }
        
        switch state {
        case .loading:
            switch challengeType {
            case .interceptKeychain:
                return "Processing Keychain"
            case .interceptNSUserDefaults:
                return "Processing NSUserDefaults"
            case .keychainDump:
                return "Dumping Keychain"
            }
        default:
            return nil
        }
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
