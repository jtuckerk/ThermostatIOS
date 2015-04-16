// Author - Santosh Rajan

import Foundation

let string = "[ {\"name\": \"John\", \"age\": 21}, {\"name\": \"Bob\", \"age\": 35} ]"

func JSONParseArray(jsonString: String) -> [AnyObject] {
    if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
        if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
            return array
        }
    }
    return [AnyObject]()
}
/*
for elem: AnyObject in JSONParseArray(string) {
    let name = elem["name"] as String
    let age = elem["age"] as Int
    println("Name: \(name), Age: \(age)")
}
*/
/*  Prints following

Name: John, Age: 21
Name: Bob, Age: 35

*/