//
//  ContentView.swift
//  Covers
//
//  Created by Michael Dacanay on 8/14/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var stockSymbolString = ""
    @State private var currentPriceString = ""
    @State private var impliedVolatilityString = ""
    @State private var daysUntilExpirationString = ""
    @State private var riskTolerance = 0
    let options = ["Conservative", "Moderate", "Aggressive"]
    
    @State private var standardDeviation = 0.0
    @State private var conservativeStrikePrice = 0.0
    @State private var moderateStrikePrice = 0.0
    @State private var aggressiveStrikePrice = 0.0
    @State var computed = false
    
    var body: some View {
        VStack {
            Image("512x512px_covers_title").resizable().frame(width: 200, height: 200)
            
            TextField("Stock Symbol", text: $stockSymbolString).padding([.leading, .bottom])
            TextField("Current Price", text: $currentPriceString).padding([.leading, .bottom])
            TextField("Implied Volatility (between 0 and 1)", text: $impliedVolatilityString).padding([.leading, .bottom])
            TextField("Days until Expiration", text: $daysUntilExpirationString).padding([.leading, .bottom])
            Picker(selection: $riskTolerance, label: Text("Approach")) {
                ForEach(0..<options.count, id: \.self) {
                    Text(self.options[$0])
                }
            }.pickerStyle(.segmented)
                .padding()
            
            Button("Compute") {
                // my code
                if let currentPrice = Double(currentPriceString),
                   let impliedVolatility = Double(impliedVolatilityString),
                   let daysUntilExpiration = Double(daysUntilExpirationString) {
                    standardDeviation = currentPrice * impliedVolatility * sqrt(daysUntilExpiration / 365)
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
            
            if computed && (currentPriceString.isEmpty || impliedVolatilityString.isEmpty || daysUntilExpirationString.isEmpty) {
                Text("Invalid input").foregroundColor(.red)
            }
            
            
            
        }
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
