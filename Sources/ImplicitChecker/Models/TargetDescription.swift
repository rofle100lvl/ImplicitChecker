struct TargetDescription: Codable {
    let name: String
    let sources: [String]
    let targetDependencies: [String]

    init(
        name: String,
        sources: [String],
        targetDependencies: [String]
    ) {
        self.name = name
        self.sources = sources
        self.targetDependencies = targetDependencies
    }
}
