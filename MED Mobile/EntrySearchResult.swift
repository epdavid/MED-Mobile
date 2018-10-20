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
    init(headword:String, pos:String, href:String) {
        self.headword = headword
        self.pos = pos
        self.href = href
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
}
