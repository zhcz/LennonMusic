//
//  ZHPlayListItem.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/5.
//

import SwiftUI
import URLImage
import Shimmer
struct ZHPlayListItem: View {
    var songList: ZHPlaySong? = nil
   
    var namespace: Namespace.ID
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        ZStack() {
            
            AsyncImage(url: URL(string: (songList?.al!.picUrl)!)!) { phase in
                
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .modifier(OutlineOverlay(cornerRadius: 20))                    } else if phase.error != nil {
                        // 加载失败时显示的视图
                        Text("Failed to load the image")
                    } else {
                        // 加载中显示的视图
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .cornerRadius(30)
                            .blur(radius: 30)
                            .matchedGeometryEffect(id: "blur\(songList?.index ?? 0)", in: namespace)
                        
                    }
            }
          
//            playNumbersTag
            titleView
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .background(.ultraThinMaterial)
    }
    
    var playNumbersTag: some View {
        VStack {
            HStack {
                Spacer()
                HStack {
//                    Image(systemName: "play.fill")
//                    Text(String((songList?.playCount)!))
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .padding(.top,5)
                .padding(.bottom,5)
                .background(Color.black.opacity(0.39))
                .cornerRadius(10)
                .foregroundStyle(Color.white.opacity(0.6))
            }
            .padding()
            Spacer()
        }
    }
    
    var titleView: some View {
        VStack {
            Spacer()
            HStack {
                HStack {
                    Text((songList?.name)!)
//                        .redacted(reason: .placeholder)
//                        .shimmering()
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .padding(.top,5)
                .padding(.bottom,5)
                .background(Color.black.opacity(0.39))
                .cornerRadius(10)
                .foregroundStyle(Color.white.opacity(0.6))
            }
            .padding()
            
        }
    }
}

struct ZHPlayListItem_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        ZHPlayListItem(namespace: namespace)
    }
}
