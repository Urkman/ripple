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
            OnboardingHealthPermissionPage()
        case 3:
            OnboardingGoalPage(
                weightText: $model.weightText,
                healthWeightState: model.healthWeightState,
                calculatedGoalMl: model.calculatedGoalMl,
                unit: model.profile.preferredUnit,
                usesWeight: model.goalUsesWeight
            )
        case 4:
            OnboardingContainersPage(unit: model.profile.preferredUnit)
        default:
            OnboardingRemindersPage(notificationStatus: model.notificationStatus)
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
                HStack(spacing: RippleSpace.sm) {
                    unitButton(VolumeUnit.milliliters, title: L10n.text("ml"))
                    unitButton(VolumeUnit.fluidOunces, title: L10n.text("fl oz"))
                }
                .accessibilityLabel(L10n.text("Units"))
            }
        }
    }

    private func unitButton(_ value: VolumeUnit, title: String) -> some View {
        let isSelected = unit == value

        return Button {
            unit = value
        } label: {
            Text(title)
                .font(RippleFont.callout.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : RippleColor.waterDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, RippleSpace.md)
                .background(
                    isSelected ? RippleColor.waterLagoon : RippleColor.waterFoam.opacity(0.7),
                    in: RoundedRectangle(cornerRadius: RippleRadius.control, style: .continuous)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct OnboardingHealthPermissionPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.lg) {
            OnboardingPageHeader(
                title: L10n.text("Connect Apple Health"),
                message: L10n.text(
                    "Ripple can use your latest Health weight for your goal and save the water you log to Health. Both permissions are requested together."
                )
            )

            GlassCard(title: L10n.text("Health")) {
                VStack(alignment: .leading, spacing: RippleSpace.md) {
                    OnboardingPermissionRow(
                        title: L10n.text("Read weight"),
                        message: L10n.text("Suggest a personal daily goal"),
                        systemImage: "scalemass"
                    )

                    Divider()

                    OnboardingPermissionRow(
                        title: L10n.text("Save logged water"),
                        message: L10n.text("Keep your Ripple entries in Health"),
                        systemImage: "arrow.up.heart"
                    )
                }
            }

            Text(
                L10n.text(
                    "Apple Health access is optional. Dismiss the system sheet to continue without it."
                )
            )
            .font(RippleFont.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct OnboardingGoalPage: View {
    @Binding var weightText: String
    let healthWeightState: HealthWeightState
    let calculatedGoalMl: Int
    let unit: VolumeUnit
    let usesWeight: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.lg) {
            OnboardingPageHeader(
                title: L10n.text("Set your daily goal"),
                message: L10n.text(
                    "Use your Health weight or enter it manually. You can change this later."
                )
            )

            healthWeightMessage

            GlassCard(title: L10n.text("Weight in kg")) {
                TextField(L10n.text("Weight in kg"), text: $weightText)
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
                    Text(
                        L10n.text(usesWeight ? "Based on your weight" : "Default goal")
                    )
                        .font(RippleFont.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var healthWeightMessage: some View {
        switch healthWeightState {
        case .found:
            Text(L10n.text("Health weight is ready."))
                .font(RippleFont.caption)
                .foregroundStyle(RippleColor.waterLagoon)
        case .unavailable:
            Text(
                L10n.text(
                    "No weight was available from Health. Enter it below or keep the default."
                )
            )
            .font(RippleFont.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        case .idle, .loading:
            EmptyView()
        }
    }
}

private struct OnboardingPermissionRow: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: RippleSpace.md) {
            Image(systemName: systemImage)
                .font(RippleFont.callout)
                .foregroundStyle(RippleColor.waterLagoon)
                .frame(width: RippleSpace.xl, height: RippleSpace.xl)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: RippleSpace.xs) {
                Text(title)
                    .font(RippleFont.callout.weight(.semibold))
                    .foregroundStyle(RippleColor.waterDeep)
                Text(message)
                    .font(RippleFont.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
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

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.lg) {
            OnboardingPageHeader(
                title: L10n.text("Reminders"),
                message: L10n.text("Reminders stay quiet outside your day.")
            )

            GlassCard {
                VStack(alignment: .leading, spacing: RippleSpace.md) {
                    Label(L10n.text("Allow reminders"), systemImage: "bell.badge")
                        .font(RippleFont.callout.weight(.semibold))
                        .foregroundStyle(RippleColor.waterDeep)

                    if notificationStatus.isAllowed {
                        Text(L10n.text("Reminders enabled"))
                            .font(RippleFont.caption)
                            .foregroundStyle(RippleColor.waterLagoon)
                    } else if notificationStatus == .denied {
                        Text(L10n.text("Notifications are off. You can change this in Settings."))
                            .font(RippleFont.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text(L10n.text("You can change this later in Settings."))
                            .font(RippleFont.caption)
                            .foregroundStyle(.secondary)
                    }
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
