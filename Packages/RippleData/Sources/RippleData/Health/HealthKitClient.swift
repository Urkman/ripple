import Foundation
import RippleDomain

#if canImport(HealthKit) && (os(iOS) || os(watchOS))
import HealthKit

actor HealthKitClient {
    static let shared = HealthKitClient()

    private let store = HKHealthStore()
    private var written: Set<UUID> = []

    private var waterType: HKQuantityType? {
        HKQuantityType.quantityType(forIdentifier: .dietaryWater)
    }

    private var bodyMassType: HKQuantityType? {
        HKQuantityType.quantityType(forIdentifier: .bodyMass)
    }

    private var workoutType: HKSampleType {
        HKObjectType.workoutType()
    }

    func status() -> HealthAuthorizationStatus {
        let water: Bool
        if let waterType {
            water = store.authorizationStatus(for: waterType) == .sharingAuthorized
        } else {
            water = false
        }
        return HealthAuthorizationStatus(
            waterWrite: water,
            workoutRead: store.authorizationStatus(for: workoutType) == .sharingAuthorized
        )
    }

    func requestWaterWrite() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable(), let waterType else { return false }
        do {
            try await store.requestAuthorization(toShare: [waterType], read: [])
            return store.authorizationStatus(for: waterType) == .sharingAuthorized
        } catch {
            return false
        }
    }

    func requestBodyMassRead() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable(), let bodyMassType else {
            return false
        }

        do {
            try await store.requestAuthorization(toShare: [], read: [bodyMassType])
            return true
        } catch {
            return false
        }
    }

    func latestBodyMassKg() async -> Double? {
        guard HKHealthStore.isHealthDataAvailable(), let bodyMassType else {
            return nil
        }

        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        ]

        do {
            let samples: [HKSample] = try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<[HKSample], Error>) in
                let query = HKSampleQuery(
                    sampleType: bodyMassType,
                    predicate: nil,
                    limit: 1,
                    sortDescriptors: sortDescriptors
                ) { _, samples, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: samples ?? [])
                    }
                }
                store.execute(query)
            }

            guard let sample = samples.first as? HKQuantitySample else {
                return nil
            }

            let kilograms = sample.quantity.doubleValue(
                for: HKUnit.gramUnit(with: .kilo)
            )
            return kilograms.isFinite && kilograms > 0 ? kilograms : nil
        } catch {
            return nil
        }
    }

    func requestWorkoutRead() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        do {
            try await store.requestAuthorization(toShare: [], read: [workoutType])
            return true
        } catch {
            return false
        }
    }

    func project(intake: Intake) async {
        guard HKHealthStore.isHealthDataAvailable(),
              let waterType,
              store.authorizationStatus(for: waterType) == .sharingAuthorized
        else { return }
        if written.contains(intake.id) { return }
        if await alreadyStored(uuid: intake.id) {
            written.insert(intake.id)
            return
        }

        let liters = Double(intake.amountMl) / 1000.0
        let quantity = HKQuantity(unit: .liter(), doubleValue: liters)
        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: intake.date,
            end: intake.date,
            metadata: [
                RippleIdentifiers.healthUUIDKey: intake.id.uuidString,
                RippleIdentifiers.healthSourceKey: intake.source.rawValue,
            ]
        )
        do {
            try await store.save(sample)
            written.insert(intake.id)
        } catch {
            // Projection failure must not roll back the log.
        }
    }

    func retract(intakeID: UUID) async {
        guard HKHealthStore.isHealthDataAvailable(), let waterType else { return }
        written.remove(intakeID)
        let predicate = HKQuery.predicateForObjects(
            withMetadataKey: RippleIdentifiers.healthUUIDKey,
            allowedValues: [intakeID.uuidString]
        )
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                store.deleteObjects(of: waterType, predicate: predicate) { _, _, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        } catch {
            // Ignore if authorization does not allow delete.
        }
    }

    func moderateMinutes(on day: Date) async -> Int {
        guard HKHealthStore.isHealthDataAvailable() else { return 0 }
        let start = Calendar.current.startOfDay(for: day)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? day
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        do {
            let workouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: workoutType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, samples, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
                    }
                }
                store.execute(query)
            }
            let seconds = workouts.reduce(0.0) { total, workout in
                total + workout.duration
            }
            return Int(seconds / 60.0)
        } catch {
            return 0
        }
    }

    private func alreadyStored(uuid: UUID) async -> Bool {
        guard let waterType else { return false }
        let predicate = HKQuery.predicateForObjects(
            withMetadataKey: RippleIdentifiers.healthUUIDKey,
            allowedValues: [uuid.uuidString]
        )
        do {
            let samples: [HKSample] = try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: waterType,
                    predicate: predicate,
                    limit: 1,
                    sortDescriptors: nil
                ) { _, samples, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: samples ?? [])
                    }
                }
                store.execute(query)
            }
            return !samples.isEmpty
        } catch {
            return false
        }
    }
}
#endif
