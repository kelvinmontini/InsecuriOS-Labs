import UIKit

extension String {
    func withBoldWords(_ words: [String]) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: self)
        
        let regularFont = UIFont.preferredFont(forTextStyle: .body)
        let boldFont = UIFont.boldSystemFont(ofSize: regularFont.pointSize)
        
        attributedText.addAttribute(.font, value: regularFont, range: NSRange(location: 0, length: self.count))
        
        for word in words {
            if let range = self.range(of: word) {
                let nsRange = NSRange(range, in: self)
                attributedText.addAttribute(.font, value: boldFont, range: nsRange)
            }
        }
        
        return attributedText
    }
}
