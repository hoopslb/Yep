//
//  String+Yep.swift
//  Yep
//
//  Created by kevinzhow on 15/4/2.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import Foundation

extension String {
    
    func toDate() -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        if let date = dateFormatter.dateFromString(self) {
            return date
        } else {
            return nil
        }
    }
}

extension String {

    enum TrimmingType {
        case Whitespace
        case WhitespaceAndNewline
    }

    func trimming(trimmingType: TrimmingType) -> String {
        switch trimmingType {
        case .Whitespace:
            return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        case .WhitespaceAndNewline:
            return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
    }

    var yep_removeAllNewLines: String {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).joinWithSeparator("")
    }
}

extension String {

    func yep_mentionWordInIndex(index: Int) -> (wordString: String, mentionWordRange: Range<Index>)? {

        println("startIndex: \(startIndex), endIndex: \(endIndex), index: \(index), length: \((self as NSString).length), count: \(self.characters.count)")

        guard index > 0 else {
            return nil
        }

        guard self.characters.count > index else {
            return nil
        }

        let index = startIndex.advancedBy(index)

        var wordString: String?
        var wordRange: Range<Index>?

        self.enumerateSubstringsInRange(Range<Index>(start: startIndex, end: endIndex), options: [.ByWords, .Reverse]) { (substring, substringRange, enclosingRange, stop) -> () in

            //println("substring: \(substring)")
            //println("substringRange: \(substringRange)")
            //println("enclosingRange: \(enclosingRange)")

            if substringRange.contains(index) {
                wordString = substring
                wordRange = substringRange
                stop = true
            }
        }

        guard let _wordString = wordString, _wordRange = wordRange else {
            return nil
        }

        guard _wordRange.startIndex != startIndex else {
            return nil
        }

        let mentionWordRange = Range<Index>(start: _wordRange.startIndex.advancedBy(-1), end: _wordRange.endIndex)

        let mentionWord = substringWithRange(mentionWordRange)

        guard mentionWord.hasPrefix("@") else {
            return nil
        }

        return (_wordString, mentionWordRange)
    }
}

extension String {

    var yep_embeddedURLs: [NSURL] {

        guard let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue) else {
            return []
        }

        var URLs = [NSURL]()

        detector.enumerateMatchesInString(self, options: [], range: NSMakeRange(0, (self as NSString).length)) { result, flags, stop in

            if let URL = result?.URL {
                URLs.append(URL)
            }
        }

        return URLs
    }

    var yep_firstImageURL: NSURL? {

        let URLs = yep_embeddedURLs

        guard !URLs.isEmpty else {
            return nil
        }

        let imageExtentions = [
            "png",
            "jpg",
            "jpeg",
        ]

        for URL in URLs {
            if let pathExtension = URL.pathExtension?.lowercaseString {
                if imageExtentions.contains(pathExtension) {
                    return URL
                }
            }
        }

        return nil
    }
}

