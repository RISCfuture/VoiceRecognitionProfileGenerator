import Foundation

protocol Generator {
    init(commands: CommandSet)    
    func generate() throws -> String
}
