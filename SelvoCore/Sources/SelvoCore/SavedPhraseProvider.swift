import Foundation

/// Offline suggestions from phrases saved on the phone. Always works, never random: the same
/// context and exclusions give the same suggestions in the same order.
public struct SavedPhraseProvider: SuggestionProvider {
    /// Phrases for one tile, two or more per style, best first.
    public struct Templates: Equatable, Sendable {
        public var plain: [String]
        public var witty: [String]
        public var short: [String]

        public init(plain: [String], witty: [String], short: [String]) {
            self.plain = plain
            self.witty = witty
            self.short = short
        }

        public func phrases(_ style: SuggestionStyle) -> [String] {
            switch style {
            case .plain: return plain
            case .witty: return witty
            case .short: return short
            }
        }
    }

    public init() {}

    public func suggestions(for context: SuggestionContext, count: Int, excluding: Set<String>) async -> [Suggestion] {
        phrases(for: context, count: count, excluding: excluding)
    }

    /// The same as `suggestions(for:count:excluding:)`, without `async`.
    ///
    /// Styles rotate in the order the context lists them, so a stack of three tries to hold one
    /// of each. When a style runs out the next style fills the slot. When every phrase is shown
    /// or excluded, it returns what remains, which may be fewer than `count`.
    public func phrases(for context: SuggestionContext, count: Int, excluding: Set<String>) -> [Suggestion] {
        pick(from: templates(for: context), styles: context.styles, count: count, excluding: excluding)
    }

    /// The next `count` cards for a stack: phrases not shown yet, then `startingOver` when
    /// they run out. Used by Another and by the refill after Incorrect.
    public func next(for context: SuggestionContext, count: Int, after stack: SuggestionStack) -> [Suggestion] {
        let fresh = phrases(for: context, count: count, excluding: stack.excluded)
        if fresh.count >= count { return fresh }
        return fresh + startingOver(
            for: context,
            count: count - fresh.count,
            onScreen: Set(stack.cards.map { $0.text }).union(fresh.map { $0.text }),
            incorrect: Set(stack.incorrect.map { $0.text })
        )
    }

    /// For when every phrase for this context has been shown: starts over so the stack can
    /// always hold `count` cards. It skips the cards on screen and, while it can, the phrases
    /// marked Incorrect. Then it adds the general phrases. Only if that is still not enough
    /// does a phrase marked Incorrect come back, because fewer than three cards breaks the rule.
    public func startingOver(
        for context: SuggestionContext,
        count: Int,
        onScreen: Set<String>,
        incorrect: Set<String>
    ) -> [Suggestion] {
        var result: [Suggestion] = []
        func add(_ templates: Templates, skipping skip: Set<String>) {
            guard result.count < count else { return }
            let taken = Set(result.map { $0.text })
            result += pick(from: templates, styles: context.styles, count: count - result.count,
                           excluding: skip.union(taken))
        }
        let own = templates(for: context)
        add(own, skipping: onScreen.union(incorrect))
        add(Self.general, skipping: onScreen.union(incorrect))
        add(own, skipping: onScreen)
        return result
    }

    private func pick(from templateSet: Templates, styles requested: [SuggestionStyle], count: Int,
                      excluding: Set<String>) -> [Suggestion] {
        let styles = requested.isEmpty ? SuggestionStyle.allCases : requested
        guard count > 0 else { return [] }

        var queues: [[String]] = styles.map { style in
            templateSet.phrases(style).filter { !excluding.contains($0) }
        }
        var used = Set<String>()
        var result: [Suggestion] = []
        var slot = 0

        while result.count < count {
            var found = false
            for offset in 0..<styles.count {
                let index = (slot + offset) % styles.count
                while let text = queues[index].first, used.contains(text) {
                    queues[index].removeFirst()
                }
                if let text = queues[index].first {
                    queues[index].removeFirst()
                    used.insert(text)
                    result.append(Suggestion(text: text, style: styles[index], source: .savedPhrase))
                    found = true
                    break
                }
            }
            if !found { break }
            slot += 1
        }
        return result
    }

    /// The phrase set for a context: the tile's own phrases, a set built from an unknown label,
    /// replies to heard text, or a general set.
    public func templates(for context: SuggestionContext) -> Templates {
        if let label = context.tileLabel?.trimmingCharacters(in: .whitespacesAndNewlines), !label.isEmpty {
            return Self.table[Self.key(label)] ?? Self.generic(label: label)
        }
        if let heard = context.heardText?.trimmingCharacters(in: .whitespacesAndNewlines), !heard.isEmpty {
            return Self.replies
        }
        return Self.general
    }

    /// True when the label has its own written phrases rather than the generic set.
    public static func hasTemplates(forLabel label: String) -> Bool {
        table[key(label)] != nil
    }

