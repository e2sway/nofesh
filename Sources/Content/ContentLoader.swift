import Foundation

enum ContentLoader {
    static func load() -> ContentLibrary {
        guard let url = Bundle.main.url(forResource: "routines", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let library = try? JSONDecoder().decode(ContentLibrary.self, from: data)
        else {
            fatalError("Bundled routines.json missing or malformed")
        }
        return library
    }
}