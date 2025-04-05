# SwiftUI Custom Rating & Feedback Prompt

**(Short Description - Reuse/expand the one we discussed)**
A SwiftUI component demonstrating how to implement a custom "Rate Our App" prompt. It uses StoreKit for positive ratings and a `mailto:` feedback form for negative responses, presented via a clean overlay.

**(Screenshot)**
![CustomRating](https://github.com/user-attachments/assets/84fb3673-4f8d-4db5-a41a-e687b644ccd4)


## Features

- Custom SwiftUI overlay view presented modally.
- Appears automatically after the main view loads (with a slight delay).
- Asks the user if they enjoyed the app experience.
- **"Yes" action:** Triggers the native `StoreKit.requestReview()` prompt (if conditions are met).
- **"No" action:** Presents a secondary feedback form.
- **Feedback Form:** Includes a `TextEditor` for user input.
- **Feedback Submission:** Uses the `mailto:` URL scheme to open the user's configured email client with pre-filled recipient, subject, and feedback body.
- **Error Handling:** Checks if an email client is available (`canOpenURL`) and shows an alert if none is found.
- Dismissible by tapping the background or dedicated close buttons.
- Uses blur and dimming effects for the background content.

## Requirements
- iOS 17.0+
- Xcode 16.0+
- Swift 5.7+
