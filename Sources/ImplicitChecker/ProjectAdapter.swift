import Foundation

protocol ProjectAdapter {
    func fetchTargetsDetails(projURL: URL) throws -> PackageDescription?
}
