//
//  MusicSwiftUIApp.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/5.
//

import SwiftUI

@main
struct MusicSwiftUIApp: App {
    @StateObject var model = Model() // Avoid calling multiple times, ensures that model initilize once and follows the lifecycle of the app
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
