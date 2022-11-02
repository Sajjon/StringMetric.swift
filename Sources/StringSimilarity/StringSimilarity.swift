import Foundation

// MARK: Public
public extension String {
    
    /// Get similarity between other. (alias of `similarityJaroWinkler(between:)`.)
    /// - Parameter other: The other `String`.
    /// - Returns: The Jaro-Winkler similarity between the receiver and `other`.
    func similarity(
        with other: String,
        algorithm: StringSimilarityAlgorithm = .jaroWinkler
    ) -> Double {
        switch algorithm {
        case .jaroWinkler: return similarityJaroWinkler(with: other)
        case .damerauLevenshtein: return Double(similarityDamerauLevenshtein(with: other))
        case .hamming: return Double(similarityHamming(with: other))
        case .levenshtein: return Double(similarityLevenshtein(with: other))
        case let .mostFrequentCharacters(k): return Double(similarityMostFreqK(with: other, K: k))
        case let .mostFrequentCharactersNormalized(k): return Double(similarityNormalizedMostFrequentK(with: other, k: k))
        }
    }
    
    /// Get Damerau-Levenshtein similarity.
    ///
    /// Reference <https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_similarity#endnote_itman#similarity_with_adjacent_transpositions>
    /// - Parameter other: The other `String`.
    /// - Returns: The Damerau-Levenshtein similarity between the receiver and `other`.
    func similarityDamerauLevenshtein(
        with other: String
    ) -> Int {
        
        let selfCount = self.count
        let otherCount = other.count
        
        if self == other {
            return 0
        }
        if selfCount == 0 {
            return otherCount
        }
        if otherCount == 0 {
            return selfCount
        }
        
        var da: [Character: Int] = [:]
        
        var d = Array(repeating: Array(repeating: 0, count: otherCount + 2), count: selfCount + 2)
        
        let maxdist = selfCount + otherCount
        d[0][0] = maxdist
        for i in 1...selfCount + 1 {
            d[i][0] = maxdist
            d[i][1] = i - 1
        }
        for j in 1...otherCount + 1 {
            d[0][j] = maxdist
            d[1][j] = j - 1
        }
        
        for i in 2...selfCount + 1 {
            var db = 1
            
            for j in 2...otherCount + 1 {
                let k = da[other[j - 2]!] ?? 1
                let l = db
                
                var cost = 1
                if self[i - 2] == other[j - 2] {
                    cost = 0
                    db = j
                }
                
                let substition = d[i - 1][j - 1] + cost
                let injection = d[i][j - 1] + 1
                let deletion = d[i - 1][j] + 1
                let selfIdx = i - k - 1
                let otherIdx = j - l - 1
                let transposition = d[k - 1][l - 1] + selfIdx + 1 + otherIdx
                
                d[i][j] = Swift.min(
                    substition,
                    injection,
                    deletion,
                    transposition
                )
            }
            
            da[self[i - 2]!] = i
        }
        
        return d[selfCount + 1][otherCount + 1]
    }
    
    
    /// Get Hamming similarity.
    ///
    /// Note: Only applicable when string lengths are equal.
    ///
    /// Reference <https://en.wikipedia.org/wiki/Hamming_similarity>.
    /// - Parameter other: The other `String`.
    /// - Returns: The Hamming similarity between the receiver and `other`.
    func similarityHamming(
        with other: String
    ) -> Int {
        precondition(self.count == other.count)
        return zip(self, other).filter { $0 != $1 }.count
    }
    
