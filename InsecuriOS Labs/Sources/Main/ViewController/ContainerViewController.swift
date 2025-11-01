import UIKit

final class ContainerViewController: UIViewController {
    
    enum MenuState {
        case closed
        case opened
    }
    
    private var menuState: MenuState = .closed
    private var navController: UINavigationController?
    
    private lazy var homeViewController = HomeViewController()
    private lazy var biometricViewController = BiometricsViewController()
    private lazy var instrumentationViewController = InstrumentationViewController()
    private lazy var storageViewController = StorageViewController()
    private lazy var jailbreakDetectionViewController = JailbreakDetectionViewController()
    private lazy var sslViewController = SSLViewController()
    
    private lazy var sideMenuView: SideMenuView = {
        let menu = SideMenuView()
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.frame.origin.x = -menu.frame.width
        return menu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyViewCode()
        setupSwipeGestures()
    }
    
    private func setupSwipeGestures() {
        setupLeftSwipeGesture()
        setupRightSwipeGesture()
    }
    
    private func setupLeftSwipeGesture() {
        let swipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.edges = .left
        view.addGestureRecognizer(swipeGesture)
    }
    
    private func setupRightSwipeGesture() {
        let swipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.edges = .right
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func handleSwipeGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            toggleMenu()
        }
    }
}

extension ContainerViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(sideMenuView)
        
        let navController = UINavigationController(rootViewController: homeViewController)
        addChild(navController)
        view.addSubview(navController.view)
        navController.didMove(toParent: self)
        self.navController = navController
    }
    
    func setupAdditionalConfiguration() {
        view.backgroundColor = .SIDE

        homeViewController.menuDelegate = self
        biometricViewController.menuDelegate = self
        instrumentationViewController.menuDelegate = self
        storageViewController.menuDelegate = self
        jailbreakDetectionViewController.menuDelegate = self
        sslViewController.menuDelegate = self
        sideMenuView.delegate = self
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            sideMenuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sideMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideMenuView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
        ])
    }
}

extension ContainerViewController: MenuButtonDelegate {
    func didTapMenuButton() {
        toggleMenu()
    }
    
    var isMenuOpened: Bool {
        menuState == .opened
    }
    
    func toggleMenu() {
        switch menuState {
        case .closed:
            menuState = .opened
            openMenuAnimation()
            updateMenuButtonIcon()
            disableCurrentViewInteraction()
        case .opened:
            menuState = .closed
            closeMenuAnimation()
            updateMenuButtonIcon()
            enableCurrentViewInteraction()
        }
    }
    
    private func updateMenuButtonIcon() {
        if let currentViewController = self.navController?.topViewController as? BaseViewController {
            currentViewController.updateMenuButtonIcon()
        }
    }
    
    private func openMenuAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 500
            
            self.navController?.view.frame.origin.x = self.view.frame.width / 1.6
            self.navController?.view.layer.cornerRadius = 24
            self.navController?.view.layer.transform = CATransform3DRotate(transform, -16 * (.pi / 180), 0, 1, 0)
            self.sideMenuView.frame.origin.x = 0
        }
    }
    
    private func closeMenuAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.navController?.view.layer.cornerRadius = 0
            self.navController?.view.layer.transform = CATransform3DIdentity
            self.navController?.view.frame.origin.x = 0
            self.sideMenuView.frame.origin.x = -self.sideMenuView.frame.width
        }
    }
}

extension ContainerViewController: SideMenuViewDelegate {
    func didSelect(item: TabOption) {
        switch item {
        case .home:
            show(viewController: homeViewController)
        case .instrumentation:
            show(viewController: instrumentationViewController)
        case .storage:
            show(viewController: storageViewController)
               case .jailbreakDetection:
            show(viewController: jailbreakDetectionViewController)
        case .sslPinning:
            show(viewController: sslViewController)
        case .biometrics:
            show(viewController: biometricViewController)
        }
    }
    
    private func show(viewController: UIViewController) {
        self.navController?.setViewControllers([viewController], animated: false)
        disableCurrentViewInteraction()
    }
}

extension ContainerViewController {
    private func disableCurrentViewInteraction() {
        if let currentViewController = self.navController?.topViewController {
            currentViewController.view.isUserInteractionEnabled = false
        }
    }
    
    private func enableCurrentViewInteraction() {
        if let currentViewController = self.navController?.topViewController {
            currentViewController.view.isUserInteractionEnabled = true
        }
    }
}
