//
//  ContentView.swift
//  Covers
//
//  Created by Michael Dacanay on 8/14/23.
//

import SwiftUI
import Combine
import CoreData

struct ContentView: View {
    private enum Field: Int, CaseIterable {
        case stockticker, price, impvolatility, daystoexp
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var stockSymbolString = ""
    @State private var currentPriceString = ""
    @State private var impliedVolatility: Double = 0.5
    @State private var daysUntilExpiration: Int = 14
    @State private var expirationDate = Date()
    
    @State private var riskTolerance = 0
    let options = ["Aggressive", "Moderate", "Conservative"]
    
    @State private var standardDeviation = 0.0
    @State private var conservativeStrikePrice = 0.0
    @State private var moderateStrikePrice = 0.0
    @State private var aggressiveStrikePrice = 0.0
    @State var computed = false
    
    var body: some View {
        VStack {
            Image("350x350px_covers_title_transparent").resizable().frame(width: 200, height: 200)
            
            Form {
                TextField("Stock ticker", text: $stockSymbolString)
                    .focused($focusedField, equals: .stockticker)
                
                HStack {
                    Text("Current price:")
                        .font(.callout)
                    TextField("USD", text: $currentPriceString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .price)
                }
                
                HStack {
                    Text("Implied volatility (0-1):")
                        .font(.callout)
                    TextField("% divide by 100", value: $impliedVolatility,
                              formatter: NumberFormatter.decimalFormatter)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .impvolatility)
                }
                
                // date
                Group {
                    HStack {
                        Text("Days until expiration:")
                            .font(.callout)
                        TextField("Or select expiration date",
                                  value: $daysUntilExpiration,
                                  formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .daystoexp)
                    }
                    
                    DatePicker("Exp. date",
                               selection: $expirationDate,
                               displayedComponents: .date)
                        .onChange(of: expirationDate) {
                            focusedField = nil
                            print("Selected date: \($0)")
                            print("Today's date: \(Date())")
                            
                            // Run your Swift code here
                            daysUntilExpiration = Int(Double(expirationDate - Date()) / 86400)
                            print("difference: \(daysUntilExpiration)")
                        }
                }
                
                // approach
                Picker(selection: $riskTolerance, label: Text("Approach")) {
                    ForEach(0..<options.count, id: \.self) {
                        Text(self.options[$0])
                    }
                }.pickerStyle(.segmented)
            }
            
            Button("Compute") {
                // my code
                if let currentPrice = Double(currentPriceString) {
                    standardDeviation = currentPrice * impliedVolatility * sqrt(Double(daysUntilExpiration) / 365)
                    aggressiveStrikePrice = ceil(currentPrice)
                    moderateStrikePrice = currentPrice + standardDeviation
                    conservativeStrikePrice = currentPrice + 1.282 * standardDeviation
                    print(standardDeviation)
                    print(aggressiveStrikePrice)
                    print(moderateStrikePrice)
                    print(conservativeStrikePrice)
                } else {
                    print("Invalid input")
                }
                computed = true
                focusedField = nil
            }.padding(10)
                .background(Color.accentColor)
                .foregroundColor(.black)
                .bold()
                .cornerRadius(10)
            
            Spacer()
            
            if conservativeStrikePrice > 0 {
                HStack {
                    VStack {
                        Text("Aggressive")
                        Text("Highest premium, 50/50 chance of keeping or losing stocks")
                            .font(.caption)
                        Text(String(format: "%.2f", aggressiveStrikePrice))
                    }
                    VStack {
                        Text("Moderate")
                        Text("1 standard deviation higher, 16% to lose stocks")
                            .font(.caption)
                        Text(String(format: "%.2f", moderateStrikePrice))
                    }
                    VStack {
                        Text("Conservative")
                        Text("10% chance to lose stocks")
                            .font(.caption)
                        Text(String(format: "%.2f", conservativeStrikePrice))
                    }
                }.padding()
            }
            
            if computed && currentPriceString.isEmpty {
                Text("Invalid input").foregroundColor(.red)
            }
            
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

extension NumberFormatter {
    static let decimalFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.maximum = 1
            formatter.minimum = 0
            return formatter
        }()
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
