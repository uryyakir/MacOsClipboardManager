//
//  NSMutableAttributedString.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 18/11/2021.
//

import Foundation

extension NSMutableAttributedString {
    // get a smaller substring for the cell preview to make the table preview more efficient
    var attributedStringShortened: NSMutableAttributedString {
        let attributedStringShortened = NSMutableAttributedString(
            attributedString: self.attributedSubstring(
                from: NSRange(
                    location: 0,
                    length: min(self.length, TableViewConstants.cellTextFieldMaxLength)
                )
            )
        )
        if self.length > TableViewConstants.cellTextFieldMaxLength { attributedStringShortened.append(NSAttributedString(string: "...")) }
        return attributedStringShortened
    }
}
