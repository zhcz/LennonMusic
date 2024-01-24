//
//  SearchTopView.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/15.
//

import SwiftUI
import AxisSegmentedView
struct SearchTopView: View {
    
    @State private var isCancelButtonVisible: Bool = false
    @EnvironmentObject var model: Model
    @Binding var searchText: String
    @State private var selection: Int = 0
    var onSearch: (String) -> Void
    var onSegmentSelected: (Int) -> Void
    var body: some View {
        
        VStack{
           
            HStack() {
               if !isCancelButtonVisible {
                    Button(action: {
                        withAnimation {
                            isCancelButtonVisible = false
                            searchText = ""
                            model.showSearchView = false
                        }
                    }) {
                        CloseButton()
                            .padding(.leading, 20)
                        //                            Image(systemName: "xmark.circle.fill")
                    }
    //                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    //                .padding(50)
    //                .ignoresSafeArea()
    //                .padding(.trailing,15)
                }
                TextField("输入搜索内容", text: $searchText,onCommit: {
                    onSearch(searchText)
                })
                .onTapGesture {
                    withAnimation {
                        isCancelButtonVisible = true
                    }
                }
                
    //            .textFieldStyle(RoundedBorderTextFieldStyle())
                //                        .background(Color("SearchView"))
                .submitLabel(.search)
    //            .keyboardType(.webSearch)
                .padding(20)
                .frame(height: 46)
                .padding(.leading, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .padding(.leading, 10)
                        Spacer()
                    }
                )
                .padding(.horizontal,20)
                
                if isCancelButtonVisible {
                    
                    Button(action: {
                        withAnimation {
                            isCancelButtonVisible = false
                            searchText = ""
                        }
                    }) {
                        Text("取消")
                            .foregroundStyle(Color.blue)
                            .padding(.trailing, 20)
                        //                            Image(systemName: "xmark.circle.fill")
                    }
                }
            }
            
            AxisSegmentedView(selection: $selection, constant: .init()) {
                
                Group {
                    
                    Text("歌单")
//                        .rotationEffect(Angle(degrees: -90))
                        .font(.callout)
                        .itemTag(0, selectArea: 0) {
                            Text("歌单")
                                .font(.callout)
                                .foregroundColor(Color.white)
//                                .background(.red)
                                
                        }
                    Text("单曲")
                        .font(.callout)
                        .foregroundColor(Color.black.opacity(0.5))
                        .itemTag(1, selectArea: 0) {
                            Text("单曲")
                                .font(.callout)
                                .foregroundColor(Color.white)
                            
                        }
                }
               
            } style: {
                ASBasicStyle()
            } onTapReceive: { selectionTap in
                /// Imperative syntax
                print("---------------------")
                print("Selection : ", selectionTap)
                print("Already selected : ", self.selection == selectionTap)
                onSegmentSelected(selectionTap)
            }
            .background(.white)
            .frame(height: 36)
            .padding(.horizontal,50)
        }

        
    }
}

#Preview {
    SearchTopView(searchText: .constant(""), onSearch: { text in
       
    }, onSegmentSelected: { index in
        
    })
}
