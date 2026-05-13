# qcraft-app

A lean Flutter client for the **q-engine** quiz API.

## Stack

Kept deliberately small — no bloc, no get_it, no codegen.

| Layer            | Choice                       |
|------------------|------------------------------|
| HTTP             | `dio` (also multipart upload) |
| File picking     | `file_picker`                |
| State            | Plain `setState` + a single `ChangeNotifier` for the in-progress quiz |
| Routing          | `Navigator` (no go_router)   |
| Models           | Hand-written (no `json_serializable`/`build_runner`) |
| Theming          | Material 3, single `ThemeData` |

## One-time setup on your dev machine

The server only holds the source — Flutter isn't installed here. From your local
machine (with Flutter SDK installed):

```bash
cd qcraft-app
flutter create --org name.codeetp --project-name qcraft_app --platforms=android,ios .
flutter pub get
```

`flutter create .` generates the `android/` and `ios/` platform folders without
touching `pubspec.yaml` or `lib/`.

## Run

The API base URL is injected at build time so you can switch between dev and
prod without code changes:

```bash
# Against the public prod API
flutter run --dart-define=API_BASE_URL=https://qcraft.code-etp.name.ng/

# Against a local q-engine on your machine
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/   # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:3000/  # iOS simulator
```

Default base URL (if `--dart-define` is omitted) is the prod domain.

## Build a release APK

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://qcraft.code-etp.name.ng/
```

## What the app does

* **Documents tab** — list, upload (PDF / DOCX / DOC / PPTX / TXT, 25 MB cap),
  delete. Uploads kick off server-side embedding automatically.
* **Quizzes tab** — list saved quizzes, tap to generate questions, take a quiz,
  see the result + weak topics.
* **Create quiz** — pick one or more documents, choose count / difficulty / type
  (MCQ, FillInTheBlank, TrueFalse, Theory, Any), optional duration.

## API surface used

| Method | Path                  | Purpose                       |
|--------|-----------------------|-------------------------------|
| GET    | `/document`           | List documents                |
| POST   | `/document/upload`    | Upload (multipart `files`)    |
| DELETE | `/document/:id`       | Delete                        |
| GET    | `/quiz`               | List quizzes with questions   |
| POST   | `/quiz/create`        | Create quiz definition        |
| POST   | `/quiz/generate/:id`  | Generate questions for quiz   |
| POST   | `/quiz/evaluate`      | Evaluate a completed attempt  |
| GET    | `/health`             | Health probe                  |

## Platform setup notes

After `flutter create .` you'll need two small manifest edits:

### Android — add INTERNET permission

`android/app/src/main/AndroidManifest.xml`, inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

(`flutter run` works without it because debug builds get a separate manifest
that includes it, but release builds will fail to talk to the API.)

### Android — cleartext for local dev (optional)

If you'll point at `http://10.0.2.2:3000`, also add this to the `<application>`
tag in the same manifest:

```xml
android:usesCleartextTraffic="true"
```

Not needed for the public `https://qcraft.code-etp.name.ng/` URL.

### iOS — file picker permission

`ios/Runner/Info.plist`:

```xml
<key>NSDocumentsFolderUsageDescription</key>
<string>qCraft needs access to your documents to upload study material.</string>
```

## Source layout

```
lib/
├── main.dart                       — entry, theme, shared apiClient singleton
├── api/
│   ├── api_client.dart             — Dio wrapper + ApiException
│   └── models.dart                 — DTOs (Document, Quiz, …) + request bodies
├── state/
│   └── quiz_session.dart           — ChangeNotifier for an in-progress attempt
├── widgets/
│   └── ui_bits.dart                — LoadingView / EmptyView / ErrorView / showSnack
└── screens/
    ├── home_screen.dart            — bottom-nav shell
    ├── documents_screen.dart       — list + upload + delete
    ├── quizzes_screen.dart         — list quizzes, open → generate → take
    ├── create_quiz_screen.dart     — pick docs + sliders for count/difficulty
    ├── take_quiz_screen.dart       — paginated answer UI
    └── result_screen.dart          — score, weak topics, breakdown
```
