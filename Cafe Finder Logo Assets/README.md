# Coffee Cafe Finder — Logo Assets

Logo: **Bean Marker** (coffee bean shaped as a map pin).

## Palette
- `#3D2817` dark coffee (bean body)
- `#6F4E37` medium coffee (highlight)
- `#D4A574` tan (background)
- `#F5E6D3` cream (crease)

## Files

```
svg/
  bean_marker_logo.svg          ← master logo (use with flutter_svg in-app)
  bean_marker_foreground.svg    ← adaptive icon foreground (transparent bg)
  bean_marker_background.svg    ← adaptive icon background (solid tan)

android/
  mipmap-mdpi/ic_launcher.png       48x48
  mipmap-hdpi/ic_launcher.png       72x72
  mipmap-xhdpi/ic_launcher.png      96x96
  mipmap-xxhdpi/ic_launcher.png    144x144
  mipmap-xxxhdpi/ic_launcher.png   192x192
  adaptive/
    ic_launcher_foreground.png    432x432  (Android 8+ adaptive)
    ic_launcher_background.png    432x432
    ic_launcher.xml               adaptive-icon descriptor

ios/
  Icon-App-*.png                  full AppIcon set (iPhone, iPad, marketing)
  Contents.json                   ready to drop into AppIcon.appiconset
```

## Flutter integration

### 1. In-app usage (splash, drawer, about page, etc.)

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_svg: ^2.0.10

flutter:
  assets:
    - assets/logo/bean_marker_logo.svg
```

Then in code:
```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/logo/bean_marker_logo.svg',
  width: 96,
  height: 96,
)
```

### 2. Launcher icons

**Android — legacy (< API 26):**
Copy `android/mipmap-*/ic_launcher.png` into
`android/app/src/main/res/mipmap-*/ic_launcher.png` (overwrite Flutter defaults).

**Android — adaptive (API 26+, recommended):**
1. Copy `adaptive/ic_launcher_foreground.png` into each `mipmap-*` folder
   (you may rescale per density: mdpi=108, hdpi=162, xhdpi=216, xxhdpi=324, xxxhdpi=432).
   The 432px file fits xxxhdpi; let Android downscale or generate per density.
2. Copy `adaptive/ic_launcher_background.png` the same way.
3. Place `ic_launcher.xml` at `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`.

**iOS:**
Replace contents of `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
with everything in the `ios/` folder (PNGs + Contents.json).

### Or: skip the manual copy with flutter_launcher_icons

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/logo/bean_marker_logo.png"     # use 1024x1024 master
  adaptive_icon_background: "#D4A574"
  adaptive_icon_foreground: "assets/logo/bean_marker_foreground.png"
  min_sdk_android: 21
```

Then run:
```bash
dart run flutter_launcher_icons
```

The package will regenerate every density automatically from a single master.
The 1024x1024 master is at `ios/Icon-App-1024x1024@1x.png`.
