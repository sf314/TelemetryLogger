//
//  ViewController.swift
//  Telemetry Logger
//
//  Created by Stephen Flores on 6/3/17.
//  Copyright © 2017 Stephen Flores. All rights reserved.
//  Uses the amazing ORSSerialPort open source library!
//

// Take data from telem object declared in Telemetry.swift

import Cocoa

class TelemetryController: NSViewController, ORSSerialPortDelegate {
    
    // ********** Data structure ***********************************************
    let serialPortManager = ORSSerialPortManager.shared()
    var serialPort: ORSSerialPort? {
        didSet { // Is this necessary?
            oldValue?.close()
            oldValue?.delegate = nil
            serialPort?.delegate = nil
        }
    }
    
    // ********** Funcs ********************************************************
    @IBAction func connectPort(_ sender: AnyObject) {
        if let port = serialPort {
            if port.isOpen {
                port.close()
                print("Closed port")
                connectButton.title = "Connect"
            } else {
                port.open()
                port.delegate = self // BLOODY HELL
                port.baudRate = 9600
                port.numberOfStopBits = 1
                port.parity = ORSSerialPortParity(rawValue: 0)!
                port.numberOfStopBits = 1
                port.dtr = false
                port.rts = false
                connectButton.title = "Disconnect"
                print("Opened port")
            }
        }
    }
    
    
    // ********** Protocol compliance ******************************************
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("Removed from system")
        self.serialPort = nil
        connectButton.title = "Connect"
        // Would set serial port to nil
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) { // Here's where data is received
        if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            print(string)
            
            // Parse for newline
            // TODO: - Add parsing code
            // Shall manipulate dataString by assignment.
            let shouldUpdate = parse(string as String)
            if shouldUpdate {
                self.updateUI(telem)
            }
            
            // Add to serial window
            self.serialWindow.textStorage?.mutableString.append(string as String)
            self.serialWindow.needsDisplay = true
            serialWindow.scrollToEndOfDocument(self)
        } else {
            print("Invalid received data")
        }
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        connectButton.title = "Disconnect"
        print("Port was opened")
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        connectButton.title = "Connect"
        serialWindow.scrollToEndOfDocument(self)
        print("Port was closed")
    }
    
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("SerialPort \(serialPort) encountered an error: \(error)")
    }
    
    
    
    // ********** UI Elements **************************************************
    
    // Windows
    @IBOutlet weak var serialWindow: NSTextView!
    @IBOutlet weak var commandWindow: NSTextField!
    
    // Buttons
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var savingButton: NSButton!
    @IBAction func sendButton(sender: AnyObject!) {
        let packet = commandWindow.stringValue
        if let data = packet.data(using: String.Encoding.utf8) {
            serialPort?.send(data)
            let notifyOfActivation = "Command sent (\(packet))\n"
            self.serialWindow.textStorage?.mutableString.append(notifyOfActivation)
            self.serialWindow.needsDisplay = true
            serialWindow.scrollToEndOfDocument(self)
        } else {
            let notifyOfActivation = "Invalid Data. Cannot send.\n"
            self.serialWindow.textStorage?.mutableString.append(notifyOfActivation)
            self.serialWindow.needsDisplay = true
            serialWindow.scrollToEndOfDocument(self)
        }
    }
    
    // Telemetry fields
    @IBOutlet weak var telemField1: NSTextField!
    @IBOutlet weak var telemField2: NSTextField!
    @IBOutlet weak var telemField3: NSTextField!
    @IBOutlet weak var telemField4: NSTextField!
    
    // Update UI
    func updateUI(_ tel: Telemetry) {
        telemField1.stringValue = String(tel.data[0])
        telemField2.stringValue = String(tel.data[1])
        telemField3.stringValue = String(tel.data[2])
        telemField4.stringValue = String(tel.data[3])
    }
    
    // Saving toggle
    @IBAction func toggleSave(_ sender: NSButton!) {
        if sender.state == NSOnState {
            telem.shouldSave = true
        } else {
            telem.shouldSave = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectButton.title = "Connect"
        serialWindow.isEditable = false
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

