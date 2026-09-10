import Testing
@testable import RippleDomain

@Suite("Container defaults")
struct ContainerTests {
    @Test("selecting a container as default clears the previous default")
    func selectingDefaultClearsPreviousDefault() async throws {
        let glass = Container(
            name: "Glass",
            amountMl: 250,
            isDefault: true,
            sort: 0,
            symbolName: "cup.and.saucer.fill"
        )
        let bottle = Container(
            name: "Large Bottle",
            amountMl: 700,
            isDefault: false,
            sort: 1,
            symbolName: "waterbottle.fill"
        )
        let repository = InMemorySettingsRepository(containers: [glass, bottle])
        var updatedBottle = bottle
        updatedBottle.isDefault = true

        try await UpsertContainer(settingsRepository: repository).run(updatedBottle)

        let saved = try await repository.containers()
        #expect(saved.first(where: { $0.id == glass.id })?.isDefault == false)
        #expect(saved.first(where: { $0.id == bottle.id })?.isDefault == true)
    }

    @Test("container sort determines the saved order")
    func containerSortPersistsOrder() async throws {
        let first = Container(name: "First", amountMl: 250, sort: 0)
        let second = Container(name: "Second", amountMl: 500, sort: 1)
        let repository = InMemorySettingsRepository(containers: [first, second])
        let upsert = UpsertContainer(settingsRepository: repository)

        var movedFirst = first
        movedFirst.sort = 1
        var movedSecond = second
        movedSecond.sort = 0

        try await upsert.run(movedFirst)
        try await upsert.run(movedSecond)

        let saved = try await repository.containers()
        #expect(saved.map(\.id) == [second.id, first.id])
        #expect(saved.map(\.sort) == [0, 1])
    }
}
