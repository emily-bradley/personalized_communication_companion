import SwiftUI
import SelvoCore

/// Supporter setup (App-Setup): five steps on one template. Name, people, places, text size
/// and theme, voice. Drafts stay here until Finish builds and saves the profile.
struct SetupView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.theme) private var theme
    @Environment(\.dynamicTypeSize) private var systemTypeSize

    static let stepCount = 5
    static let slowRate = 0.4
    static let fastRate = 0.6

    @State private var step: Int
    @State private var name: String
    @State private var people: [TileItem]
    @State private var places: [TileItem]
    /// Rows added during setup; these show a text field for the name.
    @State private var addedIDs: Set<UUID> = []
    @State private var themeID: ThemeID = .night
    @State private var textSize: TextSize = .standard
    @State private var speechRate: Double = SetupView.slowRate

    /// `startStep` and `name` let previews and screenshot tests open a later step.
    init(startStep: Int = 1, name: String = "") {
        let demo = DemoProfile.lucas
        _step = State(initialValue: min(max(startStep, 1), SetupView.stepCount))
        _name = State(initialValue: name)
        _people = State(initialValue: Array(demo.tiles(in: .people).prefix(3)))
        // Three to start, like people, so "Add a place" shows without scrolling.
        _places = State(initialValue: Array(demo.tiles(in: .places).prefix(3)))
    }

    var body: some View {
        Screen {
            TopBar(title: "") {
                BackButton(action: goBack)
            } trailing: {
                Text("Step \(step) of \(SetupView.stepCount)")
                    .textStyle(TypeScale.caption)
                    .foregroundStyle(theme.colors.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            SetupProgressBar(step: step, total: SetupView.stepCount)

            // Plain stack when it fits; scrolls only when the content is taller than the screen.
            ScrollsWhenNeeded(inset: Spacing.space1) {
                stepContent
            }
            .frame(maxHeight: .infinity, alignment: .top)

            PrimaryButton(
                title: isLastStep ? "Finish" : "Continue",
                isEnabled: canContinue,
                accessibilityHint: isLastStep
                    ? "Saves this profile and opens Home"
                    : "Goes to step \(step + 1) of \(SetupView.stepCount)",
                action: advance
            )
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Steps

    private var stepContent: some View {
        VStack(alignment: .leading, spacing: Spacing.space4) {
            SetupStepHeader(title: stepTitle, helper: stepHelper)
            switch step {
            case 1:
                SetupNameField(text: $name, submit: advance)
            case 2:
                entryList($people, addTitle: "Add a person", fieldLabel: "Name of the new person", add: addPerson)
            case 3:
                entryList($places, addTitle: "Add a place", fieldLabel: "Name of the new place", add: addPlace)
            case 4:
                lookStep
            default:
                voiceStep
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stepTitle: String {
        switch step {
        case 1: return "Who is Selvo for?"
        case 2: return "Who does \(displayName) talk to most?"
        case 3: return "Where does \(displayName) go?"
        case 4: return "How should Selvo look?"
        default: return "How should Selvo sound?"
        }
    }

    private var stepHelper: String {
        switch step {
        case 1: return "Type the name they go by. They can change it later."
        case 2: return "Add a photo of each person. \(displayName) can change this later."
        case 3: return "Add the places \(displayName) goes most. \(displayName) can change this later."
        case 4: return "Choose a text size and a theme. \(displayName) can change these later."
        default: return "Choose how fast the words are spoken. \(displayName) can change this later."
        }
    }

    private func entryList(
        _ entries: Binding<[TileItem]>,
        addTitle: String,
        fieldLabel: String,
        add: @escaping () -> Void
    ) -> some View {
        VStack(spacing: Spacing.space2) {
            ForEach(entries) { entry in
                SetupListRow(
                    symbol: entry.wrappedValue.symbol,
                    label: entry.label,
                    note: entry.wrappedValue.note,
                    isEditable: addedIDs.contains(entry.wrappedValue.id),
                    fieldLabel: fieldLabel
                )
            }
            SetupAddRow(title: addTitle, action: add)
        }
    }

    /// Text size and theme side by side. The preview follows both choices as they change.
    private var lookStep: some View {
        VStack(alignment: .leading, spacing: Spacing.space6) {
            VStack(alignment: .leading, spacing: Spacing.space3) {
                SetupSectionLabel(title: "Text size")
                HStack(spacing: Spacing.space2) {
                    ForEach(TextSize.allCases, id: \.self) { size in
                        SetupChoicePill(
                            title: "A",
                            style: sampleStyle(for: size),
                            accessibilityName: sizeName(for: size),
                            isSelected: textSize == size
                        ) {
                            textSize = size
                        }
                    }
                }
                SetupPreviewCard(text: "Are we eating soon?")
                    .environment(\.theme, Theme(themeID))
                    .environment(\.dynamicTypeSize, max(systemTypeSize, textSize.minimumDynamicType))
            }
            VStack(alignment: .leading, spacing: Spacing.space3) {
                SetupSectionLabel(title: "Theme")
                HStack(spacing: Spacing.space3) {
                    ForEach(ThemeID.allCases, id: \.self) { id in
                        SetupThemeSwatch(themeID: id, isSelected: themeID == id) {
                            themeID = id
                        }
                    }
                }
            }
        }
    }

    private var voiceStep: some View {
        VStack(alignment: .leading, spacing: Spacing.space6) {
            VStack(alignment: .leading, spacing: Spacing.space3) {
                SetupSectionLabel(title: "Speech rate")
                HStack(spacing: Spacing.space2) {
                    SetupChoicePill(
                        title: "Slow",
                        accessibilityName: "Slow speech",
                        isSelected: speechRate < 0.5
                    ) {
                        speechRate = SetupView.slowRate
                    }
                    SetupChoicePill(
                        title: "Fast",
                        accessibilityName: "Fast speech",
                        isSelected: speechRate >= 0.5
                    ) {
                        speechRate = SetupView.fastRate
                    }
                }
            }
            VStack(alignment: .leading, spacing: Spacing.space2) {
                HStack(spacing: Spacing.space3) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(theme.colors.teal)
                        .accessibilityHidden(true)
                    Text("Voice: \(VoiceCatalog.defaultName ?? "default")")
                        .textStyle(TypeScale.label)
                        .foregroundStyle(theme.colors.ink)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, Spacing.space4)
                .frame(maxWidth: .infinity, minHeight: SetupMetrics.inputHeight)
                .background(RoundedRectangle(cornerRadius: Radius.md).fill(theme.colors.surfaceRaised))
                .overlay(RoundedRectangle(cornerRadius: Radius.md).strokeBorder(theme.colors.hairline, lineWidth: 1))
                .accessibilityElement(children: .combine)
                Text("You can choose a different voice in Settings.")
                    .textStyle(TypeScale.caption)
                    .foregroundStyle(theme.colors.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func sampleStyle(for size: TextSize) -> TypeStyle {
        switch size {
        case .standard: return TypeScale.label
        case .large: return TypeScale.heading
        case .larger: return TypeScale.message
        }
    }

    private func sizeName(for size: TextSize) -> String {
        switch size {
        case .standard: return "Standard text"
        case .large: return "Large text"
        case .larger: return "Larger text"
        }
    }

    // MARK: Actions

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The name in later questions. Step 1 cannot be passed without one.
    private var displayName: String {
        trimmedName.isEmpty ? "this person" : trimmedName
    }

    private var isLastStep: Bool { step == SetupView.stepCount }

    private var canContinue: Bool {
        step != 1 || !trimmedName.isEmpty
    }

    private func goBack() {
        if step > 1 {
            step -= 1
        } else {
            model.isInSetup = false
        }
    }

    private func advance() {
        guard canContinue else { return }
        if isLastStep {
            finish()
        } else {
            step += 1
        }
    }

    private func addPerson() {
        let person = TileItem(category: .people, label: "", symbol: "person.2", tint: .sunken, position: people.count)
        addedIDs.insert(person.id)
        people.append(person)
    }

    private func addPlace() {
        let place = TileItem(category: .places, label: "", symbol: "mappin.and.ellipse", tint: .sunken, position: places.count)
        addedIDs.insert(place.id)
        places.append(place)
    }

    /// Builds the profile from the drafts, saves it, and leaves setup. Photos and phrases
    /// start from the demo set.
    private func finish() {
        let demo = DemoProfile.lucas
        let tiles: [TileItem] = demo.tiles(in: .photos)
            + numbered(people)
            + numbered(places)
            + demo.tiles(in: .phrases)
        let profile = Profile(
            name: trimmedName,
            theme: themeID,
            textSize: textSize,
            speechRate: speechRate,
            readingFont: .lexend,
            styles: demo.styles,
            helpTitle: "I need help.",
            helpPhrase: demo.helpPhrase,
            tiles: tiles,
            hasCompletedSetup: true
        )
        try? model.store.save(profile)
        model.profile = profile
        model.isInSetup = false
    }

    /// Drops rows left without a name and numbers the rest from 0 so positions stay fixed.
    private func numbered(_ items: [TileItem]) -> [TileItem] {
        let named: [TileItem] = items.compactMap { (item: TileItem) -> TileItem? in
            var copy = item
            copy.label = item.label.trimmingCharacters(in: .whitespacesAndNewlines)
            return copy.label.isEmpty ? nil : copy
        }
        return named.enumerated().map { pair -> TileItem in
            var copy = pair.element
            copy.position = pair.offset
            return copy
        }
    }
}
