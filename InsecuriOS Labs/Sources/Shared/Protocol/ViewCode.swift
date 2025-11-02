import Foundation

protocol ViewCode {
    func buildViewHierarchy()
    func setupConstraints()
    func setupAdditionalConfiguration()
    func applyViewCode()
}

extension ViewCode {
    
    func buildViewHierarchy() {}
    func setupConstraints() {}
    func setupAdditionalConfiguration() {}
    
    func applyViewCode() {
        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }
}
