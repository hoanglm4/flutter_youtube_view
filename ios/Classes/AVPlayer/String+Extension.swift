import Foundation

extension String {
    var isNumeric: Bool {
        let hasLetters = rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
        let hasNumbers = rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
        return  !hasLetters && hasNumbers
    }
    
    var url: URL? {
        return URL(string: self)
    }
    
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var urlDecoded: String {
        return removingPercentEncoding ?? self
    }
    
    var urlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    var bool: Bool? {
        let selfLowercased = trimmed.lowercased()
        if selfLowercased == "true" || selfLowercased == "1" {
            return true
        } else if selfLowercased == "false" || selfLowercased == "0" {
            return false
        }
        return nil
    }
}

// MARK: - Number
extension String {
    
    var integerValue: Int? {
        get {
            let formatter = NumberFormatter()
            formatter.locale = .current
            formatter.allowsFloats = true
            return formatter.number(from: self) as? Int
        }
    }
    
    var floatValue: Float? {
        get {
            let formatter = NumberFormatter()
            formatter.locale = .current
            formatter.allowsFloats = true
            return formatter.number(from: self) as? Float
        }
    }
    
    
    var doubleValue: Double? {
        get {
            let formatter = NumberFormatter()
            formatter.locale = .current
            formatter.allowsFloats = true
            return formatter.number(from: self) as? Double
        }
    }

}

