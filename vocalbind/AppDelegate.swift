import Cocoa
import AVFoundation
import HotKey

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private let engine = VoiceEngine()

    // Defaults for semitone amounts (you can change these in Settings)
    private var deepSemitones: Float {
        get { UserDefaults.standard.float(forKey: "deepSemis") == 0 ? -6 : UserDefaults.standard.float(forKey: "deepSemis") }
        set { UserDefaults.standard.set(newValue, forKey: "deepSemis") }
    }
    private var highSemitones: Float {
        get { UserDefaults.standard.float(forKey: "highSemis") == 0 ? 7 : UserDefaults.standard.float(forKey: "highSemis") }
        set { UserDefaults.standard.set(newValue, forKey: "highSemis") }
    }

    // Global hotkeys (Ctrl-Opt-1/2/3)
    private var hkDeep: HotKey?
    private var hkNormal: HotKey?
    private var hkHigh: HotKey?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ask for mic
       AVCaptureDevice.requestAccess(for: .audio) { _ in }

        // Menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.title = "🎙️"
        statusItem.menu = buildMenu()

        // Start audio
        try? engine.start()

        // Hotkeys
        hkDeep = HotKey(key: .one, modifiers: [.control, .option])
        hkDeep?.keyDownHandler = { [weak self] in self?.applyDeep() }

        hkNormal = HotKey(key: .two, modifiers: [.control, .option])
        hkNormal?.keyDownHandler = { [weak self] in self?.applyNormal() }

        hkHigh = HotKey(key: .three, modifiers: [.control, .option])
        hkHigh?.keyDownHandler = { [weak self] in self?.applyHigh() }
    }

    private func buildMenu() -> NSMenu {
        let m = NSMenu()

        m.addItem(withTitle: "Deep (Ctrl-Opt-1)", action: #selector(onDeep), keyEquivalent: "")
        m.addItem(withTitle: "Normal (Ctrl-Opt-2)", action: #selector(onNormal), keyEquivalent: "")
        m.addItem(withTitle: "High (Ctrl-Opt-3)", action: #selector(onHigh), keyEquivalent: "")
        m.addItem(NSMenuItem.separator())

        m.addItem(withTitle: "Settings…", action: #selector(onSettings), keyEquivalent: ",")
        m.addItem(withTitle: "Quit", action: #selector(onQuit), keyEquivalent: "q")
        m.items.forEach { $0.target = self }
        return m
    }

    // Actions
    @objc private func onDeep()   { applyDeep() }
    @objc private func onNormal() { applyNormal() }
    @objc private func onHigh()   { applyHigh() }

    private func applyDeep()   { engine.set(semitones: deepSemitones) }
    private func applyNormal() { engine.set(semitones: 0) }
    private func applyHigh()   { engine.set(semitones: highSemitones) }

    @objc private func onQuit() { NSApp.terminate(nil) }

    @objc private func onSettings() {
        SettingsWindowController.shared.show(currentDeep: deepSemitones, currentHigh: highSemitones) { [weak self] newDeep, newHigh in
            self?.deepSemitones = newDeep
            self?.highSemitones = newHigh
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool { true }
}