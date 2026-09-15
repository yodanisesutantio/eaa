# PLAN.md — Expense Tracker Build Plan

## Goal

A Flutter + Supabase mobile app (personal use, sideloaded on Android) to:
- Add expense or income entries
- View cash flow by day, week, month, and year-to-date

## Schedule Assumption

~3 hours/day, evenings 18:00–21:00. Estimated total: **26–39 hours**, roughly
**2.5–4 weeks** at a consistent weekday pace.

## Phases

### Phase 0 — Environment Setup (~1–2 hrs)
- [x] Install Flutter SDK and Android Studio SDK; physical Android phone detected
- [ ] Accept Android SDK licenses; VSCode Flutter/Dart extensions not yet verified
- [ ] `flutter doctor` clean (currently blocked by Android licenses; Visual Studio is irrelevant for Android)
- [x] Create Supabase project (`gvjpgrjrftihfpabhhzh`)
- [x] Run schema SQL and enable the RLS policy (confirmed)
- [ ] Add `currency text not null default 'USD'` to `transactions` and update the schema
  constraint to accept the supported ISO codes in `lib/core/app_settings.dart`
- [x] Add core packages
  (`supabase_flutter`, `flutter_riverpod`, `go_router`, `fl_chart`, `intl`)
- [ ] Confirm `flutter run` works on emulator and physical phone

### Phase 1 — Auth (~4–6 hrs)
- [x] Initialize Supabase client at app startup (via `--dart-define`, not hardcoded)
- [x] Sign-up / sign-in screen (email/password)
- [x] Session persistence and route guarding with `go_router`
- [x] Sign-out flow
- [x] Verify auth against the live Supabase project (successful sign-in confirmed)

### Phase 2 — Add Transaction (~4–6 hrs)
- [x] Form: amount, type toggle (expense/income), category, note, date
- [x] Insert into `transactions` table via Riverpod provider
- [x] Basic validation (amount > 0, type required)
- [x] Success/error feedback

Prototype note: the dashboard currently uses dummy summary and recent-transaction
data while Phase 3 query/filter providers are built.

Settings note: language and default currency preferences are persisted locally;
each new transaction can override the default currency.

### Phase 3 — List + Period Filters (~6–8 hrs)
- [ ] Fetch transactions scoped to logged-in user
- [ ] Filter/query by day, week, month, year-to-date
- [ ] Show running totals: income, expense, net for selected period
- [ ] Transaction list UI (grouped by date, swipe to delete/edit optional)
- [ ] Add a dashboard exchange-rate card with a chosen base/quote pair
- [ ] Add a dashboard display-currency selector; original currency keeps entries
  such as `+$400` and `-€21`, while USD conversion could show `+$400` and `-$18.44`
- [ ] Decide and implement an exchange-rate source with cached/offline fallback

### Phase 4 — Charts (~4–6 hrs)
- [ ] Bar or line chart of net flow over selected period using `fl_chart`
- [ ] Toggle between day/week/month/YTD views feeding the same chart widget
- [ ] Category breakdown (optional stretch: pie/donut chart)

### Phase 5 — Polish & Device Testing (~6–10 hrs)
- [ ] Test on physical Android phone via USB/wireless debugging
- [ ] Edge cases: no transactions yet, offline network errors, large amounts
- [ ] UI polish: empty states, loading states, consistent theme
- [ ] Build release APK (`flutter build apk --release`) and sideload to phone

## Explicitly Out of Scope (v1)

- Offline-first local database / sync
- Play Store or App Store distribution
- Multi-currency support
- Budgets, recurring transactions, or reminders (candidates for v2)

## Open Decisions

- [ ] Auth method: email/password vs. Google OAuth via Supabase
- [ ] Category list: fixed set vs. user-defined
- [ ] Whether to add a Postgres view/RPC for pre-aggregated period sums
      (nice-to-have if list-based summing feels slow later)