//
//  SyncManager+Note.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension SyncManager {
    func doNoteAction(_ action: SyncAction, note: Note, newNote: Note? = nil, completion: @escaping (Note?, Error?) -> Void) {
        let task = SyncTaskCache(note: note, newNote: newNote, actionType: action.rawValue)
        SyncTaskManager.instance.addTaskInQuery(task: task)
        
        let requestCompletion: (NENote?, Error?) -> Void = { note, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let note = note {
                SyncTaskManager.instance.removeTaskFromQuery(task: task)
                
                let complNote = Note(neNote: note)
                self.cache(note: complNote, action: action)
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
    
    func getNote(by date: Date, completion: @escaping (Note?, Error?) -> Void) {
        var complNote: Note?
        if Connectivity.isConnected() {
            let dateString = CalendarHelper().isoDateString(date: date)
            NoteRequests().get(date: dateString) { neNote, error in
                if let neNote = neNote {
                    complNote = Note(neNote: neNote)
                }
                completion(complNote, error)
            }
        } else {
            let notes = self.realm.objects(NoteCache.self)
            if let cacheNote = notes.first(where: { CalendarHelper().isDate(date: $0.date, equalTo: date) }) {
                let note = Note(cache: cacheNote)
                complNote = note
            }
            completion(complNote, nil)
        }
    }
    
    private func cache(note: Note, newNote: Note? = nil, action: SyncAction) {
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
   
    private func add(note: NoteCache) {
        try! self.realm.write({
            self.realm.add(note, update: .all)
        })
    }
    
    private func update(note: NoteCache, withNewNote newNote: NoteCache) {
        try! self.realm.write({
            if(newNote.content == "") {
                self.realm.delete(note)
            } else {
                note.content = newNote.content
            }
        })
    }
    
    private func delete(note: NoteCache) {
        try! self.realm.write({
            self.realm.delete(note)
        })
    }
        
}
