# Swift-stemmer
An algorithm for suffix stripping Porter Stemmer
Porter's stemmer for Swift

## How to use ##

1. Add the dependency to your Cargo.toml

    ```toml
    [dependencies.stem]
    git = "https://github.com/christianmce/swift_stemmer"

2. Usage
   ```swift
  let myword = "running"  
  print("running -> \(stemWord(myword))")
  print("flies -> \(stemWord("flies"))")

   ```
3. Compile / Run

   `swift command`
