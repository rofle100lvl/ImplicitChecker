import Foundation

// TODO: Make Errors for SPMAdapter
final class SPMAdapter: ProjectAdapter {
    func fetchTargetsDetails(projURL: URL) -> PackageDescription? {
        let packagePath = projURL.deletingLastPathComponent().path()
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["swift", "package", "describe", "--type", "json"]
        task.currentDirectoryPath = packagePath

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        do {
            try task.run()
        } catch {
            print("Error running process: \(error.localizedDescription)")
            return nil
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }

        guard let packageDescription = parsePackageDescription(jsonString: jsonString) else { return nil }
        return PackageDescription(targets: packageDescription.targets.map {
            TargetDescription(
                name: $0.name,
                sources: $0.sources.map { source in packagePath + "/" + source },
                targetDependencies: $0.targetDependencies + $0.productDependencies
            )
        })
    }

    private func parsePackageDescription(jsonString: String) -> SPMPackageDescription? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(SPMPackageDescription.self, from: data)
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }
}
