import Foundation

// TODO: Make Errors for SPMAdapter
final class SPMAdapter {
    private let packagePath: String

    init(packagePath: String) {
        self.packagePath = packagePath
    }
    
    func fetchTargetsDetails() -> PackageDescription? {
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
                path: $0.path,
                targetDependencies: $0.targetDependencies,
                productDependencies: $0.productDependencies
            )
        })
    }
    
    private func parsePackageDescription(jsonString: String) -> PackageDescription? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(PackageDescription.self, from: data)
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }
}
