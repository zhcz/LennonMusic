//
//  ZHLyricModel.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/16.
//

import SwiftUI

class ZHLyricModel: BaseModel,Identifiable {
    
    var lrc : String?
    var time : Double? = 0
    var duration : Double? = 0
    var animToggle: Bool = false
}

