//
//  DoingTextView+Debug.swift
//  the-system
//
//  Created by Dirk on 14/06/2021.
//

import Foundation

extension DoingTextView {
    func debugIndent() {
        for line in content.lines {
            let padding = "".padding(toLength: line.indent, withPad: " ", startingAt: 0)
            let status = line.complete ? "-" : "O"
            print(padding + status)
        }
    }
}
