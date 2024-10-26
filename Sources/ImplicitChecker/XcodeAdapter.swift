import Foundation
import XcodeProj

final class XcodeAdapter: ProjectAdapter {
    func fetchTargetsDetails(projURL: URL) throws -> ProjectDescription {
        let proj = try XcodeProj(path: .init(projURL.path()))
        let targets = try proj.pbxproj.nativeTargets
            .tryMap { target in
                let moduleName = target.name

                let packageDependencies = (target.packageProductDependencies ?? [])
                    .compactMap { $0.productName }

                let dependencies = target.dependencies.compactMap { $0.name } + packageDependencies

                let moduleFiles = try target.sourceFiles()
                    .map {
                        do {
                            return try $0.fullPath(sourceRoot: projURL.deletingLastPathComponent().path())
                        } catch {
                            return nil
                        }
                    }
                    .compactMap { $0 }
                    .compactMap {
                        URL(fileURLWithPath: $0)
                    }

                return TargetDescription(
                    name: moduleName,
                    sources: moduleFiles.map { $0.path() },
                    targetDependencies: dependencies
                )
            }
        return ProjectDescription(targets: targets)
    }
}
