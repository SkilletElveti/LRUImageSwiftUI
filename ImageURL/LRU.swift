//
//  LRU.swift
//  ImageURL
//
//  Created by Shubham Kamdi on 4/6/24.
//

import Foundation
import UIKit
import Combine
public actor LRUV2 {
    public static let shared = LRUV2()
    var tailRevokePublisher: CurrentValueSubject<URL?,Never> = .init(nil)
    var capacity: Int = 0
    var head: Node?
    var count = 0
    var cache: [URL:Node] = [:] {
        didSet {
            LRU.metrics.updateValues(0,0,0,0,cache.count)
        }
    }
    var tail: Node?

    public func set(_ capacity: Int) {
        self.capacity = 50
    }
    
    public func get(_ key: URL) -> URL? {
        LRU.metrics.updateValues(1,0,0,0,0)
        if let node = cache[key] {
            moveToHead(node)
            LRU.metrics.updateValues(0,0,1,0,0)
            return node.val
        } else {

            return nil
        }
    }
    
    public func put(
        _ value: URL,
        _ url: URL
    ) {
        if let node = cache[url] {
            node.val = value
            moveToHead(node)
        } else {
            let node = Node(value, url)
            node.next = head
            head?.prev = node
            head = node
            cache[url] = node
            count += 1
            if tail == nil {
                tail = head
            }
            LRU.metrics.updateValues(0,0,0,1,0)
        }
        if count > capacity {
            let delUrl = tail!.url
            Task { await ImageRepository.shared.delete(tail!.url) }
            cache.removeValue(forKey: tail!.url)
            tail = tail?.prev
            tail?.next = nil
            count -= 1
            DispatchQueue.main.async {
                self.tailRevokePublisher.send(delUrl)
            }
        }
    }

    func moveToHead(_ node: Node) {
        if node === head {
            return
        } else {
            node.prev?.next = node.next
            node.next?.prev = node.prev
            node.next = head
            head?.prev = node
            head = node
            
        }
        if node === tail && cache.count == 1 {
            let delUrl = tail!.url
            Task { await ImageRepository.shared.delete(tail!.url) }
            cache.removeValue(forKey: tail!.url)
            tail = tail?.prev
            tail?.next = nil
            DispatchQueue.main.async {
                self.tailRevokePublisher.send(delUrl)
            }
        }
    }

    public func getData() -> [URL] {
        var dataArr: [URL] = []
        if let head {
            var head: Node? = head
            while head != nil {
                dataArr.append(head!.val)
                head = head?.next
            }
        }
        return dataArr
    }
}


class Node {
    var val: URL
    var url: URL
    var next: Node?
    var prev: Node?

    init(_ val: URL, _ url: URL) {
        self.val = val
        self.url = url
    }
}
