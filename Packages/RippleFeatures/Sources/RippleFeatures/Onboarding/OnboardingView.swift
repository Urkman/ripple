import RippleDomain
import RippleUI
import SwiftUI

public struct OnboardingView: View {
    @Bindable var model: OnboardingViewModel
    private let onDone: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isCompleting = false
    @State private var isPerformingAction = false

    public init(model: OnboardingViewModel, onDone: @escaping () -> Void) {
        self.model = model
        self.onDone = onDone
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                OnboardingPageContent(model: model)
                    .id(model.page)
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, RippleSpace.xl)
                    .padding(.vertical, RippleSpace.lg)
            }
            .scrollIndicators(.hidden)

            footer
        }
        .background(RippleColor.surface.ignoresSafeArea())
        .task(id: model.page) {
            guard model.page == model.pageCount - 1 else { return }
            await model.refreshNotificationStatus()
        }
    }

    private var footer: some View {
        VStack(spacing: RippleSpace.md) {
            OnboardingProgressIndicator(
                currentPage: model.page,
                pageCount: model.pageCount
            )

            HStack(alignment: .center, spacing: RippleSpace.lg) {
                if model.canSkip {
                    Button(L10n.text("Skip")) {
                        advance()
                    }
                    .buttonStyle(.borderless)
                }

                Spacer(minLength: 0)

                Button(action: advance) {
                    if isBusy {
                        ProgressView()
                            .accessibilityLabel(L10n.text("Continue"))
                    } else {
                        Text(buttonTitle)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(RippleColor.waterLagoon)
                .controlSize(.large)
                .disabled(isBusy)
            }
        }
        .padding(.horizontal, RippleSpace.xl)
        .padding(.top, RippleSpace.sm)
        .padding(.bottom, RippleSpace.lg)
        .background(.ultraThinMaterial)
    }

    private var isBusy: Bool {
        isCompleting
            || isPerformingAction
            || model.isRequestingHealthAccess
            || model.isRequestingNotifications
            || model.isFinishing
    }

    private var buttonTitle: String {
        L10n.text("Continue")
    }

    private func advance() {
        guard !isBusy else { return }

        if model.page == 2 {
            isPerformingAction = true
            Task { @MainActor in
                defer { isPerformingAction = false }
                await model.requestHealthAccess()
                advancePage()
            }
            return
        }

        if model.page == model.pageCount - 1 {
            isCompleting = true
            isPerformingAction = true
            Task { @MainActor in
                defer { isPerformingAction = false }
                await model.requestNotifications()
                await model.finish()
                onDone()
            }
            return
        }

        advancePage()
    }

    private func advancePage() {
        guard model.page < model.pageCount - 1 else { return }
        withAnimation(reduceMotion ? nil : RippleMotion.springSnappy) {
            model.page += 1
        }
    }
}

private struct OnboardingProgressIndicator: View {
    let currentPage: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: RippleSpace.sm) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? RippleColor.waterLagoon
                            : RippleColor.waterDeep.opacity(0.18)
                    )
                    .frame(
                        width: index == currentPage ? RippleSpace.xl : RippleSpace.sm,
                        height: RippleSpace.xs
                    )
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.onboardingProgress(page: currentPage + 1))
    }
}

private struct OnboardingPreview: View {
    @State private var model: OnboardingViewModel

    init(
        page: Int,
        weightKg: Double? = nil,
        notificationStatus: NotificationAuthorizationStatus = .notDetermined
    ) {
        let model = OnboardingViewModel(useCases: RippleRuntime.preview)
        model.page = page
        model.notificationStatus = notificationStatus
        if let weightKg {
            model.healthWeightKg = weightKg
            model.healthWeightState = .found
            model.weightText = String(Int(weightKg))
        }
        _model = State(initialValue: model)
    }

    var body: some View {
        OnboardingView(model: model, onDone: {})
    }
}

#Preview("Onboarding · Welcome") {
    OnboardingPreview(page: 0)
}

#Preview("Onboarding · Apple Health") {
    OnboardingPreview(page: 2)
}

#Preview("Onboarding · Goal · 70 kg · Dark XXXL") {
    OnboardingPreview(page: 3, weightKg: 70)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.xxxLarge)
}

#Preview("Onboarding · Goal · No Health weight") {
    OnboardingPreview(page: 3)
}

#Preview("Onboarding · Reminders denied") {
    OnboardingPreview(page: 5, notificationStatus: .denied)
}
