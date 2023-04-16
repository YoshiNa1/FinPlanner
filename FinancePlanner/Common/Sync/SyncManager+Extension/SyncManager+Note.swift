//
//  SyncManager+Note.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension SyncManager {
    func doNoteAction(_ action: SyncAction, note: Note, newNote: Note? = nil, completion: @escaping (Note?, Error?) -> Void) {
        let requestCompletion: (NENote?, Error?) -> Void = { note, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let note = note {
                let complNote = Note(neNote: note)
                completion(complNote, error)
            }
        }
        if Connectivity.isConnected() {
            let request = NoteRequests()
            let noteDate = CalendarHelper().isoDateString(date: note.date)
            switch action {
            case .getAction:
                request.get(date: noteDate, completion: requestCompletion)
            case .createAction:
                request.create(date: noteDate, content: note.content, completion: requestCompletion)
            case .editAction:
                if let newNote = newNote {
                    request.update(date: noteDate, content: newNote.content, completion: requestCompletion)
                }
            case .deleteAction:
                request.delete(date: noteDate, completion: requestCompletion)
            }
        } else {
            self.cache(note: note, newNote: newNote, action: action)
            completion(note, nil)
        }
        
    }
    
    func cache(note: Note, newNote: Note? = nil, action: SyncAction) {
        let noteCache = NoteCache(note)
        switch action {
        case .createAction:
            self.add(note: noteCache)
        case .editAction:
            if let newNote = newNote {
                let newNoteCache = NoteCache(newNote)
                self.update(note: noteCache, withNewNote: newNoteCache)
            }
        case .deleteAction:
            self.delete(note: noteCache)
        default: break
        }
    }
    
    func getAllNotes(completion: @escaping ([Note], Error?) -> Void) {
        var complNotes = [Note]()
        if Connectivity.isConnected() {
            NoteRequests().getAll { notes, error in
                notes?.forEach({ neNote in
                    let note = Note(neNote: neNote)
                    complNotes.append(note)
                })
                completion(complNotes, error)
            }
        } else {
            let notes = self.realm.objects(NoteCache.self)
            notes.forEach({ cacheNote in
                let note = Note(cache: cacheNote)
                complNotes.append(note)
            })
            completion(complNotes, nil)
        }
    }
    
    func getNote(by date: Date, completion: @escaping (Note?) -> Void) {
        if Connectivity.isConnected() {
            let dateString = CalendarHelper().isoDateString(date: date)
            NoteRequests().get(date: dateString) { neNote, error in
                var note: Note?
                if let neNote = neNote {
                    note = Note(neNote: neNote)
                }
                completion(note)
            }
        } else {
            if let note = notes.first(where: { CalendarHelper().isDate(date: $0.date, equalTo: date) }) {
                completion(note)
            }
        }
    }
    
    func add(note: NoteCache) {
        try! self.realm.write({
            realm.add(note, update: .all)
        })
    }
    
    func update(note: NoteCache, withNewNote newNote: NoteCache) {
        try! self.realm.write({
            if(newNote.content == "") {
                realm.delete(note)
            } else {
                note.content = newNote.content
            }
        })
    }
    
    func delete(note: NoteCache) {
        try! self.realm.write({
            realm.delete(note)
        })
    }
        
}