    /// Get Jaro-Winkler similarity.
    ///
    /// (Score is normalized such that 0 equates to no similarity and 1 is an exact match).
    ///
    /// Reference <https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_similarity>
    /// - Parameter other: The other `String`.
    /// - Returns: The Jaro-Winkler similarity between the receiver and `other`.
    func similarityJaroWinkler(
        with other: String
    ) -> Double {
        
        var stringOne = self
        var stringTwo = other
        if stringOne.count > stringTwo.count {
            stringTwo = self
            stringOne = other
        }
        
        let stringOneCount = stringOne.count
        let stringTwoCount = stringTwo.count
        
        if stringOneCount == 0 && stringTwoCount == 0 {
            return 1.0
        }
        
        let matchingsimilarity = stringTwoCount / 2
        var matchingCharactersCount: Double = 0
        var transpositionsCount: Double = 0
        var previousPosition = -1
        
        // Count matching characters and transpositions.
        for (i, stringOneChar) in stringOne.enumerated() {
            for (j, stringTwoChar) in stringTwo.enumerated() {
                if max(0, i - matchingsimilarity)..<min(stringTwoCount, i + matchingsimilarity) ~= j {
                    if stringOneChar == stringTwoChar {
                        matchingCharactersCount += 1
                        if previousPosition != -1 && j < previousPosition {
                            transpositionsCount += 1
                        }
                        previousPosition = j
                        break
                    }
                }
            }
        }
        
        if matchingCharactersCount == 0.0 {
            return 0.0
        }
        
        // Count common prefix (up to a maximum of 4 characters)
        let commonPrefixCount = min(max(Double(self.commonPrefix(with: other).count), 0), 4)
        
        let jaroSimilarity = (matchingCharactersCount / Double(stringOneCount) + matchingCharactersCount / Double(stringTwoCount) + (matchingCharactersCount - transpositionsCount) / matchingCharactersCount) / 3
        
        // Default is 0.1, should never exceed 0.25 (otherwise similarity score could exceed 1.0)
        let commonPrefixScalingFactor = 0.1
        
        return jaroSimilarity + commonPrefixCount * commonPrefixScalingFactor * (1 - jaroSimilarity)
    }
    
    /// Get the Levenshtein similarity.
    ///
    /// Reference <https://en.wikipedia.org/wiki/Levenshtein_similarity#Iterative_with_two_matrix_rows>
    /// - Parameter other: The other `String`.
    /// - Returns: The Levenshtein similarity between the receiver and `other`.
    func similarityLevenshtein(
        with other: String
    ) -> Int {
        
        let selfCount = self.count
        let otherCount = other.count
        
        if self == other {
            return 0
        }
        if selfCount == 0 {
            return otherCount
        }
        if otherCount == 0 {
            return selfCount
        }
        
        // The previous row of similaritys
        var v0 = [Int](repeating: 0, count: otherCount + 1)
        // Current row of similaritys.
        var v1 = [Int](repeating: 0, count: otherCount + 1)
        // Initialize v0.
        // Edit similarity for empty self.
        for i in 0..<v0.count {
            v0[i] = i
        }
        
        for (i, selfCharacter) in self.enumerated() {
            // Calculate v1 (current row similaritys) from previous row v0
            
            // Edit similarity is delete (i + 1) chars from self to match empty t.
            v1[0] = i + 1
            
            // Use formula to fill rest of the row.
            for (j, otherCharacter) in other.enumerated() {
                let cost = selfCharacter == otherCharacter ? 0 : 1
                v1[j + 1] = Swift.min(
                    v1[j] + 1,
                    v0[j + 1] + 1,
                    v0[j] + cost
                )
            }
            
            // Copy current row to previous row for next iteration.
            for j in 0..<v0.count {
                v0[j] = v1[j]
            }
        }
        
        return v1[otherCount]
    }
    
    /// Get most frequent K similarity.
    ///
    /// Reference <https://web.archive.org/web/20191117082524/https://en.wikipedia.org/wiki/Most_frequent_k_characters>
    /// - Parameters:
    ///   - other: The other `String`.
    ///   - K: The number of most frequently occuring characters to use for the similarity comparison.
    ///   - maxsimilarity: The maximum similarity limit (defaults to a value of 10 if not provided).
    func similarityMostFreqK(
        with other: String,
        K: Int,
        maxsimilarity: Int = 10
    ) -> Int {
        
        maxsimilarity - mostFrequentKSimilarity(
            characterFrequencyHashOne: self.mostFrequentKHashing(K),
            characterFrequencyHashTwo: other.mostFrequentKHashing(K)
        )
    }
    
