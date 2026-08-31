import AppIntents
import Foundation
import RippleDomain

public struct ContainerEntity: AppEntity, Identifiable, Sendable {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Container"
    }

    public static let defaultQuery = ContainerEntityQuery()

    public var id: UUID
    public var name: String
    public var amountMl: Int

    public init(id: UUID, name: String, amountMl: Int) {
        self.id = id
        self.name = name
        self.amountMl = amountMl
    }

    public init(_ container: Container) {
        self.id = container.id
        self.name = container.name
        self.amountMl = container.amountMl
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(amountMl) ml")
    }
}

public struct ContainerEntityQuery: EntityQuery {
    public init() {}

    public func entities(for identifiers: [UUID]) async throws -> [ContainerEntity] {
        let containers = try await RippleRuntime.current.settingsRepository.containers()
        return containers.filter { identifiers.contains($0.id) }.map(ContainerEntity.init)
    }

    public func suggestedEntities() async throws -> [ContainerEntity] {
        let containers = try await RippleRuntime.current.settingsRepository.containers()
        return containers.map(ContainerEntity.init)
    }
}
