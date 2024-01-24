//
//  LogoView.swift
//  iOS15
//
//  Created by zhanghao on 2024/1/8.
//

import SwiftUI
import URLImage
struct LogoView: View {
    var image : String?
    
    var body: some View {
        
//        if (image == nil) {
//            Image("logo")
//                .resizable()
//                .frame(width: 26, height: 26)
//                .cornerRadius(10)
//                .padding(8)
//                .background(.ultraThinMaterial)
//                .backgroundStyle(cornerRadius: 18, opacity: 0.4)
//        }else{
            AsyncImage(url: URL(string: (image ?? defautAvatarUrl))) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: 26, height: 26)
                        .cornerRadius(10)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .backgroundStyle(cornerRadius: 18, opacity: 0.4)
                } else if phase.error != nil {
                    // 加载失败时显示的视图
                    Text("Failed to load the image")
                } else {
                    // 加载中显示的视图
                    ProgressView()
                }
            }
//        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
