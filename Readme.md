# ![information icon](./sbb-pictograms/picto/information-framed.svg) OeV Icons Swift

⚠️ This is a proof of concept to expose the official swiss [OeV Icons](https://digital.sbb.ch/en/foundation/assets/fpl/) as a Swift Package to be used on Apple platform applications. If this turns out to be usable, it will be moved to a community led GitHub project.

## Background

SBB publishes three icon sets on GitHub. `SBB Icons` and `Timetable Icons` are published on [sbb-design-systems/sbb-icons](https://github.com/sbb-design-systems/sbb-icons). The `Pictograms` are published on [sbb-design-systems/sbb-pictograms](https://github.com/sbb-design-systems/sbb-pictograms).

This project adds those two repositories as submodules and imports the `Timetable Icons` and `Pictograms` to an importable Swift Package. Due to usage restrictions on `SBB Icons`, those assets will not be bundled with the package.

### Usage

#### Add the Swift Package to your project

`https://github.com/r3to/OeVIconsSwift.git`

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

- [ ] check if project can be added to opentransportdata
- [ ] transform icon names in generated enum to pascal-case
- [ ] maybe add helper functions from OJP Sample App
- [ ] decide about a kotlin/android version

## Import icons and update this project

In order to import the latest icons you have to update the submodules and run `./copy-svgs-to-assets.swift`. Commit the changes on a new branch and create a pull request.

When the pull request is approved and merged, a new version tag will be set.

## License

Make sure you comply with the [right of use](https://digital.sbb.ch/en/foundation/brand/copyrights/).

For more details about icon sets visit:

- [SBB icons](https://digital.sbb.ch/en/foundation/assets/icons/) - Only to be used in SBB led projects. ⚠️ These icons are excluded from the import!
- [Timetable icons](https://digital.sbb.ch/en/foundation/assets/fpl/)
- [Pictograms](https://digital.sbb.ch/en/foundation/assets/pictos/)
