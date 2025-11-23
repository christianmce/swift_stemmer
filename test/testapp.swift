import Foundation

func testmain() {
    
    let inputHandle = FileHandle.standardInput
    let outputHandle = FileHandle.standardOutput
        
    while let line = readLine() {
        
        let stemmedWord = stem(line)
                
        if let data = (stemmedWord + "\n").data(using: .utf8) {
            outputHandle.write(data)
        }
    }
}

testmain()
