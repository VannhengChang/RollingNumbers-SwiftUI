import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension RollingNumbersView {

    /// Sets the animation type. Default value: `.allAfterFirstChangedNumber`.
    func rollingAnimationType(_ type: AnimationType) -> Self {
        var copy = self
        copy.animationType = type
        return copy
    }

    /// Sets the rolling direction. When `nil`, the direction is chosen based
    /// on whether the new value is greater (`.up`) or smaller (`.down`) than
    /// the previous one.
    func rollingDirection(_ direction: RollingDirection?) -> Self {
        var copy = self
        copy.rollingDirection = direction
        return copy
    }

    /// Horizontal alignment of the rendered number inside the available width.
    func rollingAlignment(_ alignment: Alignment) -> Self {
        var copy = self
        copy.horizontalAlignment = alignment
        return copy
    }

    /// Multiplier applied to each character's intrinsic width.
    /// Default value: `1`.
    func rollingCharacterSpacing(_ spacing: CGFloat) -> Self {
        var copy = self
        copy.characterSpacing = spacing
        return copy
    }

    /// The font used to render every character.
    func rollingFont(_ font: Font) -> Self {
        var copy = self
        copy.fontDescriptor = RollingFontDescriptor(size: 24, weight: .bold, design: .default)
        copy.displayFont = font
        return copy
    }

    /// Convenience overload that builds a system font.
    func rollingFont(
        size: CGFloat,
        weight: Font.Weight = .bold,
        design: Font.Design = .default
    ) -> Self {
        var copy = self
        copy.fontDescriptor = RollingFontDescriptor(size: size, weight: weight, design: design)
        copy.displayFont = nil
        return copy
    }

    /// Color applied to every character.
    /// Default value: `.primary`.
    func rollingTextColor(_ color: Color) -> Self {
        var copy = self
        copy.textColor = color
        return copy
    }

    /// Optional `NumberFormatter` used to format the number before rendering.
    func rollingFormatter(_ formatter: NumberFormatter?) -> Self {
        var copy = self
        copy.formatter = formatter
        return copy
    }

    /// Configuration for the rolling spring animation.
    func rollingAnimationConfiguration(_ configuration: AnimationConfiguration) -> Self {
        var copy = self
        copy.animationConfiguration = configuration
        return copy
    }

    /// Controls layout when the formatted number exceeds the available width.
    /// Default value: `.scaleToFit`.
    func rollingOverflowMode(_ mode: OverflowMode) -> Self {
        var copy = self
        copy.overflowMode = mode
        return copy
    }

    /// Closure invoked after each rolling animation completes.
    /// Note: the closure may be called once per digit per change.
    func onRollingAnimationComplete(_ completion: @escaping () -> Void) -> Self {
        var copy = self
        copy.onAnimationComplete = completion
        return copy
    }
}
