//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-02.
//

import Foundation

/// Algorithms for measuring string similarity.
public enum StringSimilarityAlgorithm: Sendable, Hashable, CustomStringConvertible {
    
    /// The [Damerau-Levenshtein][alg] similarity algorithm.
    ///
    /// [alg]: https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_similarity#endnote_itman#similarity_with_adjacent_transpositions
    case damerauLevenshtein
    
    /// The [Hamming][alg] similarity algorithm.
    ///
    /// [alg]: https://en.wikipedia.org/wiki/Hamming_similarity
    case hamming
    
    /// The [Jaro-Winkler][alg] similarity algorithm.
    /// [alg]: https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_similarity
    case jaroWinkler
    
    /// The [Levenshtein][alg] similarity algorithm.
    ///
    ///[alg]: https://en.wikipedia.org/wiki/Levenshtein_similarity#Iterative_with_two_matrix_rows
    case levenshtein
    
    /// The [Most frequent K characters][alg] similarity algorithm (non-normalized.)
    ///
    ///[alg]: https://web.archive.org/web/20191117082524/https://en.wikipedia.org/wiki/Most_frequent_k_characters
    case mostFrequentCharacters(k: Int)
    
    /// The [Most frequent K characters][alg] similarity algorithm (normalized.)
    ///
    ///[alg]: https://www.semanticscholar.org/paper/A-high-performance-approach-to-string-similarity-K-Valdestilhas-Soru/2ce037c9b5d77972af6892c170396c82d883dab9
    case mostFrequentCharactersNormalized(K: Int)
}

public extension StringSimilarityAlgorithm {
    var description: String {
        switch self {
        case let .mostFrequentCharactersNormalized(K): return "Normalized Most Frequent K Characters (k=\(K))"
        case let .mostFrequentCharacters(K): return "Most Frequent K Characters (k=\(K))"
        case .levenshtein: return "Levenshtein"
        case .jaroWinkler: return "Jaro-Winkler"
        case .hamming: return "Hamming"
        case .damerauLevenshtein: return "Damerau-Levenshtein"
        }
    }
}
