//
//  ContentView.swift
//  BetterRest
//
//  Created by Sarvad shetty on 12/3/19.
//  Copyright © 2019 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 0
    
    //alert properties
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
////     a static variable, which means it belongs to the ContentView struct itself rather than a single instance of that struct. This in turn means defaultWakeTime can be read whenever we want, because it doesn’t rely on the existence of any other properties
    
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        
        NavigationView {
            Form  {
                Section(header: Text("When do you wanna wake up?")) {
                    DatePicker("Please select a time:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Section(header: Text("Desired amount of sleep?")) {
                    Stepper(value: $sleepAmount, in: 4 ... 12, step :0.25){
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }

                }
                
                Section(header: Text("Daily coffe intake?")) {
                    Picker("Number of cups:",selection: $coffeeAmount) {
                        ForEach(1 ..< 13){
                            if($0 == 1) {
                                Text("1 cup")
                            } else {
                                Text("\($0) cups")
                            }
                        }
                    }
                }
                
                Section(header: Text("Ideal sleep time is...")) {
                    Text(idealTime)
                        .font(.largeTitle)
                        
                }
            }
            
            //navigation bar properties
            .navigationBarTitle(Text("BetterRest"))
//            .navigationBarItems(trailing:
//                //button here
//                //not putting (), to tell swift to call function an not return something
//                Button(action: calculateBedtime){
//                    Text("Calculate")
//                }
//            )
//                .alert(isPresented: $showingAlert) {
//                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
        }
        
        //to create a range from today to tommorow
//        let today = Date()
//        let tommorow = Date().addingTimeInterval(86400)
//        let range = today ... tommorow
        
        //or
        
//        DatePicker("Please enter a date:", selection: $wakeUp, in: Date()...)
//        .labelsHidden()
//        Form{
//            DatePicker("Please enter a date:", selection: $wakeUp)
//        }
//        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
//            Text("\(sleepAmount, specifier: "%g") hours")
//        }
    }
    
    var idealTime: String {
        //create instance of the model class
        let model = SleepCalculator()
        //to get date components for wake
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60 //to convert hours into seconds
        let minute = (components.minute ?? 0) * 60 //to convert minutes into seconds
        
        //prediction part
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            //we get a value in sec from core ml, to find the current time we need to sleep at, just subtract from wakeup time tell us the apropriate time to sleep by
            let sleepTime = wakeUp - prediction.actualSleep
            //the date api handles the conversion and subtraction
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: sleepTime)

            
        } catch {
            //if something went wrong
//            alertTitle = "Error"
            return "Error calculating your bedtime"
        }
        
//        showingAlert = true
    }
    
    func calculateBedtime() {
        //create instance of the model class
        let model = SleepCalculator()
        //to get date components for wake
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60 //to convert hours into seconds
        let minute = (components.minute ?? 0) * 60 //to convert minutes into seconds
        
        //prediction part
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            //we get a value in sec from core ml, to find the current time we need to sleep at, just subtract from wakeup time tell us the apropriate time to sleep by
            let sleepTime = wakeUp - prediction.actualSleep
            //the date api handles the conversion and subtraction
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is..."
            
        } catch {
            //if something went wrong
            alertTitle = "Error"
            alertMessage = "Error calculating your bedtime"
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
