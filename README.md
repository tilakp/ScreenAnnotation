# ScreenAnnotation

ScreenAnnotation is a macOS application that allows users to annotate directly on their screen using a transparent overlay. It is designed for presentations, screen recordings, and live demonstrations where drawing attention to specific areas of the screen is helpful.

## Features
- Draw freeform annotations on the screen
- Transparent overlay window that covers the main display
- Custom drawing tools leveraging NSBezierPath and Core Graphics
- Easy to clear or reset annotations

## Installation
1. Clone this repository:
   ```sh
   git clone <your-repo-url>
   ```
2. Open `ScreenAnnotation.xcodeproj` in Xcode.
3. Build and run the app using Xcode (macOS 12+ recommended).

## Usage
- Launch the application.
- Use your mouse or trackpad to draw annotations on the screen overlay.
- Press the clear/reset button (if available) to erase all annotations.

## Development
- The main logic for the transparent overlay is implemented in `ClearWindow.swift`.
- Custom drawing extensions are in `NSBezierPath+CGPath.swift`.
- The main app flow is managed by `ViewController.swift` and `AppDelegate.swift`.
- No storyboards are used for window creation; windows are created programmatically.

## Troubleshooting
- If the overlay does not cover the entire screen, ensure that the window is created with the correct frame and retained properly in `AppDelegate`.
- If you encounter issues with drawing, check the custom NSBezierPath extensions.

## License
MIT License. See [LICENSE](LICENSE) for details.
