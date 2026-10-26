# Password reset email codes

The callable Functions send a four-digit, 10-minute code through SendGrid. Verification allows at most five guesses. A successful verification returns a short-lived, one-use ticket; only the Admin SDK can then update the Firebase Authentication password.

## One-time Firebase setup

1. In SendGrid, verify a sender address and create an API key with Mail Send permission.
2. From the repository root, select project `taskora-551f1` with `firebase use taskora-551f1`.
3. Set the Functions secrets (values are prompted interactively; do not commit them):

   ```powershell
   firebase functions:secrets:set SENDGRID_API_KEY
   firebase functions:secrets:set RESET_CODE_PEPPER
   firebase functions:secrets:set RESET_SENDER_EMAIL
   ```

   Use a random `RESET_CODE_PEPPER` of at least 32 characters and the verified SendGrid sender for `RESET_SENDER_EMAIL`.
4. Install dependencies with `npm install` inside `functions`, then deploy with `firebase deploy --only functions` from the repository root.
5. Run `flutter pub get` so Flutter resolves `cloud_functions`.

Cloud Functions deployment requires a Firebase project with billing enabled (Blaze), Firestore enabled, and the Firebase CLI authenticated. Firestore TTL can optionally be enabled for `passwordResetChallenges` using the `expiresAt` field to remove expired records automatically.
