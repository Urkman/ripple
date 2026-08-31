import Foundation
import Testing
@testable import RippleDomain

@Suite("CalculateGoal")
struct CalculateGoalTests {
    let sut = CalculateGoal()

    @Test("default without weight is 2000 ml")
    func defaultWithoutWeight() {
        let profile = Profile()
        #expect(sut.run(profile: profile, workoutMinutes: 0).value == 2000)
    }

    @Test("weight uses kg * 33 rounded to 50 ml")
    func weightFormula() {
        var profile = Profile()
        profile.bodyMassKg = 70
        #expect(sut.run(profile: profile, workoutMinutes: 0).value == 2300)
    }

    @Test("manual activity adds 350 or 700")
    func activityLevel() {
        var moderate = Profile()
        moderate.activityLevel = .moderate
        #expect(sut.run(profile: moderate, workoutMinutes: 0).value == 2350)

        var high = Profile()
        high.activityLevel = .high
        #expect(sut.run(profile: high, workoutMinutes: 0).value == 2700)
    }

    @Test("opt-in workouts replace manual activity bonus")
    func workouts() {
        var profile = Profile()
        profile.activityLevel = .high
        profile.healthReadWorkoutsEnabled = true
        #expect(sut.run(profile: profile, workoutMinutes: 45).value == 2350)
        #expect(sut.run(profile: profile, workoutMinutes: 60).value == 2700)
    }

    @Test("round to fifty")
    func rounding() {
        #expect(CalculateGoal.roundToFifty(2310) == 2300)
        #expect(CalculateGoal.roundToFifty(2325) == 2350)
    }
}
