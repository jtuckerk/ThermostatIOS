// Author - Santosh Rajan

import Foundation

//let string = "{\"name\": \"John\", \"age\": 35, \"children\": [\"Jack\", \"Jill\"]}"

func JSONParseDictionary(jsonString: String) -> [String: AnyObject] {
    if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
        if let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [String: AnyObject] {
            return dictionary
        }
    }
    return [String: AnyObject]()
}
/*
let dictionary = JSONParseDictionary(string)

let name = dictionary["name"] as String                    // John
let age = dictionary["age"] as Int                         // 35
let firstChild = dictionary["children"]?[0] as String      // Jack
let secondChild = dictionary["children"]?[1] as String     // Jill
*/