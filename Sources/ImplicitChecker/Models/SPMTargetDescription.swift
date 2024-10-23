struct SPMTargetDescription: Codable {
    let name: String
    let sources: [String]
    let path: String
    let targetDependencies: [String]
    let productDependencies: [String]

    init(
        name: String,
        sources: [String],
        path: String,
        targetDependencies: [String],
        productDependencies: [String]
    ) {
        self.name = name
        self.sources = sources
        self.path = path
        self.targetDependencies = targetDependencies
        self.productDependencies = productDependencies
    }

    enum CodingKeys: String, CodingKey {
        case name
        case sources
        case path
        case targetDependencies = "target_dependencies"
        case productDependencies = "product_dependencies"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let path = try container.decode(String.self, forKey: .path)
        sources = try container.decode([String].self, forKey: .sources)
            .map { path + "/" + $0 }
        self.path = path
        targetDependencies = (try? container.decode([String].self, forKey: .targetDependencies)) ?? []
        productDependencies = (try? container.decode([String].self, forKey: .productDependencies)) ?? []
    }
}
