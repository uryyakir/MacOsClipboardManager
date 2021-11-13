//
//  String.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 16/10/2021.
//

import Foundation
import AppKit

extension String {
    var prepareForAttributedString: String {
        return self.replacingOccurrences(of: " ", with: "\u{2000}")  // replacing spaces with unicode sequence to be rendered in the attributed string
            .replacingOccurrences(of: TextNewLine.HTML.rawValue, with: "&lt;br&gt;")  // escaping actual "<br>" tags within the text
            .replacingOccurrences(of: TextNewLine.RAW.rawValue, with: TextNewLine.HTML.rawValue)
    }

    var htmlToString: String {
        return self.htmlToAttributedString()?.string ?? ""
    }

    func htmlToAttributedString(resizeToWidth: Double? = nil, resizeToHeight: Double? = nil) -> NSMutableAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            if let imagePath = self.reMatchAndExtractMatchingSubstringFromText(reExpression: RegexPatterns.HTMLImageSrcRE.rawValue) {
                assert(resizeToWidth != nil || resizeToHeight != nil)
                let image = String.extractImageSourceFromString(stringRepresentingImage: imagePath)
                let resizedImage = Constants.appDelegate.resizeImageWithRatio(
                    image: image,
                    resizeToWidth: resizeToWidth,
                    resizeToHeight: resizeToHeight
                )
                // store resized image as an attributed string's attachment
                if let resizedImage = resizedImage {
                    return resizedImage.imageToAttributedString()
                } else {
                    // return placeholder for a failed image load
                    return NSMutableAttributedString(string: Constants.failedImageLoadPlaceholder)
                }
            } else {
                return try NSMutableAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                    documentAttributes: nil
                )
            }
        } catch {
            return nil
        }
    }

    static func extractImageSourceFromString(stringRepresentingImage: String) -> NSImage? {
        let image: NSImage?
        if stringRepresentingImage.contains(RegexPatterns.b64ImageSignature.rawValue) && !stringRepresentingImage.contains("http") {
            // assume that text is a base64 representation of an image
            let b64Data = stringRepresentingImage.reMatchAndExtractMatchingSubstringFromText(
                reExpression: RegexPatterns.b64ImageRE.rawValue
            )
            let b64DataDecoded = Data(base64Encoded: b64Data!, options: .ignoreUnknownCharacters)
            image = NSImage(data: b64DataDecoded!)
        } else {
            // assume that text is simply a URL reference to image hosted-source
            let url = NSURL(string: stringRepresentingImage)!
            image = NSImage(byReferencing: url.absoluteURL!)
        }
        if image != nil {
            if image!.isValid { return image }
        }
        // if image is nil or it's invalid - return nil
        return nil
    }

    private func reMatchAndExtractMatchingSubstringFromText(reExpression: String) -> String? {
        do {
            let regularExpression = try NSRegularExpression(pattern: reExpression, options: [])
            guard let reMatch = regularExpression.firstMatch(
                in: self, options: [], range: NSRange(self.startIndex..., in: self)
            ) else { return nil }

            return String(self[Range(reMatch.range(at: 1), in: self)!])
        } catch {
            return nil
        }
    }
}
