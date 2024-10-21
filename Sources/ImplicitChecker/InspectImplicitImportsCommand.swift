import ArgumentParser

@main
struct InspectImplicitImportsCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "implicit",
            abstract: "Command to find implicit dependencies for a Swift Package.",
            version: "0.0.1"
        )
    }

    @Option(help: "Path to project Package.swift")
    var path: String

    func run() async throws {
        let adapter = SPMAdapter(packagePath: path)
        guard let package = adapter.fetchTargetsDetails() else { return }
        
        try await InspectImplicitImportsService().scan(package: package)
    }
}
