import UIKit

protocol SideMenuViewDelegate: AnyObject {
    func didSelect(item: TabOption)
}

final class SideMenuView: UIView {
    weak var delegate: SideMenuViewDelegate?
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .SIDE
        table.separatorStyle = .none
        table.register(SideMenuCell.self, forCellReuseIdentifier: SideMenuCell.identifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 64
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var selectedIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        applyViewCode()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyViewCode()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil {
            tableView.reloadData()
        }
    }
}

extension SideMenuView: ViewCode {
    func buildViewHierarchy() {
        addSubview(tableView)
    }
    
    func setupAdditionalConfiguration() {
        tableView.delegate = self
        tableView.dataSource = self
        
        if let firstItem = TabOption.allCases.first {
            delegate?.didSelect(item: firstItem)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension SideMenuView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TabOption.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SideMenuCell.identifier,
            for: indexPath
        ) as? SideMenuCell else {
            return UITableViewCell()
        }
        
        let option = TabOption.allCases[indexPath.row]
        let isSelected = selectedIndexPath == indexPath
        cell.configure(with: option, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(item: TabOption.allCases[indexPath.row])
    }
}
