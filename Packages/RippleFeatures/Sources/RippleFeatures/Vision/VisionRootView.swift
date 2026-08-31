import RippleDomain
import RippleUI
import SwiftUI

#if os(visionOS)
public struct VisionRootView: View {
    @State private var model: TodayViewModel

    public init(useCases: UseCases) {
        _model = State(initialValue: TodayViewModel(useCases: useCases))
    }

    public var body: some View {
        TodayView(model: model)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                HStack {
                    ForEach(model.snapshot.containers.prefix(3)) { container in
                        Button(container.name, systemImage: container.symbolName) {
                            Task { await model.add(container: container) }
                        }
                    }
                    Button("+ \(model.snapshot.defaultAddMl) ml") {
                        Task { await model.addDefault() }
                    }
                    .buttonStyle(.glassProminent)
                }
                .padding()
            }
    }
}
#endif
