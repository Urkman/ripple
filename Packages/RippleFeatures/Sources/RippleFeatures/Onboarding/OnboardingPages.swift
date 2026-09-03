import RippleDomain
import RippleUI
import SwiftUI

struct OnboardingPageContent: View {
    @Bindable var model: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.xxl) {
            OnboardingArtwork(stage: model.page)
                .frame(maxWidth: .infinity)

            page
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var page: some View {
        switch model.page {
        case 0:
            OnboardingWelcomePage()
        case 1:
            OnboardingUnitsPage(unit: $model.profile.preferredUnit)
        case 2:
            OnboardingHealthGoalPage(
                weightText: $model.weightText,
                healthWeightState: model.healthWeightState,
                calculatedGoalMl: model.calculatedGoalMl,
                unit: model.profile.preferredUnit,
                isRequestingHealthWeight: model.isRequestingHealthWeight,
                requestHealthWeight: {
                    Task { @MainActor in
                        await model.requestHealthWeight()
                    }
                }
            )
        case 3:
            OnboardingContainersPage(unit: model.profile.preferredUnit)
        default:
            OnboardingRemindersPage(
                notificationStatus: model.notificationStatus,
                healthWrite: model.healthWrite,
                isRequestingNotifications: model.isRequestingNotifications,
                isRequestingWaterWrite: model.isRequestingWaterWrite,
                requestNotifications: {
                    Task { @MainActor in
                        await model.requestNotifications()
                    }
                },
                requestWaterWrite: {
                    Task { @MainActor in
                        await model.requestWaterWrite()
                    }
                }
            )
        }
    }
}

private struct OnboardingWelcomePage: View {
    var body: some View {
        OnboardingPageHeader(
            title: L10n.text("Make Ripple yours."),
            message: L10n.text(
                "Log a sip from the widget, Watch, Siri, or here. Ripple stays calm and out of the way."
            )
        )
    }
}

private struct OnboardingUnitsPage: View {
    @Binding var unit: VolumeUnit

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.lg) {
            OnboardingPageHeader(
                title: L10n.text("Choose your unit"),
                message: L10n.text("Milliliters or fluid ounces. You can change this later.")
            )

            GlassCard(title: L10n.text("Units")) {
                Picker(L10n.text("Units"), selection: $unit) {
                    Text(L10n.text("ml")).tag(VolumeUnit.milliliters)
                    Text(L10n.text("fl oz")).tag(VolumeUnit.fluidOunces)
                }
                .pickerStyle(.segmented)
                .accessibilityLabel(L10n.text("Units"))
            }
        }
    }
}

