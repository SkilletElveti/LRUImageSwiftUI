//
//  LRUImage.swift
//  ImageURL
//
//  Created by Shubham Kamdi on 4/10/24.
//

import SwiftUI
import Foundation
struct LRUImage: View {
    let url: URL
    @StateObject var driver = LRUDriver()
    @State var local: URL?
    @State var isDownloading: Bool = true

    var body: some View {
        VStack {
            if isDownloading {
                Text("Downloading_Image")
                    .onReceive(driver.$dContext, perform: { dContext in
                        if let dContext,
                           let lcl = dContext.local {
                            local = lcl
                            isDownloading = false
                        }
                    })
                    .onAppear(perform: {
                        Task {
                            do {
                                try await driver.download(url)
                            } catch let err {
                                print("Error: \(err) in setting")
                            }
                        }
                    })
            } else if let local {
                Text(local.absoluteString)
                AsyncImage(url: local) { phase in
                    if let image = phase.image {
                        image // Displays the loaded image.
                    } else if phase.error != nil {
                        Text("Downloading")
                            .onAppear {
                                DispatchQueue.main.async {
                                    self.local = nil
                                    isDownloading = true
                                }
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .frame(width: 100,height: 100)
                    }
                }
            } else {
                Text("Some Error")
            }
        }
    }
}


class LRUDriver: ObservableObject {
    struct DownloadContext {
        var isDownloading: Bool?
        var local: URL?
        var downloadedImage: UIImage?
        var hasFailed: Bool?
    }
    @Published var dContext: DownloadContext?
    func download(_ url: URL) async throws {
        await _publisher(true, nil, nil, false)
        if let localImageUrl = try await _downloadImage(url) {
            await _publisher(false, nil, localImageUrl, false)
        } else {
            await _publisher(false, nil, nil, true)
        }
    }
    
    private func _publisher(
        _ isDownloading: Bool?,
        _ downloadedImage: UIImage?,
        _ localUrl: URL? = nil,
        _ hasDownloadingFailed: Bool?
    ) async {
        await MainActor.run {
            dContext = .init(
                isDownloading: isDownloading,
                local: localUrl,
                downloadedImage: downloadedImage,
                hasFailed: hasDownloadingFailed
            )
        }
    }
    
    private func _downloadImage(
        _ url: URL
    ) async throws -> URL? {
       
        if let url = await LRUV2.shared.get(url) {
            print("Ret: Cached Retrival")
            return url
        } else if let url = try? await ImageDL.utility.singleDownload(
            image: url
        ) {
            print("Ret: Data Downloaded")
            return url
        }
       
        return nil
    }
}

class ObservableExample: ObservableObject {
    @Published var number: Int = 0
    func updateValue() {
        self.number += 1
    }
}


struct ExampleView: View {
    @StateObject var observableExample = ObservableExample()
    var body: some View {
        VStack {
            Text("\(observableExample.number)")
            Button {
                observableExample.updateValue()
            } label : {
                Text("Update")
            }
        }
    }
}

//If isDownloading {
   //PLACEHOLDER_UI
    //.onReceive(driver.$dContext, perform: {
 // update local url var
        // set isDownloading to false
   //})
//} else if let local {
    // Display Image using Async Image UI
//}

