## Ralph – Emowall Auto Refactor Loop (Extended Description)

Ralph is an automated Flutter engineering loop that runs directly on the Emowall repo. Its job is to repeatedly run tests, apply small, safe changes, and gradually improve the stability and coverage of the Emowall AI 2.0 app without breaking the product’s identity.

### Scope and Responsibilities

- Works only inside the Emowall AI Flutter project.
- Focus areas (initially):
  - `SplashScreen`: animation and timed navigation to `HomeScreen`.
  - `HomeScreen`: bottom navigation between Chat, Repair, and Wallet.
  - `ChatScreen`: message sending, HTTP calls to the `/chat` backend, error handling.
- Over time, can be extended to cover:
  - Wallet features, staking views, and transaction history.
  - Repair booking flows and status tracking.
  - Additional AI tools and experimental screens.

### How the Loop Behaves

- Ralph runs in a loop (default up to 10 iterations per run).
- Each iteration:
  1. Runs `flutter test` to see the current health of the project.
  2. Calls an AI coding agent with:
     - Project context (main entry, screens, API usage).
     - Clear tasks (e.g., add tests, fix failing logic, clean code).
     - Guardrails to protect branding and architecture.
  3. Waits for the AI to modify the code and tests.
  4. Runs `flutter test` again to verify that:
     - Tests pass.
     - No new failures were introduced.
- The loop stops early if the AI explicitly signals that it has finished and all tests pass (by outputting `<promise>COMPLETE</promise>`).

### Technical Context Shared with Ralph

- Main entry file: `lib/main.dart`.
- Core screens:
  - `SplashScreen` → shows animated `ButterflyLogo`, then auto‑navigates to `HomeScreen`.
  - `HomeScreen` → three tabs: `ChatScreen`, `RepairScreen`, `WalletScreen`.
  - `ChatScreen` → calls `API_BASE + /chat` with a JSON body containing:
    - `message`: latest user message.
    - `history`: list of `{ role: 'user' | 'assistant', content: String }`.
  - `RepairScreen`, `WalletScreen` → initially “Coming Soon” placeholders that will be expanded later.
- Configuration:
  - `API_BASE` must come from `--dart-define` (`const String.fromEnvironment('API_BASE')`), never hardcoded.
  - Android and iOS native entry points are standard Flutter v2 embedding.

### Design and Branding Guardrails

Ralph must always respect Emowall’s product feel:

- Keep the dark “neo‑crypto” aesthetic:
  - Backgrounds around `#07080B` and `#0D1117`.
  - Primary accent `#00E5FF`, secondary `#7C3AED`, plus the existing highlight colors.
- Do not break the `ButterflyLogo`:
  - It is animated, multi‑color, and central to Emowall’s identity.
  - Ralph can adjust implementation details (e.g., optimize animations) but not remove or drastically simplify it.
- Preserve screen structure:
  - `SplashScreen → HomeScreen` flow stays intact.
  - Three main tabs remain: AI Chat, Repair, Wallet.
  - Screen names and basic responsibilities should stay the same unless a human explicitly approves changes.

### Safety and Change Rules

- Must not:
  - Delete or rename core screens (Splash, Home, Chat, Wallet, Repair) without human approval.
  - Hardcode URLs, API keys, or secrets in Dart code.
  - Introduce experimental packages that significantly bloat the app without a clear reason.
- Must:
  - Keep the project building successfully for Android (and later iOS).
  - Maintain or increase test coverage for areas it touches.
  - Prefer small, incremental changes over large refactors.

### Typical Tasks for Ralph

1. **Testing and Reliability**
   - Add widget and unit tests for:
     - SplashScreen timing and navigation behavior.
     - ChatScreen send‑message flow, including success and error states.
   - Fix failing tests that appear after small refactors or dependency updates.

2. **Code Quality**
   - Clean up duplicate logic, dead code, or unused imports.
   - Improve naming and structure where it is clearly safe to do so.
   - Keep code consistent with Flutter/Dart best practices (null‑safety, idiomatic widgets, etc.).

3. **Continuous Improvement**
   - When the basic flows are stable, extend tests to:
     - Future wallet and staking UIs.
     - Repair booking flows and status changes.
   - Suggest small UX improvements that do not break the Emowall brand.

### Completion Signal

- After a Ralph run, “done” means:
  - `flutter test` passes with no failures.
  - New or updated tests exist for the target areas (e.g., Splash and Chat).
  - No breaking changes to app navigation, branding, or config.
  - The AI has output the exact token: `<promise>COMPLETE</promise>`.

Ralph is not meant to replace human control of Emowall; it is a focused engineering loop that keeps the app healthy, well‑tested, and consistent with the Emowall AI 2.0 vision while humans focus on product decisions and big features.
