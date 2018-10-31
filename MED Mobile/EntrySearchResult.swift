//
//  EntrySearchResult.swift
//  MED Mobile
//
//  Created by Evan David on 10/19/18.
//  Copyright © 2018 Evan David. All rights reserved.
//

import Foundation

class EntrySearchResult {
    private var headword:String
    private var pos:String
    private var href:String
    private var def:String
    private var counter:String
    init(headword:String, pos:String, href:String, def:String, counter:String) {
        self.headword = headword
        self.pos = pos
        self.href = href
        self.def = def
        self.counter = counter
    }
    
    func getHeadword() -> String {
        return headword
    }
    func getPos() -> String {
        return pos
    }
    func getHref() -> String {
        return href
    }
    func getDef() -> String {
        return def
    }
    func getSearchString() -> String {
        return "\(counter) \(headword), \(pos)"
    }
}
