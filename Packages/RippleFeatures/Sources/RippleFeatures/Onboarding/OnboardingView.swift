import RippleDomain
import RippleUI
import SwiftUI

@MainActor
@Observable
public final class OnboardingViewModel {
    public var page = 0
    public var profile: Profile
    public var weightText = ""
    public var liveActivity = true
    public var healthWrite = false

    @ObservationIgnored private let useCases: UseCases

    public init(useCases: UseCases) {
        self.useCases = useCases
        self.profile = .fresh()
    }

    public var canSkip: Bool { page != 1 }

    public func finish() async {
        if let weight = Double(weightText.replacingOccurrences(of: ",", with: ".")), weight > 0 {
            profile.bodyMassKg = weight
        }
        profile.liveActivityEnabled = liveActivity
        profile.healthWriteEnabled = healthWrite
        profile.onboardingCompleted = true
        try? await useCases.settingsRepository.seedDefaultsIfNeeded(locale: .current)
        try? await useCases.updateProfile.run(profile)
        if profile.bodyMassKg != nil {
            try? await useCases.updateGoal.run(mode: .calculated)
        } else {
            try? await useCases.updateGoal.run(mode: .manual, manualGoalMl: 2000)
        }
        if healthWrite {
            _ = await useCases.healthAuthorizing.requestWaterWrite()
        }
        if liveActivity {
            try? await useCases.startOrUpdateLiveActivity.run()
        }
    }
}

public struct OnboardingView: View {
    @Bindable var model: OnboardingViewModel
    var onDone: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(model: OnboardingViewModel, onDone: @escaping () -> Void) {
        self.model = model
        self.onDone = onDone
    }

    public var body: some View {
        VStack(spacing: 24) {
            pageContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(model.page)

            pageDots

            HStack {
                if model.canSkip {
                    Button(L10n.text("Skip")) { advance() }
                }
                Spacer()
                Button(model.page == 4 ? L10n.text("Done") : L10n.text("Continue")) {
                    advance()
                }
                .buttonStyle(.borderedProminent)
                .tint(RippleColor.waterLagoon)
                #if os(iOS) || os(visionOS)
                .controlSize(.extraLarge)
                #endif
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(RippleColor.surface.ignoresSafeArea())
        .animation(reduceMotion ? nil : RippleMotion.springSnappy, value: model.page)
    }

    @ViewBuilder
    private var pageContent: some View {
        switch model.page {
        case 0: welcome
        case 1: units
        case 2: goal
        case 3: containers
        default: extras
        }
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(index == model.page ? RippleColor.waterLagoon : Color.secondary.opacity(0.35))
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(model.page + 1) of 5")
    }

    private var welcome: some View {
        onboardingPage(
            title: L10n.text("Hydration that follows you."),
            body: L10n.text("Log a sip from the widget, Watch, Siri, or here. Ripple stays calm and out of the way.")
        )
    }

    private var units: some View {
        VStack(spacing: 16) {
            onboardingPage(
                title: L10n.text("Choose your unit"),
                body: L10n.text("Milliliters or fluid ounces. You can change this later.")
            )
            Picker(L10n.text("Units"), selection: $model.profile.preferredUnit) {
                Text("ml").tag(VolumeUnit.milliliters)
                Text("fl oz").tag(VolumeUnit.fluidOunces)
            }
            #if os(watchOS)
            .pickerStyle(.automatic)
            #else
            .pickerStyle(.segmented)
            #endif
            .padding(.horizontal, 24)
            .accessibilityLabel(L10n.text("Units"))
        }
    }

    private var goal: some View {
        VStack(spacing: 16) {
            onboardingPage(
                title: L10n.text("A 2 liter default"),
                body: L10n.text("Enter your weight if you want a calculated goal. This is not medical advice.")
            )
            TextField(L10n.text("Weight in kg (optional)"), text: $model.weightText)
                #if os(watchOS)
                .textFieldStyle(.plain)
                #else
                .textFieldStyle(.roundedBorder)
                #endif
                .padding(.horizontal, 24)
        }
    }

    private var containers: some View {
        onboardingPage(
            title: L10n.text("Glass, cup, bottle"),
            body: L10n.text("Quick add starts with 250, 200 and 500 milliliters. Edit them any time.")
        )
    }

    private var extras: some View {
        VStack(alignment: .leading, spacing: 16) {
            onboardingPage(
                title: L10n.text("iCloud, Health, widgets"),
                body: L10n.text("Sync uses your Apple Account. Health write is optional. Add the widget when you like.")
            )
            Toggle(L10n.text("Write water to Health"), isOn: $model.healthWrite)
                .padding(.horizontal, 24)
            Toggle(L10n.text("Live Activity"), isOn: $model.liveActivity)
                .padding(.horizontal, 24)
        }
    }

    private func onboardingPage(title: String, body: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.system(size: 48))
                .foregroundStyle(RippleColor.waterLagoon)
            Text(title)
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }

    private func advance() {
        if model.page < 4 {
            model.page += 1
        } else {
            Task {
                await model.finish()
                onDone()
            }
        }
    }
}
