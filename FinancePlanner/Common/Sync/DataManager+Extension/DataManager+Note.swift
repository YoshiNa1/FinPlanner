//
//  DataManager+Note.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension DataManager {
    
    func setNote(date: Date, content: String, completion: @escaping (Note?, Error?) -> Void) {
        let note = Note(date: date, content: content)
        syncManager.getNote(by: date) { currNote, error in
            if let oldNote = currNote {
                if content == "" {
                    self.syncManager.doNoteAction(.deleteAction, note: oldNote, completion: completion)
                } else {
                    self.syncManager.doNoteAction(.editAction, note: oldNote, newNote: note, completion: completion)
                }
            } else {
                self.syncManager.doNoteAction(.createAction, note: note, completion: completion)
            }
        }
    }
    
    func getNote(by date: Date, completion: @escaping (Note?, Error?) -> Void) {
        syncManager.getNote(by: date, completion: completion)
    }
}
