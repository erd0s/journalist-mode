//
//  TextView+Debug.swift
//  the-system
//
//  Created by Dirk on 14/06/2021.
//

import Foundation

extension TextView {
    func debug() {
        print("======================== STARTING DEBUG ========================")
        print("Length: " + String(textStorage!.length))
        var currentRange = NSRange()
        var currentPosition = 0
        while true {
            let attrs = textStorage!.attributes(at: currentPosition, longestEffectiveRange: &currentRange, in: NSMakeRange(currentPosition, textStorage!.length - currentPosition))
            let attrNames = attrs.map { (arg0) -> String in
                let (key, value) = arg0
                return String(describing: key.rawValue)
            }.joined(separator: ", ")
            let string1 = attrNames + " for "
            let string2 = String(currentRange.location) + " -> "
            let string3 = String(currentRange.location + currentRange.length)
            print(string1 + string2 + string3)
            if currentRange.location + currentRange.length >= textStorage!.length {
                break
            } else {
                currentPosition = currentRange.location + currentRange.length
            }
        }
    }
}
