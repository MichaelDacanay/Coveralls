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
    @State private var stockSymbolString = ""
    @State private var currentPriceString = ""
    @State private var impliedVolatility: Double = 0.5
//    @State private var daysUntilExpirationString = ""
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
            Image("512x512px_covers_title").resizable().frame(width: 200, height: 200)
            
            TextField("Stock Symbol", text: $stockSymbolString).padding([.leading, .bottom])
            HStack {
                Text("Current price:")
                    .font(.callout)
                    .bold()
                TextField("In USD", text: $currentPriceString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding([.leading, .bottom])
            
            HStack {
                Text("Implied volatility:")
                    .font(.callout)
                    .bold()
                TextField("between 0 and 1",
                          value: $impliedVolatility,
                          formatter: NumberFormatter.decimalFormatter)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding([.leading, .bottom])
            
            
            // date
            Group {
                HStack {
                    Text("Days until expiration:")
                        .font(.callout)
                        .bold()
                    TextField("Or select expiration date",
                              value: $daysUntilExpiration,
                              formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }.padding([.leading, .bottom])
                
                DatePicker("Exp date",
                           selection: $expirationDate,
                           displayedComponents: .date)
                    .onReceive(Just(expirationDate)) { date in
                                        print("Selected date: \(date)")
                                        print("Today's date: \(Date())")
                                        
                        // Run your Swift code here
                        daysUntilExpiration = Int(Double(expirationDate - Date()) / 86400)
                                        print("difference: \(daysUntilExpiration)")
                }.padding([.leading, .bottom, .trailing])
            }
            
            // approach
            Picker(selection: $riskTolerance, label: Text("Approach")) {
                ForEach(0..<options.count, id: \.self) {
                    Text(self.options[$0])
                }
            }.pickerStyle(.segmented)
                .padding()
            
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
                        Text(String(format: "%.2f", aggressiveStrikePrice))
                    }
                    VStack {
                        Text("Moderate")
                        Text(String(format: "%.2f", moderateStrikePrice))
                    }
                    VStack {
                        Text("Conservative")
                        Text(String(format: "%.2f", conservativeStrikePrice))
                    }
                }.padding()
            }
            
            if computed && currentPriceString.isEmpty {
                Text("Invalid input").foregroundColor(.red)
            }
            
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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
