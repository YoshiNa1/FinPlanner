//
//  CurrencyConverter.swift
//  FinancePlanner
//
//  Created by Anastasiia on 30.10.2022.
//


import Foundation

// Global Enumerations:
enum ConvCurrency : String, CaseIterable {
    case none = ""
    case AUD = "AUD"; case INR = "INR"; case TRY = "TRY"
    case BGN = "BGN"; case ISK = "ISK"; case USD = "USD"
    case BRL = "BRL"; case JPY = "JPY"; case UAH = "UAH"
    case CAD = "CAD"; case KRW = "KRW"; case ZAR = "ZAR"
    case CHF = "CHF"; case MXN = "MXN"
    case CNY = "CNY"; case MYR = "MYR"
    case CZK = "CZK"; case NOK = "NOK"
    case DKK = "DKK"; case NZD = "NZD"
    case EUR = "EUR"; case PHP = "PHP"
    case GBP = "GBP"; case PLN = "PLN"
    case HKD = "HKD"; case RON = "RON"
    case HRK = "HRK"; case RUB = "RUB"
    case HUF = "HUF"; case SEK = "SEK"
    case IDR = "IDR"; case SGD = "SGD"
    case ILS = "ILS"; case THB = "THB"
    
    static var all: [ConvCurrency] {
        get {
            return ConvCurrency.allCases.filter({$0 != .none})
                                        .sorted(by: {$0.rawValue.lowercased() < $1.rawValue.lowercased()})
        }
    }
    // Public Static Methods:
    /** Returns a currency name with it's flag (🇺🇸 USD, for example). */
    static func nameWithFlag(for currency : ConvCurrency) -> String {
        return flag(for: currency) + " " + currency.rawValue
    }
    
    /** Returns a currency flag (🇺🇸 for example). */
    static func flag(for currency : ConvCurrency) -> String {
        return ConvCurrency.flagsByCurrencies[currency] ?? "?"
    }
    
    /** Returns a currency fsymbol ($ for example). */
    static func symbol(for currency : String) -> String {
        let curr = ConvCurrency.currency(for: currency)
        return ConvCurrency.symbolsByCurrencies[curr] ?? "?"
    }
    
    static func currency(for name : String) -> ConvCurrency {
        return ConvCurrency(rawValue: name) ?? .none
    }
    // Public Properties:
    /** Returns an array with all currency names and their respective flags. */
    static let allNamesWithFlags : [String] = {
        var namesWithFlags : [String] = []
        for currency in ConvCurrency.allCases {
            namesWithFlags.append(ConvCurrency.nameWithFlag(for: currency))
        }
        return namesWithFlags
    }()
    
    static let flagsByCurrencies : [ConvCurrency : String] = [
        .AUD : "🇦🇺", .INR : "🇮🇳", .TRY : "🇹🇷",
        .BGN : "🇧🇬", .ISK : "🇮🇸", .USD : "🇺🇸",
        .BRL : "🇧🇷", .JPY : "🇯🇵", .UAH : "🇺🇦",
        .CAD : "🇨🇦", .KRW : "🇰🇷", .ZAR : "🇿🇦",
        .CHF : "🇨🇭", .MXN : "🇲🇽",
        .CNY : "🇨🇳", .MYR : "🇲🇾",
        .CZK : "🇨🇿", .NOK : "🇳🇴",
        .DKK : "🇩🇰", .NZD : "🇳🇿",
        .EUR : "🇪🇺", .PHP : "🇵🇭",
        .GBP : "🇬🇧", .PLN : "🇵🇱",
        .HKD : "🇭🇰", .RON : "🇷🇴",
        .HRK : "🇭🇷", .RUB : "🇷🇺",
        .HUF : "🇭🇺", .SEK : "🇸🇪",
        .IDR : "🇮🇩", .SGD : "🇸🇬",
        .ILS : "🇮🇱", .THB : "🇹🇭",
    ]
    
