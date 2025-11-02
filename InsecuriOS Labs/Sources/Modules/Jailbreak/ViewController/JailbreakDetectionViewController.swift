import UIKit
import IOSSecuritySuite

final class JailbreakDetectionViewController: BaseViewController {
    
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
        let result = JailbreakObjcChecker.isJailbroken()
        showResultMessage(detected: result)
    }
    
    @objc private func didTapSwiftDetectionButton() {
        let result = JailbreakSwiftChecker.isJailbroken()
        showResultMessage(detected: result)
    }
    
    @objc private func didTapExternalDetectionButton() {
        let result = IOSSecuritySuite.amIJailbroken()
        showResultMessage(detected: result)
    }
    
    @objc private func didTapDylibDetectionButton() {
        if let isJailbrokenFunc = loadJailbreakFunction() {
            let isJailbroken = unsafeBitCast(isJailbrokenFunc, to: (@convention(c) () -> Int).self)()
            let result = isJailbroken == 1
            showResultMessage(detected: result)
        }
    }
    
    private func showResultMessage(detected: Bool) {
        let resultMessage = detected ? "Ops, detection got you!" : "Congratz! Detection was bypassed!"
        HLUtils.showAlert(title: resultMessage)
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
