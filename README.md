![Swift 4.x](https://img.shields.io/badge/Swift-4.x-orange) ![Swift 5.x](https://img.shields.io/badge/Swift-5.x-orange)
# Swift-stemmer
An algorithm for suffix stripping Porter Stemmer
Porter's stemmer for Swift

Dr Porter explains the stemmer thus:

> The Porter stemming algorithm (or ‘Porter stemmer’) is a process for removing
> the commoner morphological and inflexional endings from words in English. Its
> main use is as part of a term normalisation process that is usually done when
> setting up Information Retrieval systems.

[http://tartarus.org/~martin/PorterStemmer/](http://tartarus.org/~martin/PorterStemmer/)

## How to use ##

1. Usage
   ```Swift
   let myword = "running"
   print("running -> \(stemWord(myword))")
   print("flies -> \(stemWord("flies"))")

   
2. Compile / Run
   ```
   swiftc FileSwift-stemmer.swift
   ./FileSwift-stemmer
   or FileSwift-stemmer.exe