    static let symbolsByCurrencies : [ConvCurrency : String] = [
        .AUD : "$",     .INR : "₹",     .TRY : "₺",
        .BGN : "лв.",   .ISK : "kr.",   .USD : "$",
        .BRL : "$",     .JPY : "¥",     .UAH : "₴",
        .CAD : "$",     .KRW : "₩",     .ZAR : "R",
        .CHF : "₣",     .MXN : "$",
        .CNY : "¥",     .MYR : "RM",
        .CZK : "Kč",    .NOK : "kr",
        .DKK : "kr.",   .NZD : "$",
        .EUR : "€",     .PHP : "₱",
        .GBP : "£",     .PLN : "zł",
        .HKD : "$",     .RON : "lei",
        .HRK : "Kn",    .RUB : "₽",
        .HUF : "ƒ",     .SEK : "kr",
        .IDR : "₨",     .SGD : "$",
        .ILS : "₪",     .THB : "฿",
    ]
}

// Global Classes:
class CurrencyConverter {
    
    // Private Properties:
    private var exchangeRates : [ConvCurrency : Double] = [:]
    private let xmlParser = CurrencyXMLParser()
    
    // Initialization:
    init() { updateExchangeRates {} }
    
    // Public Methods:
    /** Updates the exchange rate and runs the completion afterwards. */
    public func updateExchangeRates(completion : @escaping () -> Void = {}) {
        xmlParser.parse(completion: {
            // Gets the exchange rate from the internet:
            self.exchangeRates = self.xmlParser.getExchangeRates()
            // Saves the updated exchange rate to the device's local storage:
            CurrencyConverterLocalData.saveMostRecentExchangeRates(self.exchangeRates)
            // Runs the completion:
            completion()
        }, errorCompletion: { // No internet access/network error:
            // Loads the most recent exchange rate from the device's local storage:
            self.exchangeRates = CurrencyConverterLocalData.loadMostRecentExchangeRates()
            // Runs the completion:
            completion()
        })
    }
    
    /**
     Converts a Double value based on it's currency (valueCurrency) and the output currency (outputCurrency).
     USD to EUR conversion example: convert(42, valueCurrency: .USD, outputCurrency: .EUR)
     */
    public func convert(_ value : Double, valueCurrency : ConvCurrency, outputCurrency : ConvCurrency) -> Double? {
        if let valueRate = exchangeRates[valueCurrency], let outputRate = exchangeRates[outputCurrency] {
            let multiplier = outputRate/valueRate
            return value * multiplier
        }
        return nil
    }
    
    /**
     Converts a Double value based on it's currency and the output currency, and returns a formatted String.
     Usage example: convertAndFormat(42, valueCurrency: .USD, outputCurrency: .EUR, numberStyle: .currency, decimalPlaces: 4)
     */
    public func convertAndFormat(_ value : Double, valueCurrency : ConvCurrency, outputCurrency : ConvCurrency, numberStyle : NumberFormatter.Style, decimalPlaces : Int) -> String? {
        guard let doubleOutput = convert(value, valueCurrency: valueCurrency, outputCurrency: outputCurrency) else {
            return nil
        }
        return format(doubleOutput, numberStyle: numberStyle, decimalPlaces: decimalPlaces)
    }
    
    /**
     Returns a formatted string from a double value.
     Usage example: format(42, numberStyle: .currency, decimalPlaces: 4)
     */
    public func format(_ value : Double, numberStyle : NumberFormatter.Style, decimalPlaces : Int) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = numberStyle
        formatter.maximumFractionDigits = decimalPlaces
        let formattedString = formatter.string(from: NSNumber(value: value))
        return formattedString
    }
    
}

// Private Classes:
private class CurrencyXMLParser : NSObject, XMLParserDelegate {
    
    // Private Properties:
    private let xmlURL = "https://api.exchangerate.host/latest"
    private var exchangeRates : [ConvCurrency : Double] = [
        .EUR : 1.0 // Base currency
    ]
    
    // Public Methods:
    public func getExchangeRates() -> [ConvCurrency : Double] {
        return exchangeRates
    }
    
