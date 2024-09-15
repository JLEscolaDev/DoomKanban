//
//  CloudKitManager.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import CloudKit
import GameKit

class CloudKitManager {
    // We use public instead of private because we want a public leaderboard even if private uses users storage and public uses apps storage and could cost us some money
    let publicCloudDatabase = CKContainer.default().publicCloudDatabase
    
    // Guardar el LeaderboardEntry
    func checkLeaderboardNameAvailability(displayName: String, completion: @escaping (Bool, Error?) -> Void) {
        let predicate = NSPredicate(format: "displayName == %@", displayName)
        let query = CKQuery(recordType: "LeaderboardEntry", predicate: predicate)

        publicCloudDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: ["gameCenterId"], resultsLimit: CKQueryOperation.maximumResults) { (result: Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>) in
            switch result {
            case .success(let (matchResults, _)):
                let authenticatedPlayerId = GKLocalPlayer.local.gamePlayerID // Use gamePlayerID

                if let firstMatch = matchResults.first {
                    switch firstMatch.1 {
                    case .success(let record):
                        if let existingGameCenterId = record["gameCenterId"] as? String {
                            // Directly compare authenticatedPlayerId with existingGameCenterId
                            if existingGameCenterId == authenticatedPlayerId {
                                // Name belongs to the authenticated player
                                completion(true, nil)
                            } else {
                                // Name is taken by another player
                                completion(false, nil)
                            }
                        } else {
                            // No gameCenterId found, name is available
                            completion(true, nil)
                        }
                    case .failure(let error):
                        completion(false, error)
                    }
                } else {
                    // No match found, name is available
                    completion(true, nil)
                }
            case .failure(let error):
                completion(false, error)
            }
        }
    }


    
    // Cargar los LeaderboardEntry
    func fetchLeaderboardEntries(completion: @escaping ([LeaderboardEntry]?, Error?) -> Void) {
        let query = CKQuery(recordType: "LeaderboardEntry", predicate: NSPredicate(value: true))
        
        publicCloudDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: ["gameCenterId", "displayName", "score"], resultsLimit: CKQueryOperation.maximumResults) { result in
            switch result {
            case .success(let (matchResults, _)):
                var entries: [LeaderboardEntry] = []
                for matchResult in matchResults {
                    switch matchResult.1 {
                    case .success(let record):
                        if let gameCenterId = record["gameCenterId"] as? String,
                           let displayName = record["displayName"] as? String,
                           let score = record["score"] as? Int {
                            let entry = LeaderboardEntry(gameCenterId: gameCenterId, displayName: displayName, score: score)
                            entries.append(entry)
                        }
                    case .failure(let error):
                        print("Error with record: \(error)")
                    }
                }
                completion(entries, nil)
            case .failure(let error):
                print("Error fetching leaderboard entries: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
    
    // Function to save or update leaderboard entry
    func saveLeaderboardEntry(gameCenterId: String, displayName: String, score: Int, completion: @escaping (Error?) -> Void) {
        let predicate = NSPredicate(format: "displayName == %@", displayName)
        let query = CKQuery(recordType: "LeaderboardEntry", predicate: predicate)

        publicCloudDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { (result: Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>) in
            switch result {
            case .success(let (matchResults, _)):
                if let firstMatch = matchResults.first {
                    switch firstMatch.1 {
                    case .success(let record):
                        if let existingGameCenterId = record["gameCenterId"] as? String, existingGameCenterId == gameCenterId {
                            if let existingScore = record["score"] as? Int, existingScore < score {
                                record["score"] = score
                                self.publicCloudDatabase.save(record) { savedRecord, saveError in
                                    if let saveError = saveError {
                                        print("Error updating record: \(saveError.localizedDescription)")
                                        completion(saveError)
                                    } else {
                                        print("Record updated successfully: \(savedRecord!)")
                                        completion(nil)
                                    }
                                }
                            } else {
                                print("New score is not higher than the existing score. No update needed.")
                                completion(nil)
                            }
                        } else {
                            let nameError = NSError(domain: "CloudKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "This name is already taken by another player."])
                            completion(nameError)
                        }
                    case .failure(let error):
                        completion(error)
                    }
                } else {
                    let record = CKRecord(recordType: "LeaderboardEntry")
                    record["gameCenterId"] = gameCenterId
                    record["displayName"] = displayName
                    record["score"] = score

                    self.publicCloudDatabase.save(record) { savedRecord, saveError in
                        if let saveError = saveError {
                            print("Error saving new record: \(saveError.localizedDescription)")
                            completion(saveError)
                        } else {
                            print("Record saved successfully: \(savedRecord!)")
                            completion(nil)
                        }
                    }
                }
            case .failure(let error):
                print("Error querying leaderboard: \(error.localizedDescription)")
                completion(error)
            }
        }
    }
}
