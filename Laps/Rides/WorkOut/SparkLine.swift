//
//  SparkLine.swift
//  Laps
//
//  Created by Nicholas Trienens on 1/21/23.
//

import SwiftUI
import Charts

struct SparklineShape: Shape {
    var data: [CGFloat]

    func path(in rect: CGRect) -> Path {
        print(data.count)
        guard data.count > 2  else{  return Path{ _ in} }
        let yScale = CGFloat(data.map { $0 }.max()! - data.map { $0 }.min()!)
        let xScale = CGFloat(data.count - 1)

        print(yScale)
        return Path { path in
            let points = data.enumerated().map { (i, y) in
                CGPoint(x: CGFloat(i) / xScale * rect.width,
                        y: (1 - (y / yScale)) * rect.height)
            }
            path.move(to: points.first!)
            points
                .dropFirst()
                .forEach {
                    path.addLine(to: $0)
                }
        }
    }
}
// MARK: - Sparkline
/// Sparkline Shape must be passed a set of points where the x coordinate is always unique.
struct SparklineShape2: Shape {
    init(data:[CGFloat]){
        
        points = data.enumerated().map { (i, y) in
            CGPoint(x: CGFloat(i),
                    y: y)
        }
        box = true
    }
    var points: [CGPoint]
    var box: Bool = false
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard points.count > 2  else {  return path }

        // Sort points so that x values are in order from lowest to highest
        let sPoints = points.sorted { $0.x < $1.x }
        // Get the highest X and Y values
        let maxYCoord = sPoints.map {$0.y}.max() ?? 1
        let maxXCoord = sPoints.map {$0.x}.max() ?? 1
        let minYCoord = sPoints.map {$0.y}.min() ?? maxYCoord/2
        
        // Create a scale factor to resize the chart based on maximum values
        let xScale: CGFloat = rect.maxX / CGFloat(maxXCoord)
        let yScale: CGFloat = rect.maxY / CGFloat(maxYCoord - minYCoord)
        print(yScale)
        
        // Draw the first point
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - (CGFloat(sPoints[0].y) * yScale)) )
        
        // Draw the remaining points and paths after dropping the first already used point
        for item in sPoints.dropFirst() {
            path.addLine(to: CGPoint(x: rect.minX + (item.x * xScale), y: rect.maxY - (item.y * yScale) ))
        }
        
        // Optionally draws a bounding box of the maximum coordinates
        if box {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint( x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint( x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        
        return path
    }
}



struct Sparkline: View {
     init(data: [Int] = [130]) {
        self.data = data
         let ymin = data.min() ?? 0
         let ymax = data.max() ?? 10
         if ymin == ymax {
             yMarkValues = [ymax]
         } else {
             yMarkValues = stride(from: ymin, to: ymax, by: (ymax - ymin) / 5 ) .map{ $0 }
         }
    }
    let yMarkValues: [Int]
    var data: [Int]

    var body: some View {
        GroupBox {
            Chart {
                ForEach(data.indexed(), id: \.index) { (i, w) in
                    LineMark(x: .value("Day", i), y: .value("HR", Int(w)))
                        .accessibilityValue("\(w) Steps")
                        .foregroundStyle(.red)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: yMarkValues)
            }
        }
      
        .frame(height: 140)
        
    }
}

struct SparkLine_Previews: PreviewProvider {
    static var previews: some View {
        Sparkline()
    }
}
