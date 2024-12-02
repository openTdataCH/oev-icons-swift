#!/usr/bin/env swift

import Foundation

struct Config {
    static let sourcePath: String = "Sources/OEVIcons"

    static let iconSets = [
        ("sbb-pictograms/picto", "Pictograms"),
        ("sbb-icons/icons", "OEVIcons"),
    ]
}

func main() {
    let filePath = #filePath
    guard let workingDir = URL(string: filePath)?.deletingLastPathComponent()
    else {
        fatalError()
    }
    for ((originals, title)) in Config.iconSets {
        let pictogramURL = workingDir.appending(path: originals)
        let assetRootURL = workingDir.appending(
            path: "\(Config.sourcePath)/Assets/\(title).xcassets")
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
                }
            }
            """

            FileManager.default.createFile(
                atPath: "\(assetRootPath)/Contents.json",
                contents: defaultJSON.data(using: .utf8), 
                attributes: nil)

            let files = try FileManager.default.contentsOfDirectory(
                atPath: pictogramURL.path())
            for fileName in files where fileName.hasSuffix("svg") {
                try createImageSet(
                    assetsPath: assetRootPath, 
                    fileName: fileName,
                    sourcePath: pictogramURL.path())
            }
            let enumContent = createEnum(name: title, imageNames: files)
            FileManager.default.createFile(
                atPath: "\(workingDir.path())/\(Config.sourcePath)/\(title).swift",
                contents: enumContent.data(using: .utf8),
                attributes: nil)

            print("📋 Imported \(files.count) icons to \(title).xcassets")
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

    \(tuples.map { key, image in
        "    public static let \(key) = SwiftUI.Image(\"\(image)\", bundle: Bundle.module)"
    }.joined(separator: "\n"))
    }
    """

    return content
}

func createImageSet(assetsPath: String, fileName: String, sourcePath: String)
    throws
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
