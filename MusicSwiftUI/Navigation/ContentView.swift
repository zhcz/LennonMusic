//
//  ContentView.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/5.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: Model
//    @EnvironmentObject var viewModel: PlayerViewModel
    var body: some View {
        if #available(iOS 17.0, *) {
            HomeView()
        } else {
            // Fallback on earlier versions
        }
    }
   
}

#Preview {
    ContentView()
        .environmentObject(Model())
}
