//
//  Model.swift
//  Model
//
//  Created by zhanghao on 2024/1/8.
//

import SwiftUI
import Combine

class Model: ObservableObject {
    // Tab Bar
    @Published var showTab: Bool = true
    
    // Navigation Bar
    @Published var showNav: Bool = true
    
    // Modal
    @Published var selectedModal: Modal = .signUp
    @Published var showModal: Bool = false
    @Published var dismissModal: Bool = false
    
    // Detail View
    @Published var showDetail: Bool = false
    @Published var selectedCourse: Int = 0
    
//    Search View
    @Published var showSearchView: Bool = false
    @Published var showSearchViewBar: Bool = true
    
}

enum Modal: String {
    case signUp
    case signIn
}
