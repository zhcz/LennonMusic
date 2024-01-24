//
//  ZHPlayList.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/5.
//

import SwiftUI

class ZHPlayList: BaseModel,Identifiable,ObservableObject {
    var id: Int?
    var name: String?
    var playCount: Int?
    var coverImgUrl: String?
    var description: String?
    var creator: ZHPlayListCreator?
    var index: Int = 0
    
    var image: UIImage?
    var colors : [Color]?
    
    var textHeight: CGFloat {
        
        description?.textHeight(font: UIFont.preferredFont(forTextStyle: .footnote), width: UIScreen.main.bounds.width - 80) ?? 0.0
        
    }
}


