//
//  String.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 16/10/2021.
//

import Foundation

extension String {
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )
        } catch {
            return nil
        }
    }

    var prepareForAttributedString: String {
        return self.replacingOccurrences(of: " ", with: "\u{2000}")  // replacing spaces with unicode sequence to be rendered in the attributed string
            .replacingOccurrences(of: "<br>", with: "&lt;br&gt;")  // escaping actual "<br>" tags within the text
            .replacingOccurrences(of: "\n", with: "<br>")
    }

    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
