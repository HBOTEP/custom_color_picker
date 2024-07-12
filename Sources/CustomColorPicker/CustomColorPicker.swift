// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct CustomColorPickerView: View {
    @State private var brightness: Double = 1.0
    @Binding var selectedColor: Color
    @Binding var showColorPicker: Bool

    public init(selectedColor: Binding<Color>, showColorPicker: Binding<Bool>) {
        self._selectedColor = selectedColor
        self._showColorPicker = showColorPicker
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Цвет")
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        withAnimation {
                            showColorPicker.toggle()
                        }
                    }, label: {
                        HStack {
                            Text("\(selectedColor.hexString())")
                                .foregroundColor(.blue)
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundColor(selectedColor)
                                .brightness(1 - brightness)
                                .frame(width: 20, height: 20)
                        }
                    })
                }
                
                Spacer()
            }

            if showColorPicker {
                gradientView
                    .frame(height: 70)
                    .mask(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .gesture(DragGesture(
                        minimumDistance: 0
                    ).onChanged { value in
                        self.selectedColor = getColor(
                            at: value.location.x
                        )
                    })

                Slider(value: $brightness, in: 0.0...1.0, step: 0.1)
                    .padding()
            }
        }
        .padding()
    }

    public var gradientView: some View {
        LinearGradient(
            gradient: Gradient(
                colors: generateGradientColors()
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    public func generateGradientColors() -> [Color] {
        let baseColors = [
            UIColor.white,
            UIColor.red,
            UIColor.orange,
            UIColor.yellow,
            UIColor.green,
            UIColor.cyan,
            UIColor.blue,
            UIColor.purple,
            UIColor.brown,
            UIColor.gray,
            UIColor.black
        ]
        
        var colors: [Color] = []
        for i in 0..<baseColors.count - 1 {
            colors.append(Color(baseColors[i]))
            let middleColor = UIColor.blend(
                color1: baseColors[i],
                color2: baseColors[i + 1],
                location: 0.5
            )
            colors.append(Color(middleColor))
        }
        guard let color = baseColors.last else { return colors }
        colors.append(Color(color))
        return colors
    }

    public func getColor(at position: CGFloat) -> Color {
        let colors = generateGradientColors()
        let width = UIScreen.main.bounds.width - 32
        let index = max(
            0,
            min(
                colors.count - 1,
                Int(
                    position / width * CGFloat(
                        colors.count
                    )
                )
            )
        )
        return colors[index]
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    func hexString() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "FFFFFF"
        }
        
        let componentsCount = components.count
        
        switch componentsCount {
        case 4:
            let red = components[0]
            let green = components[1]
            let blue = components[2]
            return String(format: "%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
        case 2:
            let white = components[0]
            return String(format: "%02X%02X%02X", Int(white * 255), Int(white * 255), Int(white * 255))
        default:
            return "FFFFFF"
        }
    }
}

extension UIColor {
    static func blend(color1: UIColor, color2: UIColor, location: CGFloat) -> UIColor {
        var (red1, green1, blue1, alpha1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var (red2, green2, blue2, alpha2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return UIColor(
            red: red1 + (red2 - red1) * location,
            green: green1 + (green2 - green1) * location,
            blue: blue1 + (blue2 - blue1) * location,
            alpha: alpha1 + (alpha2 - alpha1) * location
        )
    }
}
