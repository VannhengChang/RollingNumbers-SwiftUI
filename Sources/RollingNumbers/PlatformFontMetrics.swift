import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformFont = UIFont
#elseif canImport(AppKit)
import AppKit
typealias PlatformFont = NSFont
#endif

struct RollingFontDescriptor: Equatable {
    var size: CGFloat
    var weight: Font.Weight
    var design: Font.Design

    static let `default` = RollingFontDescriptor(size: 24, weight: .bold, design: .default)

    var font: Font {
        .system(size: size, weight: weight, design: design)
    }

    func platformFont() -> PlatformFont {
        PlatformFontMetrics.platformFont(size: size, weight: weight, design: design)
    }

    func lineHeight() -> CGFloat {
        PlatformFontMetrics.lineHeight(for: platformFont())
    }

    func charWidth(_ char: Character, spacing: CGFloat) -> CGFloat {
        PlatformFontMetrics.charWidth(char, font: platformFont(), spacing: spacing)
    }
}

enum PlatformFontMetrics {

    static func platformFont(
        size: CGFloat,
        weight: Font.Weight,
        design: Font.Design
    ) -> PlatformFont {
        #if canImport(UIKit)
        let uiWeight = uiKitWeight(from: weight)
        if design == .monospaced {
            return UIFont.monospacedSystemFont(ofSize: size, weight: uiWeight)
        }
        if design == .rounded {
            if let descriptor = UIFont.systemFont(ofSize: size, weight: uiWeight)
                .fontDescriptor
                .withDesign(.rounded)
            {
                return UIFont(descriptor: descriptor, size: size)
            }
        }
        return UIFont.systemFont(ofSize: size, weight: uiWeight)
        #elseif canImport(AppKit)
        let nsWeight = appKitWeight(from: weight)
        if design == .monospaced {
            return NSFont.monospacedSystemFont(ofSize: size, weight: nsWeight)
        }
        if design == .rounded {
            if let descriptor = NSFont.systemFont(ofSize: size, weight: nsWeight)
                .fontDescriptor
                .withDesign(.rounded)
            {
                return NSFont(descriptor: descriptor, size: size) ?? NSFont.systemFont(ofSize: size, weight: nsWeight)
            }
        }
        return NSFont.systemFont(ofSize: size, weight: nsWeight)
        #endif
    }

    static func lineHeight(for font: PlatformFont) -> CGFloat {
        #if canImport(UIKit)
        font.lineHeight
        #elseif canImport(AppKit)
        ceil(font.ascender - font.descender + font.leading)
        #endif
    }

    static func charWidth(_ char: Character, font: PlatformFont, spacing: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = String(char).size(withAttributes: attributes)
        return size.width * spacing
    }

    #if canImport(UIKit)
    private static func uiKitWeight(from weight: Font.Weight) -> UIFont.Weight {
        switch weight {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
    #endif

    #if canImport(AppKit)
    private static func appKitWeight(from weight: Font.Weight) -> NSFont.Weight {
        switch weight {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
    #endif
}
