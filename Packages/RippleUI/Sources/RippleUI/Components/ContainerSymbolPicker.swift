import SwiftUI

public struct ContainerSymbolOption: Identifiable, Equatable, Sendable {
    public let symbolName: String
    public let title: String

    public var id: String { symbolName }

    public init(symbolName: String, title: String) {
        self.symbolName = symbolName
        self.title = title
    }
}

public struct ContainerSymbolPicker: View {
    @Binding private var selection: String

    private let label: String
    private let options: [ContainerSymbolOption]

    public init(
        label: String,
        selection: Binding<String>,
        options: [ContainerSymbolOption]
    ) {
        self.label = label
        _selection = selection
        self.options = options
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: RippleSpace.sm) {
                ForEach(options) { option in
                    Button {
                        selection = option.symbolName
                    } label: {
                        Image(systemName: option.symbolName)
                            .font(.title3)
                            .foregroundStyle(
                                option.symbolName == selection
                                    ? RippleColor.waterLagoon
                                    : RippleColor.waterDeep
                            )
                            .symbolRenderingMode(.hierarchical)
                            .frame(
                                width: RippleLayout.minimumControlDimension,
                                height: RippleLayout.minimumControlDimension
                            )
                            .contentShape(
                                RoundedRectangle(
                                    cornerRadius: RippleRadius.control,
                                    style: .continuous
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(
                            cornerRadius: RippleRadius.control,
                            style: .continuous
                        )
                        .fill(
                            option.symbolName == selection
                                ? RippleColor.waterLagoon.opacity(0.14)
                                : .clear
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: RippleRadius.control,
                            style: .continuous
                        )
                        .stroke(
                            option.symbolName == selection
                                ? RippleColor.waterLagoon
                                : RippleColor.waterDeep.opacity(0.14),
                            lineWidth: 1
                        )
                    }
                    .accessibilityLabel(option.title)
                    .accessibilityAddTraits(
                        option.symbolName == selection ? .isSelected : []
                    )
                }
            }
            .padding(.vertical, RippleSpace.xs)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label)
    }
}

#Preview("Container symbol picker") {
    ContainerSymbolPickerPreview()
        .padding()
}

#Preview("Container symbol picker · Dark XXXL") {
    ContainerSymbolPickerPreview()
        .padding()
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}

private struct ContainerSymbolPickerPreview: View {
    @State private var selection = "cup.and.saucer.fill"

    private let options = [
        ContainerSymbolOption(symbolName: "cup.and.saucer.fill", title: "Glass"),
        ContainerSymbolOption(symbolName: "mug.fill", title: "Cup"),
        ContainerSymbolOption(symbolName: "waterbottle.fill", title: "Bottle"),
    ]

    var body: some View {
        ContainerSymbolPicker(
            label: "Icon",
            selection: $selection,
            options: options
        )
    }
}
