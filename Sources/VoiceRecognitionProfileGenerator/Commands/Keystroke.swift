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
                    case "\n": return NSLocalizedString("Enter", comment: "keyboard key")
                    case "\t": return NSLocalizedString("Tab", comment: "keyboard key")
                    case " ": return NSLocalizedString("Space", comment: "keyboard key")
                    default: return String(char)
                }
            case let .function(num):
                let format = NSLocalizedString("F%d", comment: "keyboard function key")
                return String(format: format, num)
            case let .shift(side):
                switch side {
                    case .left: return NSLocalizedString("Left Shift", comment: "keyboard key")
                    case .right: return NSLocalizedString("Right Shift", comment: "keyboard key")
                    case .none: return NSLocalizedString("Shift", comment: "keyboard key")
                }
            case let .control(side):
                switch side {
                    case .left: return NSLocalizedString("Left Control", comment: "keyboard key")
                    case .right: return NSLocalizedString("Right Control", comment: "keyboard key")
                    case .none: return NSLocalizedString("Control", comment: "keyboard key")
                }
            case let .alt(side):
                switch side {
                    case .left: return NSLocalizedString("Left Alt", comment: "keyboard key")
                    case .right: return NSLocalizedString("Right Alt", comment: "keyboard key")
                    case .none: return NSLocalizedString("Alt", comment: "keyboard key")
                }
            case let .windows(side):
                switch side {
                    case .left: return NSLocalizedString("Left Windows", comment: "keyboard key")
                    case .right: return NSLocalizedString("Right Windows", comment: "keyboard key")
                    case .none: return NSLocalizedString("Windows", comment: "keyboard key")
                }
            case .apps: return NSLocalizedString("Apps", comment: "keyboard key")
            case .backspace: return NSLocalizedString("Backspace", comment: "keyboard key")
            case .escape: return NSLocalizedString("Escape", comment: "keyboard key")
            case .capsLock: return NSLocalizedString("Caps Lock", comment: "keyboard key")
            case .insert: return NSLocalizedString("Insert", comment: "keyboard key")
            case .forwardDelete: return NSLocalizedString("Delete", comment: "keyboard key")
            case .home: return NSLocalizedString("Home", comment: "keyboard key")
            case .end: return NSLocalizedString("End", comment: "keyboard key")
            case .pageUp: return NSLocalizedString("Page Up", comment: "keyboard key")
            case .pageDown: return NSLocalizedString("Page Down", comment: "keyboard key")
            case .printScreen: return NSLocalizedString("Print Screen", comment: "keyboard key")
            case .break: return NSLocalizedString("Pause/Break", comment: "keyboard key")
            case .scrollLock: return NSLocalizedString("Scroll Lock", comment: "keyboard key")
            case .numLock: return NSLocalizedString("Num Lock", comment: "keyboard key")
            case let .numpad(char):
                switch char {
                    case "\n": return NSLocalizedString("Numpad Enter", comment: "keyboard key")
                    default:
                        let format = NSLocalizedString("Numpad %@", comment: "keyboard key")
                        return String(format: format, String(char))
                }
            case .clear: return NSLocalizedString("Clear", comment: "keyboard key")
            case .upArrow: return NSLocalizedString("Up Arrow", comment: "keyboard key")
            case .leftArrow: return NSLocalizedString("Left Arrow", comment: "keyboard key")
            case .downArrow: return NSLocalizedString("Down Arrow", comment: "keyboard key")
            case .rightArrow: return NSLocalizedString("Right Arrow", comment: "keyboard key")
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
