//
//  RAWDATA.swift
//  ImageURL
//
//  Created by Shubham Kamdi on 4/6/24.
//

import Foundation
actor ImageRepository {
    static let shared = ImageRepository()
    let fileManager = FileManager.default
    var root: URL?
    private var localFiles: [String] = []
    var docs: URL?
    init() {
        fetchFileNames()
        docs = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var documentsDirectory = paths[0]
        documentsDirectory.append("/\(Constant.imageAsset)")
        do {
            try FileManager.default.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        self.root = URL(string:"file:///\(documentsDirectory)")
    }
    
    /// Method used to write data
    /// - parameter rule: ``DataRule`` instance
    /// - parameter data: Raw data instance
    ///
    func writeData(
        rule: DataRule,
        data: Data
    ) {
        let timestamp = UUID().uuidString
        let imageURL = rule.imageDLURL
        if let root {
            var r = root
            r.append(component:"\(URLNormalizer.normalize(imageURL) ?? timestamp).jpg")
            let dummy = r
            if fileManager.createFile(atPath: r.absoluteString, contents: nil) { print("file created") }
            do {
                try data.write(to: URL(fileURLWithPath: r.path()))
                Task { await LRUV2.shared.put(dummy, imageURL) }
            } catch {
                print("Error in writing: \(error)")
            }
           
        }
    }
    
    func delete(_ file: URL) -> Bool {
        let _ = checkFor(file, true)
        return false
    }
    
    func checkFor(
        _ file: URL,
        _ shouldDelete: Bool = false
    ) -> URL? {
        let normalized = URLNormalizer.normalize(file)
        if self.localFiles.isEmpty { fetchFileNames() }
        if self.localFiles.isEmpty { return nil }
        if let index = localFiles.firstIndex(where: { file in
            let comp = file.components(separatedBy: ".")
            if comp.count > 0 {
                return comp[0] == normalized
            }
            return false
        }) {
            if let root {
                var r = root.appending(path: localFiles[index])
                let dummy = root.appending(path: localFiles[index])
                if shouldDelete {
                    do {
                        try fileManager.removeItem(at: r)
                        localFiles.remove(at: index)
                        LRU.metrics.updateValues(0,1,0,0,0)
                        print("Deleting File")
                    } catch {
                        print("Error in deleting file: \(error)")
                    }
                    return nil
                }
                Task {
                    LRU.metrics.updateValues(0,0,1,0,0)
                    await LRUV2.shared.put(dummy, file)
                }
                return URL(fileURLWithPath: r.path())
            }
        }
        return nil
    }
    
    private func fetchFileNames() {
        if let root {
            var r = try? fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            var documentsDirectory = paths[0]
            documentsDirectory.append("/\(Constant.imageAsset)")
            do {
                self.localFiles = try fileManager.contentsOfDirectory(atPath: documentsDirectory)
            } catch let err {
                print("Error in fetching: \(err.localizedDescription)")
            }
        }
    }
}

struct DataRule {
    var fileName: String
    var directoryName: String
    var imageDLURL: URL
}

import Foundation
class Constant {
    static let root = "dir_root"
    static let imageAsset = "ImageStore"
    static let path = "var/mobile/Containers/Data/Application/"
}
