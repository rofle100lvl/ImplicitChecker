import Foundation

enum SPMAdapterError: Error {
    case pipeDataIsNotParsable
}

final class SPMAdapter: ProjectAdapter {
    func fetchTargetsDetails(projURL: URL) throws -> ProjectDescription {
        let packagePath = projURL.deletingLastPathComponent().path()
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["swift", "package", "describe", "--type", "json"]
        task.currentDirectoryPath = packagePath

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        try task.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw SPMAdapterError.pipeDataIsNotParsable
        }

        let packageDescription = try parsePackageDescription(jsonString: jsonString)
        return ProjectDescription(targets: packageDescription.targets.map {
            TargetDescription(
                name: $0.name,
                sources: $0.sources.map { source in packagePath + "/" + source },
                targetDependencies: $0.targetDependencies + $0.productDependencies
            )
        })
    }

    private func parsePackageDescription(jsonString: String) throws -> SPMPackageDescription {
        guard let data = jsonString.data(using: .utf8) else {
            throw SPMAdapterError.pipeDataIsNotParsable
        }

        return try JSONDecoder().decode(SPMPackageDescription.self, from: data)
    }
}
