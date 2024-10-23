import Foundation
import XcodeProj

final class XcodeAdapter: ProjectAdapter {
    func fetchTargetsDetails(projURL: URL) throws -> PackageDescription? {
        let proj = try XcodeProj(path: .init(projURL.path()))
        return PackageDescription(targets: proj.pbxproj.nativeTargets
            .map {
                let moduleName = $0.name

                let dependencies = $0.dependencies.compactMap { $0.name } +
                    ($0.packageProductDependencies ?? []).compactMap { $0.productName }
                var moduleFiles = [URL]()

                let sourceBuildPhase = $0.buildPhases.filter {
                    $0 is PBXSourcesBuildPhase
                }.first

                if let sourceBuildPhase,
                   let files = sourceBuildPhase.files
                {
                    moduleFiles = files
                        .map {
                            do {
                                return try $0.file?.fullPath(sourceRoot: projURL.deletingLastPathComponent().path())
                            } catch {
                                return nil
                            }
                        }
                        .compactMap { $0 }
                        .compactMap {
                            URL(fileURLWithPath: $0)
                        }
                }

                return TargetDescription(
                    name: moduleName,
                    sources: moduleFiles.map { $0.path() },
                    targetDependencies: dependencies
                )
            }
        )
    }
}
