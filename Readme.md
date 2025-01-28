# OeV Icons Swift

This project exposes the official swiss [OeV Icons](https://digital.sbb.ch/en/foundation/assets/fpl/) as a Swift Package to be used on Apple platform applications.

## Background

SBB publishes these icon sets on GitHub under an [Apache License](./LICENSE). [`SBB Icons`](https://digital.sbb.ch/en/foundation/assets/icons/) and [`Timetable Icons`](https://digital.sbb.ch/en/foundation/assets/fpl/) are published on [sbb-design-systems/sbb-icons](https://github.com/sbb-design-systems/sbb-icons). The [`Pictograms`](https://digital.sbb.ch/en/foundation/assets/pictos/) are published on [sbb-design-systems/sbb-pictograms](https://github.com/sbb-design-systems/sbb-pictograms).

This project adds those two repositories as submodules and imports the `Timetable Icons` and `Pictograms` to an importable Swift Package. 

> Due to [usage restrictions](https://digital.sbb.ch/en/foundation/assets/icons/) on `SBB Icons`, those assets are excluded from the package.

### For more details about icon sets visit:

- [SBB icons](https://digital.sbb.ch/en/foundation/assets/icons/) - Only to be used in SBB led projects. ⚠️ These icons are excluded from the import!
- [Timetable icons](https://digital.sbb.ch/en/foundation/assets/fpl/)
- [Pictograms](https://digital.sbb.ch/en/foundation/assets/pictos/)


### Usage

#### Add the Swift Package to your project

Add `OEVIcons`to your project using Swift Package Manger:

```swift
dependencies: [
    .package(url: "https://github.com/openTdataCH/oev-icons-swift.git", branch: "main"),
]
```

#### Display the icons

``` swift
import SwiftUI

struct SampleView: View {
    var body: some View {
        // Directly reference assets
        Pictograms.train_right_framed
        OEVIcons.tgv


        // Display asset using image name
        Image("electric-bike-charging-station-left", bundle: Pictograms.bundle)
        Image("ev-77", bundle: OEVIcons.bundle)
    }
}

```

## TODO

- [x] check if project can be added to opentransportdata
- [ ] transform icon names in generated enum to pascal-case
- [ ] maybe add helper functions from OJP Sample App
- [ ] decide about a kotlin/android version

## Import icons and update this project

In order to import the latest icons you have to update the submodules and run `./copy-svgs-to-assets.swift`. Commit the changes on a new branch and create a pull request.

When the pull request is approved and merged, a new version tag will be set.

## License

The original icons and this project are published under an Apache License. 
Make sure you comply with the [right of use](https://digital.sbb.ch/en/foundation/brand/copyrights/).

