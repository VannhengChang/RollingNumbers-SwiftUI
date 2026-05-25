import RollingNumbers
import SwiftUI

struct ContentView: View {

    @State private var number: Double = 1234.56
    @State private var textInput = "1234.56"
    @FocusState private var isInputFocused: Bool

    @State private var animationType: RollingNumbersView.AnimationType = .allNumbers
    @State private var directionOption: DirectionOption = .auto
    @State private var alignment: RollingNumbersView.Alignment = .center
    @State private var fontSize: Double = 48
    @State private var useCurrency = false
    @State private var animationSpeed: Double = 1.0
    @State private var characterSpacing: Double = 1.0
    @State private var overflowMode: RollingNumbersView.OverflowMode = .scaleToFit

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    displaySection
                    inputSection
                    presetSection
                    configurationSection
                }
                .padding()
            }
            .navigationTitle("RollingNumbers")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }

    // MARK: - Display

    private var displaySection: some View {
        VStack(spacing: 12) {
            Text("Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)

            RollingNumbersView(number: number)
                .rollingAnimationType(animationType)
                .rollingDirection(directionOption.rollingDirection)
                .rollingAlignment(alignment)
                .rollingCharacterSpacing(CGFloat(characterSpacing))
                .rollingFont(size: CGFloat(fontSize), weight: .medium)
                .rollingTextColor(.primary)
                .rollingFormatter(useCurrency ? currencyFormatter : nil)
                .rollingAnimationConfiguration(
                    .init(duration: 1, speed: animationSpeed, damping: 17, initialVelocity: 1)
                )
                .rollingOverflowMode(overflowMode)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(displayBackgroundColor)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    isInputFocused = true
                }

            Text("Raw value: \(number, specifier: "%.2f")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Input

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Number Input")

            TextField("Enter a number", text: $textInput)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .onChange(of: textInput) { newValue in
                    applyTextInput(newValue)
                }

            Text("Tap the display or use the field above. Digits roll as the parsed value changes.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Presets

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Quick Actions")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                presetButton("+100") { applyNumber(number + 100) }
                presetButton("-100") { applyNumber(number - 100) }
                presetButton("Random") { applyNumber(.random(in: 0...999_999_999.99)) }
                presetButton("Long") { applyNumber(123_456_789.99) }
                presetButton("Reset") { applyNumber(0) }
            }
        }
    }

    // MARK: - Configuration

    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Configuration")

            VStack(alignment: .leading, spacing: 8) {
                Text("Animation Type")
                    .font(.subheadline.weight(.medium))
                Picker("Animation Type", selection: $animationType) {
                    Text("All Numbers").tag(RollingNumbersView.AnimationType.allNumbers)
                    Text("Only Changed").tag(RollingNumbersView.AnimationType.onlyChangedNumbers)
                    Text("After First Change").tag(RollingNumbersView.AnimationType.allAfterFirstChangedNumber)
                    Text("No Animation").tag(RollingNumbersView.AnimationType.noAnimation)
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Direction")
                    .font(.subheadline.weight(.medium))
                Picker("Direction", selection: $directionOption) {
                    ForEach(DirectionOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Alignment")
                    .font(.subheadline.weight(.medium))
                Picker("Alignment", selection: $alignment) {
                    Text("Leading").tag(RollingNumbersView.Alignment.leading)
                    Text("Center").tag(RollingNumbersView.Alignment.center)
                    Text("Trailing").tag(RollingNumbersView.Alignment.trailing)
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Overflow")
                    .font(.subheadline.weight(.medium))
                Picker("Overflow", selection: $overflowMode) {
                    Text("Scale to Fit").tag(RollingNumbersView.OverflowMode.scaleToFit)
                    Text("Scroll").tag(RollingNumbersView.OverflowMode.scroll)
                }
                .pickerStyle(.segmented)
            }

            Toggle("Currency Formatter", isOn: $useCurrency)

            VStack(alignment: .leading, spacing: 4) {
                Text("Font Size: \(Int(fontSize))")
                    .font(.subheadline.weight(.medium))
                Slider(value: $fontSize, in: 24...72, step: 2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Animation Speed: \(animationSpeed, specifier: "%.1f")")
                    .font(.subheadline.weight(.medium))
                Slider(value: $animationSpeed, in: 0.2...2.0, step: 0.1)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Character Spacing: \(characterSpacing, specifier: "%.1f")")
                    .font(.subheadline.weight(.medium))
                Slider(value: $characterSpacing, in: 0.5...2.0, step: 0.1)
            }
        }
    }

    // MARK: - Helpers

    private var displayBackgroundColor: Color {
        #if os(iOS)
        Color(.secondarySystemBackground)
        #elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color.gray.opacity(0.15)
        #endif
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }

    private func presetButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
    }

    private func applyTextInput(_ raw: String) {
        let cleaned = raw
            .replacingOccurrences(of: ",", with: "")
            .filter { $0.isNumber || $0 == "." || $0 == "-" }

        guard !cleaned.isEmpty, let parsed = Double(cleaned) else { return }
        number = parsed
    }

    private func applyNumber(_ value: Double) {
        number = value
        textInput = formatInputText(value)
    }

    private func formatInputText(_ value: Double) -> String {
        guard value.isFinite else { return "0" }

        let rounded = value.rounded()
        if value == rounded {
            if let intValue = Int(exactly: rounded) {
                return String(intValue)
            }
            return NSDecimalNumber(value: value).stringValue
        }

        return String(value)
    }
}

private enum DirectionOption: String, CaseIterable, Identifiable {
    case auto
    case up
    case down

    var id: String { rawValue }

    var title: String {
        switch self {
        case .auto: return "Auto"
        case .up: return "Up"
        case .down: return "Down"
        }
    }

    var rollingDirection: RollingNumbersView.RollingDirection? {
        switch self {
        case .auto: return nil
        case .up: return .up
        case .down: return .down
        }
    }
}

#Preview {
    ContentView()
}
