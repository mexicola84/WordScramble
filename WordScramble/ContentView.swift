//
//  ContentView.swift
//  WordScramble
//
//  Created by Jan Grimm on 06.12.23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    //day 31 challenge part 3: add a score to the view.
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never) //not automaticially capitalize the first letter
                }
                
                Section {
                    Text("Your current score is: \(score)")
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            // day 31 challenge part 2: built a toolbar button to start a new game whenever you want.
            .toolbar{
                Button("Start new Game") {
                    startGame()
                    score = 0
                }
            }
            .onSubmit(addNewWord) // submit the word into the usedwords array by submitting the textfield with return
            .onAppear(perform: startGame) // run a method when view is loaded
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let scoreMultiplier = answer.count //implement the letter count per answer as a base for the score.
        
        // error handling for inputing new words.
        
        //day 31 challenge part 1: Error when newWord == rootWord, minimum letters per new Word should be three.
        guard answer.count > 2 else {
            wordError(title: "Entry is too short", message: "Your input word is too short. Make sure your new word has at least three letters.")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Same as Root Word", message: "You have to build a new word out of the letters of \(rootWord)")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognize", message: "You can't just make them up, you know!")
            return
        }
        
        //Animates slide in in usedWords view
        withAnimation {
            //insert the new word on top of the list, that's why there's no use of .append
            usedWords.insert(answer, at: 0)
            score += 10 * scoreMultiplier //add to score.
            newWord = ""
        }
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        //loop over the input string and check if letter is part of the word and removes it afterwards. This way every letter is checked and if there'S one too much, the loop will return false.
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
