//
//  LRUMetrics.swift
//  ImageURL
//
//  Created by Shubham Kamdi on 4/17/24.
//

import Combine
import Foundation
class LRU {
    static let metrics = LRU()
    private var requestLRU: Int = 0
    private var revokedFromLRU: Int = 0
    private var hitLRU: Int = 0
    private var addedToLRU: Int = 0
    private var currentLRUCont = 0
    private var missedLRU = 0
    struct Context {
        var requestLRU: Int
        var revokedFromLRU: Int
        var hitLRU: Int
        var addedToLRU: Int
        var currentLRUCont: Int
        var missed: Int
    }
    private(set) var context: CurrentValueSubject<Context?,Never> = .init(nil)
    func updateValues(
        _ requestLRU: Int = 0,
        _ revokedFromLRU: Int = 0,
        _ hitLRU: Int = 0,
        _ addedToLRU: Int = 0,
        _ currentLRUCont: Int = 0,
        _ missed: Int = 0
    ) {
        self.hitLRU += hitLRU
        self.revokedFromLRU += revokedFromLRU
        self.requestLRU += requestLRU
        self.addedToLRU += addedToLRU
        self.currentLRUCont = currentLRUCont
        self.missedLRU += missed
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.context.send(
                Context(
                    requestLRU: self.hitLRU,
                    revokedFromLRU: self.revokedFromLRU,
                    hitLRU: self.hitLRU,
                    addedToLRU: self.addedToLRU,
                    currentLRUCont: self.addedToLRU,
                    missed: self.missedLRU
                )
            )
        })
    }
    
    
}
