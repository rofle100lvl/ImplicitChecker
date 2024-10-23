import ArgumentParser
import Foundation

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
        guard let urlPath = URL(string: path) else { return }
        var adapter: ProjectAdapter? = nil

        if urlPath.pathExtension == "swift" {
            adapter = SPMAdapter()
        } else if urlPath.pathExtension == "xcodeproj" {
            adapter = XcodeAdapter()
        }
        guard let package = try adapter?.fetchTargetsDetails(projURL: urlPath) else { return }

        try await InspectImplicitImportsService().scan(package: package)
    }
}
