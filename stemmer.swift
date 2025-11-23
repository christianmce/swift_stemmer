/// *******************************************************************************
/// FPorterStemmer.swift - November 2025
/// Filter for perferming word stemming based on the Porter algorithm
/// Copyright (c) 2025 Christian Mauricio Castillo Estrada (cmce at unach.mx)
/// *******************************************************************************

/// This is the Porter stemming algorithm, ported to Swift from the version coded up in ANSI C by the author. It may be be regarded
/// as canonical, in that it follows the algorithm presented in Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
/// no. 3, pp 130-137, only differing from it at the points maked --DEPARTURE-- below.
/// See also http://www.tartarus.org/~martin/PorterStemmer
/// *******************************************************************************
/// The algorithm as described in the paper could be exactly replicated by adjusting the points of DEPARTURE, but this is barely necessary,
/// because (a) the points of DEPARTURE are definitely improvements, and (b) no encoding of the Porter stemmer I have seen is anything like
/// as exact as this version, even with the points of DEPARTURE!


import Foundation

enum StemmerError: Error {
    case nonASCIICharacters
    
    var localizedDescription: String {
        switch self {
        case .nonASCIICharacters:
            return "Only support English words with ASCII characters"
        }
    }
}

class Stemmer {
    private var b: [UInt8]
    private var k: Int
    private var j: Int
    
    init(word: String) throws {
        guard word.allSatisfy({ $0.isASCII }) else {
            throw StemmerError.nonASCIICharacters
        }
        
        self.b = Array(word.lowercased().utf8)
        self.k = b.count
        self.j = 0
    }
    
    /// isConsonant(i) is true <=> stem[i] is a consonant
    private func isConsonant(_ i: Int) -> Bool {
        switch b[i] {
        case UInt8(ascii: "a"), UInt8(ascii: "e"), UInt8(ascii: "i"), 
             UInt8(ascii: "o"), UInt8(ascii: "u"):
            return false
        case UInt8(ascii: "y"):
            return i == 0 ? true : !isConsonant(i - 1)
        default:
            return true
        }
    }
    
    /// measure() measures the number of consonant sequences in [0, j).
    /// if c is a consonant sequence and v a vowel sequence, and <..> indicates arbitrary presence,    
    ///    <c><v>       gives 0
    ///    <c>vc<v>     gives 1
    ///    <c>vcvc<v>   gives 2
    ///    <c>vcvcvc<v> gives 3
    ///    ....
    private func measure() -> Int {
        var n = 0
        var i = 0
        
        while i < j {
            if !isConsonant(i) {
                break
            }
            i += 1
        }
        i += 1
        
        while true {
            while i < j {
                if isConsonant(i) {
                    break
                }
                i += 1
            }
            if i >= j {
                return n
            }
            i += 1
            n += 1
            
            while i < j {
                if !isConsonant(i) {
                    break
                }
                i += 1
            }
            if i >= j {
                return n
            }
            i += 1
        }
    }
    
    /// hasVowel() is TRUE <=> [0, j-1) contains a vowel
    private func hasVowel() -> Bool {
        for i in 0..<j {
            if !isConsonant(i) {
                return true
            }
        }
        return false
    }
    
    /// doubleConsonant(i) is TRUE <=> i,(i-1) contain a double consonant.
    private func doubleConsonant(_ i: Int) -> Bool {
        guard i >= 1 else { return false }
        guard b[i] == b[i - 1] else { return false }
        return isConsonant(i)
    }
    
    /// cvc(i) is TRUE <=> i-2,i-1,i has the form consonant - vowel - consonant
    /// and also if the second c is not w,x or y. this is used when trying to restore an e at the end of a short word. e.g.    
    /// cav(e), lov(e), hop(e), crim(e), but snow, box, tray.    
    private func cvc(_ i: Int) -> Bool {
        guard i >= 2 else { return false }
        guard isConsonant(i) else { return false }
        guard !isConsonant(i - 1) else { return false }
        guard isConsonant(i - 2) else { return false }
        
        switch b[i] {
        case UInt8(ascii: "w"), UInt8(ascii: "x"), UInt8(ascii: "y"):
            return false
        default:
            return true
        }
    }
    