    static func key(_ label: String) -> String {
        label.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .lowercased()
    }

    static func generic(label: String) -> Templates {
        Templates(
            plain: ["Can we talk about \(label)?", "I want to tell you about \(label)."],
            witty: ["I have opinions about \(label).", "Ask me about \(label). I have thoughts."],
            short: ["\(label), please.", "\(label)?"]
        )
    }

    static let replies = Templates(
        plain: ["Yes, I'd like that.", "Let me think about it.", "Can you say that again?"],
        witty: ["Ask me again after coffee.", "Sure, if I get to pick."],
        short: ["Not today.", "Yes, please."]
    )

    static let general = Templates(
        plain: ["I want to say something.", "Can we talk for a minute?"],
        witty: ["Hold on, I have a thought.", "Give me a second, this one is good."],
        short: ["One minute.", "Listen, please."]
    )

    /// Keyed by lowercased tile label. Covers every tile in the demo profile.
    static let table: [String: Templates] = [
        // Photos
        // The first two of each style are the artboard's first stack and its stack after Another.
        "coffee": Templates(
            plain: ["Can we get coffee before work?", "Do we have time to stop for coffee?"],
            witty: ["Coffee first. Then I'll be nice.", "Coffee. Now. Please."],
            short: ["Is there time for coffee?", "I could use a coffee before we go.", "Coffee, please."]
        ),
        "dinner": Templates(
            plain: ["What are we having for dinner?", "Can we eat dinner together tonight?"],
            witty: ["I'm hungry enough to eat the menu.", "I vote for dinner. Early and big."],
            short: ["Dinner soon?", "I'm hungry."]
        ),
        "home": Templates(
            plain: ["I'd like to go home now.", "Can we head home soon?"],
            witty: ["I've had enough of the outside world for today.", "Home. My couch misses me."],
            short: ["Home, please.", "Let's go home."]
        ),
        "car": Templates(
            plain: ["Can we take the car?", "Can you drive me there?"],
            witty: ["I'll pick the music, you drive.", "Shotgun. Obviously."],
            short: ["Car, please.", "Let's drive."]
        ),
        "mom": Templates(
            plain: ["Can we call Mom?", "I'd like to see Mom today."],
            witty: ["Don't tell Mom. Actually, tell Mom.", "Let's call Mom before she calls us."],
            short: ["Call Mom?", "Where's Mom?"]
        ),
        "game": Templates(
            plain: ["Can we watch the game tonight?", "What time does the game start?"],
            witty: ["Nobody talk to me during the game.", "I have a feeling we win this one. I always say that."],
            short: ["Game on?", "What's the score?"]
        ),
        "bed": Templates(
            plain: ["I'm tired. I'd like to go to bed.", "Can we get ready for bed?"],
            witty: ["My bed is calling and I'm answering.", "I'm done. Tell everyone I said good night."],
            short: ["Bedtime.", "I'm tired."]
        ),
        "rosie": Templates(
            plain: ["Can we take Rosie for a walk?", "Has Rosie eaten yet?"],
            witty: ["Rosie is the best one in this family. Sorry.", "Rosie agrees with me, by the way."],
            short: ["Where's Rosie?", "Walk Rosie?"]
        ),
        "park": Templates(
            plain: ["Can we go to the park?", "I'd like to sit outside for a while."],
            witty: ["I need fresh air and a bench with a view.", "The park is calling. Let's not keep it waiting."],
            short: ["Park?", "Let's go outside."]
        ),
        "music": Templates(
            plain: ["Can you put some music on?", "Can we listen to my playlist?"],
            witty: ["I'm picking the music. That's final.", "Turn it up. This is a good one."],
            short: ["Music, please.", "Louder, please."]
        ),
        "movie": Templates(
            plain: ["Can we watch a movie tonight?", "What movie should we watch?"],
            witty: ["I'll pick the movie. You bring snacks.", "No spoilers. I mean it."],
            short: ["Movie night?", "Popcorn?"]
        ),
        "beach": Templates(
            plain: ["Can we go to the beach?", "I'd like to see the ocean."],
            witty: ["Sun, sand, and nobody asking me to do chores.", "I was built for the beach. Let's prove it."],
            short: ["Beach day?", "Ocean, please."]
        ),
        // Places
        "coffee shop": Templates(
            plain: ["Can we stop at the coffee shop?", "I'd like to sit at the coffee shop for a bit."],
            witty: ["They know my order. Let's not disappoint them.", "One coffee and I'll be very good company."],
            short: ["Coffee shop?", "My usual, please."]
        ),
        "store": Templates(
            plain: ["Can we go to the store?", "I need a few things from the store."],
            witty: ["I have a list. It's mostly snacks.", "Just a quick trip. I promise. Mostly."],
            short: ["Store, please.", "I need something."]
        ),
        "gym": Templates(
            plain: ["Can we go to the gym today?", "I'd like to work out this afternoon."],
            witty: ["Gym first. Then I've earned dinner.", "Let's go before I talk myself out of it."],
            short: ["Gym?", "Workout time."]
        ),
        "restaurant": Templates(
            plain: ["Can we eat out tonight?", "I'd like to go to a restaurant."],
            witty: ["Let's let someone else do the dishes tonight.", "I know what I want before we sit down."],
            short: ["Eat out?", "Table for us?"]
        ),
        "work": Templates(
            plain: ["What time do I need to be at work?", "Can you take me to work?"],
            witty: ["Work again. They really can't do it without me.", "Let's get there early so I can complain about it."],
            short: ["Work today?", "Time for work."]
        ),
        "stadium": Templates(
            plain: ["Can we go to a game at the stadium?", "What time should we leave for the stadium?"],
            witty: ["Good seats or no seats.", "I'll be the loud one. You've been warned."],
            short: ["Stadium?", "Let's go cheer."]
        ),
        "doctor": Templates(
            plain: ["When is my doctor's appointment?", "I'd like to talk to the doctor about this."],
            witty: ["Let's get the doctor over with, then lunch.", "Tell the doctor I'm doing great. Mostly."],
            short: ["Doctor today?", "I need the doctor."]
        ),
        // People (Mom and Rosie are above)
        "emily": Templates(
            plain: ["Can we call Emily?", "I'd like to see Emily this week."],
            witty: ["Emily will take my side on this.", "Ask Emily. She'll pretend she knows."],
            short: ["Call Emily?", "Where's Emily?"]
        ),
        "blake": Templates(
            plain: ["Can we invite Blake over?", "I'd like to talk to Blake."],
            witty: ["Blake owes me a rematch.", "Ask Blake. He'll agree with me."],
            short: ["Call Blake?", "Is Blake coming?"]
        ),
        "dad": Templates(
            plain: ["Can we call Dad?", "I'd like to see Dad soon."],
            witty: ["Dad will have a joke about this. A bad one.", "Let's ask Dad. He loves being asked."],
            short: ["Call Dad?", "Where's Dad?"]
        ),
        "sam": Templates(
            plain: ["Can Sam come over?", "I'd like to hang out with Sam."],
            witty: ["Sam and I have plans. Big ones. Probably snacks.", "Tell Sam I'm still winning."],
            short: ["Text Sam?", "Is Sam free?"]
        ),
        // Phrases
        "yes": Templates(
            plain: ["Yes, I'd like that.", "Yes, that works for me."],
            witty: ["Yes. I thought you'd never ask.", "Yes, and I was right."],
            short: ["Yes.", "Yes, please."]
        ),
        "no": Templates(
            plain: ["No, thank you.", "No, I don't want that."],
            witty: ["No. But nice try.", "That's a no from me."],
            short: ["No.", "Not now."]
        ),
        "thank you": Templates(
            plain: ["Thank you for your help.", "Thank you, I appreciate it."],
            witty: ["Thank you. You're my favorite today.", "Thanks. I owe you one. Maybe two."],
            short: ["Thank you.", "Thanks."]
        ),
        "wait": Templates(
            plain: ["Please wait, I'm not done yet.", "Can you give me a minute?"],
            witty: ["Hold on, I'm getting to the good part.", "Wait for it. It's worth it."],
            short: ["Wait.", "One second."]
        ),
        "not that": Templates(
            plain: ["Not that one. Something else.", "That's not what I meant."],
            witty: ["Close, but not that.", "Nope. Try again."],
            short: ["Not that.", "Something else."]
        ),
        "again": Templates(
            plain: ["Can you say that again?", "Can we do that again?"],
            witty: ["Again. That was the best part.", "One more time, for the people in the back."],
            short: ["Again.", "Once more."]
        ),
        "later": Templates(
            plain: ["Can we do this later?", "Let's talk about it later."],
            witty: ["Later. Future me can handle it.", "Ask me again after coffee."],
            short: ["Later.", "Not right now."]
        ),
        "funny": Templates(
            plain: ["That was really funny.", "I think that's hilarious."],
            witty: ["Okay, that one got me.", "I'm laughing on the inside. And the outside."],
            short: ["Funny.", "Ha. Good one."]
        ),
        "i don't know": Templates(
            plain: ["I don't know yet.", "I'm not sure. Let me think."],
            witty: ["No idea. Ask me something easier.", "Great question. No clue."],
            short: ["I don't know.", "Not sure."]
        ),
    ]
}
