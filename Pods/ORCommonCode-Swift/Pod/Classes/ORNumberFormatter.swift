//
//  ORNumberFormatter.swift
//  Pods
//
//  Created by Maxim Soloviev on 31/10/2016.
//
//

import Foundation

open class ORNumberFormatter {
    
    public enum SignificantUnits: Int {
        case none       = 0
        case thousands  = 3
        case millions   = 6
        case billions   = 9
        
        var string: String {
            switch self {
            case .none:
                return ""
            case .thousands:
                return "K"
            case .millions:
                return "M"
            case .billions:
                return "B"
            }
        }
        
        init(value: Double) {
            switch abs(value) {
            case 0 ..< 1_000:
                self = .none
            case 1_000 ..< 999_999:
                self = .thousands
            case 1_000_000 ..< 999_999_999:
                self = .millions
            default:
                self = .billions
            }
        }
    }
    
    open var useCommaAsSeparator = false
    open var removeTrailingFractionZeros = true
    
    open var unitTitles = [SignificantUnits: String]()
    
    public init() {
    }
    
    open func stringValue(for number: Double, significantUnits: SignificantUnits, maxFractionDigits: Int = 1) -> String {
        let devider = pow(10.0, Double(significantUnits.rawValue))
        let value = number / devider
        let intPart = Int(value)
        
        let nsnf = NumberFormatter()
        var s = nsnf.string(for: intPart) ?? ""
        
        if maxFractionDigits > 0 {
            let floatPart = value - Double(intPart)
            let floatPartBoundedByMaxFractionDigits = Int(floatPart * pow(10.0, Double(maxFractionDigits)))
            if floatPartBoundedByMaxFractionDigits > 0 {
                var strValueFloatPart = String(format: "%\(maxFractionDigits)d", floatPartBoundedByMaxFractionDigits)
                if removeTrailingFractionZeros {
                    while strValueFloatPart.hasSuffix("0") {
                        strValueFloatPart.remove(at: strValueFloatPart.index(before: strValueFloatPart.endIndex))
                    }
                }
                let separator = useCommaAsSeparator ? "," : "."
                s.append("\(separator)\(strValueFloatPart)")
            }
        }

        return s
    }
    
    open func stringValueWithUnits(for number: Double, significantUnits: SignificantUnits, maxFractionDigits: Int = 1) -> String {
        let strValue = stringValue(for: number, significantUnits: significantUnits, maxFractionDigits: maxFractionDigits)
        let unitsString = "\(unitTitles[significantUnits] ?? significantUnits.string)"
        let s = unitsString.isEmpty ? "\(strValue)" : "\(strValue) \(unitsString)"
        return s
    }
    
    open func autoStringValue(for number: Double, maxFractionDigits: Int = 1) -> (strValue: String, significantUnits: SignificantUnits) {
        let significantUnits = SignificantUnits(value: number)
        let s = stringValue(for: number, significantUnits: significantUnits, maxFractionDigits: maxFractionDigits)
        return (s, significantUnits)
    }
    
    open func autoStringValueWithUnits(for number: Double, maxFractionDigits: Int = 1) -> String {
        let significantUnits = SignificantUnits(value: number)
        let s = stringValueWithUnits(for: number, significantUnits: significantUnits, maxFractionDigits: maxFractionDigits)
        return s
    }
}
