# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

## Firebase account persistence

Sign-in credentials are managed by Firebase Authentication, and user profiles
are saved in the Cloud Firestore `users` collection under each user's
Authentication UID. Enable the Email/Password provider in Firebase
Authentication and create a Firestore database for the configured Firebase
project. Deploy the included profile-access rules with:

```sh
firebase deploy --project echoconnect-58216 --only firestore:rules
```

The rules restrict profile reads and writes to the signed-in account. Profile
photo paths currently refer to files on the device where they were selected;
photo files themselves are not uploaded to Firebase Storage.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
