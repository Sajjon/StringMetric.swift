import XCTest
@testable import StringSimilarity

final class StringSimilarityTests: XCTestCase {
    func testLevenshtein() {
        XCTAssertEqual("".similarityLevenshtein(with: "sitting"), 7)
        XCTAssertEqual("kitten".similarityLevenshtein(with: ""), 6)
        XCTAssertEqual("kitten".similarityLevenshtein(with: "sitting"), 3)
        XCTAssertEqual("saturday".similarityLevenshtein(with: "sunday"), 3)

        XCTAssertEqual("君子和而不同".similarityLevenshtein(with: "小人同而不和"), 4)
    }

    func testDamerauLevenshtein() {
        XCTAssertEqual("".similarityDamerauLevenshtein(with: "sitting"), 7)
        XCTAssertEqual("kitten".similarityDamerauLevenshtein(with: ""), 6)
        XCTAssertEqual("kitten".similarityDamerauLevenshtein(with: "sitting"), 3)

        XCTAssertEqual("CA".similarityDamerauLevenshtein(with: "AC"), 1)
        XCTAssertEqual("specter".similarityDamerauLevenshtein(with: "spectre"), 1)
        XCTAssertEqual("CA".similarityDamerauLevenshtein(with: "ABC"), 2)

        XCTAssertEqual("君子和而不同".similarityDamerauLevenshtein(with: "小人同而不和"), 4)
    }

    func testHamming() {
        XCTAssertEqual("karolin".similarityHamming(with: "kathrin"), 3)
        XCTAssertEqual("karolin".similarityHamming(with: "kerstin"), 3)
        XCTAssertEqual("1011101".similarityHamming(with: "1001001"), 2)
        XCTAssertEqual("2173896".similarityHamming(with: "2233796"), 3)
    }

    func testMostFreqK() {
        XCTAssertEqual("research".similarityMostFreqK(with: "seeking", K: 2), 8)
        XCTAssertEqual("night".similarityMostFreqK(with: "nacht", K: 2), 9)
        XCTAssertEqual("my".similarityMostFreqK(with: "a", K: 2), 10)
        XCTAssertEqual("research".similarityMostFreqK(with: "resarch", K: 2), 6)
        XCTAssertEqual("aaaaabbbb".similarityMostFreqK(with: "ababababa", K: 2), 1)
        XCTAssertEqual("significant".similarityMostFreqK(with: "capabilities", K: 2), 7)
        XCTAssertEqual("aabbbcc".similarityMostFreqK(with: "bbccddee", K: 3), 5)
    }

    func testNormalizedMostFrequentK() {
        XCTAssertEqual("research".similarityNormalizedMostFrequentK(with: "seeking", k: 2), 0.2666, accuracy: 0.001)
        XCTAssertEqual("night".similarityNormalizedMostFrequentK(with: "nacht", k: 2), 0.2)
        XCTAssertEqual("my".similarityNormalizedMostFrequentK(with: "a", k: 2), 0.0)
        XCTAssertEqual("research".similarityNormalizedMostFrequentK(with: "resarch", k: 2), 0.4666, accuracy: 0.001)
        XCTAssertEqual("aaaaabbbb".similarityNormalizedMostFrequentK(with: "ababababa", k: 2), 1.0)
        XCTAssertEqual("significant".similarityNormalizedMostFrequentK(with: "capabilities", k: 2), 0.2609, accuracy: 0.001)
        XCTAssertEqual("aabbbcc".similarityNormalizedMostFrequentK(with: "bbccddee", k: 3), 0.6)
    }

    func testJaroWinkler() {
        XCTAssertEqual("".similarityJaroWinkler(with: ""), 1.0)
        XCTAssertEqual("".similarityJaroWinkler(with: "Yo"), 0.0)
        XCTAssertEqual("search".similarityJaroWinkler(with: "find"), 0.0)
        XCTAssertEqual("search".similarityJaroWinkler(with: "search"), 1.0)
        XCTAssertEqual("MARTHA".similarityJaroWinkler(with: "MARHTA"), 0.961, accuracy: 0.001)
        XCTAssertEqual("DWAYNE".similarityJaroWinkler(with: "DUANE"), 0.84, accuracy: 0.001)
        XCTAssertEqual("DIXON".similarityJaroWinkler(with: "DICKSONX"), 0.814, accuracy: 0.001)
        XCTAssertEqual("kitten".similarityJaroWinkler(with: "sitting"), 0.746, accuracy: 0.001)
        XCTAssertEqual("君子和而不同".similarityJaroWinkler(with: "小人同而不和"), 0.555, accuracy: 0.001)
    }
}
