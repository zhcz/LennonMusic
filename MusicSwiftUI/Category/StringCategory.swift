//
//  StringCategory.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/11.
//

import SwiftUI

extension String {
    func textHeight(font: UIFont, width: CGFloat) -> CGFloat {

        return self.boundingRect(with:CGSize(width: width, height:CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font:font], context:nil).size.height+5

    }

    func textWidth(font: UIFont, height: CGFloat) -> CGFloat {

        return self.boundingRect(with:CGSize(width: CGFloat(MAXFLOAT), height:height), options: .usesLineFragmentOrigin, attributes: [.font:font], context:nil).size.width+5

    }

}


