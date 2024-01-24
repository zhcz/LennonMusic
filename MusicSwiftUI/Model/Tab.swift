//
//  Tab.swift
//  Tab
//
//  Created by zhanghao on 2024/1/8.
//

import SwiftUI

struct TabItem: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color
    var selection: Tab
}

var tabItems = [
    TabItem(name: "tab1", icon: "", color: .teal, selection: .home),
    TabItem(name: "tab2", icon: "", color: .blue, selection: .explore),
    TabItem(name: "tab3", icon: "", color: .red, selection: .notifications),
    TabItem(name: "tab4", icon: "", color: .pink, selection: .library)
]

enum Tab: String {
    case home
    case explore
    case notifications
    case library
}
