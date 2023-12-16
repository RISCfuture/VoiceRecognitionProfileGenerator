import Foundation

extension XMLElement {
    func setAttribute(name: String, value: String) {
        addAttribute(XMLNode.attribute(withName: name, stringValue: value) as! XMLNode)
    }
    
    func addAttributes(_ attributes: Dictionary<String, String>) {
        attributes.forEach { setAttribute(name: $0, value: $1) }
    }
    
    static func make(_ name: String, value: String? = nil, attributes: Dictionary<String, String> = [:]) -> XMLElement {
        let element = XMLElement(name: name, stringValue: value)
        element.setAttributesWith(attributes)
        return element
    }
    
    func addChildren(_ children: Dictionary<String, String?>) {
        children.forEach { (name, value) in
            addChild(XMLElement(name: name, stringValue: value))
        }
    }
}
