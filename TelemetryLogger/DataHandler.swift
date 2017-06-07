//
//  DataHandler.swift
//  Telemetry Logger
//
//  Created by Stephen Flores on 6/3/17.
//  Copyright © 2017 Stephen Flores. All rights reserved.
//

// Your other files have access to the dataString variable. Use it at your 
// leisure, but do not set it to nothing; only read it.
// Also gives you access to disk saving.

import Foundation

// Data 
var dataString = ""

// TODO: - Add support for multiple telemIDs

// MARK: - Send to Telem
// Send complete dataString (full packet) to telem for handling
func sendToTelem(_ str: String) {
    // Break into components using commas
    let data = str.characters.split(separator: ",").map(String.init)
    
    // Could parse for telem IDs
    _ = telem.update(data)
}

// MARK: - Parser
// Look for newlines and append to dataString as necessary.
func parse(_ input: String) -> Bool {
    // If a newline is found, then parse the packet. Else, append it.
    if input.contains("\n") {
        let stringArray = toComponents(input)
        if stringArray.count == 1 {                             // ["123 \n 123"]
            if firstCharacter(of: stringArray[0]) == "\n" {     // ["\n 123"]
                printToTerminal(dataString)
                _ = sendToTelem(dataString)
                dataString = ""
                dataString += stringArray[0]
            } else {                                            // ["123 \n"]
                dataString += stringArray[0]
                printToTerminal(dataString)
                _ = sendToTelem(dataString)
                dataString = ""
            }
        } else if stringArray.count == 2 {                      // ["123\n", "123"]
            dataString += stringArray[0] // Add first
            printToTerminal(dataString)
            _ = sendToTelem(dataString)
            dataString = ""
            dataString += stringArray[1] // Add second
        } else {                         // Just a newline?
            printToTerminal(dataString)
            _ = sendToTelem(dataString)
            dataString = ""
            // Ignore newline character
        }
        return true
    } else {
        // Simple append
        dataString += input
        return false
    }
}

// MARK: - Helper functions
// Convert a string to an array of strings using newline. And remove spaces
func toComponents(_ str: String) -> [String] {
    var arr = str.characters.split(separator: "\n").map(String.init)
    
    for i in 0..<arr.count {
        arr[i] = arr[i].replacingOccurrences(of: " ", with: "")
    }
    
    return arr
}

// Get the first character of string
func firstCharacter(of str: String) -> String {
    return String(str[str.startIndex])
}

// Print raw string from serial to console
func printToTerminal(_ str: String) {
    print("Parser: \(str)")
}


// MARK: - File saving
func saveToDisk(data str: String, withName fileName: String) {
    if telem.shouldSave {
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
