//
//  ImageDL.swift
//  ImageURL
//
//  Created by Shubham Kamdi on 4/6/24.
//

import Foundation
import UIKit
public actor ImageDL {
    public static let utility = ImageDL()
    var request: URLRequest?
    
    /// Call this method to initiate download
    /// - parameter image: URL of the image you want to download
    ///
    func singleDownload(
        image: URL
    ) async throws -> URL? {
         return try? await createRequest(for: image)
    }
    
    func createRequest(
        for image: URL
    ) async throws -> URL? {
        if let url = await ImageRepository.shared.checkFor(image) { 
            print("IMGDL: Image returned")
            return await LRUV2.shared.get(image)?.absoluteURL
        }
        request = URLRequest(url: image)
        //request?.cachePolicy = .reloadIgnoringLocalCacheData
        guard let request else { return nil }
        let (data,response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200,
              let _ = UIImage(data: data)
        else { return nil }
        await ImageRepository.shared.writeData(rule: .init(fileName: image.absoluteString, directoryName: "Trial", imageDLURL: response.url!), data: data)
        return await LRUV2.shared.get(image)?.absoluteURL
    }
    
    func batchDownload(
        withPriority: TaskPriority,
        images: [String]
    ) async throws -> [URL?] {
        return try await withThrowingTaskGroup(of: URL?.self) { group in
            var urls: [URL?] = []
            urls.reserveCapacity(images.count)
            for image in images { group.addTask(priority: withPriority) { try await self.createRequest(for: URL(string: image)!) } }
            for try await url in group { urls.append(url) }
            return urls
        }
    }
}
