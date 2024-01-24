//
//  PlayListItem.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/9.
//

import SwiftUI

struct PlayListItem: View {
    var namespace: Namespace.ID
    var playList: ZHPlayList?
    
    @EnvironmentObject var model: Model
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
//            LogoView(image: course.logo)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                .padding(20)
//                .matchedGeometryEffect(id: "logo\(course.index)", in: namespace)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(playList!.name ?? "")
                    .font(.title).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .matchedGeometryEffect(id: "title\(playList!.index)", in: namespace)
                    .foregroundColor(.white)
                
//                Text("20 videos - 3 hours".uppercased())
//                    .font(.footnote).bold()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .matchedGeometryEffect(id: "subtitle\(playList!.index)", in: namespace)
//                    .foregroundColor(.white.opacity(0.7))
                
                Text(playList?.description ?? "")
                    .font(.footnote)
                    .frame(maxWidth: .infinity,maxHeight: 50, alignment: .leading)
                    .foregroundColor(.white.opacity(0.7))
                    .matchedGeometryEffect(id: "description\(playList!.index)", in: namespace)
            }
            .padding(20)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .cornerRadius(30)
                    .blur(radius: 30)
                    .matchedGeometryEffect(id: "blur\(playList!.index)", in: namespace)
            )
        }
        .background(
            AsyncImage(url: URL(string: (playList!.coverImgUrl)!)!) { phase in
                
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .disabled(true)
                        .matchedGeometryEffect(id: "background\(playList!.index)", in: namespace)
                    } else if phase.error != nil {
                        // 加载失败时显示的视图
                        Text("Failed to load the image")
                    } else {
                        // 加载中显示的视图
//                        ProgressView()
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .cornerRadius(30)
                            .blur(radius: 30)
                            .matchedGeometryEffect(id: "blur\(playList!.index)", in: namespace)
                        
                    }
            }
        )
        .mask(
            RoundedRectangle(cornerRadius: 30)
                .matchedGeometryEffect(id: "mask\(playList!.index)", in: namespace)
        )
//        .overlay(
//            Image(horizontalSizeClass == .compact ? "Waves 1" : "Waves 2")
//                .frame(maxHeight: .infinity, alignment: .bottom)
//                .offset(y: 0)
//                .opacity(0)
//                .matchedGeometryEffect(id: "waves\(playList!.index)", in: namespace)
//        )
//        .frame(height: 300)
        .onTapGesture {
            withAnimation(.openCard) {
//                model.showSearchView = false
                model.showSearchViewBar = false
                model.showDetail = true
                model.selectedCourse = playList!.index
            }
        }
    }
}

struct CardItem_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        PlayListItem(namespace: namespace)
            .environmentObject(Model())
    }
}
