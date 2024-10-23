import Foundation

struct InspectImplicitImportsServiceErrorIssue: Equatable {
    let target: String
    let implicitDependencies: Set<String>
}

enum InspectImplicitImportsServiceError: Error, CustomStringConvertible, Equatable {
    case implicitImportsFound([InspectImplicitImportsServiceErrorIssue])

    public var description: String {
        switch self {
        case let .implicitImportsFound(issues):
            """
            The following implicit dependencies were found:
            \(
                issues.map { " - \($0.target) implicitly depends on: \($0.implicitDependencies.joined(separator: ", "))" }
                    .joined(separator: "\n")
            )
            """
        }
    }
}

final class InspectImplicitImportsService {
    private let targetScanner: TargetImportsScanning

    init(
        targetScanner: TargetImportsScanning = TargetImportsScanner()
    ) {
        self.targetScanner = targetScanner
    }

    func scan(package: PackageDescription) async throws {
        let issues = try await lint(package: package)
        guard issues.isEmpty else {
            throw InspectImplicitImportsServiceError.implicitImportsFound(issues)
        }
        print("We did not find any implicit dependencies in your project.")
    }

    private func lint(package: PackageDescription) async throws -> [InspectImplicitImportsServiceErrorIssue] {
        let allTargetNames = Set(package.targets.flatMap { $0.targetDependencies })
        var implicitTargetImports: [String: Set<String>] = [:]
        for target in package.targets {
            let sourceDependencies = try await targetScanner.imports(for: target)
            let explicitTargetDependencies = Set(target.targetDependencies)
            let implicitImports = sourceDependencies
                .intersection(allTargetNames)
                .subtracting(explicitTargetDependencies)
            if !implicitImports.isEmpty {
                implicitTargetImports[target.name] = implicitImports
            }
        }
        return implicitTargetImports.map { target, implicitDependencies in
            InspectImplicitImportsServiceErrorIssue(
                target: target,
                implicitDependencies: implicitDependencies
            )
        }
    }
}
