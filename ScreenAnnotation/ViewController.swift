//
//  ViewController.swift
//  ScreenAnnotation
//
//  Created by Marc Vandehey on 9/5/17.
//  Copyright 2017 SkyVan Labs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  // Pen/highlighter state
  var isHighlighterMode = false
  let penLineWeight: CGFloat = 5
  let highlighterLineWeight: CGFloat = 20

  // Default colors
  let penColors: [(String, NSColor)] = [
    ("Red", .red),
    ("Blue", .blue),
    ("Green", .green),
    ("Black", .black)
  ]
  let highlighterColors: [(String, NSColor)] = [
    ("Yellow", NSColor.yellow.withAlphaComponent(0.3)),
    ("Green", NSColor.green.withAlphaComponent(0.3)),
    ("Pink", NSColor.systemPink.withAlphaComponent(0.3)),
    ("Blue", NSColor.blue.withAlphaComponent(0.3))
  ]
  var selectedPenColor: NSColor = .red
  var selectedHighlighterColor: NSColor = NSColor.yellow.withAlphaComponent(0.3)
  var penColorMenuItems: [NSMenuItem] = []
  var highlighterColorMenuItems: [NSMenuItem] = []

  var currentPath: NSBezierPath?
  var currentShape: CAShapeLayer?
  var currentColor: CurrentColorView!

  private let offText = "Disable Drawing"
  private let onText = "Enable Drawing"

  @IBOutlet weak var clearButton: NSMenuItem!
  @IBOutlet weak var toggleButton: NSMenuItem!
  var penButton: NSMenuItem!
  var highlighterButton: NSMenuItem!
  @IBOutlet var optionsMenu: NSMenu!

  @IBAction func clearButtonClicked(_ sender: Any) {
    view.layer?.sublayers?.removeAll()
    
    view.addSubview(currentColor)
  }

  @IBAction func toggleButtonClicked(_ sender: Any) {
    view.window!.ignoresMouseEvents = !view.window!.ignoresMouseEvents

    toggleButton.title = view.window!.ignoresMouseEvents ? onText : offText
    
    currentColor.alphaValue = 0
  }

  @IBAction func penButtonClicked(_ sender: Any) {
    isHighlighterMode = false
    penButton.state = .on
    highlighterButton.state = .off
  }

  @IBAction func highlighterButtonClicked(_ sender: Any) {
    isHighlighterMode = true
    highlighterButton.state = .on
    penButton.state = .off
  }

  @objc func selectPenColor(_ sender: NSMenuItem) {
    if let idx = penColorMenuItems.firstIndex(of: sender) {
      selectedPenColor = penColors[idx].1
      for (i, item) in penColorMenuItems.enumerated() {
        item.state = i == idx ? .on : .off
      }
    }
  }

  @objc func selectHighlighterColor(_ sender: NSMenuItem) {
    if let idx = highlighterColorMenuItems.firstIndex(of: sender) {
      selectedHighlighterColor = highlighterColors[idx].1
      for (i, item) in highlighterColorMenuItems.enumerated() {
        item.state = i == idx ? .on : .off
      }
    }
  }

  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

  override func awakeFromNib() {
    statusItem.menu = optionsMenu
    let icon = NSImage(named: NSImage.Name(rawValue: "pencil"))
    icon?.isTemplate = true // best for dark mode
    statusItem.button?.image = icon

    toggleButton.title = offText
    
    currentColor = CurrentColorView.newInstance()
    
    view.addSubview(currentColor)
    
    let options = [NSTrackingArea.Options.mouseMoved, NSTrackingArea.Options.activeInKeyWindow] as NSTrackingArea.Options
    let trackingArea = NSTrackingArea(rect:view.frame,options:options,owner:self,userInfo:nil)
    view.addTrackingArea(trackingArea)

    // Remove all items
    while optionsMenu.items.count > 0 {
      optionsMenu.removeItem(at: 0)
    }

    // 1. Clear (Command+C)
    clearButton.keyEquivalent = "c"
    clearButton.keyEquivalentModifierMask = [.command]
    optionsMenu.addItem(clearButton)
    optionsMenu.addItem(NSMenuItem.separator())

    // 2. Enable/Disable Drawing
    optionsMenu.addItem(toggleButton)
    optionsMenu.addItem(NSMenuItem.separator())

    // 3. Pen (Command+P)
    let penItem = NSMenuItem(title: "Pen", action: #selector(penButtonClicked(_:)), keyEquivalent: "p")
    penItem.target = self
    penItem.state = isHighlighterMode ? .off : .on
    penButton = penItem
    optionsMenu.addItem(penItem)

    // 4. Pen Color submenu
    let penColorMenu = NSMenu(title: "Pen Color")
    penColorMenuItems = []
    for (i, (name, color)) in penColors.enumerated() {
      let item = NSMenuItem(title: name, action: #selector(selectPenColor(_:)), keyEquivalent: "")
      item.target = self
      item.state = i == 0 ? .on : .off
      item.image = colorSwatchImage(color: color)
      penColorMenu.addItem(item)
      penColorMenuItems.append(item)
    }
    let penColorMenuItem = NSMenuItem(title: "Pen Color", action: nil, keyEquivalent: "")
    penColorMenuItem.submenu = penColorMenu
    optionsMenu.addItem(penColorMenuItem)
    optionsMenu.addItem(NSMenuItem.separator())

    // 5. Highlighter (Command+H)
    let highlighterItem = NSMenuItem(title: "Highlighter", action: #selector(highlighterButtonClicked(_:)), keyEquivalent: "h")
    highlighterItem.target = self
    highlighterItem.state = isHighlighterMode ? .on : .off
    highlighterButton = highlighterItem
    optionsMenu.addItem(highlighterItem)

    // 6. Highlighter Color submenu
    let highlighterColorMenu = NSMenu(title: "Highlighter Color")
    highlighterColorMenuItems = []
    for (i, (name, color)) in highlighterColors.enumerated() {
      let item = NSMenuItem(title: name, action: #selector(selectHighlighterColor(_:)), keyEquivalent: "")
      item.target = self
      item.state = i == 0 ? .on : .off
      item.image = colorSwatchImage(color: color)
      highlighterColorMenu.addItem(item)
      highlighterColorMenuItems.append(item)
    }
    let highlighterColorMenuItem = NSMenuItem(title: "Highlighter Color", action: nil, keyEquivalent: "")
    highlighterColorMenuItem.submenu = highlighterColorMenu
    optionsMenu.addItem(highlighterColorMenuItem)
    optionsMenu.addItem(NSMenuItem.separator())

    // 7. Quit (always last)
    var quitItem = optionsMenu.item(withTitle: "Quit")
    if quitItem == nil {
      quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
      quitItem?.target = self
      quitItem?.keyEquivalentModifierMask = [.command]
    } else {
      optionsMenu.removeItem(quitItem!)
    }
    optionsMenu.addItem(quitItem!)
  }

  @objc func quitApp() {
    NSApp.terminate(nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.frame = CGRect(origin: CGPoint(), size: NSScreen.main!.visibleFrame.size)
  }

  func startDrawing(at point: NSPoint) {
    currentPath = NSBezierPath()
    currentShape = CAShapeLayer()
    
    if isHighlighterMode {
      currentShape?.lineWidth = highlighterLineWeight
      currentShape?.strokeColor = selectedHighlighterColor.cgColor
    } else {
      currentShape?.lineWidth = penLineWeight
      currentShape?.strokeColor = selectedPenColor.cgColor
    }
    currentShape?.fillColor = NSColor.clear.cgColor

    currentShape?.lineJoin = kCALineJoinRound
    currentShape?.lineCap = kCALineCapRound

    currentPath?.move(to: point)
    currentPath?.line(to: point)

    currentShape?.path = currentPath?.cgPath

    view.layer?.addSublayer(currentShape!)
    
    currentColor.removeFromSuperview()
    view.addSubview(currentColor)
  }

  func continueDrawing(at point: NSPoint) {
    currentPath?.line(to: point)

    if let shape = currentShape {
      shape.path = currentPath?.cgPath
    }
    
    updateCurrentColorLocation(point: point)
  }

  func endDrawing(at point: NSPoint) {
    currentPath?.line(to: point)

    if let shape = currentShape {
      shape.path = currentPath?.cgPath
    }

    currentPath = nil
    currentShape = nil
    
    updateCurrentColorLocation(point: point)
  }
    
  func updateCurrentColorLocation(point: NSPoint) {
    currentColor.frame.origin.x = point.x - 20
    currentColor.frame.origin.y = point.y - 20
    
    currentColor.alphaValue = 1
  }
  
  override func mouseMoved(with event: NSEvent) {
    updateCurrentColorLocation(point: event.locationInWindow)
  }
  
  // Utility to create a color swatch image
  func colorSwatchImage(color: NSColor, size: NSSize = NSSize(width: 16, height: 16)) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    color.setFill()
    let rect = NSRect(origin: .zero, size: size)
    let path = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
    path.fill()
    image.unlockFocus()
    return image
  }
}
