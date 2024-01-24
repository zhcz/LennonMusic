//
//  Wave.swift
//  iOS15
//
//  Created by zhanghao on 2024/1/8.
//

import SwiftUI

struct Wave: View {
    var body: some View {
        Canvas { context, size in
            let image = context.resolve(Image(systemName: "moon"))
            context.clipToLayer { innerContext in
                innerContext.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            context.fill(path(in: CGRect(x: 0, y: 0, width: size.width, height: size.height)), with: .color(.blue))
        }
        .frame(width: 300, height: 300)
    }
    
    func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.size.width
            let height = rect.size.height
            path.move(to: CGPoint(x: 0.21687*width, y: 0.12026*height))
            path.addCurve(to: CGPoint(x: -0.408*width, y: -0.0197*height), control1: CGPoint(x: -0.04*width, y: 0.05172*height), control2: CGPoint(x: -0.168*width, y: 0.00463*height))
            path.addCurve(to: CGPoint(x: -1.328*width, y: -0.25*height), control1: CGPoint(x: -0.648*width, y: -0.04403*height), control2: CGPoint(x: -0.72995*width, y: -0.21905*height))
            path.addCurve(to: CGPoint(x: -1.91467*width, y: -0.23896*height), control1: CGPoint(x: -1.92606*width, y: -0.28095*height), control2: CGPoint(x: -1.86933*width, y: -0.25862*height))
            path.addCurve(to: CGPoint(x: -1.91467*width, y: 1.04433*height), control1: CGPoint(x: -1.91467*width, y: -0.13297*height), control2: CGPoint(x: -1.91467*width, y: 1.04433*height))
            path.addLine(to: CGPoint(x: 2.38267*width, y: 1.04433*height))
            path.addLine(to: CGPoint(x: 2.38267*width, y: 0.41071*height))
            path.addCurve(to: CGPoint(x: 2.04667*width, y: 0.36022*height), control1: CGPoint(x: 2.38267*width, y: 0.41071*height), control2: CGPoint(x: 2.22533*width, y: 0.38362*height))
            path.addCurve(to: CGPoint(x: 1.05934*width, y: 0.24639*height), control1: CGPoint(x: 1.868*width, y: 0.33682*height), control2: CGPoint(x: 1.60945*width, y: 0.27127*height))
            path.addCurve(to: CGPoint(x: 0.21687*width, y: 0.12026*height), control1: CGPoint(x: 0.50923*width, y: 0.22152*height), control2: CGPoint(x: 0.3501*width, y: 0.1558*height))
            path.closeSubpath()
            return path
        }
}

struct Wave_Previews: PreviewProvider {
    static var previews: some View {
        Wave()
    }
}
