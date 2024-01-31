//
//  test.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/26.
//

import SwiftUI

struct test: View {
    
    var body: some View {
        
        customm(title: "423", type: .three) {
            Text("ffff")
            Image(systemName: "heart.fill")
        }
        
        
    }
}
struct customm<Content: View>: View {
    enum ViewType {
        case one
        case two
        case three
    }
    
    var title: String
    var content: Content
    var type : ViewType
    
    init(title: String,type:ViewType,@ViewBuilder content:() -> Content) {
        self.title = title
        self.type = type
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading){
            Text(title)
                .font(.largeTitle)
            
            content
            sectionVew
            
            Rectangle()
                .frame(height: 2)
            
        }
        .padding()
    }
    
   @ViewBuilder var sectionVew: some View {
//        VStack {来看看
            switch type {
            case .one :
                Text("one")
            case .two :
                Text("two")
            case .three :
                Image(systemName: "bolt.fill")
            }
            
//        }
    }
    
}


@available(iOS 16.0, *)
struct newView : View {
    @State var isDetail: Bool = false
    @State var text : String = "dvv"
    var body: some View {
        NavigationView {
            VStack{
                secondView(title:text)
//                    .preference(key: myPreferenceKey.self, value: "texfadsft")
            }
            
            .navigationTitle("标题")
        }
//        .onPreferenceChange(myPreferenceKey.self, perform: { value in
//            self.text = value
//        })
        
        .navigationBarTitleDisplayMode(.large)

    }
}
struct secondView: View {
    var title:String
    var body: some View {
        Text(title)
            .font(.largeTitle)
    }
}

struct myPreferenceKey : PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

struct scrollView: View {
   @State var offset_y : CGFloat = 0
    var tabbarItems: [tabItem] = [MusicSwiftUI.tabItem(name: "主页", image: "house", color: .red),MusicSwiftUI.tabItem(name: "喜欢", image: "heart", color: .blue),MusicSwiftUI.tabItem(name: "我的", image: "person", color: .green)]
    @Binding var selectTab: tabItem
    var body: some View{
        
            ScrollView {
                
                VStack{
                    Text("1321")
//                        .font(.largeTitle)
                        .background(
                            GeometryReader(content: { geometry in
                                Text("")
                                    .preference(key: myPreferenceKey.self, value: geometry.frame(in: .global).minY)
                            })
                        )
                    ForEach(0..<30) { _ in
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .foregroundColor(Color.red.opacity(0.6))
                            .cornerRadius(30)
                    }
                    .padding()
                    
                }
                .onPreferenceChange(myPreferenceKey.self, perform: { value in
                    offset_y = value
                })
                
        }
            .overlay(alignment: .center) {
                Text("\(offset_y)")
            }
       
        tabView(tabItems: tabbarItems, selectTab: $selectTab)
        
        
    }
}

struct tabView : View {
    var tabItems: [tabItem]
    @Binding var selectTab : tabItem
    var body: some View{
        HStack {
            ForEach(tabItems,id: \.self) { tab in
                VStack {
                    Image.init(systemName: tab.image)
                        .foregroundColor(selectTab == tab ? tab.color : .gray)
                    Text(tab.name)
                        .foregroundColor(selectTab == tab ? tab.color : .gray)
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        
                    }
        
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical,5)
                .background(selectTab == tab ? tab.color.opacity(0.2) : .clear)
                .cornerRadius(10)
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(10)
    }
}
struct tabItem: Hashable {
    var name: String
    var image: String
    var color: Color
}
@available(iOS 16.0, *)
#Preview {
//
    scrollView(selectTab: .constant(tabItem(name: "首页", image: "house", color: .red)))
}
