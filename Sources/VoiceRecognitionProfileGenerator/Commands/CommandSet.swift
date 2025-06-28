class CommandSet {
    let name: String
    private var commands = [Command]()
    private var aliases = [String: Command]()

    var lastCommand: Command? { commands.last }

    init(name: String) { self.name = name }

    func childrenFor(command: Command) -> [Command] {
        commands.filter { $0.parent === command }
    }

    func hasChildren(_ command: Command) -> Bool {
        commands.contains { $0.parent === command }
    }

    func isVirtual(_ command: Command) -> Bool { return hasChildren(command) }
    func isReal(_ command: Command) -> Bool { return !isVirtual(command) }

    func add(command: Command, withAlias alias: String? = nil) throws {
        commands.append(command)

        if let alias {
            guard !hasAlias(named: alias) else {
                throw CommandFileErrors.aliasNameInUse(alias, line: nil)
            }
            aliases[alias] = command
        }
    }

    func add(commands: [Command]) throws {
        for command in commands { try add(command: command) }
    }

    func each(_ callback: (Command) throws -> Void) rethrows {
        for command in commands {
            try callback(command)
        }
    }

    func resolveAlias(_ name: String) throws -> Command {
        guard let command = aliases[name] else { throw CommandFileErrors.unknownAlias(name, line: nil) }
        return command
    }

    func hasAlias(named name: String) -> Bool { return aliases.keys.contains(name) }

    func copyChildren(of command: Command, to parent: Command?) -> [Command] {
        return childrenFor(command: command).flatMap { child in
            let newChild = child.copyTo(parent: parent)
            let nested = copyChildren(of: child, to: newChild)
            return [newChild] + nested
        }
    }
}
