/// MARK: - Usage Examples

/// Example 1: Using Result type
let result1 = stem("caresses")
switch result1 {
case .success(let stemmed):
    print("caresses -> \(stemmed)")  // caresses -> caress
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}



/// Example 2: Direct usage with multiple words
let testWords = ["agreed", "disabled", "educational", "ponies", "ties", "cats", "meeting", "matting", "effectively"]

print("\nStemming examples:")
for word in testWords {
    if case .success(let stemmed) = stem(word) {
        print("\(word) -> \(stemmed)")
    }
}



/// Example 3: Convenience function with default value
func stemWord(_ word: String) -> String {
    switch stem(word) {
    case .success(let stemmed):
        return stemmed
    case .failure:
        return word
    }
}

print("\n\n Usage Examples:")
print("running -> \(stemWord("running"))")
print("flies -> \(stemWord("meeting"))")
