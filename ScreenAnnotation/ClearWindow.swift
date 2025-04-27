//
//  ClearWindow.swift
//  ScreenAnnotation
//
//  Created by Marc Vandehey on 9/5/17.
//  Copyright 2017 SkyVan Labs. All rights reserved.
//

import Cocoa

class ClearWindow : NSWindow {
  override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
    // Always use the main screen's visibleFrame for full screen coverage (excluding menu bar and Dock)
    let screenRect = NSScreen.main?.visibleFrame ?? contentRect
    super.init(contentRect: screenRect, styleMask: StyleMask.borderless, backing: backingStoreType, defer: flag)

    level = NSWindow.Level.statusBar

    backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.001)
  }

  override func mouseDown(with event: NSEvent) {
    (contentViewController as? ViewController)?.startDrawing(at: event.locationInWindow)
  }

  override func mouseDragged(with event: NSEvent) {
    (contentViewController as? ViewController)?.continueDrawing(at: event.locationInWindow)
  }

  override func mouseUp(with event: NSEvent) {
    (contentViewController as? ViewController)?.endDrawing(at: event.locationInWindow)
  }

  override func keyDown(with event: NSEvent) {
    if event.modifierFlags.contains(.command) {
      switch event.charactersIgnoringModifiers?.lowercased() {
      case "h":
        (contentViewController as? ViewController)?.highlighterButtonClicked(self)
      case "p":
        (contentViewController as? ViewController)?.penButtonClicked(self)
      default:
        super.keyDown(with: event)
      }
    } else {
      super.keyDown(with: event)
    }
  }

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }
}
