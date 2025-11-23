/// *******************************************************************************
/// FPorterStemmer.swift - November 2025
/// Filter for perferming word stemming based on the Porter algorithm
/// Copyright (c) 2025 Christian Mauricio Castillo Estrada (cmce at unach.mx)
/// *******************************************************************************

import Foundation

func testmain() {
    let fileName = "in.txt"    
    let currentDirectory = FileManager.default.currentDirectoryPath
    let filePath = "\(currentDirectory)/\(fileName)"
    let outputHandle = FileHandle.standardOutput
    
    guard FileManager.default.fileExists(atPath: filePath) else {
        print("Error: The file '\(fileName)' does not exist in this \(currentDirectory)")
        return
    }
    
    do {
        
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {    
       
        let stemmedWord = stem(line)
                
        if let data = (stemmedWord + "\n").data(using: .utf8) {
            outputHandle.write(data)
        }
    }
        
}

    
testmain()
