#if DEBUG
import OSLog
import RippleData
import RippleDomain
import SwiftUI

struct WatchDemoDataGateView<Content: View>: View {
    private enum PreparationState {
        case preparing
        case ready
        case failed(Error)
    }

    private let useCases: UseCases
    private let content: () -> Content
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "de.stefansturm.ripple",
        category: "DemoData"
    )
    @State private var state: PreparationState = .preparing
    @State private var preparationAttempt = 0

    init(
        useCases: UseCases,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.useCases = useCases
        self.content = content
    }

    var body: some View {
        Group {
            switch state {
            case .preparing:
                ProgressView()
                    .controlSize(.large)
            case .ready:
                content()
            case .failed(let error):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title3)
                    Text("Demo data setup failed")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        state = .preparing
                        preparationAttempt += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: preparationAttempt) {
            await prepare()
        }
    }

    private func prepare() async {
        do {
            try await DemoDataSeeder().seed(
                using: useCases,
                now: Date(),
                calendar: .current,
                locale: .current
            )
            state = .ready
        } catch is CancellationError {
            return
        } catch {
            logger.error("Demo data preparation failed: \(error.localizedDescription, privacy: .public)")
            state = .failed(error)
        }
    }
}
#endif
