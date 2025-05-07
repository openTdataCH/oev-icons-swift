#!/usr/bin/env swift

import Foundation

struct IconSet {
    let sourcePath: String
    let key: String
    let name: String
    let includedTags: [String]?

    init(sourcePath: String, key: String, name: String, includedTags: [String]? = nil) {
        self.sourcePath = sourcePath
        self.key = key
        self.name = name
        self.includedTags = includedTags
    }
}

struct Config {
    static let pathToPackageSources: String = "Sources/OEVIcons"
    static let iconSets = [
        IconSet(sourcePath: "sbb-pictograms/picto", key: "picto", name: "Pictograms"),
        IconSet(sourcePath: "sbb-icons/icons", key: "icons", name: "OEVIcons", includedTags: ["timetable-icons","Product-Brands"]),
    ]
}

func main() {
    let filePath = #filePath
    guard let workingDir = URL(string: filePath)?.deletingLastPathComponent()
    else {
        fatalError()
    }

    for iconSet in Config.iconSets {
        let originals = iconSet.sourcePath
        let title = iconSet.name
        let indexJSONURL = workingDir
            .appending(path: originals)
            .appending(path: "index.json")
        let assetRootURL = workingDir.appending(
            path: "\(Config.pathToPackageSources)/Assets/\(title).xcassets")
        do {
            print("🚀 Start Creating Assets for \(title)")
            let assetRootPath = assetRootURL.path()

            if FileManager.default.fileExists(atPath: assetRootPath) {
                try FileManager.default.removeItem(atPath: assetRootPath)
                print("🗑️  Deleted previous xcassets directory")
            }

            try FileManager.default.createDirectory(atPath: assetRootPath, withIntermediateDirectories: true, attributes: nil)

            let defaultJSON = """
             {
                 "info" : {
                     "author" : "xcode",
                     "version" : 1
                 },
                 "properties" : {
                     "generate-swift-asset-symbol-extensions" : "disabled"
                 }
             }
             
             """

            FileManager.default.createFile(
                atPath: "\(assetRootPath)/Contents.json",
                contents: defaultJSON.data(using: .utf8),
                attributes: nil)

            guard let data = FileManager.default.contents(atPath: indexJSONURL.path()) else {
                fatalError("empty directory")
            }

            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let icons = json?[iconSet.key] as? [[String: Any?]]  {
                let fileNames: [String] = icons.compactMap { icon in
                    if let includedTags = iconSet.includedTags,
                       let tags = icon["tags"] as? [String] {
                        let shouldInclude = includedTags.contains { tagToInclude in
                            tags.contains(tagToInclude)
                        }
                        if shouldInclude {
                            return icon["name"] as? String
                        }
                        // print("⚠️  Skipping \(icon["name"] as? String ?? "?")")
                        return nil
                    } else {
                        return icon["name"] as? String
                    }
                }
                let files = Set(fileNames)
                for file in files {
                    let fileName = "\(file).svg"
                    let filePath = workingDir.appending(path: originals)
                        .appending(path: fileName).path()
                    if FileManager.default.fileExists(atPath: filePath) {
                        try createImageSet(
                            assetsPath: assetRootPath,
                            fileName: fileName,
                            sourcePath: workingDir.appending(path: originals).path())
                    }
                }
                let ignoredCount = icons.count - files.count
                let ignored = ignoredCount > 0 ? " – \(ignoredCount) Files ignored" : ""
                print("📋 Imported \(files.count) icons to \(title).xcassets\(ignored)")

                let content = createEnum(name: title, imageNames: files.sorted())
                FileManager.default.createFile(
                    atPath: "\(Config.pathToPackageSources)/\(title).swift",
                    contents: content.data(using: .utf8),
                    attributes: nil)
                print("🧑‍💻 Updated enum in \(title).swift")
            }

        } catch {
            print(error.localizedDescription)
        }
    }

    print("✅ done.")
}

func createEnum(name: String, imageNames: [String]) -> String {
    let sortedNames = imageNames.sorted(
        using: String.StandardComparator(.localizedStandard))

    let tuples = sortedNames.map({
        let image = $0.droppingSuffix
        var key = (image.first?.isNumber == true) ? "_\(image)" : image
        key =
        key.replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: "+", with: "_")
            .droppingSuffix
        return (key, image)
    })

    let content =
    """
    import SwiftUI
    
    public enum \(name) {
    
        public static let bundle = Bundle.module
    
    \(tuples.map { key, image in
        "    public static let \(key) = SwiftUI.Image(\"\(image)\", bundle: Bundle.module)"
    }.joined(separator: "\n"))
    }
    
    """

    return content
}

func createImageSet(assetsPath: String, fileName: String, sourcePath: String) throws
{
    let droppingSuffix = fileName.droppingSuffix
    let imageSetPath = "\(assetsPath)/\(droppingSuffix).imageset"
    try FileManager.default.createDirectory(
        atPath: imageSetPath, withIntermediateDirectories: true)
    try FileManager.default.copyItem(
        atPath: "\(sourcePath)/\(fileName)",
        toPath: "\(imageSetPath)/\(fileName)")

    let json = contentsJSON(fileName: fileName)
    FileManager.default.createFile(
        atPath: "\(imageSetPath)/Contents.json",
        contents: json.data(using: .utf8),
        attributes: nil)
}

func contentsJSON(fileName: String) -> String {
"""
{
  "images" : [
    {
      "filename" : "\(fileName)",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : true
  }
}

"""
}

main()

extension String {
    var droppingSuffix: String {
        if let d = self.split(
            separator: ".", maxSplits: 2, omittingEmptySubsequences: false
        ).first {
            String(d)
        } else {
            self
        }
    }
}
