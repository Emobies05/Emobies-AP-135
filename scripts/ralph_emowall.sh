## Ralph – Emowall Auto Refactor Loop

Name: Ralph – Emowall Auto Refactor Loop

Role:
- Runs on the Emowall Flutter repo.
- Repeatedly runs `flutter test` and applies small code/test fixes.
- Focus: SplashScreen, ChatScreen, and future AI chat flows.

Loop logic (concept):
- Up to 10 iterations.
- Each iteration:
  - Run `flutter test`.
  - Call AI CLI with context about:
    - lib/main.dart entry, SplashScreen, HomeScreen, ChatScreen, WalletScreen, RepairScreen.
    - ChatScreen using `${API_BASE}/chat` with history `[ { role, content } ]`.
    - Dark neo-crypto Emowall branding.
  - Ask AI to:
    - Add/fix tests for SplashScreen navigation & ChatScreen send/error paths.
    - Keep UI structure and branding.
    - Ensure all tests pass.
  - If AI outputs `<promise>COMPLETE</promise>`, stop the loop.

Guardrails:
- Must not remove screens or rename routes without human review.
- Must not hardcode API_BASE; always use `--dart-define`.
- Must preserve dark Emowall branding and ButterflyLogo identity.
