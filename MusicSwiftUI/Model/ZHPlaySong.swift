//
//  ZHPlaySong.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/8.
//

import SwiftUI

class ZHPlaySong: BaseModel,Identifiable {
    var id : Int?
    var br : Int?
    var size : Int?
//    var code : Int?
    var expi : Int?
    var gain : Int?
    var fee : Int?
    var payed : Int?
    var flag : Int?
    
    var canExtend : Bool?

    
    var mp3Url: String?
    var url : String?
    var md5 : String?
    var type : String?
    var level : String?
    var encodeType : String?
    
    var name : String?
    
    var singer : String?
    
    var picUrl : String?
    
    var al : ZHSongAlModel?
    var ar : ZHSongArModel?
    var index: Int = -1
   
    var image: UIImage?
    var colors : [Color]?
    
}


//专辑
class ZHSongAlModel: BaseModel {
    var pic_str : String?
    var id : Int?
    var pic : Int?
    var name : String?
    var tns : Dictionary<String, Any>?
    var picUrl : String?
    var img1v1Url : String?
}

//歌手
class ZHSongArModel: BaseModel {
    var name : String?
    var id : Int?
    var tns : Array<Any>?
    var alias : Array<Any>?
    
}
