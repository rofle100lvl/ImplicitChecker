import Foundation

protocol TargetImportsScanning {
    func imports(for target: TargetDescription) async throws -> Set<String>
}

final class TargetImportsScanner: TargetImportsScanning {
    private let importSourceCodeScanner: ImportSourceCodeScanner
    
    init(
        importSourceCodeScanner: ImportSourceCodeScanner = ImportSourceCodeScanner()
    ) {
        self.importSourceCodeScanner = importSourceCodeScanner
    }
    
    func imports(for target: TargetDescription) async throws -> Set<String> {
        var imports = Set(
            try await target.sources.concurrentMap { file in
                try await self.matchPattern(at: file)
            }
                .flatMap { $0 }
        )
        imports.remove(target.name)
        return imports
    }
    
    private func matchPattern(at path: String) async throws -> Set<String> {
        let language: ProgrammingLanguage
        guard let url = URL(string: path) else { return [] }
        switch url.pathExtension {
        case "swift":
            language = .swift
        case "h", "m", "cpp", "mm":
            language = .objc
        default:
            return []
        }
        
        let sourceCode = try String(contentsOfFile: path)
        return try importSourceCodeScanner.extractImports(
            from: sourceCode,
            language: language
        )
    }
}
