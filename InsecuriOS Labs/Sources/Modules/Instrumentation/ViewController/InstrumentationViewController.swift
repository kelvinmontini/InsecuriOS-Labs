import UIKit

enum InstrumentationChallengeType {
    case denyDebugChallenge1
    case denyDebugChallenge2
    case memoryPatching
    case fridaServerDetection
}

final class InstrumentationViewController: BaseViewController {
    
    private let instrumentation = Instrumentation()
    private var currentBottomSheet: ChallengeBottomSheet?
    private var currentChallengeType: InstrumentationChallengeType?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.attributedText = "Use LLDB or Frida to complete the challenges below. The first two challenges require bypassing anti-debugging mechanisms by intercepting debugger detection methods. The third challenge requires modifying a string in memory, changing \"There is no spoon\" to \"The spoon is real!\"".withBoldWords(["LLDB", "Frida", "There is no spoon", "The spoon is real!"])
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
    
    private lazy var verifyTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Memory Patching", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapVerifyTextButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var fridaServerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Frida Server Detection", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapFridaServerButton), for: .touchUpInside)
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

extension InstrumentationViewController {
    @objc private func didTapDenyDebugChallenge1Button() {
        presentChallengeBottomSheet(title: "Deny Debug (Challenge 1)", challengeType: .denyDebugChallenge1) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.instrumentation.denyDebuggerInternalWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapDenyDebugChallenge2Button() {
        presentChallengeBottomSheet(title: "Deny Debug (Challenge 2)", challengeType: .denyDebugChallenge2) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.instrumentation.denyDebuggerExternalWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapVerifyTextButton() {
        instrumentation.getTextInMemory()
    }
    
    @objc private func didTapFridaServerButton() {
        presentChallengeBottomSheet(title: "Frida Server Detection", challengeType: .fridaServerDetection) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.instrumentation.detectFridaServerWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    private func presentChallengeBottomSheet(
        title: String,
        challengeType: InstrumentationChallengeType,
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

extension InstrumentationViewController: ChallengeBottomSheetDelegate {
    func challengeBottomSheetDidDismiss() {
        currentBottomSheet = nil
        currentChallengeType = nil
    }
}

extension InstrumentationViewController: ChallengeBottomSheetDataSource {
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, messageForState state: ChallengeState) -> String? {
        guard let challengeType = currentChallengeType else { return nil }
        
        switch state {
        case .finished(let result):
            switch result {
            case .success(let detected):
                switch challengeType {
                case .denyDebugChallenge1, .denyDebugChallenge2:
                    return detected ? "Debugger detected." : "No debugger detected."
                case .memoryPatching:
                    return detected ? "Text verification failed. Expected 'The spoon is real!'." : "Text verification passed. 'The spoon is real!'"
                case .fridaServerDetection:
                    return detected ? "Frida server detected." : "No Frida server detected."
                }
            case .failure:
                return "Challenge completed with an error."
            }
        default:
            return nil
        }
    }
    
}

extension InstrumentationViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(denyDebugChallenge1Button)
        view.addSubview(denyDebugChallenge2Button)
        view.addSubview(verifyTextButton)
        view.addSubview(fridaServerButton)
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
            
            fridaServerButton.topAnchor.constraint(equalTo: verifyTextButton.bottomAnchor, constant: 16),
            fridaServerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fridaServerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fridaServerButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    func setupAdditionalConfiguration() {
        title = "Instrumentation"
        view.backgroundColor = .black
    }
}
