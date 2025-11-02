import UIKit

final class ApplicationPatchingViewController: BaseViewController {
    
    private let applicationPatching = ApplicationPatching()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.attributedText = "The goal of the exercises below is that by using LLDB, you will be able to intercept the methods that capture debugging and terminate the application, and change the text from \"I love Google!\" to \"I love Apple!\"".withBoldWords(["LLBD", "I love Apple!", "I love Hacking!"])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var denyDebuggerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Deny Debugger", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapDenyDebuggerButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var denyDebuggerExternalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Deny Debugger (External)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapDenyDebuggerExternalButton), for: .touchUpInside)
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
    
    private lazy var showMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Message", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapShowMessageButton), for: .touchUpInside)
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
    @objc private func didTapDenyDebuggerButton() {
        applicationPatching.denyDebuggerInternal()
        showResultMessage()
    }
    
    @objc private func didTapDenyDebuggerExternalButton() {
        applicationPatching.denyDebuggerExternal()
        showResultMessage()
    }
    
    @objc private func didTapKillApplicationButton() {
        applicationPatching.killApplication()
        showResultMessage()
    }
    
    @objc private func didTapShowMessageButton() {
        applicationPatching.showAlert()
    }
    
    private func showResultMessage() {
        HLUtils.showAlert(title: "Are you still here!? Maybe it worked, or you just don’t have a debugger attached.")
    }
}

extension ApplicationPatchingViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(denyDebuggerButton)
        view.addSubview(denyDebuggerExternalButton)
        view.addSubview(killApplicationButton)
        view.addSubview(showMessageButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            denyDebuggerButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            denyDebuggerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            denyDebuggerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            denyDebuggerButton.heightAnchor.constraint(equalToConstant: 52),
            
            denyDebuggerExternalButton.topAnchor.constraint(equalTo: denyDebuggerButton.bottomAnchor, constant: 16),
            denyDebuggerExternalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            denyDebuggerExternalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            denyDebuggerExternalButton.heightAnchor.constraint(equalToConstant: 52),
            
            killApplicationButton.topAnchor.constraint(equalTo: denyDebuggerExternalButton.bottomAnchor, constant: 16),
            killApplicationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            killApplicationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            killApplicationButton.heightAnchor.constraint(equalToConstant: 52),
            
            showMessageButton.topAnchor.constraint(equalTo: killApplicationButton.bottomAnchor, constant: 16),
            showMessageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            showMessageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            showMessageButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    func setupAdditionalConfiguration() {
        title = "Application Patching"
        view.backgroundColor = .black
    }
}
