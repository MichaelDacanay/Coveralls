//
//  ContentView.swift
//  Covers
//
//  Created by Michael Dacanay on 8/14/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var stockSymbol = ""
    @State private var currentPrice = ""
    @State private var impliedVolatility = ""
    @State private var riskTolerance = 0
    let options = ["Conservative", "Moderate", "Aggressive"]
    
    
    @State private var conservativeStrikePrice = ""
    @State private var moderateStrikePrice = ""
    @State private var aggressiveStrikePrice = ""
    
    var body: some View {
        VStack {
            Image("512x512px_covers_title").resizable().frame(width: 200, height: 200)
            
            TextField("Stock Symbol", text: $stockSymbol).padding([.leading, .bottom])
            TextField("Current Price", text: $currentPrice).padding([.leading, .bottom])
            TextField("Implied Volatility", text: $impliedVolatility).padding([.leading, .bottom])
            Picker(selection: $riskTolerance, label: Text("Approach")) {
                ForEach(0..<options.count, id: \.self) {
                    Text(self.options[$0])
                }
            }.pickerStyle(.segmented)
                .padding()
            
            Button("Compute") {
                // my code
            }.padding(10)
                .background(Color.accentColor)
                .foregroundColor(.black)
                .bold()
                .cornerRadius(10)
            
            Spacer()
            
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
