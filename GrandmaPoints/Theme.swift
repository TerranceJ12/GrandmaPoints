import SwiftUI

struct AppTheme {
    // Colors
    static let primaryColor = Color(red: 0.2, green: 0.5, blue: 0.8)
    static let secondaryColor = Color(red: 0.9, green: 0.6, blue: 0.3)
    static let backgroundColor = Color(red: 0.95, green: 0.97, blue: 0.99)
    static let cardColor = Color.white
    
    // Text Styles
    static let titleStyle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headlineStyle = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyStyle = Font.system(.body, design: .rounded)
    
    // UI Element Styling
    static func primaryButtonStyle() -> some ButtonStyle {
        return CustomButtonStyle(bgColor: primaryColor, textColor: .white)
    }
    
    static func secondaryButtonStyle() -> some ButtonStyle {
        return CustomButtonStyle(bgColor: secondaryColor, textColor: .white)
    }
}

// Custom Button Style
struct CustomButtonStyle: ButtonStyle {
    var bgColor: Color
    var textColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(bgColor.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(textColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

// Custom TextField Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}
