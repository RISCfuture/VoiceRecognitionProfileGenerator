import Foundation

extension XMLElement {
  static func make(_ name: String, value: String? = nil, attributes: [String: String] = [:])
    -> XMLElement
  {
    let element = XMLElement(name: name, stringValue: value)
    element.setAttributesWith(attributes)
    return element
  }

  func setAttribute(name: String, value: String) {
    guard let node = XMLNode.attribute(withName: name, stringValue: value) as? XMLNode else {
      return
    }
    addAttribute(node)
  }

  func addAttributes(_ attributes: [String: String]) {
    attributes.forEach { setAttribute(name: $0, value: $1) }
  }

  func addChildren(_ children: [String: String?]) {
    children.forEach { name, value in
      addChild(XMLElement(name: name, stringValue: value))
    }
  }
}
