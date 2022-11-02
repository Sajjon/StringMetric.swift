//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-02.
//

import Foundation

/// Algorithms for measuring string similarity.
public enum StringSimilarityAlgorithm: Sendable, Hashable {
    
    /// The [Damerau-Levenshtein][alg] distance algorithm.
    ///
    /// [alg]: https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#endnote_itman#Distance_with_adjacent_transpositions
    case damerauLevenshtein
    
    /// The [Hamming][alg] distance algorithm.
    ///
    /// [alg]: https://en.wikipedia.org/wiki/Hamming_distance
    case hamming
    
    /// The [Jaro-Winkler][alg] distance algorithm.
    /// [alg]: https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance
    case jaroWinkler
    
    /// The [Levenshtein][alg] distance algorithm.
    ///
    ///[alg]: https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_two_matrix_rows
    case levenshtein
    
    /// The [Most frequent K characters][alg] distance algorithm (non-normalized.)
    ///
    ///[alg]: https://web.archive.org/web/20191117082524/https://en.wikipedia.org/wiki/Most_frequent_k_characters
    case mostFrequentCharacters(k: Int)
    
    /// The [Most frequent K characters][alg] distance algorithm (normalized.)
    ///
    ///[alg]: https://www.semanticscholar.org/paper/A-high-performance-approach-to-string-similarity-K-Valdestilhas-Soru/2ce037c9b5d77972af6892c170396c82d883dab9
    case mostFrequentCharactersNormalized(K: Int)
}
