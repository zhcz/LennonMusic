//
//  ButtonCategory.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/19.
//

import UIKit

// 定义一个关联对象的键
private var onTapKey: Void?

extension UIButton {
    // onTap 闭包属性
    var onTapp: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &onTapKey) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &onTapKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue != nil {
                addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            } else {
                removeTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            }
        }
    }

    @objc private func buttonTapped() {
        onTapp?()
    }
}