    /// ends(s) is true <=> [0, k) ends with the string s.
    private func ends(_ s: String) -> Bool {
        let sBytes = Array(s.utf8)
        let len = sBytes.count
        
        guard len <= k else { return false }
        
        let range = (k - len)..<k
        if Array(b[range]) == sBytes {
            j = k - len
            return true
        }
        return false
    }
    
    /// setTo(s) sets [j,k) to the characters in the string s, readjusting k.    
    private func setTo(_ s: String) {
        let sBytes = Array(s.utf8)
        let len = sBytes.count
        
        for i in 0..<len {
            b[j + i] = sBytes[i]
        }
        k = j + len
    }
    
    /// r(s) is used further down.
    private func r(_ s: String) {
        if measure() > 0 {
            setTo(s)
        }
    }
    
    /// step1ab() gets rid of plurals and -ed or -ing. e.g.    
    ///     caresses  ->  caress
    ///     ponies    ->  poni
    ///     ties      ->  ti
    ///     caress    ->  caress
    ///     cats      ->  cat
    ///
    ///     feed      ->  feed
    ///     agreed    ->  agree
    ///     disabled  ->  disable
    ///
    ///     matting   ->  mat
    ///     mating    ->  mate
    ///     meeting   ->  meet
    ///     milling   ->  mill
    ///     messing   ->  mess
    ///
    ///     meetings  ->  meet
    private func step1ab() {
        if b[k - 1] == UInt8(ascii: "s") {
            if ends("sses") {
                k -= 2
            } else if ends("ies") {
                setTo("i")
            } else if b[k - 2] != UInt8(ascii: "s") {
                k -= 1
            }
        }
        
        if ends("eed") {
            if measure() > 0 {
                k -= 1
            }
        } else if (ends("ed") || ends("ing")) && hasVowel() {
            k = j
            if ends("at") {
                setTo("ate")
            } else if ends("bl") {
                setTo("ble")
            } else if ends("iz") {
                setTo("ize")
            } else if doubleConsonant(k - 1) {
                k -= 1
                switch b[k - 1] {
                case UInt8(ascii: "l"), UInt8(ascii: "s"), UInt8(ascii: "z"):
                    k += 1
                default:
                    break
                }
            } else if measure() == 1 && cvc(k - 1) {
                setTo("e")
            }
        }
    }
    
    /// step1c() turns terminal y to i when there is another vowel in the stem.
    private func step1c() {
        if ends("y") && hasVowel() {
            b[k - 1] = UInt8(ascii: "i")
        }
    }
    
    /// step2() maps double suffices to single ones. so -ization ( = -ize
    /// plus -ation) maps to -ize etc. note that the string before the suffix
    /// must give m() > 0.
    private func step2() {
        guard k >= 2 else { return }
        
        switch b[k - 2] {
        case UInt8(ascii: "a"):
            if ends("ational") { r("ate"); return }
            if ends("tional") { r("tion"); return }
            
        case UInt8(ascii: "c"):
            if ends("enci") { r("ence"); return }
            if ends("anci") { r("ance"); return }
            
        case UInt8(ascii: "e"):
            if ends("izer") { r("ize"); return }
            
        case UInt8(ascii: "l"):
            if ends("bli") { r("ble"); return }
            if ends("alli") { r("al"); return }
            if ends("entli") { r("ent"); return }
            if ends("eli") { r("e"); return }
            if ends("ousli") { r("ous"); return }
            
        case UInt8(ascii: "o"):
            if ends("ization") { r("ize"); return }
            if ends("ation") { r("ate"); return }
            if ends("ator") { r("ate"); return }
            
        case UInt8(ascii: "s"):
            if ends("alism") { r("al"); return }
            if ends("iveness") { r("ive"); return }
            if ends("fulness") { r("ful"); return }
            if ends("ousness") { r("ous"); return }
            
        case UInt8(ascii: "t"):
            if ends("aliti") { r("al"); return }
            if ends("iviti") { r("ive"); return }
            if ends("biliti") { r("ble"); return }
            
        case UInt8(ascii: "g"):
            if ends("logi") { r("log"); return }
            
        default:
            break
        }
    }
    
