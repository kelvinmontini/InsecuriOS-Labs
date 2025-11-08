import UIKit

final class ApplicationPatchingViewController: BaseViewController {
    
    private let applicationPatching = ApplicationPatching()
    private var currentBottomSheet: ChallengeBottomSheet?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.attributedText = "The goal of the exercises below is that by using LLDB or Frida you will be able to intercept the methods that detect debugging, and change the text from \"I love Apple!\" to \"I love Hacking!\"".withBoldWords(["LLDB", "Frida", "I love Apple!", "I love Hacking!"])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var denyDebugChallenge1Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Deny Debug (Challenge 1)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapDenyDebugChallenge1Button), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var denyDebugChallenge2Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Deny Debug (Challenge 2)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapDenyDebugChallenge2Button), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var killApplicationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kill Application", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapKillApplicationButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var verifyTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify Text", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapVerifyTextButton), for: .touchUpInside)
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

extension ApplicationPatchingViewController {
    @objc private func didTapDenyDebugChallenge1Button() {
        presentChallengeBottomSheet(title: "Deny Debug (Challenge 1)") { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.applicationPatching.denyDebuggerInternalWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapDenyDebugChallenge2Button() {
        presentChallengeBottomSheet(title: "Deny Debug (Challenge 2)") { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.applicationPatching.denyDebuggerExternalWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapKillApplicationButton() {
        presentChallengeBottomSheet(title: "Kill Application") { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.applicationPatching.killApplicationWithStates(
                onStateUpdate: { bottomSheet.updateState($0) },
                onCountdownUpdate: { bottomSheet.updateCountdown($0) }
            )
        }
    }
    
    @objc private func didTapVerifyTextButton() {
        presentChallengeBottomSheet(title: "Verify Text", numberOfIndicators: 2) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.applicationPatching.verifyTextInMemoryWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    private func presentChallengeBottomSheet(
        title: String,
        numberOfIndicators: Int = 3,
        onPresented: @escaping (ChallengeBottomSheet) -> Void
    ) {
        guard currentBottomSheet == nil else { return }
        
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

extension ApplicationPatchingViewController: ChallengeBottomSheetDelegate {
    func challengeBottomSheetDidDismiss() {
        currentBottomSheet = nil
    }
}

extension ApplicationPatchingViewController: ChallengeBottomSheetDataSource {
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, messageForState state: ChallengeState) -> String? {
        switch state {
        case .finished(let result):
            switch result {
            case .success(let detected):
                let title = bottomSheet.challengeTitle
                
                if title.contains("Deny Debug (Challenge 1)") || title.contains("Deny Debug (Challenge 2)") {
                    return detected ? "Debugger detected." : "No debugger detected."
                } else if title.contains("Verify Text") {
                    return detected ? "Text verification failed. Expected 'I love Hacking!'." : "Text verification passed. 'I love Hacking!'"
                } else if title.contains("Kill Application") {
                    return detected ? "Application terminated successfully." : "Application closure prevented successfully."
                }
                return nil
            case .failure:
                return "Challenge completed with an error."
            }
        default:
            return nil
        }
    }
    
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, shouldShowCountdown: Bool) -> Bool {
        return bottomSheet.challengeTitle.contains("Kill Application")
    }
    
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, countdownMessage seconds: Int) -> String? {
        return "Application will close automatically in \(seconds) second\(seconds == 1 ? "" : "s"). Try to prevent this from happening."
    }
}

extension ApplicationPatchingViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(denyDebugChallenge1Button)
        view.addSubview(denyDebugChallenge2Button)
        view.addSubview(verifyTextButton)
        view.addSubview(killApplicationButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            denyDebugChallenge1Button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            denyDebugChallenge1Button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            denyDebugChallenge1Button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            denyDebugChallenge1Button.heightAnchor.constraint(equalToConstant: 52),
            
            denyDebugChallenge2Button.topAnchor.constraint(equalTo: denyDebugChallenge1Button.bottomAnchor, constant: 16),
            denyDebugChallenge2Button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            denyDebugChallenge2Button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            denyDebugChallenge2Button.heightAnchor.constraint(equalToConstant: 52),
            
            verifyTextButton.topAnchor.constraint(equalTo: denyDebugChallenge2Button.bottomAnchor, constant: 16),
            verifyTextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            verifyTextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            verifyTextButton.heightAnchor.constraint(equalToConstant: 52),
            
            killApplicationButton.topAnchor.constraint(equalTo: verifyTextButton.bottomAnchor, constant: 16),
            killApplicationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            killApplicationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            killApplicationButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    func setupAdditionalConfiguration() {
        title = "Application Patching"
        view.backgroundColor = .black
    }
}
