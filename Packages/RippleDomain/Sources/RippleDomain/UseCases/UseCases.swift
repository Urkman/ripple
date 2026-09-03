import Foundation

public struct UseCases: Sendable {
    public var logIntake: LogIntake
    public var undoLastIntake: UndoLastIntake
    public var editIntake: EditIntake
    public var deleteIntake: DeleteIntake
    public var observeToday: ObserveToday
    public var observeHistory: ObserveHistory
    public var observeMonth: ObserveMonth
    public var observeStats: ObserveStats
    public var restoreIntake: RestoreIntake
    public var updateGoal: UpdateGoal
    public var calculateGoal: CalculateGoal
    public var updateProfile: UpdateProfile
    public var upsertContainer: UpsertContainer
    public var deleteContainer: DeleteContainer
    public var exportData: ExportData
    public var rescheduleReminders: RescheduleReminders
    public var healthAuthorizing: any HealthAuthorizing
    public var requestHealthReadAccess: RequestHealthReadAccess
    public var requestHealthWaterWrite: RequestHealthWaterWrite
    public var requestNotificationAuthorization: RequestNotificationAuthorization
    public var settingsRepository: any SettingsRepository

    public init(
        logIntake: LogIntake,
        undoLastIntake: UndoLastIntake,
        editIntake: EditIntake,
        deleteIntake: DeleteIntake,
        observeToday: ObserveToday,
        observeHistory: ObserveHistory,
        observeMonth: ObserveMonth,
        observeStats: ObserveStats,
        restoreIntake: RestoreIntake,
        updateGoal: UpdateGoal,
        calculateGoal: CalculateGoal,
        updateProfile: UpdateProfile,
        upsertContainer: UpsertContainer,
        deleteContainer: DeleteContainer,
        exportData: ExportData,
        rescheduleReminders: RescheduleReminders,
        healthAuthorizing: any HealthAuthorizing,
        requestHealthReadAccess: RequestHealthReadAccess,
        requestHealthWaterWrite: RequestHealthWaterWrite,
        requestNotificationAuthorization: RequestNotificationAuthorization,
        settingsRepository: any SettingsRepository
    ) {
        self.logIntake = logIntake
        self.undoLastIntake = undoLastIntake
        self.editIntake = editIntake
        self.deleteIntake = deleteIntake
        self.observeToday = observeToday
        self.observeHistory = observeHistory
        self.observeMonth = observeMonth
        self.observeStats = observeStats
        self.restoreIntake = restoreIntake
        self.updateGoal = updateGoal
        self.calculateGoal = calculateGoal
        self.updateProfile = updateProfile
        self.upsertContainer = upsertContainer
        self.deleteContainer = deleteContainer
        self.exportData = exportData
        self.rescheduleReminders = rescheduleReminders
        self.healthAuthorizing = healthAuthorizing
        self.requestHealthReadAccess = requestHealthReadAccess
        self.requestHealthWaterWrite = requestHealthWaterWrite
        self.requestNotificationAuthorization = requestNotificationAuthorization
        self.settingsRepository = settingsRepository
    }

    public static func assemble(
        intakeRepository: any IntakeRepository,
        settingsRepository: any SettingsRepository,
        widgetReloading: any WidgetReloading,
        health: any HealthProjecting,
        reminders: any ReminderScheduling,
        workouts: any WorkoutReading,
        healthAuthorizing: any HealthAuthorizing,
        notificationAuthorizing: any NotificationAuthorizing = NoOpNotificationAuthorizing()
    ) -> UseCases {
        let calculateGoal = CalculateGoal()
        let observeToday = ObserveToday(
            intakeRepository: intakeRepository,
            settingsRepository: settingsRepository,
            workoutReading: workouts,
            calculateGoal: calculateGoal
        )
        return UseCases(
            logIntake: LogIntake(
                intakeRepository: intakeRepository,
                settingsRepository: settingsRepository,
                widgetReloading: widgetReloading,
                health: health,
                reminders: reminders
            ),
            undoLastIntake: UndoLastIntake(
                intakeRepository: intakeRepository,
                settingsRepository: settingsRepository,
                widgetReloading: widgetReloading,
                health: health,
                reminders: reminders,
                observeToday: observeToday
            ),
            editIntake: EditIntake(
                intakeRepository: intakeRepository,
                widgetReloading: widgetReloading,
                health: health
            ),
            deleteIntake: DeleteIntake(
                intakeRepository: intakeRepository,
                settingsRepository: settingsRepository,
                widgetReloading: widgetReloading,
                health: health,
                reminders: reminders,
                observeToday: observeToday
            ),
            observeToday: observeToday,
            observeHistory: ObserveHistory(
                intakeRepository: intakeRepository,
                observeToday: observeToday
            ),
            observeMonth: ObserveMonth(
                intakeRepository: intakeRepository,
                settingsRepository: settingsRepository,
                calculateGoal: calculateGoal
            ),
            observeStats: ObserveStats(
                intakeRepository: intakeRepository,
                settingsRepository: settingsRepository,
                calculateGoal: calculateGoal
            ),
            restoreIntake: RestoreIntake(
                intakeRepository: intakeRepository,
                settingsRepository: settingsRepository,
                widgetReloading: widgetReloading,
                health: health,
                reminders: reminders,
                observeToday: observeToday
            ),
            updateGoal: UpdateGoal(
                settingsRepository: settingsRepository,
                workoutReading: workouts,
                widgetReloading: widgetReloading,
                calculateGoal: calculateGoal
            ),
            calculateGoal: calculateGoal,
            updateProfile: UpdateProfile(
                settingsRepository: settingsRepository,
                reminders: reminders
            ),
            upsertContainer: UpsertContainer(settingsRepository: settingsRepository),
            deleteContainer: DeleteContainer(settingsRepository: settingsRepository),
            exportData: ExportData(
                intakeRepository: intakeRepository,
                settingsRepository: settingsRepository
            ),
            rescheduleReminders: RescheduleReminders(
                settingsRepository: settingsRepository,
                intakeRepository: intakeRepository,
                reminders: reminders
            ),
            healthAuthorizing: healthAuthorizing,
            requestHealthReadAccess: RequestHealthReadAccess(
                healthAuthorizing: healthAuthorizing
            ),
            requestHealthWaterWrite: RequestHealthWaterWrite(
                healthAuthorizing: healthAuthorizing
            ),
            requestNotificationAuthorization: RequestNotificationAuthorization(
                authorizing: notificationAuthorizing
            ),
            settingsRepository: settingsRepository
        )
    }
}
