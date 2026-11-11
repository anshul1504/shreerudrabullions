import Foundation
import UIKit

extension String {
    var onlyDigits: String { filter(\.isNumber) }

    /// Strips +91 / 91 and keeps at most 10 digits (toIndianMobileDigits on Android).
    var indianMobileDigits: String {
        let digits = filter { $0.isASCII && $0.isNumber }
        if digits.count == 12 && digits.hasPrefix("91") {
            return String(digits.dropFirst(2))
        }
        return String(digits.prefix(10))
    }

    var isValidIndianMobile: Bool {
        count == 10 && ["6", "7", "8", "9"].contains(first)
    }

    var titleCased: String {
        split(whereSeparator: \.isWhitespace)
            .map { word in word.prefix(1).uppercased() + word.dropFirst().lowercased() }
            .joined(separator: " ")
    }

    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func ifBlank(_ fallback: @autoclosure () -> String) -> String {
        isBlank ? fallback() : self
    }

    /// Same as Kotlin's replaceFirstChar { it.uppercase() }.
    var capitalizedFirst: String {
        prefix(1).uppercased() + dropFirst()
    }
}

enum RateMovement {
    /// 1 when the rate went up, -1 when it went down, 0 when unchanged or not numeric.
    static func compare(_ current: String, _ previous: String?) -> Int {
        guard let currentValue = Double(current.replacingOccurrences(of: ",", with: "")),
              let previous,
              let previousValue = Double(previous.replacingOccurrences(of: ",", with: "")) else { return 0 }
        if currentValue > previousValue { return 1 }
        if currentValue < previousValue { return -1 }
        return 0
    }
}

enum HTMLText {
    /// Converts CKEditor HTML from the admin to readable plain text.
    static func plainText(_ html: String) -> String {
        var text = html
        let blockBreaks = [
            (#"(?i)<br\s*/?>"#, "\n"),
            (#"(?i)</(p|div|h[1-6]|tr)>"#, "\n"),
            (#"(?i)<li[^>]*>"#, "• "),
            (#"(?i)</li>"#, "\n"),
            (#"<[^>]+>"#, ""),
        ]
        for (pattern, replacement) in blockBreaks {
            text = text.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
        }
        let entities = [
            "&nbsp;": " ", "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": "\"",
            "&#39;": "'", "&apos;": "'", "&rsquo;": "’", "&lsquo;": "‘", "&ldquo;": "“",
            "&rdquo;": "”", "&ndash;": "–", "&mdash;": "—", "&bull;": "•", "&hellip;": "…", "&#8377;": "₹",
        ]
        for (entity, value) in entities {
            text = text.replacingOccurrences(of: entity, with: value)
        }
        text = text.replacingOccurrences(of: #"[ \t]+\n"#, with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: #"\n{3,}"#, with: "\n\n", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

@MainActor
enum ExternalLinks {
    static func dial(_ phone: String) {
        let number = phone.filter { $0.isNumber || $0 == "+" }
        guard !number.isEmpty, let url = URL(string: "tel:\(number)") else { return }
        UIApplication.shared.open(url)
    }

    static func whatsApp(_ phone: String) {
        let digits = phone.onlyDigits
        guard !digits.isEmpty else { return }
        let number = digits.count == 10 ? "91\(digits)" : digits
        guard let url = URL(string: "https://wa.me/\(number)") else { return }
        UIApplication.shared.open(url)
    }

    static func email(_ address: String) {
        guard !address.isBlank, let url = URL(string: "mailto:\(address)") else { return }
        UIApplication.shared.open(url)
    }
}
