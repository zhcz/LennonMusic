//
//  DateCategory.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/5.
//

import SwiftUI

extension Date {
    //Date 转 String
    init(_ dateString: String, dateFormat: String = "yyyy-MM-dd") {
            let df = DateFormatter()
            df.dateFormat = dateFormat
            let date = df.date(from: dateString)!
            self.init(timeInterval: 0, since: date)
        }
    //String 转 Date
    func format(_ dateFormat: String, LocalId: String = "zh_CN") -> String {
        let df = DateFormatter()
        df.dateFormat="yyyy-MM-dd HH:mm:ss"
        let dateStr = df.string(from: self)
        return dateStr
    }
    
    // 转成当前时区的日期
    static func dateFromGMT(_ date: Date) -> Date {
        let secondFromGMT: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT(for: date))
        return date.addingTimeInterval(secondFromGMT)
    }
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }

    
}
