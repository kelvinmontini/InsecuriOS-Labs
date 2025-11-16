import UIKit

protocol ChallengeBottomSheetDelegate: AnyObject {
    func challengeBottomSheetDidDismiss()
}

protocol ChallengeBottomSheetDataSource: AnyObject {
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, messageForState state: ChallengeState) -> String?
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, statusTextForState state: ChallengeState) -> String?
}

extension ChallengeBottomSheetDataSource {
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, messageForState state: ChallengeState) -> String? {
        return nil
    }
    
    func challengeBottomSheet(_ bottomSheet: ChallengeBottomSheet, statusTextForState state: ChallengeState) -> String? {
        return nil
    }
}

final class ChallengeBottomSheet: UIViewController {
    
    weak var delegate: ChallengeBottomSheetDelegate?
    weak var dataSource: ChallengeBottomSheetDataSource?
    
    private var currentState: ChallengeState = .started {
        didSet {
            updateUI()
        }
    }
    
    let challengeTitle: String
    private let numberOfIndicators: Int
    
    private lazy var backgroundOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.PURPLE.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dragIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = challengeTitle
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "The challenge has been initiated. Follow the progress below."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressIndicators: [UIImageView] = {
        var indicators: [UIImageView] = []
        for _ in 0..<numberOfIndicators {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "circle")
            imageView.tintColor = UIColor.white.withAlphaComponent(0.3)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 32),
                imageView.heightAnchor.constraint(equalToConstant: 32)
            ])
            imageView.setContentHuggingPriority(.required, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
            indicators.append(imageView)
        }
        return indicators
    }()
    
    private lazy var progressLines: [UIView] = {
        var lines: [UIView] = []
        for _ in 0..<(numberOfIndicators - 1) {
            let line = UIView()
            line.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            line.layer.cornerRadius = 2
            line.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                line.heightAnchor.constraint(equalToConstant: 4)
            ])
            line.setContentHuggingPriority(.defaultLow, for: .horizontal)
            line.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            lines.append(line)
        }
        return lines
    }()
    
    private lazy var progressIndicatorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 0..<numberOfIndicators {
            stackView.addArrangedSubview(progressIndicators[i])
            
            if i < numberOfIndicators - 1 {
                stackView.insertArrangedSubview(progressLines[i], at: i * 2 + 1)
            }
        }
        
        return stackView
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Challenge Started"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var pulseAnimation: CABasicAnimation?
    private var rotationAnimation: CABasicAnimation?
    
    init(challengeTitle: String, numberOfIndicators: Int = 3) {
        self.challengeTitle = challengeTitle
        self.numberOfIndicators = numberOfIndicators
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyViewCode()
        setupProgressLinesConstraint()
    }
    
    private func setupProgressLinesConstraint() {
        guard progressLines.count >= 2 else { return }
        for i in 1..<progressLines.count {
            progressLines[i].widthAnchor.constraint(equalTo: progressLines[0].widthAnchor).isActive = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        animatePresentation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGlowEffect()
    }
    
    func updateState(_ state: ChallengeState) {
        currentState = state
    }
    
    private func updateUI() {
        switch currentState {
        case .started:
            updateStatus(text: "Challenge Started", color: .white, completedIndicators: 1, hasError: false)
            resultLabel.isHidden = true
            
        case .loading:
            let loadingText = dataSource?.challengeBottomSheet(self, statusTextForState: currentState) ?? "Applying Detections"
            updateStatus(text: loadingText, color: .white, completedIndicators: 1, hasError: false)
            if resultLabel.text == nil || resultLabel.text?.isEmpty == true {
                resultLabel.isHidden = true
            }
            startPulseAnimation()
            startRotationAnimation()
            
        case .finished(let result):
            stopPulseAnimation()
            stopRotationAnimation()
            
            let statusColor: UIColor
            let hasError: Bool
            let message: String
            let statusText: String
            
            switch result {
            case .success(let detected):
                if detected {
                    statusColor = .systemRed
                    hasError = true
                    statusText = "Failed"
                    message = dataSource?.challengeBottomSheet(self, messageForState: currentState) ?? "Challenge completed with error."
                } else {
                    statusColor = .systemGreen
                    hasError = false
                    statusText = "Success"
                    message = dataSource?.challengeBottomSheet(self, messageForState: currentState) ?? "Challenge completed successfully."
                }
            case .failure:
                statusColor = .systemRed
                hasError = true
                statusText = "Failed"
                message = dataSource?.challengeBottomSheet(self, messageForState: currentState) ?? "Challenge completed with an error."
            }
            
            updateStatus(text: statusText, color: statusColor, completedIndicators: numberOfIndicators, hasError: hasError)
            resultLabel.text = message
            resultLabel.textColor = statusColor
            resultLabel.isHidden = false
        }
        
        animateProgress()
    }
    
    private func updateStatus(text: String, color: UIColor, completedIndicators: Int, hasError: Bool) {
        statusLabel.text = text
        statusLabel.textColor = color
        
        let isLoading = currentState == .loading
        
        for (index, indicator) in progressIndicators.enumerated() {
            let isCompleted = index < completedIndicators
            let middleIndex = numberOfIndicators == 3 ? 1 : -1
            let isCurrentLoading = isLoading && numberOfIndicators == 3 && index == middleIndex
            
            UIView.animate(withDuration: 0.4, delay: Double(index) * 0.15, options: .curveEaseInOut) {
                if isCurrentLoading {
                    indicator.image = UIImage(systemName: "arrow.clockwise.circle.fill")
                    indicator.tintColor = .white
                } else if isCompleted {
                    if hasError && index >= 1 {
                        indicator.image = UIImage(systemName: "xmark.circle.fill")
                        indicator.tintColor = .systemRed
                    } else {
                        indicator.image = UIImage(systemName: "checkmark.circle.fill")
                        indicator.tintColor = color
                    }
                } else {
                    indicator.image = UIImage(systemName: "circle")
                    indicator.tintColor = UIColor.white.withAlphaComponent(0.3)
                }
                
                indicator.transform = isCompleted && !isCurrentLoading ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
            }
            
            if index < progressLines.count {
                let line = progressLines[index]
                let nextIndicatorCompleted = index + 1 < completedIndicators
                let nextIndicatorLoading = isLoading && index == 0
                
                UIView.animate(withDuration: 0.4, delay: Double(index) * 0.15, options: .curveEaseInOut) {
                    if nextIndicatorCompleted {
                        line.backgroundColor = color
                    } else if nextIndicatorLoading {
                        line.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                    } else {
                        line.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                    }
                }
            }
        }
        
        updateGlowEffect(color: color)
    }
    
    private func updateGlowEffect(color: UIColor? = nil) {
        statusLabel.layer.shadowRadius = 8
        statusLabel.layer.shadowOpacity = 0.6
        statusLabel.layer.shadowOffset = .zero
        statusLabel.layer.masksToBounds = false
        
        progressIndicators.forEach { indicator in
            indicator.layer.shadowColor = indicator.tintColor?.cgColor
            indicator.layer.shadowRadius = 6
            indicator.layer.shadowOpacity = 0.5
            indicator.layer.shadowOffset = .zero
            indicator.layer.masksToBounds = false
        }
    }
    
    private func startPulseAnimation() {
        stopPulseAnimation()
        
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 0.6
        pulse.toValue = 1.0
        pulse.duration = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        statusLabel.layer.add(pulse, forKey: "pulse")
        if numberOfIndicators == 3 && progressIndicators.count > 1 {
            progressIndicators[1].layer.add(pulse, forKey: "pulse")
        }
        pulseAnimation = pulse
    }
    
    private func stopPulseAnimation() {
        statusLabel.layer.removeAnimation(forKey: "pulse")
        progressIndicators.forEach { $0.layer.removeAnimation(forKey: "pulse") }
        pulseAnimation = nil
    }
    
    private func startRotationAnimation() {
        stopRotationAnimation()
        
        guard progressIndicators.count > 1 else { return }
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 1.5
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        progressIndicators[1].layer.add(rotation, forKey: "rotation")
        self.rotationAnimation = rotation
    }
    
    private func stopRotationAnimation() {
        progressIndicators.forEach { $0.layer.removeAnimation(forKey: "rotation") }
        rotationAnimation = nil
    }
    
    private func animateProgress() {
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func animatePresentation() {
        view.layoutIfNeeded()
        
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        backgroundOverlay.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
            self.backgroundOverlay.alpha = 1
        }
    }
    
    @objc private func dismissBottomSheet() {
        stopPulseAnimation()
        stopRotationAnimation()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.bounds.height)
            self.backgroundOverlay.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false) {
                self.delegate?.challengeBottomSheetDidDismiss()
            }
        }
    }
}

extension ChallengeBottomSheet: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(backgroundOverlay)
        view.addSubview(containerView)
        containerView.addSubview(dragIndicator)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(progressIndicatorStackView)
        containerView.addSubview(statusLabel)
        containerView.addSubview(resultLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 380),
            
            dragIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            dragIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dragIndicator.widthAnchor.constraint(equalToConstant: 40),
            dragIndicator.heightAnchor.constraint(equalToConstant: 5),
            
            titleLabel.topAnchor.constraint(equalTo: dragIndicator.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            progressIndicatorStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            progressIndicatorStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            progressIndicatorStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            progressIndicatorStackView.heightAnchor.constraint(equalToConstant: 32),
            
            statusLabel.topAnchor.constraint(equalTo: progressIndicatorStackView.bottomAnchor, constant: 32),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            resultLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            resultLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            resultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            resultLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    func setupAdditionalConfiguration() {
        view.backgroundColor = .clear
    }
}

