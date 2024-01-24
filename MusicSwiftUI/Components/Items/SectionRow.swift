//
//  SectionRow.swift
//  SectionRow
//
//  Created by zhanghao on 2024/1/8.
//

import SwiftUI

struct SectionRow: View {
    var section: ZHPlaySong? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(section!.index == -1 ? "" : String((section?.index ?? 0)+1))
                .fontWeight(.semibold)
            
//                .overlay(CircularView(value: section.progress))
            VStack(alignment: .leading, spacing: 8) {
                Text(section?.name ?? "")
                    .fontWeight(.semibold)
                    
                Text(section?.ar?.name ?? "")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.top,5)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct SectionRow_Previews: PreviewProvider {
    static var previews: some View {
        SectionRow()
    }
}
