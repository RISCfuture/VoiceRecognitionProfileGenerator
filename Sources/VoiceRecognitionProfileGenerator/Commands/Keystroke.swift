import Foundation

enum Side {
    case left
    case right
}

enum Keystroke {
    case character(_ char: Character)

    case function(_ num: UInt8)

    case shift(side: Side?)
    case control(side: Side?)
    case alt(side: Side?)
    case windows(side: Side?)
    case apps

    case backspace
    case escape
    case capsLock

    case insert
    case forwardDelete
    case home
    case end
    case pageUp
    case pageDown

    case printScreen
    case `break`
    case scrollLock

    case numLock
    case numpad(_ char: Character)
    case clear

    case upArrow
    case leftArrow
    case downArrow
    case rightArrow

    var isValid: Bool {
        switch self {
            case let .character(char): return validCharacter(char)
            case let .function(num): return validFunctionKey(num)
            case let .numpad(char): return validNumpadKey(char)
            default: return true
        }
    }

    var localizedDescription: String {
        switch self {
            case let .character(char):
                switch char {
                    case "\n": return String(localized: "Enter", bundle: Bundle.module, comment: "keyboard key")
                    case "\t": return String(localized: "Tab", bundle: Bundle.module, comment: "keyboard key")
                    case " ": return String(localized: "Space", bundle: Bundle.module, comment: "keyboard key")
                    default: return String(char)
                }
            case let .function(num):
                let format = String(localized: "F%d", comment: "keyboard function key")
                return String(format: format, num)
            case let .shift(side):
                switch side {
                    case .left: return String(localized: "Left Shift", bundle: Bundle.module, comment: "keyboard key")
                    case .right: return String(localized: "Right Shift", bundle: Bundle.module, comment: "keyboard key")
                    case .none: return String(localized: "Shift", bundle: Bundle.module, comment: "keyboard key")
                }
            case let .control(side):
                switch side {
                    case .left: return String(localized: "Left Control", bundle: Bundle.module, comment: "keyboard key")
                    case .right: return String(localized: "Right Control", bundle: Bundle.module, comment: "keyboard key")
                    case .none: return String(localized: "Control", bundle: Bundle.module, comment: "keyboard key")
                }
            case let .alt(side):
                switch side {
                    case .left: return String(localized: "Left Alt", bundle: Bundle.module, comment: "keyboard key")
                    case .right: return String(localized: "Right Alt", bundle: Bundle.module, comment: "keyboard key")
                    case .none: return String(localized: "Alt", bundle: Bundle.module, comment: "keyboard key")
                }
            case let .windows(side):
                switch side {
                    case .left: return String(localized: "Left Windows", bundle: Bundle.module, comment: "keyboard key")
                    case .right: return String(localized: "Right Windows", bundle: Bundle.module, comment: "keyboard key")
                    case .none: return String(localized: "Windows", bundle: Bundle.module, comment: "keyboard key")
                }
            case .apps: return String(localized: "Apps", bundle: Bundle.module, comment: "keyboard key")
            case .backspace: return String(localized: "Backspace", bundle: Bundle.module, comment: "keyboard key")
            case .escape: return String(localized: "Escape", bundle: Bundle.module, comment: "keyboard key")
            case .capsLock: return String(localized: "Caps Lock", bundle: Bundle.module, comment: "keyboard key")
            case .insert: return String(localized: "Insert", bundle: Bundle.module, comment: "keyboard key")
            case .forwardDelete: return String(localized: "Delete", bundle: Bundle.module, comment: "keyboard key")
            case .home: return String(localized: "Home", bundle: Bundle.module, comment: "keyboard key")
            case .end: return String(localized: "End", bundle: Bundle.module, comment: "keyboard key")
            case .pageUp: return String(localized: "Page Up", bundle: Bundle.module, comment: "keyboard key")
            case .pageDown: return String(localized: "Page Down", bundle: Bundle.module, comment: "keyboard key")
            case .printScreen: return String(localized: "Print Screen", bundle: Bundle.module, comment: "keyboard key")
            case .break: return String(localized: "Pause/Break", bundle: Bundle.module, comment: "keyboard key")
            case .scrollLock: return String(localized: "Scroll Lock", bundle: Bundle.module, comment: "keyboard key")
            case .numLock: return String(localized: "Num Lock", bundle: Bundle.module, comment: "keyboard key")
            case let .numpad(char):
                switch char {
                    case "\n": return String(localized: "Numpad Enter", bundle: Bundle.module, comment: "keyboard key")
                    default:
                        let format = String(localized: "Numpad %@", bundle: Bundle.module, comment: "keyboard key")
                        return String(format: format, String(char))
                }
            case .clear: return String(localized: "Clear", bundle: Bundle.module, comment: "keyboard key")
            case .upArrow: return String(localized: "Up Arrow", bundle: Bundle.module, comment: "keyboard key")
            case .leftArrow: return String(localized: "Left Arrow", bundle: Bundle.module, comment: "keyboard key")
            case .downArrow: return String(localized: "Down Arrow", bundle: Bundle.module, comment: "keyboard key")
            case .rightArrow: return String(localized: "Right Arrow", bundle: Bundle.module, comment: "keyboard key")
        }
    }

    private func validCharacter(_ char: Character) -> Bool {
        if "A"..."Z" ~= char { return true }
        if "a"..."z" ~= char { return true }
        if "0"..."9" ~= char { return true }
        if "`-=[]\\;'\n,./".contains(char) { return true }
        return false
    }

    private func validFunctionKey(_ num: UInt8) -> Bool { 1...15 ~= num }

    private func validNumpadKey(_ char: Character) -> Bool {
        if "0"..."9" ~= char { return true }
        if "/*-+\n.".contains(char) { return true }
        return false
    }
}
