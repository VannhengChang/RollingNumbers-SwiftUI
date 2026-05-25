import SwiftUI

/// A SwiftUI view that displays a number with a smooth rolling animation
/// between digit changes.
///
/// `RollingNumbersView` is the SwiftUI counterpart of the original UIKit
/// `RollingNumbersView`. It is fully declarative — the view animates
/// automatically whenever the value passed in `init(number:)` changes.
///
/// ```swift
/// @State private var balance: Double = 0
///
/// var body: some View {
///     RollingNumbersView(number: balance)
///         .rollingFont(size: 48, weight: .medium)
///         .rollingTextColor(.primary)
///         .rollingAnimationType(.allAfterFirstChangedNumber)
///         .rollingDirection(.up)
/// }
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct RollingNumbersView: View {

    // MARK: - Public types

    /// Animation that affects how digits roll when the number changes.
    public enum AnimationType: Hashable {
        /// All digits roll, even if only one digit changed.
        case allNumbers
        /// Only the digits that actually changed roll.
        case onlyChangedNumbers
        /// All digits at and after the first changed digit roll.
        case allAfterFirstChangedNumber
        /// Digits update without any animation.
        case noAnimation
    }

    /// Direction the digits roll in.
    public enum RollingDirection: Hashable {
        /// Digits roll from bottom to top (counting up visually).
        case up
        /// Digits roll from top to bottom (counting down visually).
        case down
    }

    /// Horizontal alignment of the rendered number inside the view.
    public enum Alignment: Hashable {
        case leading
        case center
        case trailing
    }

    /// How the view behaves when the formatted number is wider than
    /// the available space.
    public enum OverflowMode: Hashable {
        /// Uniformly scales the number down to fit. Default.
        case scaleToFit
        /// Allows horizontal scrolling to reveal clipped digits.
        case scroll
    }

    /// Configuration for the spring animation used when digits roll.
    ///
    /// The values mirror the parameters of `CASpringAnimation` used by the
    /// original UIKit implementation and are mapped onto SwiftUI's
    /// `interpolatingSpring` animation.
    public struct AnimationConfiguration: Hashable {

        /// Maximum animation duration. Used to clamp the spring's settle time
        /// via `Animation.speed`.
        public var duration: Double

        /// Animation speed multiplier. Default value: `0.3`.
        public var speed: Double

        /// Spring damping. Default value: `17`.
        public var damping: Double

        /// Initial spring velocity. Default value: `1`.
        public var initialVelocity: Double

        public init(
            duration: Double = 1,
            speed: Double = 0.3,
            damping: Double = 17,
            initialVelocity: Double = 1
        ) {
            self.duration = duration
            self.speed = speed
            self.damping = damping
            self.initialVelocity = initialVelocity
        }

        /// Returns the corresponding SwiftUI `Animation`.
        public var animation: Animation {
            Animation
                .interpolatingSpring(
                    mass: 1,
                    stiffness: 100,
                    damping: damping,
                    initialVelocity: initialVelocity
                )
                .speed(speed)
        }
    }

    // MARK: - Configuration (mutated through View modifiers below)

    let number: Double

    var animationType: AnimationType = .allAfterFirstChangedNumber
    var rollingDirection: RollingDirection?
    var horizontalAlignment: Alignment = .leading
    var characterSpacing: CGFloat = 1
    var fontDescriptor: RollingFontDescriptor = .default
    var displayFont: Font?
    var textColor: Color = .primary
    var formatter: NumberFormatter?
    var animationConfiguration: AnimationConfiguration = .init()
    var overflowMode: OverflowMode = .scaleToFit
    var onAnimationComplete: (() -> Void)?

    // MARK: - State

    @State private var previousText: String = ""

    // MARK: - Init

    /// Create a `RollingNumbersView` displaying the given number.
    /// - Parameter number: The numeric value to render.
    public init(number: Double) {
        self.number = number
    }

    // MARK: - Derived values

    /// Text representation of the number, applying `formatter` when set.
    var text: String {
        if let formatter = formatter {
            return formatter.string(from: NSNumber(value: number)) ?? defaultText
        }
        return defaultText
    }

    private var defaultText: String {
        Self.stringRepresentation(for: number)
    }

    static func stringRepresentation(for number: Double) -> String {
        guard number.isFinite else { return "0" }

        let rounded = number.rounded()
        if number == rounded {
            if let intValue = Int(exactly: rounded) {
                return String(intValue)
            }
            return NSDecimalNumber(value: number).stringValue
        }

        return String(number)
    }

    private var lineHeight: CGFloat {
        fontDescriptor.lineHeight()
    }

    private var swiftUIFont: Font {
        displayFont ?? fontDescriptor.font
    }

    private var swiftUIAlignment: SwiftUI.Alignment {
        switch horizontalAlignment {
        case .leading:  return .leading
        case .center:   return .center
        case .trailing: return .trailing
        }
    }

    private func charWidth(_ char: Character) -> CGFloat {
        fontDescriptor.charWidth(char, spacing: characterSpacing)
    }

    // MARK: - Element resolution

    fileprivate struct Element: Identifiable {
        let id: Int
        let char: Character
        let width: CGFloat
        let digit: Int?
        let shouldAnimate: Bool
        let direction: RollingDirection
    }

    private func defaultDirection(for prevText: String) -> RollingDirection {
        let prev = Double(prevText.filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? number
        return number < prev ? .down : .up
    }

    private func computeElements(currentText: String, prevText: String) -> [Element] {
        let currentChars = Array(currentText)
        let prevChars = Array(prevText)

        let currentDigits: [Int?] = currentChars.map { Int(String($0)) }
        let prevDigits: [Int?] = prevChars.map { Int(String($0)) }

        let firstChangedIndex: Int? = {
            guard animationType == .allAfterFirstChangedNumber else { return nil }
            let maxCount = max(currentDigits.count, prevDigits.count)
            for i in 0..<maxCount {
                let current = i < currentDigits.count ? currentDigits[i] : nil
                let prev = i < prevDigits.count ? prevDigits[i] : nil
                if current != prev { return i }
            }
            return nil
        }()

        let direction = rollingDirection ?? defaultDirection(for: prevText)
        let isInitial = prevText.isEmpty

        return currentChars.enumerated().map { index, char in
            let digit = currentDigits[index]
            let prevDigit: Int? = index < prevDigits.count ? prevDigits[index] : nil

            var shouldAnimate = false
            if !isInitial, digit != nil {
                switch animationType {
                case .allNumbers:
                    shouldAnimate = true
                case .onlyChangedNumbers:
                    shouldAnimate = prevDigit != digit
                case .allAfterFirstChangedNumber:
                    if let firstChangedIndex = firstChangedIndex, index >= firstChangedIndex {
                        shouldAnimate = true
                    }
                case .noAnimation:
                    shouldAnimate = false
                }
            }

            return Element(
                id: index,
                char: char,
                width: charWidth(char),
                digit: digit,
                shouldAnimate: shouldAnimate,
                direction: direction
            )
        }
    }

    private var scaleAnchor: UnitPoint {
        switch horizontalAlignment {
        case .leading:  return .leading
        case .center:   return .center
        case .trailing: return .trailing
        }
    }

    private func totalWidth(for elements: [Element]) -> CGFloat {
        elements.reduce(0) { $0 + $1.width }
    }

    @ViewBuilder
    private func rollingContent(
        elements: [Element],
        animation: Animation
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(elements) { element in
                if let digit = element.digit {
                    DigitColumnView(
                        targetDigit: digit,
                        direction: element.direction,
                        width: element.width,
                        height: lineHeight,
                        font: swiftUIFont,
                        color: textColor,
                        animation: element.shouldAnimate ? animation : nil,
                        animateOnAppear: element.shouldAnimate,
                        onAnimationComplete: onAnimationComplete
                    )
                    .id(element.id)
                } else {
                    Text(String(element.char))
                        .font(swiftUIFont)
                        .foregroundColor(textColor)
                        .frame(width: element.width, height: lineHeight, alignment: .center)
                }
            }
        }
    }

    // MARK: - Body

    public var body: some View {
        let currentText = self.text
        let elements = computeElements(currentText: currentText, prevText: previousText)
        let animation = animationConfiguration.animation
        let contentWidth = totalWidth(for: elements)

        Group {
            switch overflowMode {
            case .scaleToFit:
                GeometryReader { geometry in
                    let scale = contentWidth > 0
                        ? min(1, geometry.size.width / contentWidth)
                        : 1

                    rollingContent(elements: elements, animation: animation)
                        .scaleEffect(scale, anchor: scaleAnchor)
                        .frame(
                            width: geometry.size.width,
                            height: lineHeight,
                            alignment: swiftUIAlignment
                        )
                }
            case .scroll:
                ScrollView(.horizontal, showsIndicators: false) {
                    rollingContent(elements: elements, animation: animation)
                        .frame(width: contentWidth, height: lineHeight, alignment: swiftUIAlignment)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: lineHeight)
        .clipped()
        .onAppear {
            if previousText.isEmpty {
                previousText = currentText
            }
        }
        .onChange(of: currentText) { newValue in
            // Defer so digit columns still see the previous value and
            // `shouldAnimate == true` on the frame where the change occurs.
            DispatchQueue.main.async {
                previousText = newValue
            }
        }
    }
}
