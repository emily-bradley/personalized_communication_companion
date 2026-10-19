# Selvo: App Store readiness

What App Store Connect will ask about Selvo, the answers that match the app today, and what is still open. TestFlight internal testing needs only some of this; external testing and the App Store need all of it. Recheck each answer against the code before submitting, because the app is still changing.

## 1. Privacy policy

App Store Connect requires a privacy policy URL for every app, even one that collects nothing. Selvo needs a short public page (the website or a simple hosted page) that says, in plain words:

- **No data collected.** Selvo has no accounts, no analytics, no advertising, no tracking, and no servers. The profile (name, people, places, tiles, phrases, photos chosen for tiles, settings) is saved only on the phone.
- **Suggestions stay on the phone.** On iPhones with Apple Intelligence (iOS 26 and later), suggestions come from Apple's on-device model. Everywhere else they come from saved phrases. Nothing is sent anywhere.
- **Speaking stays on the phone.** Speak uses the iPhone's built-in voices.
- **Listen uses Apple speech recognition.** When the phone can recognize speech by itself, audio stays on the phone. When on-device recognition is not available on that phone or for that language, Apple's speech recognition service may process the audio to turn it into text. Selvo does not keep the audio. Apple's handling is covered by Apple's privacy policy.
- **Photos.** Selvo reads only the photos the person picks for a tile, and keeps its own copy on the phone.
- **Deleting data.** Deleting Selvo from the phone deletes everything.
- **Contact.** An email address for privacy questions.

The privacy manifest (`Selvo/Resources/PrivacyInfo.xcprivacy`) already declares no tracking and no collected data. Keep the policy and the manifest saying the same thing.

## 2. Privacy nutrition label

In App Store Connect, **App Privacy**: answer **No, we do not collect data from this app**. The label then reads **Data Not Collected**.

This holds because nothing leaves the phone under Selvo's control. When Listen falls back to Apple's speech service, Apple processes that audio as the platform provider; Selvo never receives or stores it. Confirm this reading against Apple's App Privacy guidance before answering. Revisit this answer if Selvo ever adds sync, backup to a server, crash reporting from a third party, or analytics.

## 3. Accessibility Nutrition Labels

App Store Connect lets an app declare which accessibility features work across its common tasks. Only claim a feature after testing every common task with it on a real iPhone: setup, choosing a tile, choosing words, Speak, Show, Listen, Help, and Settings. Each one below is **verify before claiming**.

| Feature | Why Selvo should qualify | Status |
| --- | --- | --- |
| VoiceOver | Controls are written with labels and hints | Verify before claiming |
| Larger Text | Dynamic Type up to the accessibility sizes, plus Selvo's own text size setting | Verify before claiming, especially tile grids at the largest sizes |
| Dark Interface | Nightlight is a dark theme and the default | Verify before claiming |
| Sufficient Contrast | Every text pair in the tokens clears WCAG AA in both themes, most clear AAA | Verify before claiming on screen, including Help and disabled states |
| Reduced Motion | Selvo has very little motion; check it respects Reduce Motion where it animates | Verify before claiming |

Features not to claim for now: Voice Control, Captions, and Audio Descriptions, unless they are tested and the label's definition fits. Differentiate Without Color Alone is likely true (Spoken and success always carry a check and a word) and is worth testing too.

## 4. Microphone and speech consent

- Selvo asks for the microphone and speech recognition only when the person opens Listen, never at launch.
- The purpose strings in `project.yml` are in plain words:
  - Microphone: "Selvo uses the microphone in Listen to show what people say to you as text."
  - Speech recognition: "Selvo turns what people say to you into text in Listen. When your phone can do this by itself, nothing is sent to Apple."
  - Photos: "Selvo lets you choose your own photos for your tiles."
- If permission is denied, Listen says so and offers Done. Everything else keeps working.
- Listen only runs while its screen is open and stops when the person leaves it.
- The speech recognition string says "nothing is sent to Apple" only when on-device recognition is available. Keep the privacy policy wording in step with it (section 1).

## 5. No medical claims

Selvo is a communication companion. It is not a medical device, does not diagnose, treat, or monitor any condition, and is not a replacement for speech therapy or emergency services.

- App Store description, screenshots, keywords, and the website must not claim therapy, rehabilitation, clinical outcomes, or treatment of aphasia or any condition.
- It is fine to say who Selvo is for, using the brand copy: "A modern communication app for non-verbal adults."
- Help shows a phrase in large type for people nearby. It does not call anyone or contact emergency services, and the store copy must not suggest it does.
- Choose the **Productivity** or **Lifestyle** category rather than **Medical**. **Health & Fitness** also invites medical expectations, so avoid it.
- Store copy follows the brand voice rules in `docs/design/system/README.md`: none of the words listed there to avoid, and no exclamation marks.

## 6. Age rating

Answer the age rating questions in App Store Connect honestly; the expected result is the lowest rating (4+ under the current system).

- No violence, mature themes, gambling, contests, or medical or treatment information.
- No web browsing, no messaging between people, and no content made by other people that Selvo shows to others.
- Suggestions come from Apple's on-device model or saved phrases. The model is instructed to stay adult and plain; check its output before answering the question about AI generated content, if App Store Connect asks it.
- Selvo is designed for adults but is safe for any age, so it does not need an age gate.

## 7. Before external TestFlight and App Store submission

- Privacy policy page written and hosted, with its URL in App Store Connect.
- Support URL (required): a page or an email link.
- App Privacy answered as Data Not Collected.
- Age rating questionnaire completed.
- Category chosen (see section 5).
- For external TestFlight: test description, feedback email, and Beta App Review contact details.
- For the App Store: description, keywords, subtitle, 6.9 inch iPhone screenshots (App Store Connect scales them for smaller iPhones), and app review notes explaining that Listen needs the microphone and that the demo profile does not load on a real iPhone (reviewers start at Welcome and can use **Set up together**).
- The 1024 by 1024 app icon in the asset catalog, with no transparency.

## Open items

- **Bundle ID.** `com.emilykenney.selvo` is a placeholder until Emily confirms it. It cannot change after the app record exists.
- **Xcode version for uploads.** Since April 28, 2026, App Store Connect requires the iOS 26 SDK, so the TestFlight workflow uses Xcode 26 and CI builds every push with Xcode 26 as well. Xcode 26 also compiles the on-device model suggestions (Foundation Models), which Xcode 16 builds leave out.
- **Privacy manifest.** It declares no required reason APIs. Recheck before each submission that Selvo still does not use UserDefaults, file timestamp, disk space, system boot time, or active keyboard APIs, directly or through a dependency.
- **Accessibility label testing.** Each feature in section 3 needs a test pass on a real iPhone before it is claimed.
- **Privacy policy host and contact email.** Emily to choose.
- **App name.** Check that "Selvo" is available in App Store Connect; have a fallback ready.
- **Category.** Productivity or Lifestyle, Emily to choose.
