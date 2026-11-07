import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [LoyaltyCard.self, CustomRetailer.self] }
}

enum LocardsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

enum StoreRecovery {
    private static let marker = ".recovered-"

    /// Opens the store. If that fails, moves the store files aside (never deletes them) and opens a fresh one.
    static func makeContainer() -> (container: ModelContainer, recovered: Bool) {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let config = ModelConfiguration(schema: schema)
        try? FileManager.default.createDirectory(
            at: config.url.deletingLastPathComponent(), withIntermediateDirectories: true)
        func open(_ config: ModelConfiguration) throws -> ModelContainer {
            try ModelContainer(for: schema, migrationPlan: LocardsMigrationPlan.self, configurations: [config])
        }
        do {
            return (try open(config), false)
        } catch {
            moveAside(config.url)
            do {
                return (try open(config), true)
            } catch {
                // Last resort: the app still launches, but nothing is saved this session.
                let memory = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return (try! open(memory), true)
            }
        }
    }

    private static func moveAside(_ storeURL: URL) {
        let fm = FileManager.default
        let stamp = String(Int(Date.now.timeIntervalSince1970))
        for suffix in ["", "-wal", "-shm"] {
            let source = URL(fileURLWithPath: storeURL.path + suffix)
            guard fm.fileExists(atPath: source.path) else { continue }
            let target = URL(fileURLWithPath: source.path + marker + stamp)
            try? fm.moveItem(at: source, to: target)
        }
    }

    /// Files from earlier recoveries, for sharing from Settings.
    static func recoveredFiles() -> [URL] {
        let dir = ModelConfiguration().url.deletingLastPathComponent()
        let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        return files.filter { $0.lastPathComponent.contains(marker) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
