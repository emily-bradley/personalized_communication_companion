# Selvo on TestFlight

This is how to get Selvo onto iPhones through TestFlight. You do the setup once. After that, each new build is one button in GitHub.

The workflow is `.github/workflows/testflight.yml`. It runs only when you start it by hand. It builds Selvo on a GitHub Mac, signs it with your Apple Developer account, and uploads it to App Store Connect.

## Part 1: setup you do once

1. **Confirm the bundle ID.** Selvo uses `com.emilykenney.selvo`. It is set in `project.yml` (`PRODUCT_BUNDLE_IDENTIFIER`, and `BUNDLE_ID` in `scripts/demo.sh`). A bundle ID cannot be changed after the app is created in App Store Connect, so decide now. If you want a different one, change both files before step 3.

2. **Find your Team ID.** Sign in at [developer.apple.com/account](https://developer.apple.com/account), open **Membership details**, and copy the **Team ID**. It is 10 letters and numbers.

3. **Register the bundle ID.** At developer.apple.com, open **Certificates, Identifiers & Profiles**, then **Identifiers**, then the **+** button. Choose **App IDs**, then **App**. Enter the description `Selvo` and choose **Explicit** with the bundle ID from step 1. Selvo needs no extra capabilities. Select **Continue**, then **Register**.

4. **Create the app record.** Sign in at [appstoreconnect.apple.com](https://appstoreconnect.apple.com), open **Apps**, select **+**, then **New App**.
   - Platform: iOS
   - Name: Selvo (if the name is taken, try a variation such as "Selvo: Your voice")
   - Primary language: English (U.S.)
   - Bundle ID: the one from step 1
   - SKU: any text you like, for example `selvo-ios`
   - Access: Full Access

5. **Create an App Store Connect API key.** In App Store Connect, open **Users and Access**, then **Integrations**, then **App Store Connect API**, then **Team Keys**. (If this is the first key, select **Request Access** and accept the terms.) Select **+**, name it `Selvo GitHub`, choose **App Manager** access, and select **Generate**.
   - Copy the **Issuer ID** shown above the list of keys.
   - Copy the **Key ID** of the new key.
   - Select **Download API Key**. Apple lets you download the `.p8` file only once, so keep it somewhere safe, such as your password manager.

6. **Add 4 repository secrets in GitHub.** Open the repository, then **Settings**, **Secrets and variables**, **Actions**, **New repository secret**. Add each of these:

   | Secret name | What to paste |
   | --- | --- |
   | `ASC_KEY_ID` | The Key ID from step 5 |
   | `ASC_ISSUER_ID` | The Issuer ID from step 5 |
   | `ASC_KEY_P8` | The whole text of the `.p8` file, including the `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` lines. Open the file in TextEdit to copy it. |
   | `APPLE_TEAM_ID` | The Team ID from step 2 |

   The Team ID is not secret, but keeping it with the others means the workflow reads everything from one place.

7. **Optional: archive from Xcode on your Mac.** If you also want to build for TestFlight from Xcode, open `Config/Signing.xcconfig` and replace `[EMILY_TEAM_ID]` with your Team ID. The workflow does not need this, because it passes the Team ID itself. The Simulator demo never needs it.

## Part 2: upload a build

1. Open the repository on GitHub and select the **Actions** tab.
2. Select **TestFlight** in the list on the left.
3. Select **Run workflow**, keep the branch as `main`, and select the green **Run workflow** button.
4. Wait about 15 to 25 minutes. A green check means the build was uploaded.

Each run uses the run number as the build number, so build numbers go up by 1 every time (1, 2, 3, and so on). The version stays 0.1.0 until it is changed in `project.yml` (`MARKETING_VERSION`).

## Part 3: add testers

1. In App Store Connect, open **Apps**, then **Selvo**, then **TestFlight**.
2. Wait for the build to finish processing. This usually takes 5 to 30 minutes after the upload. Apple sends an email when it is ready.
3. Export compliance is already answered: Selvo sets `ITSAppUsesNonExemptEncryption` to NO, so App Store Connect does not ask about encryption.
4. Under **Internal Testing**, select **+** to create a group (for example `Family`), and add people. Internal testers must be members of your App Store Connect team: add them first in **Users and Access** with any role, such as Marketing or Customer Support.
5. Turn on automatic distribution for the group, or add the build to the group by hand.
6. Each tester gets an email invitation. They install the **TestFlight** app from the App Store on their iPhone, open the invitation, and install Selvo.

Internal testing needs no review from Apple. External testing (people outside your team, by email or public link) needs a short Beta App Review for the first build, plus a test description and a contact email.

Each TestFlight build works for 90 days.

## Troubleshooting

**"These repository secrets are empty or missing"**
The first step names which ones. Add them as in Part 1, step 6. Secret names must match exactly, in capitals.

**Signing errors such as "No profiles for com.emilykenney.selvo were found" or "No Account for Team"**
- Check that `APPLE_TEAM_ID` is the 10 character Team ID, not your name or the Issuer ID.
- Check that the bundle ID is registered (Part 1, step 3) under the same team.
- Check that the bundle ID in `project.yml` matches the app record exactly.

**"Cloud signing permission error" or "not allowed to create certificates"**
The API key needs enough access to create a distribution certificate. Create a new key with **Admin** access, update `ASC_KEY_ID` and `ASC_KEY_P8`, and run again. Revoke the old key afterwards.

**"Invalid key" or "authentication failed"**
The `.p8` text was probably cut off. Paste it again into `ASC_KEY_P8`, with the BEGIN and END lines. Check that `ASC_KEY_ID` matches that key and that the key has not been revoked.

**"The bundle version must be higher than the previously uploaded version"**
A build with that number already exists, for example one you uploaded from Xcode. Run the workflow again: every run gets a higher number. If a build from Xcode used a number well above the run number, ask for the workflow to add a fixed offset to the run number.

**Upload rejected because of the SDK or Xcode version**
Apple sets a minimum Xcode version for uploads, and it rises each spring. Since April 28, 2026, uploads must be built with the iOS 26 SDK, so the TestFlight workflow selects Xcode 26 (`scripts/ci_select_xcode.sh 26`), while the main CI tests use Xcode 16. CI also builds every push with Xcode 26 so the upload build stays working, and runs the demo script with Xcode 16, 26 and 27 and every test with Xcode 27.

**The build uploaded but does not appear in TestFlight**
It is still processing. Check your email for a message from App Store Connect. If processing failed, the email says why.
