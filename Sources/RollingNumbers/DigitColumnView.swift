import SwiftUI

/// Internal view that renders a single rolling digit column.
///
/// The column stacks two cycles of `0...9` (so 20 cells in total) and rolls
/// through exactly ten cells on every digit change. Before each animation the
/// offset is reset (without animation) to the column's `start` position for
/// the new digit, and is then animated to the matching `end` position. This
/// mirrors the strategy used by the original UIKit implementation.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct DigitColumnView: View {

    let targetDigit: Int
    let direction: RollingNumbersView.RollingDirection
    let width: CGFloat
    let height: CGFloat
    let font: Font
    let color: Color
    let animation: Animation?
    let animateOnAppear: Bool
    let onAnimationComplete: (() -> Void)?

    @State private var offset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<20, id: \.self) { index in
                Text(String(index % 10))
                    .font(font)
                    .foregroundColor(color)
                    .frame(width: width, height: height, alignment: .center)
            }
        }
        .frame(width: width, height: height, alignment: .top)
        .offset(y: offset)
        .clipped()
        .frame(width: width, height: height)
        .onAppear {
            if animateOnAppear, let animation = animation {
                performAnimation(to: targetDigit, using: animation)
            } else {
                offset = endOffset(for: targetDigit)
            }
        }
        .onChange(of: targetDigit) { newDigit in
            performAnimation(to: newDigit)
        }
        .onChange(of: direction) { _ in
            offset = endOffset(for: targetDigit)
        }
    }

    private func performAnimation(to newDigit: Int) {
        guard let animation = animation else {
            offset = endOffset(for: newDigit)
            return
        }
        performAnimation(to: newDigit, using: animation)
    }

    private func performAnimation(to newDigit: Int, using animation: Animation) {
        var noAnimationTransaction = Transaction()
        noAnimationTransaction.disablesAnimations = true
        withTransaction(noAnimationTransaction) {
            offset = startOffset(for: newDigit)
        }

        DispatchQueue.main.async {
            withAnimation(animation) {
                offset = endOffset(for: newDigit)
            }
            if let onAnimationComplete = onAnimationComplete {
                let delay = estimatedSettleTime(for: animation)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    onAnimationComplete()
                }
            }
        }
    }

    /// Position that shows `digit` at the top of the column.
    private func startOffset(for digit: Int) -> CGFloat {
        switch direction {
        case .up:   return -CGFloat(digit) * height
        case .down: return -CGFloat(digit + 10) * height
        }
    }

    /// Position that shows `digit` at the top of the column after rolling
    /// through ten cells.
    private func endOffset(for digit: Int) -> CGFloat {
        switch direction {
        case .up:   return -CGFloat(digit + 10) * height
        case .down: return -CGFloat(digit) * height
        }
    }

    /// Best-effort estimation used purely to schedule the completion handler;
    /// SwiftUI does not expose an animation completion API on iOS 14.
    private func estimatedSettleTime(for _: Animation) -> TimeInterval {
        return 0.6
    }
}
