//
//  StringExtensions.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 1/10/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import Cocoa

extension String {
    subscript (index: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy:index)
        return self[charIndex]
    }
    
//    subscript (range: Range<Int>) -> String {
////        let startIndex = self.startIndex.advancedBy(range.startIndex)
////        let endIndex = startIndex.advancedBy(range.count)
//
//        let startIndex = self.index(range., offsetBy:self.startIndex.encodedOffset)
//        let endIndex = self.index(self.startIndex, offsetBy:range)
//
//        return self[startIndex..<endIndex]
//    }
}
