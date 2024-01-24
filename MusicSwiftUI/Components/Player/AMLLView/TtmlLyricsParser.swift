//
//  TTMLParser.swift
//
//
//  Created by YICHAO LI on 2024/1/3.
//

import Foundation
import SwiftSoup

public class TTMLParser: NSObject {
    private var currentIndexNum: Int = 0
    private var ttmlLyrics: [TtmlLyric] = []
    private var currentTtmlLyric: TtmlLyric?
    private var currentSubTtmlLyrics: [SubTtmlLyric] = []
    private var currentTranslation: String?
    private var currentRoman: String?
    private var currentBgLyric: BgTtmlLyric?
    private var currentElement: String?
}

extension TTMLParser {
    public func decodeTtml(data: Data, coderType: String.Encoding)  async throws -> [TtmlLyric] {
        guard let htmlString = String(data: data, encoding: coderType) else { throw NSError() }
        return try await decodeTtml(htmlString: htmlString)
    }
    
    public func decodeTtml(htmlString: String) async throws -> [TtmlLyric] {
        guard let doc = try? SwiftSoup.parse(htmlString) else { throw NSError(); }
        guard let body = doc.body() else { throw NSError(); }
        
        var ttmlLyrics: [TtmlLyric] = []
        
        do {
            let pElements = try body.getElementsByTag("p")
            for (index, pElement) in pElements.enumerated() {
                let beginTime   = try pElement.attr("begin")
                let endTime     = try pElement.attr("end")
                let ttmAgent    = try pElement.attr("ttm:agent")
                let itunesKey   = try pElement.attr("itunes:key")
                
                if !ttmAgent.isEmpty || !itunesKey.isEmpty {
                    var currentTtmlLyric = TtmlLyric(indexNum: index,
                                                     position: getPositionFromAgent(ttmAgent),
                                                     beginTime: beginTime.toTimeInterval(),
                                                     endTime: endTime.toTimeInterval(),
                                                     mainLyric: [],
                                                     bgLyric: nil,
                                                     translation: nil,
                                                     roman: nil)
                    
                    var currentSubTtmlLyrics: [SubTtmlLyric] = []
                    var currentTranslation: String?
                    var currentRoman: String?
                    var currentBgLyric: BgTtmlLyric?
                    var bgSubLyricsElements: [Element] = []
                    var bgSubTtmlLyricList : [SubTtmlLyric] = []
                    
                    let spanElements = try pElement.getElementsByTag("span")
                    for spanElement in spanElements {
                        let role = try spanElement.attr("ttm:role")
                        let text = try spanElement.text()
                        
                        if role == "x-translation" {
                            currentTranslation = text
                        } else if role == "x-roman" {
                            currentRoman = text
                        } else if role == "x-bg" {
                            currentBgLyric = BgTtmlLyric(subLyric: [], translation: nil, roman: nil)
                            let bgSpanElements = try spanElement.getElementsByTag("span")
                            for bgSpanElement in bgSpanElements {
                                let bgBeginTime         = try bgSpanElement.attr("begin")
                                let bgEndTime           = try bgSpanElement.attr("end")
                                let bgSpanElementRole   = try bgSpanElement.attr("ttm:role")
                                let bgSpanElementText   = try bgSpanElement.text()
                                if bgSpanElementRole == "x-translation" {
                                    currentBgLyric?.translation = try bgSpanElement.text()
                                } else if bgSpanElementRole == "x-roman" {
                                    currentBgLyric?.roman       = try bgSpanElement.text()
                                } else if bgSpanElement.hasAttr("begin") {
                                    let bgSubTtmlLyric = SubTtmlLyric(beginTime: bgBeginTime.toTimeInterval(), endTime: bgEndTime.toTimeInterval(), text: bgSpanElementText)
                                    bgSubTtmlLyricList.append(bgSubTtmlLyric)
                                }
                                currentBgLyric?.subLyric = bgSubTtmlLyricList
                                bgSubLyricsElements.append(bgSpanElement)
                            }
                        }
                        else {
                            if bgSubLyricsElements.contains(spanElement) { continue }
                            let subLyricBeginTime  = try spanElement.attr("begin")
                            let subLyricEndTime    = try spanElement.attr("end")
                            let subTtmlLyric = SubTtmlLyric(beginTime: subLyricBeginTime.toTimeInterval(), endTime: subLyricEndTime.toTimeInterval(), text: text)
                            currentSubTtmlLyrics.append(subTtmlLyric)
                        }
                    }
                    let mainLyricBeginTime  = try pElement.attr("begin")
                    let mainLyricEndTime    = try pElement.attr("end")
                    
                    currentTtmlLyric.beginTime      = mainLyricBeginTime.toTimeInterval()
                    currentTtmlLyric.endTime        = mainLyricEndTime.toTimeInterval()
                    currentTtmlLyric.mainLyric      = currentSubTtmlLyrics
                    currentTtmlLyric.bgLyric        = bgSubTtmlLyricList.isEmpty == true ? nil : currentBgLyric
                    currentTtmlLyric.translation    = currentTranslation
                    currentTtmlLyric.roman          = currentRoman
                    
                    ttmlLyrics.append(currentTtmlLyric)
                }
            }
        } catch {
            throw error
        }
        
        if ttmlLyrics.isEmpty { throw NSError() }
        return ttmlLyrics
    }
}

extension TTMLParser {    
    private func getPositionFromAgent(_ agent: String) -> TtmlLyricPositionType {
        if agent == "v1" { return .main }
        return .sub
    }
}

// MARK: Extension
extension String {
    func toTimeInterval() -> TimeInterval {
        let pattern = #"(\d+):(\d+)\.(\d+)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        
        guard let match = matches.first,
              match.numberOfRanges == 4,
              let minutesRange = Range(match.range(at: 1), in: self),
              let secondsRange = Range(match.range(at: 2), in: self),
              let millisecondsRange = Range(match.range(at: 3), in: self),
              let minutes = Double(self[minutesRange]),
              let seconds = Double(self[secondsRange]),
              let milliseconds = Double(self[millisecondsRange]) else {
            return TimeInterval(0)
        }
        
        let totalMilliseconds = (minutes * 60 + seconds) * 1000 + milliseconds
        let timeInterval = totalMilliseconds / 1000
        
        return timeInterval
    }
}
