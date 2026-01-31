/// *******************************************************************************
/// FPorterStemmer.swift - November 2025
/// Filter for perferming word stemming based on the Porter algorithm
/// Copyright (c) 2025 Christian Mauricio Castillo Estrada (cmce at unach.mx)
/// *******************************************************************************

import Foundation

func testMainCode() {
// Main Example: I have included Dr Porter's sample input and output text in a test suite (input.txt)
// Declare the URLs of the input and output files
    let urlInput = URL(fileURLWithPath: "input.txt")
    let urlOutput = URL(fileURLWithPath: "outputdata.txt")
    print("\n Swift Stemmer Output: \n")

    let Buffercapacity = 23700
    var entryLines: [String] = []
    var outputLines: [String] = []
    entryLines.reserveCapacity(Buffercapacity)
    outputLines.reserveCapacity(Buffercapacity)

    // Read file input.txt ---------------------------------------------------------------
    do {
        let contentBody = try String(contentsOf: urlInput, encoding: .utf8)
        entryLines = contentBody.components(separatedBy: .newlines)        
        print(" \(entryLines.count) input words were read")

        for rowword in entryLines {
            if case .success(let stemmed) = stem(rowword) {
                outputLines.append(stemmed)
            }      
        }
        
    } catch {
        print("Error reading file: \(error)")        
    }
    
    // Write file output  ----------------------------------------------------------------
    do {
        let contentBodyOut = outputLines.joined(separator: "\n")
        try contentBodyOut.write(to: urlOutput, atomically: true, encoding: .utf8)        
        print("File saved successfully")
        
    } catch {
        print("Error writing to file: \(error)")
    }

        
}

    
testMainCode()
