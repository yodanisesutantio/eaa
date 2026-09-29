-- Phase 3: align transaction currencies and add protected diagnostics.
-- Apply this migration in the Supabase SQL editor or with the Supabase CLI.

alter table public.transactions
  drop constraint if exists transactions_currency_check;

alter table public.transactions
  add constraint transactions_currency_check check (
    currency in (
      'USD', 'EUR', 'GBP', 'CAD', 'JPY', 'AUD', 'CHF', 'CNY', 'HKD', 'NZD',
      'SGD', 'INR', 'KRW', 'IDR', 'BRL', 'MXN', 'ZAR', 'SEK', 'NOK', 'DKK',
      'PLN', 'CZK', 'HUF', 'TRY', 'AED', 'SAR', 'THB', 'MYR', 'PHP', 'VND'
    )
  );

create table if not exists public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  event_type text not null,
  entity_type text,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.app_errors (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  error_code text,
  message text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.activity_logs enable row level security;
alter table public.app_errors enable row level security;

drop policy if exists "Users can create their own activity logs" on public.activity_logs;
create policy "Users can create their own activity logs"
  on public.activity_logs for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can view their own activity logs" on public.activity_logs;
create policy "Users can view their own activity logs"
  on public.activity_logs for select
  using (auth.uid() = user_id);

drop policy if exists "Users can create their own app errors" on public.app_errors;
create policy "Users can create their own app errors"
  on public.app_errors for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can view their own app errors" on public.app_errors;
create policy "Users can view their own app errors"
  on public.app_errors for select
  using (auth.uid() = user_id);

create index if not exists activity_logs_user_created_at_idx
  on public.activity_logs(user_id, created_at desc);

create index if not exists app_errors_user_created_at_idx
  on public.app_errors(user_id, created_at desc);
