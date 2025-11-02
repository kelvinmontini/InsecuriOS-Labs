import UIKit

final class FridaDetectionViewController: BaseViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.attributedText = "Below are two challenges to test some common detections of instrumentation tools.\n\nFridaGadget protection will only work for a repackaged application.".withBoldWords(["FridaGadget"])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fridaServerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Check frida-server", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapFridaServerButton), for: .touchUpInside)
        button.backgroundColor = .PURPLE
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var fridaGadgetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Check packed FridaGadget", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapFridaGadgetButton), for: .touchUpInside)
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

extension FridaDetectionViewController {
    @objc private func didTapFridaServerButton() {
        let result = FridaDetector.detect()
        self.showResultMessage(detected: result)
    }
    
    @objc private func didTapFridaGadgetButton() {
        let result = FridaDetector.detectFridaGadget()
        self.showResultMessage(detected: result)
    }
    
    private func showResultMessage(detected: Bool) {
        let resultMessage = detected ? "Ops, detection got you!" : "Congratz! Detection was bypassed!"
        HLUtils.showAlert(title: resultMessage)
    }
}

extension FridaDetectionViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(fridaServerButton)
        view.addSubview(fridaGadgetButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            fridaServerButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            fridaServerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fridaServerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fridaServerButton.heightAnchor.constraint(equalToConstant: 52),
            
            fridaGadgetButton.topAnchor.constraint(equalTo: fridaServerButton.bottomAnchor, constant: 16),
            fridaGadgetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fridaGadgetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fridaGadgetButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    func setupAdditionalConfiguration() {
        title = "Frida Detection"
        view.backgroundColor = .black
    }
}
