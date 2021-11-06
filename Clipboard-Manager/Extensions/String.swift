//
//  String.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 16/10/2021.
//

import Foundation
import AppKit

extension String {
    func htmlToAttributedString(resizeToWidth: Double? = nil, resizeToHeight: Double? = nil) -> NSMutableAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            let pattern = "src=\"(.*?)\""
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            if let match = regex.firstMatch(in: self, options: [], range: NSRange(self.startIndex..., in: self)) {
                let imagePath = String(self[Range(match.range(at: 1), in: self)!])
                let image: NSImage
                if imagePath.contains("base64") {
                    let b64Pattern = "base64(.*)"
                    let b64Regex = try NSRegularExpression(pattern: b64Pattern, options: [])
                    guard let b64Match = b64Regex.firstMatch(
                        in: imagePath, options: [], range: NSRange(imagePath.startIndex..., in: imagePath)
                    ) else { return nil }
                    let b64Data = String(imagePath[Range(b64Match.range(at: 1), in: imagePath)!])
                    let b64DataDecoded = Data(base64Encoded: b64Data, options: .ignoreUnknownCharacters)
                    image = NSImage(data: b64DataDecoded!)!
                } else {
                    let url = NSURL(string: imagePath)!
                    image = NSImage(byReferencing: url.absoluteURL!)
                }
                let imageWidth = (image.size.width == 0.0 ? 30.0 : image.size.width)
                let imageHeight = (image.size.height == 0.0 ? 30.0 : image.size.height)
                let resizeRatio = (resizeToWidth ?? resizeToHeight!) / imageWidth
                let imageResized = image.resized(to: NSSize(width: resizeRatio * imageWidth, height: resizeRatio * imageHeight))
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = imageResized
                return NSMutableAttributedString(attachment: imageAttachment)
            }
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
        return self.htmlToAttributedString()?.string ?? ""
    }
}
