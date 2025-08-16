import Cocoa

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    static let shared = SettingsWindowController()

    private var deepButtons: [NSButton] = []
    private var highButtons: [NSButton] = []
    private var onSave: ((Float, Float) -> Void)?

    private var deepValue: Int = Int(UserDefaults.standard.float(forKey: "deepSemis") == 0 ? -6 : UserDefaults.standard.float(forKey: "deepSemis"))
    private var highValue: Int = Int(UserDefaults.standard.float(forKey: "highSemis") == 0 ? 7 : UserDefaults.standard.float(forKey: "highSemis"))

    convenience init() {
        self.init(window: nil)
        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 420, height: 280),
                           styleMask: [.titled, .closable],
                           backing: .buffered, defer: false)
        win.title = "Settings"
        win.center()
        win.isReleasedWhenClosed = false
        win.delegate = self
        self.window = win

       let content = NSView(frame: win.contentView!.bounds)
        content.translatesAutoresizingMaskIntoConstraints = false
        win.contentView = content

        let deepLabel = label("Deep semitone:")
        deepLabel.frame.origin = NSPoint(x: 20, y: 220)
        content.addSubview(deepLabel)

        deepButtons = makeRow(prefix: "Deep", y: 190, selected: deepValue) { [weak self] v in
            self?.deepValue = v
        }
        deepButtons.forEach(content.addSubview)

        let highLabel = label("High semitone:")
        highLabel.frame.origin = NSPoint(x: 20, y: 140)
        content.addSubview(highLabel)

        highButtons = makeRow(prefix: "High", y: 110, selected: highValue) { [weak self] v in
            self?.highValue = v
        }
        highButtons.forEach(content.addSubview)

        let save = NSButton(title: "Save", target: self, action: #selector(savePressed))
        save.frame = NSRect(x: 220, y: 20, width: 80, height: 30) save.setButtonType(.momentaryPushIn)
        content.addSubview(save)

        let close = NSButton(title: "Close", target: self, action: #selector(closePressed))
        close.keyEquivalent = "\u{1B}" // Esc
        close.frame = NSRect(x: 310, y: 20, width: 80, height: 30)
        content.addSubview(close)
    }

    func show(currentDeep: Float, currentHigh: Float, onSave: @escaping (Float, Float) -> Void) {
        self.onSave = onSave
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func savePressed() {
        UserDefaults.standard.set(Float(deepValue), forKey: "deepSemis")
        UserDefaults.standard.set(Float(highValue), forKey: "highSemis")
        onSave?(Float(deepValue), Float(highValue))
    }

    @objc private func closePressed() { self.window?.close() }

    // Helpers
    private func label(_ text: String) -> NSTextField {
        let l = NSTextField(labelWithString: text) l.setAccessibilityLabel(text)
        return l
    }

    private func makeRow(prefix: String, y: CGFloat, selected: Int, onChange: @escaping (Int)->Void) -> [NSButton] {
        // Buttons 1..12 (±12). For deep we show negative labels.
        var buttons: [NSButton] = []
        for i in 1...12 {
            let value = prefix == "Deep" ? -i : i
            let b = NSButton(checkboxWithTitle: "\(value)", target: nil, action: nil)
            b.frame = NSRect(x: 20 + (i-1)*32, y: y, width: 30, height: 28)
            b.setAccessibilityLabel("\(prefix) \(value) semitones")
            b.state = (value == selected) ? .on : .off
            b.action = #selector(choiceChanged(_:))
            b.target = self
            b.tag = value
            buttons.append(b)
        }
        // Ensure only one can be selected at a time
        func setExclusive(_ sender: NSButton) {
            for b in buttons { b.state = (b == sender ? .on : .off) }
            onChange(sender.tag)
        }   objc_setAssociatedObject(self, Unmanaged.passUnretained(self).toOpaque(), setExclusive as Any, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return buttons
    }

    @objc private func choiceChanged(_ sender: NSButton) {
        // Find array containing sender
        if self.deepButtons.contains(sender) {
            for b in deepButtons { b.state = (b == sender ? .on : .off) }
            deepValue = sender.tag
        } else if self.highButtons.contains(sender) {
            for b in highButtons { b.state = (b == sender ? .on : .off) }
            highValue = sender.tag
        }
    }
}