private struct OnboardingHealthGoalPage: View {
    @Binding var weightText: String
    let healthWeightState: HealthWeightState
    let calculatedGoalMl: Int
    let unit: VolumeUnit
    let isRequestingHealthWeight: Bool
    let requestHealthWeight: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.lg) {
            OnboardingPageHeader(
                title: L10n.text("Use Apple Health weight"),
                message: L10n.text(
                    "Ripple can use your latest Health weight to suggest a personal daily goal."
                )
            )

            GlassCard {
                VStack(alignment: .leading, spacing: RippleSpace.md) {
                    Label(
                        L10n.text("Use Apple Health weight"),
                        systemImage: "heart.text.square"
                    )
                    .font(RippleFont.callout.weight(.semibold))
                    .foregroundStyle(RippleColor.waterDeep)

                    Button(action: requestHealthWeight) {
                        if isRequestingHealthWeight {
                            ProgressView()
                                .accessibilityLabel(L10n.text("Use Apple Health weight"))
                        } else if healthWeightState == .found {
                            Label(L10n.text("Use Health weight"), systemImage: "checkmark")
                        } else {
                            Label(
                                L10n.text("Use Apple Health weight"),
                                systemImage: "arrow.down"
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isRequestingHealthWeight)

                    if healthWeightState == .unavailable {
                        Text(
                            L10n.text(
                                "No weight found in Health. You can enter it below instead."
                            )
                        )
                        .font(RippleFont.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            GlassCard(title: L10n.text("Weight in kg")) {
                TextField(L10n.text("Weight in kg"), text: $weightText)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel(L10n.text("Weight in kg"))
            }

            GlassCard {
                VStack(alignment: .leading, spacing: RippleSpace.sm) {
                    Text(L10n.text("Calculated daily goal"))
                        .font(RippleFont.callout.weight(.semibold))
                        .foregroundStyle(RippleColor.waterDeep)
                    Text(
                        VolumeFormatter.current.string(
                            milliliters: calculatedGoalMl,
                            unit: unit
                        )
                    )
                    .font(RippleFont.display)
                    .foregroundStyle(RippleColor.waterLagoon)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    Text(L10n.text("Based on your weight"))
                        .font(RippleFont.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct OnboardingContainersPage: View {
    let unit: VolumeUnit

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.lg) {
            OnboardingPageHeader(
                title: L10n.text("Glass, cup, bottle"),
                message: L10n.text(
                    "Quick add starts with 250, 200 and 500 milliliters. Edit them any time."
                )
            )

            GlassCard {
                VStack(alignment: .leading, spacing: RippleSpace.lg) {
                    HStack(spacing: RippleSpace.sm) {
                        ForEach([250, 200, 500], id: \.self) { amount in
                            Text(
                                VolumeFormatter.current.string(
                                    milliliters: amount,
                                    unit: unit
                                )
                            )
                            .font(RippleFont.callout.monospacedDigit())
                            .foregroundStyle(RippleColor.waterDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RippleSpace.sm)
                            .background(
                                RippleColor.waterAqua.opacity(0.18),
                                in: Capsule()
                            )
                        }
                    }

                    Text(
                        L10n.text(
                            "Quick add starts with 250, 200 and 500 milliliters. Edit them any time."
                        )
                    )
                    .font(RippleFont.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct OnboardingRemindersPage: View {
    let notificationStatus: NotificationAuthorizationStatus
    let healthWrite: Bool
    let isRequestingNotifications: Bool
    let isRequestingWaterWrite: Bool
    let requestNotifications: () -> Void
    let requestWaterWrite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.lg) {
            OnboardingPageHeader(
                title: L10n.text("Your goal, your way"),
                message: L10n.text("Reminders stay quiet outside your day.")
            )

            GlassCard {
                VStack(alignment: .leading, spacing: RippleSpace.md) {
                    Label(L10n.text("Allow reminders"), systemImage: "bell.badge")
                        .font(RippleFont.callout.weight(.semibold))
                        .foregroundStyle(RippleColor.waterDeep)
                    Text(L10n.text("You can change this later in Settings."))
                        .font(RippleFont.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if notificationStatus == .denied {
                        Text(L10n.text("Notifications are off. You can change this in Settings."))
                            .font(RippleFont.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Button(action: requestNotifications) {
                            if isRequestingNotifications {
                                ProgressView()
                                    .accessibilityLabel(L10n.text("Allow reminders"))
                            } else if notificationStatus.isAllowed {
                                Label(L10n.text("Reminders enabled"), systemImage: "checkmark")
                            } else {
                                Label(L10n.text("Allow reminders"), systemImage: "bell.badge")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isRequestingNotifications || notificationStatus.isAllowed)
                    }
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: RippleSpace.md) {
                    Label(
                        L10n.text("Allow Ripple to write water to Health"),
                        systemImage: "heart"
                    )
                    .font(RippleFont.callout.weight(.semibold))
                    .foregroundStyle(RippleColor.waterDeep)
                    Text(L10n.text("Water logging in Health is optional."))
                        .font(RippleFont.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: requestWaterWrite) {
                        if isRequestingWaterWrite {
                            ProgressView()
                                .accessibilityLabel(
                                    L10n.text("Allow Ripple to write water to Health")
                                )
                        } else if healthWrite {
                            Label(L10n.text("Water write enabled"), systemImage: "checkmark")
                        } else {
                            Label(
                                L10n.text("Allow Ripple to write water to Health"),
                                systemImage: "arrow.up"
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isRequestingWaterWrite || healthWrite)
                }
            }
        }
    }
}

private struct OnboardingPageHeader: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.md) {
            Text(title)
                .font(RippleFont.title)
                .foregroundStyle(RippleColor.waterDeep)
                .fixedSize(horizontal: false, vertical: true)
            Text(message)
                .font(RippleFont.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
