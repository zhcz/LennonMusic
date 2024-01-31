//
//  Textt.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/26.
//

import SwiftUI

// 关于PreferenceKey的使用:
// 当某个场景下,父view需要获取子view的某些信息,
// 就可以考虑使用PreferenceKey这个技术,
// 它最大的优点是可以让子view封装任何信息.
// 但这可能存在一些潜在的问题,
// 如果父view的布局改变了,
// 影响到了子view的布局,
// 子view的布局又影响了父view的布局,
// 这种情况可能会出现死循环。
//（是不是在构建父view和子view时,
// 尽量不让两者的布局产生改变,
// 是不是就能解决这个问题吗？
// 本例子中父view不会改变布局,
// 子view也不会改变布局)

// PreferenceKey怎么在本例中使用的大致思路:
// 首先,要给每个月份元素添加实现PreferenceKey协议的值,
//     每个月份元素都是由MonthView结构来实现的,该MonthView返回的view中,
//     在.background()修饰符中包含了MyPreferenceViewSetter方法,
//     该方法返回的Rectangle图形中又用到了.preference修饰器,
//     该修饰器的key/value组合以供后续父view调取数据;
// 其次,VStack中包含的所有月份元素,
//     又会因为.onPreferenceChange修饰器中的代码的执行
//     而将所有的月份元素的相关数据全部汇总于rects变量,
// 再次,ZStack中的RoundedRectangle()生成,
//     又因@State修饰的rects而生成初始值,即实时形成最初的框,
// 最后,因为@State修饰的activeIdx的变化,
//     而使RoundedRectangle()这个view的大小和位置实时的变化。

import SwiftUI

struct PreferenceKeyExample: View {
    @State private var activeIdx: Int = 0
    @State private var rects: [CGRect] = Array<CGRect>(repeating: CGRect(), count:12)
    
    var body: some View {
        // 不设置(alignment: .topLeading)的时候,边框就会往下掉,这是为啥？
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30)
                .stroke(lineWidth: 3.0).foregroundColor(Color.green)
                .frame(width:rects[activeIdx].size.width, height:rects[activeIdx].size.height)
                .offset(x: rects[activeIdx].minX, y: rects[activeIdx].minY)
                .animation(.easeInOut(duration: 1.0))
            
            
            VStack {
                Spacer()
                
                HStack {
                    MonthView(activeMonth: $activeIdx, label: "January", idx: 0)
                    MonthView(activeMonth: $activeIdx, label: "February", idx: 1)
                    MonthView(activeMonth: $activeIdx, label: "March", idx: 2)
                    MonthView(activeMonth: $activeIdx, label: "April", idx: 3)
                }
                
                Spacer()
                
                HStack {
                    MonthView(activeMonth: $activeIdx, label: "May", idx: 4)
                    MonthView(activeMonth: $activeIdx, label: "June", idx: 5)
                    MonthView(activeMonth: $activeIdx, label: "July", idx: 6)
                    MonthView(activeMonth: $activeIdx, label: "August", idx: 7)
                }
                
                Spacer()
                
                HStack {
                    MonthView(activeMonth: $activeIdx, label: "September", idx: 8)
                    MonthView(activeMonth: $activeIdx, label: "October", idx: 9)
                    MonthView(activeMonth: $activeIdx, label: "November", idx: 10)
                    MonthView(activeMonth: $activeIdx, label: "December", idx: 11)
                }
                
                Spacer()
            }
            // ZStack通过.onPreferenceChange获取了全部的preferences,
            // 然后根据包裹中的数据给self.rects赋值
            .onPreferenceChange(MyTextPreferenceKey.self) {
                preferences in
                for p in preferences {
                    self.rects[p.viewIdx] = p.rect
                }
            }
        }
        // 命名空间坐标系的名称
        .coordinateSpace(name: "myZstack")
    }
}

struct MonthView: View {
    @Binding var activeMonth: Int
    let label: String
    let idx: Int
    
    var body: some View {
        Text(label)
            .padding(10)
            .background(MyPreferenceViewSetter(idx: idx))
            .onTapGesture {
                self.activeMonth = self.idx
            }
    }
}

struct MyPreferenceViewSetter: View {
    let idx: Int
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                // preference要求传入一个key和value
                // key只需要实现PreferenceKey协议即可,
                // 该协议要求实现一个静态变量defaultValue和静态函数reduce
                // value放入封装好的MyTextPreferenceData这个结构体
                // 当父view想要获取子view信息的时候,
                // 它就会遍历view中的reduce,然后把所有的包裹合并成一个数组
                // 这里用到了GeometryReader的.frame(in: .named())命名空间,
                // 不同于用.global和.local,应该是更好定位。
                .preference(key: MyTextPreferenceKey.self,
                            value: [MyTextPreferenceData(viewIdx: self.idx, rect: geometry.frame(in: .named("myZstack")))]
                )
        }
    }
}

// 把需要传递的信息封装成一个结构体,
// 因为.onPreferenceChange传递的数据
// 必须要实现Equatable协议,不然会报错。
// 这里打包了两个信息,一个是月份的id,一个是月份的坐标(使用CGRect类型来实现)
struct MyTextPreferenceData: Equatable {
    let viewIdx: Int
    let rect: CGRect
}

struct MyTextPreferenceKey: PreferenceKey {
    typealias Value = [MyTextPreferenceData]
    
    static var defaultValue: [MyTextPreferenceData] = []

    static func reduce(value: inout [MyTextPreferenceData], nextValue: () -> [MyTextPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}
