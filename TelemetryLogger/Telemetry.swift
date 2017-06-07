//
//  Telemetry.swift
//  Telemetry Logger
//
//  Created by Stephen Flores on 6/3/17.
//  Copyright © 2017 Stephen Flores. All rights reserved.
//

// Create global instance of data structure to use in main controller
// Utilizes dataString from DataHandler to retrieve data from string array
// Can call public functions to retrieve data in main thing

// Here, it's assumed to all be Double values

import Foundation

struct Telemetry {
    // ***** Options
    var shouldSave = true
    
    // ***** Data array (fixed size of 4)
    var data = Array(repeating: 0.0, count: 4)
    var id = ""
    
    // ***** Update data using string array (assumes no spaces)
    mutating func update(_ input: [String]) -> Bool{
        print("tel.update called with \(input)")
        // If unable to cast a data field, report it.
        var allValid = true
        id = input[0]
        
        // Walk through data bits
        // data[0] = input[1] // Depends on size of input array
        // data[1] = input[2]
        // data[2] = input[3]
        // data[3] = input[4]
        for i in 0..<(input.count - 1) {
            // Get input at correct index
            var inputString = input[i + 1]
            
            // Filter out extraneous characters
            inputString = inputString.replacingOccurrences(of: "\r", with: "")
            inputString = inputString.replacingOccurrences(of: "\t", with: "")
            inputString = inputString.replacingOccurrences(of: "\0", with: "")
            inputString = inputString.replacingOccurrences(of: "\n", with: "")
            inputString = inputString.replacingOccurrences(of: " ", with: "")
            
            // Try to pull double value, else set to default of 0.0
            if let value = Double(inputString) {
                data[i] = value
            } else {
                data[i] = 0.0
                allValid = false
            }
        }
        
        print("State of data is \(data)")
        
        // Save to file
        self.save(atFilename: "telemetry.csv")
        
        return allValid
    }
    
    // Create String
    func asString() -> String {
        
        var returnString = id + ","
        
        for value in data {
            returnString += String(value) + ", "
        }
        
        returnString += "\n"
        
        return returnString
    }
    
    // Save data
    func save(atFilename fileName: String) {
        if shouldSave {
            // Create string
            let str = asString()
            
            // Create document URL
            let documentsUrl = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0] as NSURL
            let fileURL = documentsUrl.appendingPathComponent(fileName)
            
            print("Saving to disk: '\(str)'")
            
            // Save
            if let oStream = OutputStream(url: fileURL!, append: true) {
                oStream.open()
                let length = str.lengthOfBytes(using: String.Encoding.utf8)
                oStream.write(str, maxLength: length) // Yes!!!!
                oStream.close()
            } else {
                print("Could not write to file \(fileName)")
            }
        }
    }
    
}

// Global instance
var telem = Telemetry()
