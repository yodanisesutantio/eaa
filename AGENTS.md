# AGENTS.md — Expense Tracker (Flutter + Supabase)

This file gives coding agents (Claude Code, etc.) the context needed to work on this
project consistently. Keep it updated as decisions change.

## Project Overview

A personal mobile app to track expenses and income, with the ability to view cash
flow by day, week, month, and year-to-date. Built for personal use, deployed by
sideloading an APK to an Android phone (no Play Store distribution planned).

## Tech Stack

- **Framework:** Flutter (Dart)
- **Backend:** Supabase (Postgres + Auth + Row Level Security)
- **State management:** Riverpod (`flutter_riverpod`)
- **Navigation:** `go_router`
- **Charts:** `fl_chart`
- **Dates:** `intl`

## Architecture & Conventions

- Follow standard Flutter project layout. Feature-first folder structure under `lib/`:
  ```
  lib/
    main.dart
    core/
      supabase_client.dart      # Supabase init, env config
      theme.dart
    features/
      auth/
        auth_provider.dart
        sign_in_screen.dart
      transactions/
        models/
          transaction.dart
        providers/
          transactions_provider.dart
        screens/
          add_transaction_screen.dart
          transaction_list_screen.dart
        widgets/
          transaction_tile.dart
      summary/
        providers/
          summary_provider.dart
        screens/
          summary_screen.dart
        widgets/
          period_chart.dart
  ```
- Use Riverpod providers for all Supabase reads/writes — no direct Supabase calls
  inside widgets. Widgets should only read providers.
- Never hardcode the Supabase URL or anon key. Load them via `--dart-define` or a
  `.env` file (not committed to git) read at startup.
- All money amounts are `numeric` in Postgres and should be handled as `double` in
  Dart, formatted with `intl` for display. Avoid floating point for calculations
  where precision matters — round consistently at display time.
- Dates: store `occurred_at` as a plain date (no time) in Postgres. All period
  filtering (day/week/month/YTD) should be computed from this field.

## Supabase Schema

```sql
create table transactions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  type text check (type in ('expense', 'income')) not null,
  amount numeric not null,
  currency text not null default 'USD',
  category text,
  note text,
  occurred_at date not null default current_date,
  created_at timestamptz default now()
);

alter table transactions enable row level security;
create policy "Users can manage their own transactions"
  on transactions for all
  using (auth.uid() = user_id);
```

If new tables or columns are added, update this section so agents stay in sync
with the real schema.

## Commands

- Run app on connected device/emulator: `flutter run`
- Run with env vars: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- Analyze/lint: `flutter analyze`
- Format: `dart format .`
- Run tests: `flutter test`
- Build release APK: `flutter build apk --release`

## Things to Avoid

- Don't introduce a second state management approach alongside Riverpod.
- Don't commit `.env` files, Supabase keys, or any secrets.
- Don't add offline-first sync (WatermelonDB/Drift-style local DB) unless
  explicitly requested — out of scope for v1.
- Don't add Play Store / App Store release configuration — this app is sideloaded
  for personal use only.

## Current Status

Phase 0 package setup is complete. Flutter 3.47.2 is installed and a physical
Android device is detected. Android SDK licenses still need to be accepted.

Phase 1 auth shell is implemented under `lib/`: Supabase startup configuration,
email sign-up/sign-in, guarded routes, session-aware navigation, and sign-out.
Run the app with `SUPABASE_URL` and `SUPABASE_ANON_KEY` (the public publishable
key) supplied through `--dart-define`. Live auth verification and the database
schema/RLS setup are still pending.