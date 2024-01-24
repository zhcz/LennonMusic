//
//  BaseModel.swift
//  swiftDemo2
//
//  Created by zhanghao on 2022/4/24.
//  Copyright © 2022 张浩. All rights reserved.
//

import UIKit
import HandyJSON

class BaseModel: HandyJSON {
    
    var code : Int?
    var unikey : String?
    
    var qrurl  : String?
    var qrimg : String?
    var lyric : String?
    required init() { }
    
    func mapping(mapper: HelpingMapper) {   //自定义解析规则，日期数字颜色，如果要指定解析格式，子类实现重写此方法即可
    //        mapper <<<
    //            date <-- CustomDateFormatTransform(formatString: "yyyy-MM-dd")
    //
    //        mapper <<<
    //            decimal <-- NSDecimalNumberTransform()
    //
    //        mapper <<<
    //            url <-- URLTransform(shouldEncodeURLString: false)
    //
    //        mapper <<<
    //            data <-- DataTransform()
    //
    //        mapper <<<
    //            color <-- HexColorTransform()
          }
}
