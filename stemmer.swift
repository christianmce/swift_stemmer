// **************************************************************************
// FPorterStemmer.swift - August 2023
// Filter for perferming word stemming based on the Porter algorithm
// Copyright (c) 2023 Christian Mauricio Castillo Estrada (cmce at unach.mx)
// **************************************************************************

// This is the Porter stemming algorithm, ported to Python from the version coded up in ANSI C by the author. It may be be regarded
// as canonical, in that it follows the algorithm presented in Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
// no. 3, pp 130-137, only differing from it at the points maked --DEPARTURE-- below.
// See also http://www.tartarus.org/~martin/PorterStemmer
// **************************************************************************
// The algorithm as described in the paper could be exactly replicated by adjusting the points of DEPARTURE, but this is barely necessary,
// because (a) the points of DEPARTURE are definitely improvements, and (b) no encoding of the Porter stemmer I have seen is anything like
// as exact as this version, even with the points of DEPARTURE!

import UIKit

class Stemmer {
  private var b = [Character]()
  // offset into b 
  private var i: Int
  // offset to end of stemmed word */
  private var i_end, k, k: Int
  // unit of size whereby b is increased 
  private let INC: Int = 50

  func add(_ ch: Character) {
    if (i == b.count)
    {
      var new_b = new Character[i+INC]
      var c: Int = 0
        while(c<i){
          new_b[c] = b[c]
        }
        b = new_b
    }
    b[i++] = ch
  }
   
  
  //***************************************************************** avances **********************
  var toDoCount: Int { return toDoItems.count }
  var doneCount: Int { return doneItems.count }
  private var doneItems = [ToDoItem]()
  
  // plist related
  var toDoPathURL: URL {
    let fileURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    guard let documentURL = fileURLs.first else {
      fatalError("Something went wrong. Documents url could not be found")
    }
    
    return documentURL.appendingPathComponent("toDoItems.plist")
  }
  
  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: nil)
    
    if let nsToDoItems = NSArray(contentsOf: toDoPathURL) {
      for dict in nsToDoItems {
        if let toDoItem = ToDoItem(dict: dict as! [String:Any]) {
          toDoItems.append(toDoItem)
        }
      }
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
    save()
  }
  
  @objc func save() {
    let nsToDoItems = toDoItems.map { $0.plistDict }
    
    guard nsToDoItems.count > 0 else {
      try? FileManager.default.removeItem(at: toDoPathURL)
      return
    }
    
    do {
      let plistData = try PropertyListSerialization.data(
        fromPropertyList: nsToDoItems,
        format: PropertyListSerialization.PropertyListFormat.xml,
        options: PropertyListSerialization.WriteOptions(0)
      )
      try plistData.write(to: toDoPathURL,
                          options: Data.WritingOptions.atomic)
    } catch {
      print(error)
    }
  }
  
  
  func add(_ item: ToDoItem) {
    toDoItems.append(item)
  }
  
  func item(at index: Int) -> ToDoItem {
    return toDoItems[index]
  }
  
  func doneItem(at index: Int) -> ToDoItem {
    return doneItems[index]
  }
  
  func checkItem(at index: Int) {
    let checkedItem = toDoItems.remove(at: index)
    doneItems.append(checkedItem)
  }
  
  func uncheckItem(at index: Int) {
    let uncheckedItem = doneItems.remove(at: index)
    toDoItems.append(uncheckedItem)
  }
  
  func removeAll() {
    toDoItems.removeAll()
    doneItems.removeAll()
  }
}
