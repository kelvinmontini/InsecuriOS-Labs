import UIKit

protocol MenuButtonDelegate: AnyObject {
    func didTapMenuButton()
    var isMenuOpened: Bool { get }
}

class BaseViewController: UIViewController {
    
    weak var menuDelegate: MenuButtonDelegate?
    
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: getMenuButtonImage(),
            style: .plain,
            target: self,
            action: #selector(didTapMenuButton)
        )
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuButton()
    }
    
    private func setupMenuButton() {
        navigationItem.leftBarButtonItem = menuButton
    }
    
    private func getMenuButtonImage() -> UIImage? {
        return menuDelegate?.isMenuOpened == true
        ? UIImage(systemName: "xmark")
        : UIImage(systemName: "line.3.horizontal.decrease")
    }
    
    @objc private func didTapMenuButton() {
        menuDelegate?.didTapMenuButton()
    }
    
    func updateMenuButtonIcon() {
        guard let newImage = getMenuButtonImage() else { return }
        
        let tempImageView = UIImageView()
        tempImageView.image = menuButton.image
        
        UIView.transition(
            with: tempImageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                tempImageView.image = newImage
            }
        ) { _ in
            self.menuButton.image = newImage
        }
    }
}