    /// step3() deals with -ic-, -full, -ness etc. similar strategy to step2.
    private func step3() {
        switch b[k - 1] {
        case UInt8(ascii: "e"):
            if ends("icate") { r("ic"); return }
            if ends("ative") { r(""); return }
            if ends("alize") { r("al"); return }
            
        case UInt8(ascii: "i"):
            if ends("iciti") { r("ic"); return }
            
        case UInt8(ascii: "l"):
            if ends("ical") { r("ic"); return }
            if ends("ful") { r(""); return }
            
        case UInt8(ascii: "s"):
            if ends("ness") { r(""); return }
            
        default:
            break
        }
    }
    
    /// step4() takes off -ant, -ence etc., in context <c>vcvc<v>.
    private func step4() {
        guard k >= 2 else { return }
        
        switch b[k - 2] {
        case UInt8(ascii: "a"):
            if !ends("al") { return }
            
        case UInt8(ascii: "c"):
            if !ends("ance") && !ends("ence") { return }
            
        case UInt8(ascii: "e"):
            if !ends("er") { return }
            
        case UInt8(ascii: "i"):
            if !ends("ic") { return }
            
        case UInt8(ascii: "l"):
            if !ends("able") && !ends("ible") { return }
            
        case UInt8(ascii: "n"):
            if !ends("ant") && !ends("ement") && !ends("ment") && !ends("ent") {
                return
            }
            
        case UInt8(ascii: "o"):
            if ends("ion") && j > 1 && 
               (b[j - 1] == UInt8(ascii: "s") || b[j - 1] == UInt8(ascii: "t")) {
                // handled
            } else if !ends("ou") {
                return
            }
            
        case UInt8(ascii: "s"):
            if !ends("ism") { return }
            
        case UInt8(ascii: "t"):
            if !ends("ate") && !ends("iti") { return }
            
        case UInt8(ascii: "u"):
            if !ends("ous") { return }
            
        case UInt8(ascii: "v"):
            if !ends("ive") { return }
            
        case UInt8(ascii: "z"):
            if !ends("ize") { return }
            
        default:
            return
        }
        
        if measure() > 1 {
            k = j
        }
    }
    
    /// step5() removes a final -e if measure() > 1, and changes -ll to -l if measure() > 1    
    private func step5() {
        j = k
        
        if b[k - 1] == UInt8(ascii: "e") {
            let a = measure()
            if a > 1 || (a == 1 && !cvc(k - 2)) {
                k -= 1
            }
        }
        
        if b[k - 1] == UInt8(ascii: "l") && doubleConsonant(k - 1) && measure() > 1 {
            k -= 1
        }
    }
    
    private func get() -> String {
        return String(bytes: b[..<k], encoding: .utf8)!
    }
    
    func stem() -> String {
        step1ab()
        step1c()
        step2()
        step3()
        step4()
        step5()
        return get()
    }
}

/// Public function to get the stem of a word
func stem(_ word: String) -> Result<String, StemmerError> {
    guard word.count > 2 else {
        return .success(word)
    }
    
    do {
        let stemmer = try Stemmer(word: word)
        return .success(stemmer.stem())
    } catch let error as StemmerError {
        return .failure(error)
    } catch {
        return .failure(.nonASCIICharacters)
    }
}

// MARK: - Usage Examples

// Example 1: Using Result type
let result1 = stem("caresses")
switch result1 {
case .success(let stemmed):
    print("caresses -> \(stemmed)")  // caresses -> caress
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}

// Example 2: Direct usage with multiple words
let testWords = ["agreed", "disabled", "ponies", "ties", "cats", 
                 "meeting", "matting", "mating", "educational", "effectively"]

print("\nStemming examples:")
for word in testWords {
    if case .success(let stemmed) = stem(word) {
        print("\(word) -> \(stemmed)")
    }
}

// Example 3: Convenience function with default value
func stemWord(_ word: String) -> String {
    switch stem(word) {
    case .success(let stemmed):
        return stemmed
    case .failure:
        return word
    }
}

print("\nConvenience function:")
print("running -> \(stemWord("running"))")
print("flies -> \(stemWord("flies"))")