    public func parse(completion : @escaping () -> Void, errorCompletion : @escaping () -> Void) {
        guard let url = URL(string: xmlURL) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to parse the XML!")
                print(error ?? "Unknown error")
                errorCompletion()
                return
            }
            let dictionary = try? JSONSerialization.jsonObject(with: data)
            if let dict = dictionary as? Dictionary<String, Any>, let rates = dict["rates"] as? Dictionary<String, Double> {
                for rate in rates {
                    if let exchangeRate = self.makeExchangeRate(currency: rate.key, rate: rate.value) {
                        self.exchangeRates.updateValue(exchangeRate.rate, forKey: exchangeRate.currency)
                    }
                }
                completion()
            }
        }
        task.resume()
    }
    
    // Private Methods:
    private func makeExchangeRate(currency : String, rate : Double) -> (currency : ConvCurrency, rate : Double)? {
        guard let currency = ConvCurrency(rawValue: currency) else { return nil }
        return (currency, rate)
    }
    
}

// Private Classes:
private class CurrencyConverterLocalData {
    
    // Structs:
    struct Keys {
        static let mostRecentExchangeRates = "CurrencyConverterLocalData.Keys.mostRecentExchangeRates"
    }
    
//TODO: UPDATE!!
    static let fallBackExchangeRates : [ConvCurrency : Double] = [
        .USD : 1.1321,
        .JPY : 126.76,
        .BGN : 1.9558,
        .CZK : 25.623,
        .DKK : 7.4643,
        .GBP : 0.86290,
        .HUF : 321.90,
        .PLN : 4.2796,
        .RON : 4.7598,
        .SEK : 10.4788,
        .CHF : 1.1326,
        .ISK : 135.20,
        .NOK : 9.6020,
        .HRK : 7.4350,
        .RUB : 72.6133,
        .TRY : 6.5350,
        .AUD : 1.5771,
        .BRL : 4.3884,
        .CAD : 1.5082,
        .CNY : 7.5939,
        .HKD : 8.8788,
        .IDR : 15954.12,
        .ILS : 4.0389,
        .INR : 78.2915,
        .KRW : 1283.00,
        .MXN : 21.2360,
        .MYR : 4.6580,
        .NZD : 1.6748,
        .PHP : 58.553,
        .SGD : 1.5318,
        .THB : 35.955,
        .ZAR : 15.7631,
        .UAH : 36.862058
    ]
    
    // Static Methods:
    /** Saves the most recent exchange rates by locally storing it. */
    static func saveMostRecentExchangeRates(_ exchangeRates : [ConvCurrency : Double]) {
        let convertedExchangeRates = convertExchangeRatesForUserDefaults(exchangeRates)
        UserDefaults.standard.set(convertedExchangeRates, forKey: Keys.mostRecentExchangeRates)
    }
    
    /** Loads the most recent exchange rates from the local storage. */
    static func loadMostRecentExchangeRates() -> [ConvCurrency : Double] {
        if let userDefaultsExchangeRates = UserDefaults.standard.dictionary(forKey: Keys.mostRecentExchangeRates) as? [String : Double] {
            return convertExchangeRatesFromUserDefaults(userDefaultsExchangeRates)
        }
        else {
            // Fallback:
            return fallBackExchangeRates
        }
    }
    
    // Private Static Methods:
    /** Converts the [String : Double] dictionary with the exchange rates to a [Currency : Double] dictionary. */
    private static func convertExchangeRatesFromUserDefaults(_ userDefaultsExchangeRates : [String : Double]) -> [ConvCurrency : Double] {
        var exchangeRates : [ConvCurrency : Double] = [:]
        for userDefaultExchangeRate in userDefaultsExchangeRates {
            if let currency = ConvCurrency(rawValue: userDefaultExchangeRate.key) {
                exchangeRates.updateValue(userDefaultExchangeRate.value, forKey: currency)
            }
        }
        return exchangeRates
    }
    
    /**
     Converts the [Currency : Double] dictionary with the exchange rates to a [String : Double] one so it can be stored locally.
     */
    private static func convertExchangeRatesForUserDefaults(_ exchangeRates : [ConvCurrency : Double]) -> [String : Double] {
        var userDefaultsExchangeRates : [String : Double] = [:]
        for exchangeRate in exchangeRates {
            userDefaultsExchangeRates.updateValue(exchangeRate.value, forKey: exchangeRate.key.rawValue)
        }
        return userDefaultsExchangeRates
    }
    
}
