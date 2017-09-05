//
//  Transcript.swift
//  SpeechToText
//
//  Created by Jakob Stoeck on 5/18/17.
//  Copyright © 2017 Jakob Stoeck. All rights reserved.
//

import Foundation
import Speech
import os.log

class Transcript {

    let text: String
    static let appGroup = "group.de.jakobstoeck.voicetotext"
    static let settings = UserDefaults(suiteName: Transcript.appGroup)!
    static let lastMessageKey = "Transcript/lastTranscript"
    static let lastMessageDefault = ""

    init?(text: String) {
        self.text = text
    }

    convenience init?(googleSpeechApiResponse data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as! [String:[[String:[[String:Any]]]]] else {
            return nil
        }
        // the result may be split in multiple arrays. take the first alternative of each array and concatenate the sentences
        let transcript = (json["results"]!).flatMap {
            $0["alternatives"]![0]["transcript"] as? String
            }.joined(separator: "")
        self.init(text: transcript)
    }

    convenience init?(appleSpeechApiResponse result: SFSpeechRecognitionResult) {
        self.init(text: result.bestTranscription.formattedString)
    }

    class func getLastMessage() -> String {
        guard let text = Transcript.settings.string(forKey: Transcript.lastMessageKey) else {
            return lastMessageDefault
        }
        return text
    }

    class func getLanguage() -> String {
        if let lang = Transcript.settings.string(forKey: "language_preference") {
            return lang
        }
        else if let lang = Locale.preferredLanguages.first {
            return lang
        }
        else {
            return "en-GB"
        }
    }

    func save() {
        Transcript.settings.set(text, forKey: Transcript.lastMessageKey)
    }
}
