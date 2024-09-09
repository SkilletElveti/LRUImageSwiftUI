//
//  URLNormalization.swift
//  ImageURL
//
//  Created by Shubham Kamdi on 4/13/24.
//

import Foundation
class URLNormalizer {
    static func normalize(_ url: URL) -> String? {
        let normal = url.absoluteString.components(separatedBy: "/")
        var normalized = ""
        for char in normal.joined() where !char.isPunctuation {
            normalized += "\(char)"
        }
        return normalized.isEmpty ? nil : normalized
    }
}
