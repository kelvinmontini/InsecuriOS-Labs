import UIKit
import IOSSecuritySuite

enum JailbreakChallengeType {
    case objcImplementation
    case swiftImplementation
    case externalLibraryImplementation
    case dylibImplementation
}

final class JailbreakDetectionViewController: BaseViewController {
    
    private var currentBottomSheet: ChallengeBottomSheet?
    private var currentChallengeType: JailbreakChallengeType?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.attributedText = "Here are some exercises to practice problem-solving in Jailbreak environments. Try solving them first using LLDB and then Frida.".withBoldWords(["LLBD", "Frida"])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var objcDetectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Objective-C Implementation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapObjCDetectionButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var swiftDetectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Swift Implementation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapSwiftDetectionButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var externalDetectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("External Library Implementation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapExternalDetectionButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var dylibDetectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("dylib Implementation", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapDylibDetectionButton), for: .touchUpInside)
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

extension JailbreakDetectionViewController {
    @objc private func didTapObjCDetectionButton() {
        presentChallengeBottomSheet(title: "Objective-C Implementation", challengeType: .objcImplementation) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.performObjCDetectionWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapSwiftDetectionButton() {
        presentChallengeBottomSheet(title: "Swift Implementation", challengeType: .swiftImplementation) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            JailbreakSwiftChecker.isJailbrokenWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapExternalDetectionButton() {
        presentChallengeBottomSheet(title: "External Library Implementation", challengeType: .externalLibraryImplementation) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.performExternalDetectionWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    @objc private func didTapDylibDetectionButton() {
        presentChallengeBottomSheet(title: "dylib Implementation", challengeType: .dylibImplementation) { [weak self] bottomSheet in
            guard let self = self else { return }
            
            self.performDylibDetectionWithStates(
                onStateUpdate: { bottomSheet.updateState($0) }
            )
        }
    }
    
    private func presentChallengeBottomSheet(
        title: String,
        challengeType: JailbreakChallengeType,
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
    
    private func performObjCDetectionWithStates(
        onStateUpdate: @escaping (ChallengeState) -> Void
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onStateUpdate(.loading)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            Thread.sleep(forTimeInterval: 1.5)
            
            JailbreakObjcChecker.isJailbroken { detected in
                let result: Result<Bool, Error> = .success(!detected)
                
                DispatchQueue.main.async {
                    onStateUpdate(.finished(result))
                }
            }
        }
    }
    
    private func performExternalDetectionWithStates(
        onStateUpdate: @escaping (ChallengeState) -> Void
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onStateUpdate(.loading)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            Thread.sleep(forTimeInterval: 1.5)
            
            let detected = IOSSecuritySuite.amIJailbroken()
            let result: Result<Bool, Error> = .success(!detected)
            
            DispatchQueue.main.async {
                onStateUpdate(.finished(result))
            }
        }
    }
    
    private func performDylibDetectionWithStates(
        onStateUpdate: @escaping (ChallengeState) -> Void
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onStateUpdate(.loading)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            Thread.sleep(forTimeInterval: 1.5)
            
            var detected = false
            if let isJailbrokenFunc = self.loadJailbreakFunction() {
                let isJailbroken = unsafeBitCast(isJailbrokenFunc, to: (@convention(c) () -> Int).self)()
                detected = isJailbroken == 1
            }
            
            let result: Result<Bool, Error> = .success(!detected)
            
            DispatchQueue.main.async {
                onStateUpdate(.finished(result))
            }
        }
    }
    
    private func loadJailbreakFunction() -> UnsafeMutableRawPointer? {
        guard let libPath = Bundle.main.path(forResource: "Frameworks/libJailbreakChecker", ofType: "dylib") else {
            return nil
        }
        
        guard let dylib = dlopen(libPath, RTLD_LAZY) else {
            return nil
        }
        
        guard let isJailbrokenFunc = dlsym(dylib, "is_jailbroken") else {
            dlclose(dylib)
            return nil
        }
        
        return isJailbrokenFunc
    }
}

extension JailbreakDetectionViewController: ChallengeBottomSheetDelegate {
    func challengeBottomSheetDidDismiss() {
        currentBottomSheet = nil
        currentChallengeType = nil
    }
}

extension JailbreakDetectionViewController: ChallengeBottomSheetDataSource {
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, messageForState state: ChallengeState) -> String? {
        guard currentChallengeType != nil else { return nil }
        
        switch state {
        case .finished(let result):
            switch result {
            case .success(let success):
                return success ? "Congratz! Detection was bypassed!" : "Ops, detection got you!"
            case .failure:
                return "Challenge completed with an error."
            }
        default:
            return nil
        }
    }
}

extension JailbreakDetectionViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(objcDetectionButton)
        view.addSubview(swiftDetectionButton)
        view.addSubview(externalDetectionButton)
        view.addSubview(dylibDetectionButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            objcDetectionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            objcDetectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            objcDetectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            objcDetectionButton.heightAnchor.constraint(equalToConstant: 52),
            
            swiftDetectionButton.topAnchor.constraint(equalTo: objcDetectionButton.bottomAnchor, constant: 16),
            swiftDetectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            swiftDetectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            swiftDetectionButton.heightAnchor.constraint(equalToConstant: 52),
            
            externalDetectionButton.topAnchor.constraint(equalTo: swiftDetectionButton.bottomAnchor, constant: 16),
            externalDetectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            externalDetectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            externalDetectionButton.heightAnchor.constraint(equalToConstant: 52),
            
            dylibDetectionButton.topAnchor.constraint(equalTo: externalDetectionButton.bottomAnchor, constant: 16),
            dylibDetectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dylibDetectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dylibDetectionButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    func setupAdditionalConfiguration() {
        title = "Jailbreak Detection"
        view.backgroundColor = .black
    }
}
