import Foundation
import RippleDomain

extension IntakeRecord {
    func toDomain() -> Intake {
        Intake(
            id: id,
            date: date,
            amountMl: amountMl,
            beverage: Beverage(rawValue: beverageRaw) ?? .water,
            source: IntakeSource(rawValue: sourceRaw) ?? .app,
            containerId: containerId,
            note: note,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func apply(_ intake: Intake) {
        id = intake.id
        date = intake.date
        amountMl = intake.amountMl
        beverageRaw = intake.beverage.rawValue
        sourceRaw = intake.source.rawValue
        containerId = intake.containerId
        note = intake.note
        isDeleted = intake.isDeleted
        createdAt = intake.createdAt
        updatedAt = intake.updatedAt
    }
}

extension ContainerRecord {
    func toDomain() -> Container {
        Container(
            id: id,
            name: name,
            amountMl: amountMl,
            isDefault: isDefault,
            sort: sort,
            symbolName: symbolName,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func apply(_ container: Container) {
        id = container.id
        name = container.name
        amountMl = container.amountMl
        isDefault = container.isDefault
        sort = container.sort
        symbolName = container.symbolName
        createdAt = container.createdAt
        updatedAt = container.updatedAt
    }
}

extension GoalSettingsRecord {
    func toDomain() -> GoalSettings {
        GoalSettings(
            mode: GoalMode(rawValue: modeRaw) ?? .manual,
            manualGoalMl: manualGoalMl,
            updatedAt: updatedAt
        )
    }

    func apply(_ settings: GoalSettings) {
        modeRaw = settings.mode.rawValue
        manualGoalMl = settings.manualGoalMl
        updatedAt = settings.updatedAt
    }
}

extension ProfileRecord {
    func toDomain() -> Profile {
        Profile(
            preferredUnit: VolumeUnit(rawValue: preferredUnitRaw) ?? .milliliters,
            bodyMassKg: bodyMassKg,
            activityLevel: ActivityLevel(rawValue: activityLevelRaw) ?? .sedentary,
            wakeTime: ClockTime(hour: wakeHour, minute: wakeMinute),
            sleepTime: ClockTime(hour: sleepHour, minute: sleepMinute),
            remindersEnabled: remindersEnabled,
            healthReadWorkoutsEnabled: healthReadWorkoutsEnabled,
            healthWriteEnabled: healthWriteEnabled,
            hapticsEnabled: hapticsEnabled,
            liveActivityEnabled: liveActivityEnabled,
            onboardingCompleted: onboardingCompleted,
            updatedAt: updatedAt
        )
    }

    func apply(_ profile: Profile) {
        preferredUnitRaw = profile.preferredUnit.rawValue
        bodyMassKg = profile.bodyMassKg
        activityLevelRaw = profile.activityLevel.rawValue
        wakeHour = profile.wakeTime.hour
        wakeMinute = profile.wakeTime.minute
        sleepHour = profile.sleepTime.hour
        sleepMinute = profile.sleepTime.minute
        remindersEnabled = profile.remindersEnabled
        healthReadWorkoutsEnabled = profile.healthReadWorkoutsEnabled
        healthWriteEnabled = profile.healthWriteEnabled
        hapticsEnabled = profile.hapticsEnabled
        liveActivityEnabled = profile.liveActivityEnabled
        onboardingCompleted = profile.onboardingCompleted
        updatedAt = profile.updatedAt
    }
}

extension ReminderRuleRecord {
    func toDomain() -> ReminderRule {
        ReminderRule(
            enabled: enabled,
            start: ClockTime(hour: startHour, minute: startMinute),
            end: ClockTime(hour: endHour, minute: endMinute),
            intervalMinutes: intervalMinutes,
            afterLastSipMinutes: afterLastSipMinutes,
            updatedAt: updatedAt
        )
    }

    func apply(_ rule: ReminderRule) {
        enabled = rule.enabled
        startHour = rule.start.hour
        startMinute = rule.start.minute
        endHour = rule.end.hour
        endMinute = rule.end.minute
        intervalMinutes = rule.intervalMinutes
        afterLastSipMinutes = rule.afterLastSipMinutes
        updatedAt = rule.updatedAt
    }
}