    /// Get normalized most frequent K similarity.
    ///
    /// (Score is normalized such that 0 equates to no similarity and 1 is an exact match).
    ///
    /// Reference <https://www.semanticscholar.org/paper/A-high-performance-approach-to-string-similarity-K-Valdestilhas-Soru/2ce037c9b5d77972af6892c170396c82d883dab9>
    /// - Parameters:
    ///   - other: The other `String`.
    ///   - k: The number of most frequently occuring characters to use for the similarity comparison.
    /// - Returns: The normalized most frequent K similarity between the receiver and `other`.
    func similarityNormalizedMostFrequentK(
        with other: String,
        k: Int
    ) -> Double {
        
        let selfMostFrequentKHash = self.mostFrequentKHashing(k)
        let otherMostFrequentKHash = other.mostFrequentKHashing(k)
        let commonCharacters = Set(selfMostFrequentKHash.keys).intersection(Set(otherMostFrequentKHash.keys))
        
        // Return early if there are no common characters between the two hashes
        guard !commonCharacters.isEmpty else {
            return 0
        }
        
        let similarity = commonCharacters.reduce(0) { characterCountSum, character -> Int in
            characterCountSum + selfMostFrequentKHash[character]! + otherMostFrequentKHash[character]!
        }
        
        return Double(similarity) / Double(self.count + other.count)
    }
}

// MARK: - Private methods
private extension String {
    
    /// Get a hash of character-frequency pairs for the receiver.
    ///
    /// If two characters have the same frequency, then favour the one that occurs first in the receiver.
    /// - Parameters:
    ///   - k: The maximum number of character-frequency pairs to include in the returned hash.
    /// - Returns: a `Dictionary` hash of the most frequent characters in the receiver.
    func mostFrequentKHashing(_ k: Int) -> [Character: Int] {
        
        let characterFrequencies = self.reduce(into: [Character: Int]()) { characterFrequencies, character in
            characterFrequencies[character] = (characterFrequencies[character] ?? 0) + 1
        }
        
        let sortedFrequencies = characterFrequencies.sorted { (characterFrequencies1, characterFrequencies2) -> Bool in
            // If frequencies are equal, sort against character index in receiver
            if characterFrequencies1.value == characterFrequencies2.value {
                return self.firstIndex(of: characterFrequencies1.key)! < self.firstIndex(of: characterFrequencies2.key)!
            }
            return characterFrequencies1.value > characterFrequencies2.value
        }
        
        // If receiver is shorter than `K` characters, use `sortedFrequencies.count`
        let clampedK = min(k, sortedFrequencies.count)
        
        return sortedFrequencies[0..<clampedK].reduce(into: [Character: Int]()) { mostFrequentKHash, characterFrequencyPair in
            mostFrequentKHash[characterFrequencyPair.key] = characterFrequencyPair.value
        }
    }
    
    /// Get the similarity measure between two character-frequency `Dictionary` hashes.
    /// - Parameters:
    ///   - characterFrequencyHashOne: a `Dictionary` hash returned from `mostFrequentKHashing(_ k: Int)` for a particular `String`.
    ///   - characterFrequencyHashTwo: a `Dictionary` hash returned from `mostFrequentKHashing(_ k: Int)` for a different `String`.
    func mostFrequentKSimilarity(
        characterFrequencyHashOne: [Character: Int],
        characterFrequencyHashTwo: [Character: Int]
    ) -> Int {
        
        let commonCharacters = Set(characterFrequencyHashOne.keys).intersection(Set(characterFrequencyHashTwo.keys))
        
        // Return early if there are no common characters between the two hashes
        guard !commonCharacters.isEmpty else {
            return 0
        }
        
        return commonCharacters.reduce(0) { characterCountSum, character -> Int in
            characterCountSum + characterFrequencyHashOne[character]!
        }
    }
}
