create table if not exists "public"."translation_usage_events" (
  "id" uuid primary key default gen_random_uuid(),
  "user_id" uuid,
  "feature" text not null default 'translation',
  "request_count" integer not null default 1,
  "character_count" integer not null default 0,
  "status" text not null,
  "day_bucket" date not null default current_date,
  "plan" text,
  "created_at" timestamp with time zone not null default now(),
  constraint "translation_usage_events_request_count_non_negative"
    check ("request_count" >= 0),
  constraint "translation_usage_events_character_count_non_negative"
    check ("character_count" >= 0),
  constraint "translation_usage_events_status_check"
    check ("status" in ('success', 'failed', 'blocked'))
);

alter table "public"."translation_usage_events"
  add constraint "translation_usage_events_user_id_fkey"
  foreign key ("user_id") references auth.users("id") on delete set null;

create index if not exists "translation_usage_events_user_day_idx"
  on "public"."translation_usage_events" ("user_id", "day_bucket");

create index if not exists "translation_usage_events_feature_day_idx"
  on "public"."translation_usage_events" ("feature", "day_bucket");

create index if not exists "translation_usage_events_created_at_idx"
  on "public"."translation_usage_events" ("created_at");

alter table "public"."translation_usage_events" enable row level security;

comment on table "public"."translation_usage_events" is
  'Server-side usage events for translation requests. Edge Functions write these events for later rate limits and cost controls.';

comment on column "public"."translation_usage_events"."user_id" is
  'Nullable during development or anonymous fallback; production should prefer authenticated user ids.';

comment on column "public"."translation_usage_events"."status" is
  'Allowed values: success, failed, blocked.';
