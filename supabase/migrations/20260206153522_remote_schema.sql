drop extension if exists "pg_net";

create schema if not exists "util";

create extension if not exists "pg_trgm" with schema "public";

create type "public"."srs_mode" as enum ('time', 'adaptive', 'hybrid');

create sequence "public"."captures_id_seq";

create sequence "public"."ingest_errors_id_seq";


  create table "public"."a_deck_state" (
    "user_id" text not null,
    "category_id" text not null,
    "mode" text not null,
    "word_id" text not null,
    "last_queued_counter" integer not null default '-1'::integer
      );



  create table "public"."a_refill_state" (
    "user_id" text not null,
    "category_id" text not null,
    "mode" text not null,
    "refill_counter" integer not null default 0
      );



  create table "public"."captures" (
    "id" bigint not null default nextval('public.captures_id_seq'::regclass),
    "user_id" uuid not null,
    "text" text not null,
    "source_url" text,
    "source_title" text,
    "user_agent" text,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."categories" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "type" text not null,
    "created_at" timestamp with time zone not null default now(),
    "order_index" integer,
    "group_slug" text,
    "group_name" text
      );


alter table "public"."categories" enable row level security;


  create table "public"."category_refill_state" (
    "user_id" uuid not null,
    "category_id" uuid not null,
    "mode" text not null,
    "refill_counter" integer not null default 0,
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."entries" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "term" text not null,
    "lang" text default 'de'::text,
    "context" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "fts" tsvector generated always as (to_tsvector('simple'::regconfig, ((COALESCE(term, ''::text) || ' '::text) || COALESCE(context, ''::text)))) stored,
    "translation_de" text,
    "synonyms_en" text[] default '{}'::text[],
    "source_url" text,
    "source_title" text,
    "user_agent" text
      );


alter table "public"."entries" enable row level security;


  create table "public"."ingest_errors" (
    "id" bigint not null default nextval('public.ingest_errors_id_seq'::regclass),
    "created_at" timestamp with time zone default now(),
    "target" text,
    "user_id" uuid,
    "payload" jsonb,
    "message" text
      );



  create table "public"."lesson_words" (
    "lesson_id" uuid not null,
    "word_id" uuid not null,
    "order_index" integer not null default 0
      );


alter table "public"."lesson_words" enable row level security;


  create table "public"."lessons" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "category_id" uuid,
    "order_index" integer not null default 0,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."lessons" enable row level security;


  create table "public"."profiles" (
    "id" uuid not null,
    "created_at" timestamp with time zone default now(),
    "capture_key" text
      );



  create table "public"."single_session_items" (
    "user_id" uuid not null default auth.uid(),
    "category_id" uuid not null,
    "stage" integer not null,
    "word_id" uuid not null,
    "bucket" text not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."single_session_items" enable row level security;


  create table "public"."staging_words" (
    "text" text not null,
    "translation" text not null,
    "from_lang" text not null default 'en'::text,
    "to_lang" text not null default 'de'::text,
    "level" text,
    "pos" text,
    "category_slug" text not null,
    "subdomain" text
      );



  create table "public"."user_category_daily_budget" (
    "user_id" uuid not null,
    "category_id" uuid not null,
    "mode" public.srs_mode not null,
    "budget_date" date not null,
    "early_used" integer not null default 0,
    "late_used" integer not null default 0,
    "same_stage_run" integer not null default 0,
    "last_stage" integer,
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."user_daily_picks" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "word_id" uuid not null,
    "scheduled_for" date,
    "sent_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."user_daily_picks" enable row level security;


  create table "public"."user_hybrid_daily_state" (
    "user_id" uuid not null,
    "category_id" uuid not null,
    "mode" public.srs_mode not null default 'hybrid'::public.srs_mode,
    "day_start" timestamp with time zone not null,
    "early_done" integer not null default 0,
    "late_done" integer not null default 0,
    "last_stage" integer,
    "same_stage_run" integer not null default 0,
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."user_hybrid_daily_state" enable row level security;


  create table "public"."user_hybrid_daily_stats" (
    "user_id" uuid not null,
    "category_id" uuid not null,
    "day" date not null,
    "early_done" integer not null default 0,
    "late_done" integer not null default 0,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."user_hybrid_daily_stats" enable row level security;


  create table "public"."user_requeue" (
    "user_id" uuid not null,
    "category_id" uuid not null,
    "mode" public.srs_mode not null,
    "word_id" uuid not null,
    "show_after" integer not null,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."user_s0_lock_state" (
    "user_id" uuid not null,
    "category_id" uuid not null,
    "mode" public.srs_mode not null,
    "s0_locked" boolean not null default false,
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."user_word_srs" (
    "user_id" uuid not null,
    "word_id" uuid not null,
    "category_id" uuid not null,
    "mode" public.srs_mode not null,
    "stage" integer not null default 0,
    "ef" numeric not null default 1.00,
    "streak" integer not null default 0,
    "lapses" integer not null default 0,
    "last_reviewed_at" timestamp with time zone,
    "next_due_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."user_word_srs" enable row level security;


  create table "public"."user_word_srs_lock" (
    "user_id" uuid not null,
    "category_id" uuid not null,
    "word_id" uuid not null,
    "mode" public.srs_mode not null,
    "stage" integer not null,
    "locked_until" timestamp with time zone,
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."user_words" (
    "user_id" uuid not null,
    "word_id" uuid not null,
    "picked" boolean not null default true,
    "favorite" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "srs_stage" smallint not null default 0,
    "next_due_at" timestamp with time zone,
    "last_reviewed_at" timestamp with time zone,
    "last_result" boolean,
    "source" text default 'app'::text
      );


alter table "public"."user_words" enable row level security;


  create table "public"."word_categories" (
    "word_id" uuid not null,
    "category_id" uuid not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."word_categories" enable row level security;


  create table "public"."word_progress" (
    "user_id" uuid not null,
    "category_id" uuid not null,
    "word_id" uuid not null,
    "mode" public.srs_mode not null,
    "stage" smallint not null,
    "streak_in_stage" integer not null,
    "ever_enrolled" boolean not null,
    "is_mastered" boolean not null,
    "mastered_version" integer not null default 0,
    "added_to_category_at" timestamp with time zone not null,
    "mastered_at" timestamp with time zone,
    "updated_at" timestamp with time zone not null,
    "device_seq" bigint not null,
    "device_id" text not null
      );


alter table "public"."word_progress" enable row level security;


  create table "public"."word_progress_deck_state" (
    "user_id" uuid not null,
    "category_id" uuid not null,
    "word_id" uuid not null,
    "mode" text not null,
    "last_queued_counter" integer not null default 0,
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."word_progress_deck_state" enable row level security;


  create table "public"."words" (
    "id" uuid not null default gen_random_uuid(),
    "text" text not null,
    "translation" text not null,
    "from_lang" text not null,
    "to_lang" text not null,
    "domain" text,
    "pos" text,
    "level" text,
    "tags" text[] default '{}'::text[],
    "srs_stage" integer default 0,
    "created_at" timestamp with time zone default now(),
    "due_at" timestamp with time zone,
    "translated_by" text,
    "translated_at" timestamp with time zone,
    "qa_score" numeric,
    "qa_note" text
      );


alter table "public"."words" enable row level security;

alter sequence "public"."captures_id_seq" owned by "public"."captures"."id";

alter sequence "public"."ingest_errors_id_seq" owned by "public"."ingest_errors"."id";

CREATE UNIQUE INDEX a_deck_state_pkey ON public.a_deck_state USING btree (user_id, category_id, mode, word_id);

CREATE UNIQUE INDEX a_refill_state_pkey ON public.a_refill_state USING btree (user_id, category_id, mode);

CREATE UNIQUE INDEX captures_pkey ON public.captures USING btree (id);

CREATE INDEX categories_order_idx ON public.categories USING btree (order_index, name);

CREATE UNIQUE INDEX categories_pkey ON public.categories USING btree (id);

CREATE UNIQUE INDEX categories_slug_key ON public.categories USING btree (slug);

CREATE UNIQUE INDEX category_refill_state_pkey ON public.category_refill_state USING btree (user_id, category_id, mode);

CREATE INDEX entries_fts_idx ON public.entries USING gin (fts);

CREATE UNIQUE INDEX entries_pkey ON public.entries USING btree (id);

CREATE UNIQUE INDEX entries_user_term_lang_uidx ON public.entries USING btree (user_id, lower(term), lower(lang));

CREATE INDEX idx_a_deck_state_lookup ON public.a_deck_state USING btree (user_id, category_id, mode, last_queued_counter);

CREATE INDEX idx_categories_group_order ON public.categories USING btree (group_slug, order_index);

CREATE INDEX idx_categories_group_slug_id ON public.categories USING btree (group_slug, id);

CREATE INDEX idx_categories_slug ON public.categories USING btree (slug);

CREATE INDEX idx_categories_slug_id ON public.categories USING btree (slug, id);

CREATE INDEX idx_lesson_words_lesson ON public.lesson_words USING btree (lesson_id, order_index);

CREATE INDEX idx_lessons_category ON public.lessons USING btree (category_id, order_index);

CREATE INDEX idx_single_session_lookup ON public.single_session_items USING btree (user_id, category_id, stage, bucket);

CREATE INDEX idx_ssi_user_cat_stage_bucket ON public.single_session_items USING btree (user_id, category_id, stage, bucket);

CREATE INDEX idx_ssi_word ON public.single_session_items USING btree (word_id);

CREATE INDEX idx_udp_user_day ON public.user_daily_picks USING btree (user_id, scheduled_for);

CREATE INDEX idx_udp_user_unsent ON public.user_daily_picks USING btree (user_id, sent_at) WHERE (sent_at IS NULL);

CREATE INDEX idx_udp_user_word ON public.user_daily_picks USING btree (user_id, word_id);

CREATE INDEX idx_user_hybrid_daily_stats_user_day ON public.user_hybrid_daily_stats USING btree (user_id, day);

CREATE INDEX idx_user_word_srs_adaptive_queue ON public.user_word_srs USING btree (user_id, category_id, mode, stage);

CREATE INDEX idx_user_word_srs_queue ON public.user_word_srs USING btree (user_id, category_id, mode, next_due_at);

CREATE INDEX idx_uw_user_due ON public.user_words USING btree (user_id, next_due_at) WHERE (next_due_at IS NOT NULL);

CREATE INDEX idx_uw_user_source ON public.user_words USING btree (user_id, source);

CREATE INDEX idx_uw_user_stage ON public.user_words USING btree (user_id, srs_stage);

CREATE INDEX idx_wc_category_id ON public.word_categories USING btree (category_id);

CREATE INDEX idx_wc_category_id_word_id ON public.word_categories USING btree (category_id, word_id);

CREATE INDEX idx_wc_word_id ON public.word_categories USING btree (word_id);

CREATE INDEX idx_wc_word_id_category_id ON public.word_categories USING btree (word_id, category_id);

CREATE INDEX idx_word_categories_category ON public.word_categories USING btree (category_id, word_id);

CREATE INDEX idx_word_categories_word ON public.word_categories USING btree (word_id, category_id);

CREATE INDEX idx_word_progress_stage ON public.word_progress USING btree (user_id, category_id, mode, is_mastered, stage);

CREATE INDEX idx_word_progress_updated ON public.word_progress USING btree (user_id, category_id, mode, updated_at);

CREATE INDEX idx_words_created_at ON public.words USING btree (created_at);

CREATE INDEX idx_words_domain ON public.words USING btree (domain);

CREATE INDEX idx_words_level ON public.words USING btree (level);

CREATE INDEX idx_words_pos ON public.words USING btree (pos);

CREATE INDEX idx_words_tags ON public.words USING gin (tags);

CREATE INDEX idx_words_text_btree ON public.words USING btree (text);

CREATE INDEX idx_words_text_lang ON public.words USING btree (text, from_lang, to_lang);

CREATE INDEX idx_words_text_trgm ON public.words USING gin (text public.gin_trgm_ops);

CREATE INDEX idx_words_translation_trgm ON public.words USING gin (translation public.gin_trgm_ops);

CREATE UNIQUE INDEX ingest_errors_pkey ON public.ingest_errors USING btree (id);

CREATE UNIQUE INDEX lesson_words_pkey ON public.lesson_words USING btree (lesson_id, word_id);

CREATE UNIQUE INDEX lessons_pkey ON public.lessons USING btree (id);

CREATE UNIQUE INDEX profiles_capture_key_key ON public.profiles USING btree (capture_key);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX single_session_items_pkey ON public.single_session_items USING btree (user_id, category_id, stage, word_id);

CREATE UNIQUE INDEX user_category_daily_budget_pkey ON public.user_category_daily_budget USING btree (user_id, category_id, mode, budget_date);

CREATE UNIQUE INDEX user_daily_picks_pkey ON public.user_daily_picks USING btree (id);

CREATE UNIQUE INDEX user_daily_picks_user_id_word_id_scheduled_for_key ON public.user_daily_picks USING btree (user_id, word_id, scheduled_for);

CREATE UNIQUE INDEX user_hybrid_daily_state_pk ON public.user_hybrid_daily_state USING btree (user_id, category_id, mode, day_start);

CREATE UNIQUE INDEX user_hybrid_daily_state_uq_user_cat_mode ON public.user_hybrid_daily_state USING btree (user_id, category_id, mode);

CREATE INDEX user_hybrid_daily_state_user_cat_idx ON public.user_hybrid_daily_state USING btree (user_id, category_id, mode, day_start);

CREATE UNIQUE INDEX user_hybrid_daily_stats_pkey ON public.user_hybrid_daily_stats USING btree (user_id, category_id, day);

CREATE INDEX user_requeue_due_idx ON public.user_requeue USING btree (user_id, category_id, mode, show_after);

CREATE UNIQUE INDEX user_requeue_pkey ON public.user_requeue USING btree (user_id, category_id, mode, word_id);

CREATE UNIQUE INDEX user_s0_lock_state_pk ON public.user_s0_lock_state USING btree (user_id, category_id, mode);

CREATE UNIQUE INDEX user_word_srs_lock_pkey ON public.user_word_srs_lock USING btree (user_id, category_id, word_id, mode, stage);

CREATE UNIQUE INDEX user_word_srs_pk ON public.user_word_srs USING btree (user_id, word_id, category_id, mode);

CREATE UNIQUE INDEX user_word_srs_unique ON public.user_word_srs USING btree (user_id, category_id, word_id, mode);

CREATE UNIQUE INDEX user_word_srs_unique_key ON public.user_word_srs USING btree (user_id, word_id, category_id, mode);

CREATE UNIQUE INDEX user_words_pkey ON public.user_words USING btree (user_id, word_id);

CREATE UNIQUE INDEX user_words_user_id_word_id_uniq ON public.user_words USING btree (user_id, word_id);

CREATE UNIQUE INDEX user_words_user_word_unique ON public.user_words USING btree (user_id, word_id);

CREATE UNIQUE INDEX ux_words_pair ON public.words USING btree (text, translation, from_lang, to_lang);

CREATE UNIQUE INDEX word_categories_pkey ON public.word_categories USING btree (word_id, category_id);

CREATE UNIQUE INDEX word_progress_deck_state_pkey ON public.word_progress_deck_state USING btree (user_id, category_id, word_id, mode);

CREATE UNIQUE INDEX word_progress_pk ON public.word_progress USING btree (user_id, category_id, word_id, mode);

CREATE UNIQUE INDEX words_pkey ON public.words USING btree (id);

CREATE UNIQUE INDEX words_text_lang_uniq ON public.words USING btree (text, from_lang, to_lang);

alter table "public"."a_deck_state" add constraint "a_deck_state_pkey" PRIMARY KEY using index "a_deck_state_pkey";

alter table "public"."a_refill_state" add constraint "a_refill_state_pkey" PRIMARY KEY using index "a_refill_state_pkey";

alter table "public"."captures" add constraint "captures_pkey" PRIMARY KEY using index "captures_pkey";

alter table "public"."categories" add constraint "categories_pkey" PRIMARY KEY using index "categories_pkey";

alter table "public"."category_refill_state" add constraint "category_refill_state_pkey" PRIMARY KEY using index "category_refill_state_pkey";

alter table "public"."entries" add constraint "entries_pkey" PRIMARY KEY using index "entries_pkey";

alter table "public"."ingest_errors" add constraint "ingest_errors_pkey" PRIMARY KEY using index "ingest_errors_pkey";

alter table "public"."lesson_words" add constraint "lesson_words_pkey" PRIMARY KEY using index "lesson_words_pkey";

alter table "public"."lessons" add constraint "lessons_pkey" PRIMARY KEY using index "lessons_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."single_session_items" add constraint "single_session_items_pkey" PRIMARY KEY using index "single_session_items_pkey";

alter table "public"."user_category_daily_budget" add constraint "user_category_daily_budget_pkey" PRIMARY KEY using index "user_category_daily_budget_pkey";

alter table "public"."user_daily_picks" add constraint "user_daily_picks_pkey" PRIMARY KEY using index "user_daily_picks_pkey";

alter table "public"."user_hybrid_daily_state" add constraint "user_hybrid_daily_state_pk" PRIMARY KEY using index "user_hybrid_daily_state_pk";

alter table "public"."user_hybrid_daily_stats" add constraint "user_hybrid_daily_stats_pkey" PRIMARY KEY using index "user_hybrid_daily_stats_pkey";

alter table "public"."user_requeue" add constraint "user_requeue_pkey" PRIMARY KEY using index "user_requeue_pkey";

alter table "public"."user_s0_lock_state" add constraint "user_s0_lock_state_pk" PRIMARY KEY using index "user_s0_lock_state_pk";

alter table "public"."user_word_srs" add constraint "user_word_srs_pk" PRIMARY KEY using index "user_word_srs_pk";

alter table "public"."user_word_srs_lock" add constraint "user_word_srs_lock_pkey" PRIMARY KEY using index "user_word_srs_lock_pkey";

alter table "public"."user_words" add constraint "user_words_pkey" PRIMARY KEY using index "user_words_pkey";

alter table "public"."word_categories" add constraint "word_categories_pkey" PRIMARY KEY using index "word_categories_pkey";

alter table "public"."word_progress" add constraint "word_progress_pk" PRIMARY KEY using index "word_progress_pk";

alter table "public"."word_progress_deck_state" add constraint "word_progress_deck_state_pkey" PRIMARY KEY using index "word_progress_deck_state_pkey";

alter table "public"."words" add constraint "words_pkey" PRIMARY KEY using index "words_pkey";

alter table "public"."captures" add constraint "captures_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."captures" validate constraint "captures_user_id_fkey";

alter table "public"."categories" add constraint "categories_slug_key" UNIQUE using index "categories_slug_key";

alter table "public"."categories" add constraint "categories_type_check" CHECK ((type = ANY (ARRAY['topic'::text, 'pos'::text, 'level'::text, 'origin'::text, 'custom'::text]))) not valid;

alter table "public"."categories" validate constraint "categories_type_check";

alter table "public"."lesson_words" add constraint "lesson_words_lesson_id_fkey" FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE not valid;

alter table "public"."lesson_words" validate constraint "lesson_words_lesson_id_fkey";

alter table "public"."lesson_words" add constraint "lesson_words_word_id_fkey" FOREIGN KEY (word_id) REFERENCES public.words(id) ON DELETE CASCADE not valid;

alter table "public"."lesson_words" validate constraint "lesson_words_word_id_fkey";

alter table "public"."lessons" add constraint "lessons_category_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL not valid;

alter table "public"."lessons" validate constraint "lessons_category_fkey";

alter table "public"."lessons" add constraint "lessons_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL not valid;

alter table "public"."lessons" validate constraint "lessons_category_id_fkey";

alter table "public"."profiles" add constraint "profiles_capture_key_key" UNIQUE using index "profiles_capture_key_key";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."single_session_items" add constraint "single_session_items_bucket_check" CHECK ((bucket = ANY (ARRAY['src'::text, 'sr1'::text, 'sr2'::text]))) not valid;

alter table "public"."single_session_items" validate constraint "single_session_items_bucket_check";

alter table "public"."single_session_items" add constraint "single_session_items_stage_check" CHECK (((stage >= 1) AND (stage <= 5))) not valid;

alter table "public"."single_session_items" validate constraint "single_session_items_stage_check";

alter table "public"."user_daily_picks" add constraint "user_daily_picks_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."user_daily_picks" validate constraint "user_daily_picks_user_id_fkey";

alter table "public"."user_daily_picks" add constraint "user_daily_picks_user_id_word_id_scheduled_for_key" UNIQUE using index "user_daily_picks_user_id_word_id_scheduled_for_key";

alter table "public"."user_daily_picks" add constraint "user_daily_picks_word_id_fkey" FOREIGN KEY (word_id) REFERENCES public.words(id) ON DELETE CASCADE not valid;

alter table "public"."user_daily_picks" validate constraint "user_daily_picks_word_id_fkey";

alter table "public"."user_hybrid_daily_state" add constraint "user_hybrid_daily_state_counters_chk" CHECK (((early_done >= 0) AND (late_done >= 0) AND (same_stage_run >= 0))) not valid;

alter table "public"."user_hybrid_daily_state" validate constraint "user_hybrid_daily_state_counters_chk";

alter table "public"."user_hybrid_daily_state" add constraint "user_hybrid_daily_state_mode_chk" CHECK ((mode = 'hybrid'::public.srs_mode)) not valid;

alter table "public"."user_hybrid_daily_state" validate constraint "user_hybrid_daily_state_mode_chk";

alter table "public"."user_hybrid_daily_state" add constraint "user_hybrid_daily_state_stage_chk" CHECK (((last_stage IS NULL) OR ((last_stage >= 0) AND (last_stage <= 5)))) not valid;

alter table "public"."user_hybrid_daily_state" validate constraint "user_hybrid_daily_state_stage_chk";

alter table "public"."user_word_srs" add constraint "adaptive_due_not_null" CHECK (((mode <> 'adaptive'::public.srs_mode) OR (next_due_at IS NOT NULL))) not valid;

alter table "public"."user_word_srs" validate constraint "adaptive_due_not_null";

alter table "public"."user_word_srs" add constraint "user_word_srs_ef_chk" CHECK (((ef >= 0.60) AND (ef <= 2.20))) not valid;

alter table "public"."user_word_srs" validate constraint "user_word_srs_ef_chk";

alter table "public"."user_word_srs" add constraint "user_word_srs_stage_chk" CHECK (((stage >= 0) AND (stage <= 5))) not valid;

alter table "public"."user_word_srs" validate constraint "user_word_srs_stage_chk";

alter table "public"."user_word_srs" add constraint "user_word_srs_unique" UNIQUE using index "user_word_srs_unique";

alter table "public"."user_word_srs" add constraint "user_word_srs_unique_key" UNIQUE using index "user_word_srs_unique_key";

alter table "public"."user_word_srs_lock" add constraint "user_word_srs_lock_stage_chk" CHECK (((stage >= 0) AND (stage <= 5))) not valid;

alter table "public"."user_word_srs_lock" validate constraint "user_word_srs_lock_stage_chk";

alter table "public"."user_words" add constraint "user_words_source_check" CHECK ((source = ANY (ARRAY['browser'::text, 'app'::text, 'import'::text]))) not valid;

alter table "public"."user_words" validate constraint "user_words_source_check";

alter table "public"."user_words" add constraint "user_words_srs_stage_check" CHECK (((srs_stage >= 0) AND (srs_stage <= 5))) not valid;

alter table "public"."user_words" validate constraint "user_words_srs_stage_check";

alter table "public"."user_words" add constraint "user_words_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."user_words" validate constraint "user_words_user_id_fkey";

alter table "public"."user_words" add constraint "user_words_user_id_word_id_uniq" UNIQUE using index "user_words_user_id_word_id_uniq";

alter table "public"."user_words" add constraint "user_words_user_word_unique" UNIQUE using index "user_words_user_word_unique";

alter table "public"."user_words" add constraint "user_words_word_id_fkey" FOREIGN KEY (word_id) REFERENCES public.words(id) ON DELETE CASCADE not valid;

alter table "public"."user_words" validate constraint "user_words_word_id_fkey";

alter table "public"."word_categories" add constraint "word_categories_category_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE not valid;

alter table "public"."word_categories" validate constraint "word_categories_category_fkey";

alter table "public"."word_categories" add constraint "word_categories_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE not valid;

alter table "public"."word_categories" validate constraint "word_categories_category_id_fkey";

alter table "public"."word_categories" add constraint "word_categories_word_id_fkey" FOREIGN KEY (word_id) REFERENCES public.words(id) ON DELETE CASCADE not valid;

alter table "public"."word_categories" validate constraint "word_categories_word_id_fkey";

alter table "public"."word_progress" add constraint "word_progress_stage_check" CHECK (((stage >= 0) AND (stage <= 5))) not valid;

alter table "public"."word_progress" validate constraint "word_progress_stage_check";

alter table "public"."word_progress" add constraint "word_progress_streak_in_stage_check" CHECK ((streak_in_stage >= 0)) not valid;

alter table "public"."word_progress" validate constraint "word_progress_streak_in_stage_check";

alter table "public"."words" add constraint "words_text_lang_uniq" UNIQUE using index "words_text_lang_uniq";

set check_function_bodies = off;

create or replace view "public"."category_words" as  SELECT category_id,
    word_id
   FROM public.word_categories wc;


CREATE OR REPLACE FUNCTION public.enroll_s0_to_s1(p_user uuid, p_category uuid, p_mode text, p_n integer)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_enrolled int;
begin
  insert into public.user_word_srs
    (user_id, word_id, category_id, mode, stage, ef, streak, lapses, next_due_at)
  select
    p_user,
    w.id,
    p_category,
    p_mode,
    1,
    1.0,
    0,
    0,
    null
  from public.words w
  where w.category_id = p_category
    and not exists (
      select 1
      from public.user_word_srs u
      where u.user_id = p_user
        and u.word_id = w.id
        and u.category_id = p_category
        and u.mode = p_mode
    )
  limit p_n
  on conflict (user_id, word_id, category_id, mode)
  do nothing;

  get diagnostics v_enrolled = row_count;
  return v_enrolled;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fetch_learn_queue_for_mode(p_category_id uuid, p_mode text, p_stage integer DEFAULT NULL::integer, p_limit integer DEFAULT 200)
 RETURNS TABLE(word_id uuid, srs_stage integer)
 LANGUAGE sql
 STABLE
AS $function$select
  wc.word_id,
  coalesce(uws.stage, 0) as srs_stage
from public.word_categories wc
left join public.user_word_srs uws
  on uws.user_id = auth.uid()
 and uws.word_id = wc.word_id
 and uws.category_id = wc.category_id
 and uws.mode = p_mode::public.srs_mode
left join lateral (
  select next_stage
  from public.fn_hybrid_next_stage(p_category_id, auth.uid())
  limit 1
) ns on p_mode = 'hybrid'
where wc.category_id = p_category_id
  and (
    case
      when p_mode = 'hybrid' then coalesce(uws.stage, 0) = ns.next_stage
      when p_stage is not null then coalesce(uws.stage, 0) = p_stage
      else coalesce(uws.stage, 0) between 0 and 5
    end
  )
order by
  -- ✅ Reviews (S1–S5) zuerst, New (S0) zuletzt
  case when coalesce(uws.stage, 0) = 0 then 1 else 0 end asc,
  uws.last_reviewed_at nulls first,
  wc.word_id
limit p_limit;$function$
;

CREATE OR REPLACE FUNCTION public.fetch_learn_queue_for_mode_debug(p_category_id uuid, p_mode text, p_limit integer, p_user uuid)
 RETURNS TABLE(word_id uuid, srs_stage integer)
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
  v_user uuid := p_user;
  v_mode public.srs_mode := p_mode::public.srs_mode;
  v_next_stage int;
begin
  if v_user is null then
    raise exception 'p_user must be provided in debug function';
  end if;

  if v_mode = 'hybrid'::public.srs_mode then
    select n.next_stage
      into v_next_stage
    from public.fn_hybrid_next_stage(
      p_category_id,
      v_user,
      null, 0,
      18, 12, 3
    ) n;

    if v_next_stage is null then
      return;
    end if;

    return query
    select
      uws.word_id,
      uws.stage
    from public.user_word_srs uws
    where uws.user_id = v_user
      and uws.category_id = p_category_id
      and uws.mode = 'hybrid'::public.srs_mode
      and uws.stage = v_next_stage
    limit p_limit;

    return;
  end if;

  -- fallback (optional)
  return;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fetch_learn_queue_hybrid(p_category_id uuid, p_limit integer)
 RETURNS TABLE(word_id uuid, srs_stage integer)
 LANGUAGE sql
 STABLE
AS $function$
  select * from public.fetch_learn_queue_hybrid(p_category_id, p_limit, null::uuid);
$function$
;

CREATE OR REPLACE FUNCTION public.fetch_learn_queue_hybrid(p_category_id uuid, p_limit integer, p_user uuid DEFAULT NULL::uuid)
 RETURNS TABLE(word_id uuid, srs_stage integer)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  v_user uuid := COALESCE(p_user, auth.uid());
  v_today timestamptz := date_trunc('day', now());
  v_last_stage int;
  v_same_run int;
  v_next_stage int;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  END IF;

  -- Daily-State holen (falls nicht vorhanden -> NULL/0)
  SELECT s.last_stage, s.same_stage_run
    INTO v_last_stage, v_same_run
  FROM public.user_hybrid_daily_state s
  WHERE s.user_id = v_user
    AND s.category_id = p_category_id
    AND s.mode = 'hybrid'::public.srs_mode
    AND s.day_start = v_today;

  v_last_stage := COALESCE(v_last_stage, -1);
  v_same_run   := COALESCE(v_same_run, 0);

  -- ✅ Next-Stage via 7-Arg Overload (maxSameStage wirkt!)
  SELECT n.next_stage
    INTO v_next_stage
  FROM public.fn_hybrid_next_stage(
    p_category_id,
    v_user,
    v_last_stage,
    v_same_run,
    18,  -- early budget
    12,  -- late budget
    3    -- maxSameStage
  ) n;

  IF v_next_stage IS NULL THEN
    RETURN; -- nichts freigegeben
  END IF;

  RETURN QUERY
  SELECT uws.word_id, uws.stage
  FROM public.user_word_srs uws
  WHERE uws.user_id = v_user
    AND uws.category_id = p_category_id
    AND uws.mode = 'hybrid'::public.srs_mode
    AND uws.stage = v_next_stage
    AND (
      v_next_stage BETWEEN 0 AND 2
      OR (uws.next_due_at IS NOT NULL AND uws.next_due_at <= now())
    )
  ORDER BY
    COALESCE(uws.next_due_at, 'infinity'::timestamptz) ASC,
    uws.updated_at ASC
  LIMIT p_limit;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_a_srs_bootstrap(p_user uuid, p_category uuid, p_take integer DEFAULT 20)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
  moved int;
begin
  with picked as (
    select word_id
    from word_progress
    where user_id = p_user
      and category_id = p_category
      and mode = 'adaptive'
      and stage = 0
    order by added_to_category_at asc
    limit p_take
  )
  update word_progress wp
  set stage = 1,
      updated_at = now()
  from picked
  where wp.word_id = picked.word_id
    and wp.user_id = p_user
    and wp.category_id = p_category
    and wp.mode = 'adaptive';

  get diagnostics moved = row_count;
  return moved;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_a_srs_fetch_words_for_stage(p_user uuid, p_category uuid, p_stage integer, p_limit integer, p_refill_counter integer)
 RETURNS TABLE(word_id uuid)
 LANGUAGE sql
 STABLE
AS $function$
  select wp.word_id
  from public.word_progress wp
  left join public.word_progress_deck_state ds
    on ds.user_id = wp.user_id
   and ds.category_id = wp.category_id
   and ds.word_id = wp.word_id
   and ds.mode = wp.mode::text
  where wp.user_id = p_user
    and wp.category_id = p_category
    and wp.mode = 'adaptive'
    and wp.is_mastered = false
    and wp.stage = p_stage
    and coalesce(ds.last_queued_counter, -1) < p_refill_counter
  order by wp.word_id
  limit p_limit;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_a_srs_next_refill_counter(p_user uuid, p_category uuid, p_mode text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
  v_new integer;
begin
  insert into public.category_refill_state(user_id, category_id, mode, refill_counter)
  values (p_user, p_category, p_mode, 1)
  on conflict (user_id, category_id, mode)
  do update set refill_counter = public.category_refill_state.refill_counter + 1,
               updated_at = now()
  returning refill_counter into v_new;

  return v_new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_a_srs_refill_enroll(p_user uuid, p_category uuid)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
  s1_count int;
  s0_total int;
  capacity int;
  enroll_limit int;
  n int;
begin
  select count(*) into s1_count
  from user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'
    and stage = 1;

  select count(*) into s0_total
  from user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'
    and stage = 0;

  capacity := greatest(0, 20 - s1_count);
  if capacity = 0 or s0_total = 0 then
    return 0;
  end if;

  enroll_limit := case
    when s0_total > 40 then 20
    else ceil(s0_total * 0.25)
  end;

  n := least(capacity, enroll_limit, s0_total);

  update user_word_srs
  set stage = 1,
      streak = 0,
      updated_at = now()
  where id in (
    select id
    from user_word_srs
    where user_id = p_user
      and category_id = p_category
      and mode = 'adaptive'
      and stage = 0
    order by created_at asc, word_id asc
    limit n
  );

  return n;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_a_srs_refill_enroll(p_user uuid, p_category uuid, p_mode text, p_refill_counter integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
  v_s1_count integer;
  v_need integer;
  v_enroll integer;
begin
  -- S1 count (mode-aware)
  select count(*)
    into v_s1_count
  from public.word_progress wp
  where wp.user_id = p_user
    and wp.category_id = p_category
    and wp.mode::text = p_mode
    and wp.is_mastered = false
    and wp.stage = 1;

  -- target band: S1_min=12, S1_max=20; enroll only if below min; enroll_limit_max=8
  v_need := greatest(0, 12 - v_s1_count);
  v_enroll := least(8, v_need);

  if v_enroll <= 0 then
    return 0;
  end if;

  -- deterministisch aus S0 nehmen
  with pick as (
    select wp.word_id
    from public.word_progress wp
    where wp.user_id = p_user
      and wp.category_id = p_category
      and wp.mode::text = p_mode
      and wp.is_mastered = false
      and wp.stage = 0
    order by wp.added_to_category_at asc, wp.word_id asc
    limit v_enroll
  ),
  upd as (
    update public.word_progress wp
      set stage = 1,
          ever_enrolled = true
    where wp.user_id = p_user
      and wp.category_id = p_category
      and wp.mode::text = p_mode
      and wp.word_id in (select word_id from pick)
    returning wp.word_id
  )
  -- ensure deck-state rows exist (mode bleibt text in deck_state -> compare via wp.mode::text überall)
  insert into public.word_progress_deck_state(user_id, category_id, word_id, mode, last_queued_counter)
  select p_user, p_category, u.word_id, p_mode, 0
  from upd u
  on conflict (user_id, category_id, word_id, mode) do nothing;

  return v_enroll;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_asrs_allow_new_cards(p_category_id uuid, p_mode text, p_user uuid, p_min_active integer)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
AS $function$with stats as (
    select
      count(*) filter (where srs_stage_user between 1 and 5) as active_1_5,
      count(*) filter (where srs_stage_user = 1)            as t1_count
    from public.v_words_user_srs
    where category_id = p_category_id
      and srs_mode = p_mode           -- srs_mode ist TEXT in der View
      and user_id = p_user
  )
  select
    (active_1_5 = 0 OR active_1_5 >= p_min_active)
    and (t1_count <= 30)
  from stats;$function$
;

CREATE OR REPLACE FUNCTION public.fn_category_word_count(p_category_id uuid)
 RETURNS integer
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  select count(*)::int
  from public.word_categories
  where category_id = p_category_id
$function$
;

CREATE OR REPLACE FUNCTION public.fn_consume_requeue(p_word_id uuid, p_category_id uuid, p_mode public.srs_mode, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
delete from public.user_requeue
where user_id = coalesce(p_user, auth.uid())
  and category_id = p_category_id
  and mode = p_mode
  and word_id = p_word_id;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_debug_hybrid_guards(p_category_id uuid, p_user uuid DEFAULT NULL::uuid)
 RETURNS TABLE(v_user uuid, today_start timestamp with time zone, early_budget integer, late_budget integer, max_same_stage integer, early_done_today integer, late_done_today integer, early_remaining integer, late_remaining integer, stage3_unlocked_cards integer, stage4_unlocked_cards integer, stage5_unlocked_cards integer, stage3_locked_cards integer, stage4_locked_cards integer, stage5_locked_cards integer)
 LANGUAGE sql
 STABLE
AS $function$
with params as (
  select
    coalesce(p_user, auth.uid()) as v_user,
    date_trunc('day', now()) as today_start,
    18::int as early_budget,
    12::int as late_budget,
    3::int  as max_same_stage
),
uws as (
  select
    u.stage,
    u.last_reviewed_at,
    u.next_due_at
  from public.user_word_srs u
  join params p on true
  where u.user_id = p.v_user
    and u.category_id = p_category_id
    and u.mode = 'hybrid'::public.srs_mode
),
stats as (
  select
    count(*) filter (
      where stage between 0 and 2
        and last_reviewed_at >= (select today_start from params)
    ) as early_done_today,

    -- LATE zählt nur, wenn es zum Review-Zeitpunkt wirklich DUE war
    count(*) filter (
      where stage between 3 and 5
        and last_reviewed_at >= (select today_start from params)
        and next_due_at is not null
        and next_due_at <= last_reviewed_at
    ) as late_done_today,

    count(*) filter (
      where stage = 3
        and (last_reviewed_at is null or now() >= last_reviewed_at + public.fn_hybrid_lock_interval(3))
    ) as stage3_unlocked_cards,
    count(*) filter (
      where stage = 4
        and (last_reviewed_at is null or now() >= last_reviewed_at + public.fn_hybrid_lock_interval(4))
    ) as stage4_unlocked_cards,
    count(*) filter (
      where stage = 5
        and (last_reviewed_at is null or now() >= last_reviewed_at + public.fn_hybrid_lock_interval(5))
    ) as stage5_unlocked_cards,

    count(*) filter (
      where stage = 3
        and last_reviewed_at is not null
        and now() < last_reviewed_at + public.fn_hybrid_lock_interval(3)
    ) as stage3_locked_cards,
    count(*) filter (
      where stage = 4
        and last_reviewed_at is not null
        and now() < last_reviewed_at + public.fn_hybrid_lock_interval(4)
    ) as stage4_locked_cards,
    count(*) filter (
      where stage = 5
        and last_reviewed_at is not null
        and now() < last_reviewed_at + public.fn_hybrid_lock_interval(5)
    ) as stage5_locked_cards
  from uws
)
select
  p.v_user,
  p.today_start,
  p.early_budget,
  p.late_budget,
  p.max_same_stage,
  s.early_done_today,
  s.late_done_today,
  greatest(p.early_budget - s.early_done_today, 0) as early_remaining,
  greatest(p.late_budget - s.late_done_today, 0) as late_remaining,
  s.stage3_unlocked_cards,
  s.stage4_unlocked_cards,
  s.stage5_unlocked_cards,
  s.stage3_locked_cards,
  s.stage4_locked_cards,
  s.stage5_locked_cards
from params p
cross join stats s;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_enroll_user_category_mode(p_category_id uuid, p_mode text, p_user uuid DEFAULT NULL::uuid)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_mode srs_mode := p_mode::srs_mode;
  v_inserted int := 0;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- 1) Ensure user_words exists for ALL words in category
  insert into public.user_words (user_id, word_id, picked, favorite, created_at)
  select v_user, wc.word_id, false, false, now()
  from public.word_categories wc
  where wc.category_id = p_category_id
  on conflict (user_id, word_id) do nothing;

  -- 2) Ensure user_word_srs exists for this mode/category (A-SRS: next_due_at NULL)
  insert into public.user_word_srs (
    user_id, word_id, category_id, mode,
    stage, ef, streak, lapses, next_due_at, last_reviewed_at
  )
  select
    v_user,
    wc.word_id,
    wc.category_id,
    v_mode,
    0,
    1.00,
    0,
    0,
    null,
    null
  from public.word_categories wc
  where wc.category_id = p_category_id
  on conflict (user_id, word_id, category_id, mode)
  do nothing;

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_enroll_word_mode(p_word uuid, p_category uuid, p_mode text, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_mode srs_mode := p_mode::srs_mode;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- 1) Ensure user_words exists (optional but recommended for your view-join)
  insert into public.user_words(user_id, word_id, picked, favorite, created_at)
  values (v_user, p_word, false, false, now())
  on conflict (user_id, word_id) do nothing;

  -- 2) Ensure user_word_srs exists for this mode/category
  insert into public.user_word_srs(
    user_id, word_id, category_id, mode,
    stage, streak, lapses, ef,
    next_due_at, last_reviewed_at
  )
  values (
    v_user, p_word, p_category, v_mode,
    0, 0, 0, 1.00,
    null, now()
  )
  on conflict (user_id, word_id, category_id, mode) do nothing;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_get_s0_locked(p_category_id uuid, p_mode public.srs_mode, p_user uuid DEFAULT NULL::uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_locked boolean;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- Hybrid: S0-Lock existiert nicht (immer false)
  if p_mode = 'hybrid'::public.srs_mode then
    return false;
  end if;

  select s0_locked
    into v_locked
  from public.user_s0_lock_state
  where user_id = v_user
    and category_id = p_category_id
    and mode = p_mode;

  return coalesce(v_locked, false);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_consume_budget(p_category_id uuid, p_user uuid, p_stage integer, p_early_budget integer, p_late_budget integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$DECLARE
  v_today timestamptz := date_trunc('day', now());
BEGIN
  -- Ensure state row exists (unique key is: user_id, category_id, mode)
  INSERT INTO public.user_hybrid_daily_state (
    user_id, category_id, mode, day_start,
    early_done, late_done, last_stage, same_stage_run, updated_at
  )
  VALUES (
    p_user, p_category_id, 'hybrid'::public.srs_mode, v_today,
    0, 0, NULL, 0, now()
  )
  ON CONFLICT (user_id, category_id, mode)
  DO UPDATE
  SET
    -- keep day_start in sync (new day -> roll to today and reset counters)
    day_start = CASE
      WHEN public.user_hybrid_daily_state.day_start < v_today THEN v_today
      ELSE public.user_hybrid_daily_state.day_start
    END,
    early_done = CASE
      WHEN public.user_hybrid_daily_state.day_start < v_today THEN 0
      ELSE public.user_hybrid_daily_state.early_done
    END,
    late_done = CASE
      WHEN public.user_hybrid_daily_state.day_start < v_today THEN 0
      ELSE public.user_hybrid_daily_state.late_done
    END,
    updated_at = now();

  -- Consume budget (with hard cap)
  UPDATE public.user_hybrid_daily_state u
  SET
    early_done = CASE
      WHEN p_stage BETWEEN 0 AND 2 AND u.early_done < p_early_budget THEN u.early_done + 1
      ELSE u.early_done
    END,
    late_done  = CASE
      WHEN p_stage BETWEEN 3 AND 5 AND u.late_done < p_late_budget THEN u.late_done + 1
      ELSE u.late_done
    END,
    last_stage = p_stage,
    same_stage_run = CASE
      WHEN u.last_stage = p_stage THEN u.same_stage_run + 1
      ELSE 1
    END,
    updated_at = now()
  WHERE u.user_id = p_user
    AND u.category_id = p_category_id
    AND u.mode = 'hybrid'::public.srs_mode;

  -- If we attempted to consume but were already at cap, fail fast (hard cap enforcement)
  IF p_stage BETWEEN 0 AND 2 THEN
    IF (SELECT early_done FROM public.user_hybrid_daily_state
        WHERE user_id=p_user AND category_id=p_category_id AND mode='hybrid'::public.srs_mode) > p_early_budget THEN
      RAISE EXCEPTION 'Early budget exceeded (cap=%)', p_early_budget;
    END IF;
  ELSIF p_stage BETWEEN 3 AND 5 THEN
    IF (SELECT late_done FROM public.user_hybrid_daily_state
        WHERE user_id=p_user AND category_id=p_category_id AND mode='hybrid'::public.srs_mode) > p_late_budget THEN
      RAISE EXCEPTION 'Late budget exceeded (cap=%)', p_late_budget;
    END IF;
  END IF;
END;$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_counts_as_late_done(p_user uuid, p_category_id uuid, p_word_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select exists (
    select 1
    from public.user_word_srs uws
    where uws.user_id = p_user
      and uws.category_id = p_category_id
      and uws.mode = 'hybrid'::public.srs_mode
      and uws.word_id = p_word_id

      -- Late-Band
      and uws.stage between 3 and 5

      -- war zum Zeitpunkt der Prüfung wirklich DUE
      and uws.next_due_at is not null
      and uws.next_due_at <= now()

      -- und war NICHT durch Zeitlock gesperrt (6h / 18h / 72h)
      and (
        uws.last_reviewed_at is null
        or now() >= uws.last_reviewed_at + public.fn_hybrid_lock_interval(uws.stage)
      )
  );
$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_daily_ensure(p_category_id uuid, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_day date := (now() at time zone 'utc')::date;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- Guard: nur sich selbst (wenn JWT vorhanden)
  if auth.uid() is not null and v_user <> auth.uid() then
    raise exception 'Forbidden: cannot access other user.';
  end if;

  insert into public.user_hybrid_daily_stats(user_id, category_id, day)
  values (v_user, p_category_id, v_day)
  on conflict (user_id, category_id, day) do nothing;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_daily_get(p_category_id uuid, p_user uuid DEFAULT NULL::uuid)
 RETURNS TABLE(day date, early_done integer, late_done integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_day date := (now() at time zone 'utc')::date;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  if auth.uid() is not null and v_user <> auth.uid() then
    raise exception 'Forbidden: cannot access other user.';
  end if;

  perform public.fn_hybrid_daily_ensure(p_category_id, v_user);

  return query
  select s.day, s.early_done, s.late_done
  from public.user_hybrid_daily_stats s
  where s.user_id = v_user
    and s.category_id = p_category_id
    and s.day = v_day;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_daily_inc(p_category_id uuid, p_bucket text, p_delta integer DEFAULT 1, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_day date := (now() at time zone 'utc')::date;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  if auth.uid() is not null and v_user <> auth.uid() then
    raise exception 'Forbidden: cannot access other user.';
  end if;

  perform public.fn_hybrid_daily_ensure(p_category_id, v_user);

  update public.user_hybrid_daily_stats s
  set
    early_done = case when p_bucket = 'early' then s.early_done + p_delta else s.early_done end,
    late_done  = case when p_bucket = 'late'  then s.late_done  + p_delta else s.late_done  end,
    updated_at = now()
  where s.user_id = v_user
    and s.category_id = p_category_id
    and s.day = v_day;

  if not found then
    raise exception 'Daily stats missing (unexpected).';
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_daily_inc(p_category_id uuid, p_user uuid, p_is_late boolean, p_early_budget integer DEFAULT 18, p_late_budget integer DEFAULT 12)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
  v_day date := (now() at time zone 'utc')::date;
begin
  insert into public.hybrid_daily(user_id, category_id, day, early_done, late_done)
  values (p_user, p_category_id, v_day, 0, 0)
  on conflict (user_id, category_id, day) do nothing;

  if p_is_late then
    update public.hybrid_daily d
    set late_done = least(d.late_done + 1, p_late_budget)
    where d.user_id = p_user and d.category_id = p_category_id and d.day = v_day;
  else
    update public.hybrid_daily d
    set early_done = least(d.early_done + 1, p_early_budget)
    where d.user_id = p_user and d.category_id = p_category_id and d.day = v_day;
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_get_daily_state(p_category_id uuid, p_user uuid DEFAULT NULL::uuid)
 RETURNS public.user_hybrid_daily_state
 LANGUAGE plpgsql
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_day  timestamptz := date_trunc('day', now());
  v_row  public.user_hybrid_daily_state;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  select *
    into v_row
  from public.user_hybrid_daily_state s
  where s.user_id = v_user
    and s.category_id = p_category_id
    and s.mode = 'hybrid'::public.srs_mode
    and s.day_start = v_day;

  if not found then
    insert into public.user_hybrid_daily_state(
      user_id, category_id, mode, day_start,
      early_done, late_done, last_stage, same_stage_run
    )
    values (
      v_user, p_category_id, 'hybrid'::public.srs_mode, v_day,
      0, 0, null, 0
    )
    returning * into v_row;
  end if;

  return v_row;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_lock_interval(p_stage integer)
 RETURNS interval
 LANGUAGE sql
 STABLE
AS $function$
  select case p_stage
    when 3 then interval '6 hours'
    when 4 then interval '18 hours'
    when 5 then interval '72 hours'
    else interval '0 hours'  -- Stage 0–2: kein Zeit-Lock (wird über Budgets geregelt)
  end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_next_stage(p_category_id uuid, p_user uuid DEFAULT NULL::uuid, p_last_stage integer DEFAULT NULL::integer, p_same_stage_count integer DEFAULT 0, p_early_budget integer DEFAULT 18, p_late_budget integer DEFAULT 12, p_max_same_stage integer DEFAULT 3)
 RETURNS TABLE(next_stage integer, reason text, early_remaining integer, late_remaining integer)
 LANGUAGE plpgsql
 STABLE
AS $function$DECLARE
  v_user uuid := COALESCE(p_user, auth.uid());
  v_today timestamptz := date_trunc('day', now());

  s record;

  v_late_best int;
  v_early_best int;

  v_has_due_late boolean;   -- ✅ NEW
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  END IF;

  -- 1) HARD CAP: budgets come ONLY from user_hybrid_daily_state (source of truth)
  SELECT
    uhd.early_done,
    uhd.late_done
  INTO s
  FROM public.user_hybrid_daily_state uhd
  WHERE uhd.user_id = v_user
    AND uhd.category_id = p_category_id
    AND uhd.mode = 'hybrid'::public.srs_mode
    AND uhd.day_start = v_today;

  early_remaining := greatest(p_early_budget - COALESCE(s.early_done, 0), 0);
  late_remaining  := greatest(p_late_budget  - COALESCE(s.late_done, 0), 0);

  -- 2) best late stage (highest stage 5..3) that is due and unlocked
  SELECT uws.stage
    INTO v_late_best
  FROM public.user_word_srs uws
  WHERE uws.user_id = v_user
    AND uws.category_id = p_category_id
    AND uws.mode = 'hybrid'::public.srs_mode
    AND uws.stage BETWEEN 3 AND 5
    AND uws.next_due_at IS NOT NULL
    AND uws.next_due_at <= now()
    AND NOT public.fn_hybrid_stage_locked(v_user, p_category_id, uws.stage)
  ORDER BY uws.stage DESC
  LIMIT 1;

  -- ✅ NEW: "due late exists" check (ignoring locks)
  SELECT EXISTS (
    SELECT 1
    FROM public.user_word_srs uws
    WHERE uws.user_id = v_user
      AND uws.category_id = p_category_id
      AND uws.mode = 'hybrid'::public.srs_mode
      AND uws.stage BETWEEN 3 AND 5
      AND uws.next_due_at IS NOT NULL
      AND uws.next_due_at <= now()
  )
  INTO v_has_due_late;

  -- 3) best early stage (prefer 2, then 1, then 0) that has any cards
  SELECT uws.stage
    INTO v_early_best
  FROM public.user_word_srs uws
  WHERE uws.user_id = v_user
    AND uws.category_id = p_category_id
    AND uws.mode = 'hybrid'::public.srs_mode
    AND uws.stage BETWEEN 0 AND 2
  ORDER BY uws.stage DESC
  LIMIT 1;

  -- ✅ NEW: if due late exists BUT none is unlocked => all_locked (do NOT fall back to early)
  IF late_remaining > 0 AND v_has_due_late AND v_late_best IS NULL THEN
    next_stage := NULL;
    reason := 'all_locked';
    RETURN NEXT;
    RETURN;
  END IF;

  -- LATE FIRST (only if late budget available AND there is a due+unlocked late card)
  IF late_remaining > 0 AND v_late_best IS NOT NULL THEN
    next_stage := v_late_best;
    reason := 'late_due_available';

  ELSIF early_remaining > 0 AND v_early_best IS NOT NULL THEN
    next_stage := v_early_best;
    reason := 'early_available';

  ELSE
    next_stage := NULL;
    reason := CASE
      WHEN late_remaining <= 0 AND early_remaining <= 0 THEN 'budgets_exhausted'
      WHEN v_late_best IS NULL AND v_early_best IS NULL THEN 'no_cards'
      WHEN v_late_best IS NULL THEN 'no_due_late'
      ELSE 'all_locked'
    END;
  END IF;

  -- MaxSameStage guard
  IF next_stage IS NOT NULL
     AND p_last_stage IS NOT NULL
     AND next_stage = p_last_stage
     AND p_same_stage_count >= p_max_same_stage THEN

    IF next_stage BETWEEN 3 AND 5 THEN
      SELECT uws.stage
        INTO next_stage
      FROM public.user_word_srs uws
      WHERE uws.user_id = v_user
        AND uws.category_id = p_category_id
        AND uws.mode = 'hybrid'::public.srs_mode
        AND uws.stage BETWEEN 3 AND 5
        AND uws.stage <> p_last_stage
        AND uws.next_due_at IS NOT NULL
        AND uws.next_due_at <= now()
        AND NOT public.fn_hybrid_stage_locked(v_user, p_category_id, uws.stage)
      ORDER BY uws.stage DESC
      LIMIT 1;

      IF next_stage IS NULL AND early_remaining > 0 AND v_early_best IS NOT NULL THEN
        next_stage := v_early_best;
        reason := 'early_available_forced_by_maxsame';
      ELSE
        reason := 'late_due_available_forced_by_maxsame';
      END IF;

    ELSE
      SELECT uws.stage
        INTO next_stage
      FROM public.user_word_srs uws
      WHERE uws.user_id = v_user
        AND uws.category_id = p_category_id
        AND uws.mode = 'hybrid'::public.srs_mode
        AND uws.stage BETWEEN 0 AND 2
        AND uws.stage <> p_last_stage
      ORDER BY uws.stage DESC
      LIMIT 1;

      IF next_stage IS NULL AND late_remaining > 0 AND v_late_best IS NOT NULL THEN
        next_stage := v_late_best;
        reason := 'late_due_available_forced_by_maxsame';
      ELSE
        reason := 'early_available_forced_by_maxsame';
      END IF;
    END IF;
  END IF;

  RETURN NEXT;
END;$function$
;

CREATE OR REPLACE FUNCTION public.fn_hybrid_stage_locked(p_user uuid, p_category_id uuid, p_stage integer)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select not exists (
    select 1
    from public.user_word_srs uws
    where uws.user_id = p_user
      and uws.category_id = p_category_id
      and uws.mode = 'hybrid'::public.srs_mode
      and uws.stage = p_stage
      -- nur "late" Kandidaten, die wirklich due sind
      and uws.next_due_at is not null
      and uws.next_due_at <= now()
      -- und deren Stage-Lock abgelaufen ist
      and (
        uws.last_reviewed_at is null
        or now() >= uws.last_reviewed_at + public.fn_hybrid_lock_interval(p_stage)
      )
  );
$function$
;

CREATE OR REPLACE FUNCTION public.fn_requeue_s0_fail(p_category_id uuid, p_word_id uuid, p_mode text DEFAULT 'adaptive'::text, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_mode public.srs_mode := p_mode::public.srs_mode;
  v_show_after int;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- nächste freie Position 1..10 (ansonsten 10)
  select least(10, coalesce(max(r.show_after), 0) + 1)
    into v_show_after
  from public.user_requeue r
  where r.user_id = v_user
    and r.category_id = p_category_id
    and r.mode = v_mode;

  insert into public.user_requeue(user_id, category_id, mode, word_id, show_after, created_at)
  values (v_user, p_category_id, v_mode, p_word_id, v_show_after, now())
  on conflict (user_id, category_id, mode, word_id)
  do update set
    show_after = excluded.show_after,
    created_at = excluded.created_at;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_requeue_s0_fail(p_word_id uuid, p_category_id uuid, p_mode public.srs_mode, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_stage int;
  v_stage0_count int;
  v_show_after int;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- aktuelle Stage holen (missing => 0)
  select coalesce(uws.stage, 0)
    into v_stage
  from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.word_id = p_word_id
    and uws.category_id = p_category_id
    and uws.mode = p_mode;

  v_stage := coalesce(v_stage, 0);

  -- nur wenn wirklich Stage 0
  if v_stage <> 0 then
    return;
  end if;

  -- Stage0 Count der Kategorie
  select count(*)::int
    into v_stage0_count
  from public.word_categories wc
  left join public.user_word_srs uws
    on uws.user_id = v_user
   and uws.word_id = wc.word_id
   and uws.category_id = wc.category_id
   and uws.mode = p_mode
  where wc.category_id = p_category_id
    and coalesce(uws.stage, 0) = 0;

  v_stage0_count := coalesce(v_stage0_count, 0);

  -- Regel: bei <10 darf ans Ende, sonst max 10 später
  if v_stage0_count < 10 then
    v_show_after := 999999;
  else
    v_show_after := 10;
  end if;

  insert into public.user_requeue (user_id, category_id, mode, word_id, show_after, created_at)
  values (v_user, p_category_id, p_mode, p_word_id, v_show_after, now())
  on conflict (user_id, category_id, mode, word_id)
  do update set
    show_after = excluded.show_after,
    created_at = excluded.created_at;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_reset_category_progress(cat uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$declare
  v_user uuid := auth.uid();
begin
  -- Guard: muss im User-Kontext laufen
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Run from app or set JWT claims in SQL editor.';
  end if;

  -- 1) Fortschritt löschen: alle SRS-Einträge dieser Kategorie für den User
  delete from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.category_id = cat;

  -- 2) Optional aber sinnvoll: Requeue ebenfalls löschen
  delete from public.user_requeue r
  where r.user_id = v_user
    and r.category_id = cat;

end;$function$
;

CREATE OR REPLACE FUNCTION public.fn_reset_category_progress(p_category_id uuid, p_mode text, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_mode public.srs_mode := p_mode::public.srs_mode;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- Guard: in der App darf niemand andere Nutzer resetten
  if auth.uid() is not null and v_user <> auth.uid() then
    raise exception 'Forbidden: cannot reset other user.';
  end if;

  -- Progress löschen (damit Stage 0 wieder "voll" ist)
  delete from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.category_id = p_category_id
    and uws.mode = v_mode;

  -- Requeue ebenfalls leeren (sonst kommen Wörter wieder „vorgemerkt“)
  delete from public.user_requeue r
  where r.user_id = v_user
    and r.category_id = p_category_id
    and r.mode = v_mode;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_reset_user_category(p_category_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user uuid := auth.uid();
  v_affected int;
begin
  update public.user_words uw
  set srs_stage = 0,
      next_due_at = null,
      last_reviewed_at = null,
      last_result = null
  from public.word_categories wc
  where uw.user_id = v_user
    and wc.word_id = uw.word_id
    and wc.category_id = p_category_id;

  get diagnostics v_affected = row_count;
  return jsonb_build_object('affected', v_affected);
end
$function$
;

CREATE OR REPLACE FUNCTION public.fn_reset_user_category(p_category_id uuid, p_mode text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user uuid := auth.uid();
  v_mode public.srs_mode := p_mode::public.srs_mode;
  v_deleted_srs int := 0;
  v_deleted_requeue int := 0;
  v_deleted_single int := 0;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL).';
  end if;

  -- Reset NUR für den gewählten Modus
  delete from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.category_id = p_category_id
    and uws.mode = v_mode;

  get diagnostics v_deleted_srs = row_count;

  -- Optional: Queue pro Modus leeren (falls Tabelle/Spalte existiert)
  delete from public.user_requeue r
  where r.user_id = v_user
    and r.category_id = p_category_id
    and r.mode = v_mode;

  get diagnostics v_deleted_requeue = row_count;

  delete from public.single_session_items ssi
  where ssi.user_id = v_user
    and ssi.category_id = p_category_id
    and ssi.mode = v_mode;

  get diagnostics v_deleted_single = row_count;

  return jsonb_build_object(
    'mode', v_mode::text,
    'deleted_user_word_srs', v_deleted_srs,
    'deleted_user_requeue', v_deleted_requeue,
    'deleted_single_session_items', v_deleted_single
  );
end
$function$
;

CREATE OR REPLACE FUNCTION public.fn_seed_user_category(p_category_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
with src as (
  select w.id
  from public.words w
  join public.word_categories wc on wc.word_id = w.id
  where wc.category_id = p_category_id
  order by w.id asc
),
ins as (
  insert into public.user_words (user_id, word_id, srs_stage, next_due_at, picked, favorite, source, created_at)
  select auth.uid(), src.id, 0, null, false, false, 'app', now()
  from src
  left join public.user_words uw
    on uw.user_id = auth.uid() and uw.word_id = src.id
  where uw.word_id is null
  returning word_id
)
select jsonb_build_object('seeded', (select count(*) from ins));
$function$
;

CREATE OR REPLACE FUNCTION public.fn_set_s0_locked(p_category_id uuid, p_mode public.srs_mode, p_locked boolean, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- Hybrid: S0-Lock darf nicht gesetzt werden
  if p_mode = 'hybrid'::public.srs_mode then
    raise exception 'S0 lock is not allowed in hybrid mode.';
  end if;

  insert into public.user_s0_lock_state(user_id, category_id, mode, s0_locked, updated_at)
  values (v_user, p_category_id, p_mode, p_locked, now())
  on conflict (user_id, category_id, mode) do update
    set s0_locked = excluded.s0_locked,
        updated_at = now();
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_single_session_counts(p_category_id uuid, p_stage integer)
 RETURNS TABLE(src integer, sr1 integer, sr2 integer)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    count(*) filter (where bucket = 'src') as src,
    count(*) filter (where bucket = 'sr1') as sr1,
    count(*) filter (where bucket = 'sr2') as sr2
  from public.single_session_items
  where user_id = auth.uid()
    and category_id = p_category_id
    and stage = p_stage;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_single_session_move(p_category_id uuid, p_stage integer, p_word_id uuid, p_correct boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_old text;
  v_new text;
  v_delay interval;
begin
  -- Aktuellen Bucket holen
  select bucket
    into v_old
  from public.single_session_items
  where user_id = auth.uid()
    and category_id = p_category_id
    and stage = p_stage
    and word_id = p_word_id
  limit 1;

  if v_old is null then
    v_old := 'src';
    insert into public.single_session_items(user_id, category_id, stage, word_id, bucket)
    values (auth.uid(), p_category_id, p_stage, p_word_id, v_old)
    on conflict (user_id, category_id, stage, word_id)
      do update set bucket = excluded.bucket;
  end if;

  -- Mini-SRS Übergänge (SRC <-> SR1 <-> SR2)
  if p_correct then
    case v_old
      when 'src' then v_new := 'sr1';
      when 'sr1' then v_new := 'sr2';
      when 'sr2' then v_new := 'sr2';  -- bleibt in SR2
      else v_new := v_old;
    end case;
  else
    case v_old
      when 'sr2' then v_new := 'sr1';  -- zurück nach SR1
      when 'sr1' then v_new := 'src';  -- zurück nach SRC
      when 'src' then v_new := 'src';
      else v_new := v_old;
    end case;
  end if;

  -- Kleine Verzögerung, damit Karten später wieder aktiv werden
  select (5 + floor(random() * 6))::int * interval '1 second' into v_delay;

  update public.single_session_items
     set bucket = v_new,
         created_at = now() + v_delay
   where user_id = auth.uid()
     and category_id = p_category_id
     and stage = p_stage
     and word_id = p_word_id;

  if not found then
    insert into public.single_session_items(user_id, category_id, stage, word_id, bucket, created_at)
    values (auth.uid(), p_category_id, p_stage, p_word_id, v_new, now() + v_delay)
    on conflict (user_id, category_id, stage, word_id)
      do update set bucket = excluded.bucket, created_at = excluded.created_at;
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_single_session_move(p_category_id uuid, p_stage integer, p_word_id uuid, p_to_bucket text)
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  insert into public.single_session_items (user_id, category_id, stage, word_id, bucket, created_at)
  values (auth.uid(), p_category_id, p_stage, p_word_id, p_to_bucket, now())
  on conflict (user_id, category_id, stage, word_id)
  do update set bucket = excluded.bucket, created_at = now();
$function$
;

CREATE OR REPLACE FUNCTION public.fn_single_session_next(p_category_id uuid, p_stage integer)
 RETURNS TABLE(word_id uuid, bucket text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select word_id, bucket
  from public.single_session_items
  where user_id = auth.uid()
    and category_id = p_category_id
    and stage = p_stage
    and bucket in ('src','sr1','sr2')   -- zieht jetzt ALLE
  order by created_at asc
  limit 1;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_single_session_next_src(p_category_id uuid, p_stage integer)
 RETURNS uuid
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select word_id
  from public.single_session_items
  where user_id = auth.uid()
    and category_id = p_category_id
    and stage = p_stage
    and bucket = 'src'
  order by created_at
  limit 1;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_single_session_reset(p_category_id uuid, p_stage integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  -- vollständige Session dieser Stage entfernen
  delete from public.single_session_items
  where user_id = auth.uid()
    and category_id = p_category_id
    and stage = p_stage;

  -- erneut seeden
  perform public.fn_single_session_seed(p_category_id, p_stage, 200);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_single_session_seed(p_category_id uuid, p_stage integer, p_limit integer DEFAULT 200)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  -- alte Items der Session löschen
  delete from public.single_session_items
  where user_id = auth.uid()
    and category_id = p_category_id
    and stage = p_stage;

  -- neue Quelle (SRC) füllen – nur Wörter der Kategorie in genau dieser Stage
  insert into public.single_session_items (user_id, category_id, stage, word_id, bucket)
  select
    auth.uid(),
    p_category_id,
    p_stage,
    v.id,
    'src'
  from public.v_words_user as v
  join public.word_categories wc on wc.word_id = v.id
  where wc.category_id = p_category_id
    and coalesce(v.srs_stage_user,0) = p_stage
  order by random()
  limit p_limit
  on conflict (user_id, category_id, stage, word_id) do nothing;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_srs_reset_category(p_category_id uuid, p_mode text, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_mode public.srs_mode := p_mode::public.srs_mode;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- Sicherheitscheck: aktuell nur adaptive erlaubt
  if v_mode <> 'adaptive' then
    raise exception 'Reset currently supports only adaptive mode. Got=%', v_mode;
  end if;

  -- Alle SRS-Zustände der Kategorie zurücksetzen
  update public.user_word_srs
  set
    stage = 0,
    streak = 0,
    lapses = 0,
    ef = 1.0,
    next_due_at = null,
    last_reviewed_at = null
  where user_id = v_user
    and category_id = p_category_id
    and mode = v_mode;

end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_submit_review(_word_id uuid, _correct boolean, _user_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  update user_words
  set
    srs_stage = case
      when _correct and srs_stage < 5 then srs_stage + 1
      when not _correct and srs_stage > 0 then srs_stage - 1
      else srs_stage
    end,
    last_reviewed_at = now(),
    next_due_at = case
      when _correct then
        now() + interval '1 hour' * power(2, srs_stage)  -- Exponential steigende Intervalle
      else
        now() + interval '10 minutes'
    end
  where word_id = _word_id and user_id = _user_id;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_tsrs_allow_new_cards(p_category_id uuid, p_mode text, p_user uuid)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  WITH stats AS (
    SELECT
      COUNT(*) FILTER (
        WHERE srs_stage_user BETWEEN 1 AND 5
          AND next_due_at_user <= now()
      ) AS due_reviews,

      COUNT(*) FILTER (
        WHERE srs_stage_user = 1
      ) AS t1_count,

      COUNT(*) FILTER (
        WHERE srs_stage_user = 1
          AND user_added_at >= date_trunc('day', now())
      ) AS new_today
    FROM public.v_words_user_srs
    WHERE category_id = p_category_id
      AND srs_mode = p_mode
      AND user_id = p_user
  )
  SELECT
    due_reviews = 0
    AND t1_count <= 30
    AND new_today < 10
  FROM stats;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_category_progress(cat uuid)
 RETURNS TABLE(total bigint, stage0 bigint, stage1 bigint, stage2 bigint, stage3 bigint, stage4 bigint, stage5 bigint, due_today bigint, new_total bigint)
 LANGUAGE sql
 STABLE
AS $function$
  with base as (
    select
      coalesce(srs_stage_user, 0) as stage,
      next_due_at_user
    from public.v_words_user_cats
    where category_id = cat
  )
  select
    count(*)::bigint as total,
    count(*) filter (where stage = 0)::bigint as stage0,
    count(*) filter (where stage = 1)::bigint as stage1,
    count(*) filter (where stage = 2)::bigint as stage2,
    count(*) filter (where stage = 3)::bigint as stage3,
    count(*) filter (where stage = 4)::bigint as stage4,
    count(*) filter (where stage = 5)::bigint as stage5,
    count(*) filter (where next_due_at_user is not null and next_due_at_user <= now())::bigint as due_today,
    count(*) filter (where stage = 0)::bigint as new_total
  from base;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_category_progress(p_category uuid, p_mode public.srs_mode, p_user uuid DEFAULT NULL::uuid)
 RETURNS TABLE(total integer, stages integer[], due_today integer)
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
with base as (
  select
    wc.word_id,
    coalesce(uws.stage, 0) as stage,
    uws.next_due_at
  from public.word_categories wc
  left join public.user_word_srs uws
    on uws.user_id = coalesce(p_user, auth.uid())
   and uws.category_id = wc.category_id
   and uws.word_id = wc.word_id
   and uws.mode = p_mode
  where wc.category_id = p_category
),
agg as (
  select
    count(*)::int as total,
    array[
      count(*) filter (where stage = 0),
      count(*) filter (where stage = 1),
      count(*) filter (where stage = 2),
      count(*) filter (where stage = 3),
      count(*) filter (where stage = 4),
      count(*) filter (where stage = 5)
    ]::int[] as stages,
    count(*) filter (
      where stage > 0
        and next_due_at is not null
        and next_due_at <= now()
    )::int as due_today
  from base
)
select total, stages, due_today from agg;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_category_progress_mode(p_cat uuid, p_mode text, p_user uuid)
 RETURNS TABLE(total bigint, stage0 bigint, stage1 bigint, stage2 bigint, stage3 bigint, stage4 bigint, stage5 bigint, mastered bigint, due_today bigint, new_total bigint)
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  with p as (
    select
      coalesce(p_user, auth.uid()) as user_id,
      p_cat as category_id,
      (p_mode::public.srs_mode) as mode
  )
  select
    count(*) filter (where wp.is_mastered = false)                                  as total,

    count(*) filter (
      where wp.stage = 0
        and wp.ever_enrolled = false
        and wp.is_mastered = false
    )                                                                               as stage0,

    count(*) filter (where wp.stage = 1 and wp.is_mastered = false)                as stage1,
    count(*) filter (where wp.stage = 2 and wp.is_mastered = false)                as stage2,
    count(*) filter (where wp.stage = 3 and wp.is_mastered = false)                as stage3,
    count(*) filter (where wp.stage = 4 and wp.is_mastered = false)                as stage4,
    count(*) filter (where wp.stage = 5 and wp.is_mastered = false)                as stage5,

    count(*) filter (where wp.is_mastered = true)                                  as mastered,

    0::bigint                                                                       as due_today,

    count(*) filter (
      where wp.stage = 0
        and wp.ever_enrolled = false
        and wp.is_mastered = false
    )                                                                               as new_total
  from public.word_progress wp
  join p on
       wp.user_id     = p.user_id
   and wp.category_id = p.category_id
   and wp.mode        = p.mode;
$function$
;

-- v_words_user muss VOR fn_user_learn_queue existieren (Referenz)
create or replace view "public"."v_words_user" as  SELECT w.id,
    w.text,
    w.translation,
    w.from_lang,
    w.to_lang,
    w.domain,
    w.pos,
    w.level,
    w.tags,
    w.created_at AS word_created_at,
    (uw.user_id IS NOT NULL) AS in_my_words,
    COALESCE(uw.picked, false) AS picked_user,
    COALESCE(uw.favorite, false) AS favorite_user,
    uw.created_at AS user_added_at,
    COALESCE((uw.srs_stage)::integer, 0) AS srs_stage_user,
    uw.next_due_at AS next_due_at_user,
    uw.last_reviewed_at AS last_reviewed_at_user,
    uw.last_result AS last_result_user
   FROM (public.words w
     LEFT JOIN public.user_words uw ON (((uw.word_id = w.id) AND (uw.user_id = auth.uid()))));

CREATE OR REPLACE FUNCTION public.fn_user_learn_queue(cat uuid, take integer DEFAULT 50)
 RETURNS SETOF public.v_words_user
 LANGUAGE sql
 STABLE
AS $function$
  select vu.*
  from public.v_words_user vu
  join public.word_categories wc on wc.word_id = vu.id
  where wc.category_id = cat
  order by
    case
      when vu.next_due_at_user is not null and vu.next_due_at_user <= now() then 0
      when vu.srs_stage_user = 0 then 1
      else 2
    end,
    coalesce(vu.next_due_at_user, now() + interval '100 years') asc,
    vu.word_created_at asc
  limit take
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_learn_queue_adaptive(p_category_id uuid, p_take integer DEFAULT 30, p_user uuid DEFAULT NULL::uuid)
 RETURNS TABLE(word_id uuid, category_id uuid, srs_stage integer, next_due_at timestamp with time zone, is_requeue boolean)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    out_word_id as word_id,
    out_category_id as category_id,
    out_srs_stage as srs_stage,
    out_next_due_at as next_due_at,
    out_is_requeue as is_requeue
  from public.fn_user_learn_queue_adaptive_impl(p_category_id, p_take, p_user);
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_learn_queue_adaptive_impl(p_category_id uuid, p_take integer DEFAULT 30, p_user uuid DEFAULT NULL::uuid)
 RETURNS TABLE(out_word_id uuid, out_category_id uuid, out_srs_stage integer, out_next_due_at timestamp with time zone, out_is_requeue boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_take int := greatest(coalesce(p_take, 30), 1);
  v_mode_txt text := 'adaptive';
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  return query
  with
  p as (
    select v_user as user_id, p_category_id as cat_id, v_take as take_n
  ),

  rf as (
    select coalesce(
      (
        select crs.refill_counter
        from public.category_refill_state crs
        join p on crs.user_id = p.user_id
              and crs.category_id = p.cat_id
              and crs.mode::text = v_mode_txt
        limit 1
      ),
      0
    )::int as refill_counter
  ),

  rq as (
    select r.word_id, r.show_after
    from public.user_requeue r
    join p on r.user_id = p.user_id
          and r.category_id = p.cat_id
          and r.mode::text = v_mode_txt
    order by r.created_at desc
    limit 10
  ),

  s as (
    select
      wc.word_id,
      wc.category_id,
      coalesce(wp.stage, 0)::int as stage,
      null::timestamptz as next_due_at,
      wp.updated_at as last_reviewed_at
    from public.word_categories wc
    join p on wc.category_id = p.cat_id
    left join public.word_progress wp
      on wp.user_id     = p.user_id
     and wp.word_id     = wc.word_id
     and wp.category_id = wc.category_id
     and wp.mode::text  = v_mode_txt
  ),

  s_nr as (
    select s.*
    from s
    where not exists (select 1 from rq where rq.word_id = s.word_id)
  ),

  eligible as (
    select
      snr.word_id,
      snr.category_id,
      snr.stage,
      snr.next_due_at,
      snr.last_reviewed_at,
      coalesce(wpds.last_queued_counter, -1)::int as last_queued_counter,
      (select rf.refill_counter from rf)::int as refill_counter,
      (coalesce(wpds.last_queued_counter, -1) < (select rf.refill_counter from rf)) as is_eligible
    from s_nr snr
    left join public.word_progress_deck_state wpds
      on wpds.user_id     = (select user_id from p)
     and wpds.category_id = snr.category_id
     and wpds.word_id     = snr.word_id
     and wpds.mode::text  = v_mode_txt
  ),

  s_ok as (
    select * from eligible where is_eligible = true
  ),

  s1 as (
    select e.word_id, e.category_id, 1 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 1
  ),
  s2 as (
    select e.word_id, e.category_id, 2 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 2
  ),
  s3 as (
    select e.word_id, e.category_id, 3 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 3
  ),
  s4 as (
    select e.word_id, e.category_id, 4 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 4
  ),
  s5 as (
    select e.word_id, e.category_id, 5 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 5
  ),

  base as (
    select s2.word_id, s2.category_id, s2.stg, s2.next_due_at, 60 as prio, s2.rn from s2
    union all select s3.word_id, s3.category_id, s3.stg, s3.next_due_at, 59 as prio, s3.rn from s3
    union all select s1.word_id, s1.category_id, s1.stg, s1.next_due_at, 58 as prio, s1.rn from s1
    union all select s4.word_id, s4.category_id, s4.stg, s4.next_due_at, 57 as prio, s4.rn from s4
    union all select s5.word_id, s5.category_id, s5.stg, s5.next_due_at, 56 as prio, s5.rn from s5 where s5.rn <= 2
  ),

  base_pos as (
    select b.*,
           row_number() over (order by b.prio desc, b.rn asc, b.word_id) as base_i
    from base b
  ),

  base_final as (
    select
      bp.word_id, bp.category_id, bp.stg, bp.next_due_at,
      (bp.base_i + (select count(*) from rq where rq.show_after <= bp.base_i)) as pos
    from base_pos bp
  ),

  rq_final as (
    select
      r.word_id,
      (select cat_id from p) as category_id,
      coalesce(wp.stage, 0)::int as stg,
      null::timestamptz as next_due_at,
      r.show_after as pos
    from rq r
    left join public.word_progress wp
      on wp.user_id     = (select user_id from p)
     and wp.word_id     = r.word_id
     and wp.category_id = (select cat_id from p)
     and wp.mode::text  = v_mode_txt
  ),

  merged as (
    select rqf.word_id, rqf.category_id, rqf.stg, rqf.next_due_at, rqf.pos, true as is_requeue
    from rq_final rqf
    union all
    select bf.word_id, bf.category_id, bf.stg, bf.next_due_at, bf.pos, false as is_requeue
    from base_final bf
  ),

  final_take as materialized (
    select m.word_id, m.category_id, m.pos
    from merged m
    order by m.pos asc, m.word_id
    limit (select take_n from p)
  ),

  mark_queued as (
    insert into public.word_progress_deck_state
      (user_id, category_id, word_id, mode, last_queued_counter, updated_at)
    select
      (select user_id from p),
      ft.category_id,
      ft.word_id,
      v_mode_txt,                       -- <- TEXT!
      (select refill_counter from rf),
      now()
    from final_take ft
    on conflict (user_id, category_id, word_id, mode)
    do update set
      last_queued_counter = excluded.last_queued_counter,
      updated_at = excluded.updated_at
    returning 1
  ),

  force_exec as (
    select count(*)::int as wrote_rows from mark_queued
  )

  select
    ft.word_id as out_word_id,
    ft.category_id as out_category_id,
    m.stg as out_srs_stage,
    m.next_due_at as out_next_due_at,
    m.is_requeue as out_is_requeue
  from final_take ft
  join merged m
    on m.word_id = ft.word_id
   and m.category_id = ft.category_id
   and m.pos = ft.pos
  cross join force_exec
  order by ft.pos asc, ft.word_id;

end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_requeue_consume(p_category_id uuid, p_word_id uuid, p_mode text DEFAULT 'adaptive'::text, p_user uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_mode public.srs_mode := p_mode::public.srs_mode;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  delete from public.user_requeue r
  where r.user_id = v_user
    and r.category_id = p_category_id
    and r.mode = v_mode
    and r.word_id = p_word_id;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_review(p_word uuid, p_result boolean)
 RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_old_stage integer;
  v_new_stage integer;
  v_next timestamptz;
  v_days integer;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  select uw.srs_stage
    into v_old_stage
  from public.user_words uw
  where uw.user_id = v_uid
    and uw.word_id = p_word;

  if p_result then
    -- CORRECT
    if v_old_stage is null then
      v_new_stage := 1;
    else
      v_new_stage := least(5, v_old_stage + 1);
    end if;

    v_days := case v_new_stage
      when 1 then 2
      when 2 then 6
      when 3 then 19
      when 4 then 45
      when 5 then 90
      else 2
    end;

    v_next := now() + make_interval(days => v_days);

    insert into public.user_words (user_id, word_id, srs_stage, next_due_at, last_reviewed_at)
    values (v_uid, p_word, v_new_stage, v_next, now())
    on conflict (user_id, word_id)
    do update set
      srs_stage = excluded.srs_stage,
      next_due_at = excluded.next_due_at,
      last_reviewed_at = excluded.last_reviewed_at;

    return query select v_new_stage, v_next;

  else
    -- WRONG
    if v_old_stage is null then
      -- bleibt "neu" (S0 ohne Row), sofort wieder fällig
      return query select 0, now();
      return;
    end if;

    v_new_stage := case
      when v_old_stage = 1 then 1
      else greatest(1, v_old_stage - 1)
    end;

    v_next := now(); -- immediate retry

    update public.user_words
    set srs_stage = v_new_stage,
        next_due_at = v_next,
        last_reviewed_at = now()
    where user_id = v_uid
      and word_id = p_word;

    return query select v_new_stage, v_next;
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_review_debug(p_user uuid, p_word uuid, p_result boolean)
 RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_old_stage integer;
  v_new_stage integer;
  v_next timestamptz;
  v_days integer;
begin
  if p_user is null then
    raise exception 'p_user is null';
  end if;

  select uw.srs_stage
    into v_old_stage
  from public.user_words uw
  where uw.user_id = p_user
    and uw.word_id = p_word;

  if p_result then
    -- CORRECT
    if v_old_stage is null then
      v_new_stage := 1;
    else
      v_new_stage := least(5, v_old_stage + 1);
    end if;

    v_days := case v_new_stage
      when 1 then 2
      when 2 then 6
      when 3 then 19
      when 4 then 45
      when 5 then 90
      else 2
    end;

    v_next := now() + make_interval(days => v_days);

    insert into public.user_words (user_id, word_id, srs_stage, next_due_at, last_reviewed_at)
    values (p_user, p_word, v_new_stage, v_next, now())
    on conflict (user_id, word_id)
    do update set
      srs_stage = excluded.srs_stage,
      next_due_at = excluded.next_due_at,
      last_reviewed_at = excluded.last_reviewed_at;

    return query select v_new_stage, v_next;

  else
    -- WRONG
    if v_old_stage is null then
      -- bleibt "neu"
      return query select 0, now();
      return;
    end if;

    -- nicht unter S1 fallen, und sofort wieder fällig machen
    v_new_stage := case
      when v_old_stage = 1 then 1
      else greatest(1, v_old_stage - 1)
    end;

    v_next := now(); -- immediate retry

    update public.user_words
    set srs_stage = v_new_stage,
        next_due_at = v_next,
        last_reviewed_at = now()
    where user_id = p_user
      and word_id = p_word;

    return query select v_new_stage, v_next;
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_review_hybrid(p_word uuid, p_category uuid, p_result boolean, p_user uuid DEFAULT NULL::uuid)
 RETURNS TABLE(srs_stage integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user  uuid := coalesce(p_user, auth.uid());
  v_stage integer := 0;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  select uws.stage
    into v_stage
  from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.word_id = p_word
    and uws.category_id = p_category
    and uws.mode = 'hybrid'::public.srs_mode;

  if not found then
    v_stage := 0;
  end if;

  perform public.fn_hybrid_consume_budget(
    p_category,
    v_user,
    v_stage,
    18,  -- early budget
    12   -- late budget
  );

  return query
  select *
  from public.fn_user_review_mode(
    p_word,
    p_category,
    p_result,
    'hybrid'::text,
    v_user
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_review_mode(p_category uuid, p_mode public.srs_mode, p_result boolean, p_user uuid, p_word uuid)
 RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT * FROM public.fn_user_review_mode_text(
    p_user,
    p_category,
    p_word,
    p_mode::text,
    p_result
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_review_mode_text(p_user uuid, p_category uuid, p_word uuid, p_mode text, p_result boolean)
 RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_stage   int;
  v_streak  int;
  v_ef      numeric;
  v_lapses  int;

  v_new_stage  int;
  v_new_streak int;
begin
  -- 1) HARD CONTRACT: niemals implicit enrollen (S0 darf nicht reviewed werden)
  select stage, streak, ef, lapses
    into v_stage, v_streak, v_ef, v_lapses
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and word_id = p_word
    and mode = p_mode
  for update;

  if not found then
    raise exception 'A-SRS: word not enrolled (S0) - use refill/enroll first'
      using errcode = 'P0001';
  end if;

  -- 2) Promotion-Regel: erst nach 2× korrekt in Folge promoten
  if p_result is true then
    v_new_streak := v_streak + 1;

    if v_new_streak >= 2 then
      v_new_stage := least(v_stage + 1, 5);
      v_new_streak := 0; -- nach Promotion streak reset
    else
      v_new_stage := v_stage; -- bleibt in Stage, nur streak steigt
    end if;

  else
    -- falsch: einfacher Bounce nach unten (konservativ), streak reset, lapses++
    v_new_stage := greatest(v_stage - 1, 1); -- niemals auf 0 (S0 ist "nicht enrolled")
    v_new_streak := 0;
    v_lapses := v_lapses + 1;
  end if;

  update public.user_word_srs
  set stage = v_new_stage,
      streak = v_new_streak,
      lapses = v_lapses,
      last_reviewed_at = now(),
      updated_at = now()
  where user_id = p_user
    and category_id = p_category
    and word_id = p_word
    and mode = p_mode;

  -- aktuell gibst du eh null zurück, daher lassen wir next_due_at = null
  srs_stage := v_new_stage;
  next_due_at := null;
  return next;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_review_mode_v2(p_word uuid, p_category uuid, p_grade smallint, p_mode text, p_response_ms integer DEFAULT NULL::integer, p_flipped boolean DEFAULT false)
 RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$declare
  v_user uuid := auth.uid();
  v_mode srs_mode := p_mode::srs_mode;

  v_stage int;
  v_ef numeric;
  v_streak int;
  v_lapses int;

  v_base_days int;
  v_interval_days int;

  v_correct boolean := (p_grade >= 1);
  v_promote boolean := (p_grade = 2);
begin
  if v_user is null then
    raise exception 'No auth user in context';
  end if;

  -- Load or init
  select stage, ef, streak, lapses
    into v_stage, v_ef, v_streak, v_lapses
  from public.user_word_srs
  where user_id = v_user and word_id = p_word and category_id = p_category and mode = v_mode;

  if not found then
    v_stage := 0; v_ef := 1.00; v_streak := 0; v_lapses := 0;
    insert into public.user_word_srs(user_id, word_id, category_id, mode)
    values (v_user, p_word, p_category, v_mode);
  end if;

  -- ===== Stage update (A/H adaptiv; Time später separat) =====
  if v_correct then
    v_streak := v_streak + 1;

    -- Aufstieg (konservativ, aber sauber):
    -- 0->1 bei erstem Erfolg, 1->2 nach 2x Erfolg, danach je 1x
    if v_promote then
      if v_stage = 0 then
        v_stage := 1; v_streak := 0;
      elsif v_stage = 1 and v_streak >= 2 then
        v_stage := 2; v_streak := 0;
      elsif v_stage between 2 and 4 and v_streak >= 1 then
        v_stage := v_stage + 1; v_streak := 0;
      end if;
    end if;

    -- EF-Update nur für adaptive/hybrid
    if v_mode in ('adaptive','hybrid') then
      -- grade: 2 = sicher, 1 = hard/unsicher
      v_ef := case p_grade
        when 2 then least(2.30, v_ef + 0.06)
        when 1 then greatest(0.60, v_ef - 0.02)
        else v_ef
      end;
    end if;

  else
    v_lapses := v_lapses + 1;
    v_streak := 0;

    -- nie unter Stage 1 zurück in A/H (wie dein Wunsch)
    v_stage := greatest(1, v_stage - 1);

    if v_mode in ('adaptive','hybrid') then
      v_ef := greatest(0.60, v_ef - 0.18);
    end if;
  end if;

  -- ===== BaseDays (wie T-SRS transparent) =====
  v_base_days := case v_stage
    when 1 then 1
    when 2 then 2
    when 3 then 6
    when 4 then 19
    when 5 then 60
    else 0
  end;

  if v_stage = 0 then
    next_due_at := null;
  else
    if v_mode in ('adaptive','hybrid') then
      v_interval_days := greatest(1, round(v_base_days * v_ef)::int);
      -- "hard" soll früher wiederkommen als "good"
      if p_grade = 1 then
        v_interval_days := greatest(1, ceil(v_interval_days * 0.6)::int);
      end if;
    else
      v_interval_days := v_base_days;
    end if;

    -- falsche Antwort: deutlich früher, aber nicht sofort
    if not v_correct then
      v_interval_days := greatest(1, ceil(v_interval_days * 0.5)::int);
    end if;

    next_due_at := now() + make_interval(days => v_interval_days);
  end if;

  update public.user_word_srs
  set stage = v_stage,
      ef = v_ef,
      streak = v_streak,
      lapses = v_lapses,
      last_reviewed_at = now(),
      next_due_at = fn_user_review_mode_v2.next_due_at
  where user_id = v_user and word_id = p_word and category_id = p_category and mode = v_mode;

  srs_stage := v_stage;
  return next;
end;$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_review_mode_v2(p_word uuid, p_category uuid, p_result boolean, p_mode text, p_user uuid DEFAULT NULL::uuid)
 RETURNS TABLE(srs_stage integer, early_done integer, late_done integer, last_stage integer, same_stage_run integer, day_start timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_stage integer;
  v_today timestamptz := date_trunc('day', now());
  v_early integer := null;
  v_late integer := null;
  v_last_stage integer := null;
  v_same_run integer := null;
  v_day_start timestamptz := null;
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- 1) run the existing review logic (keeps all your current rules/locks)
  select r.srs_stage
    into v_stage
  from public.fn_user_review_mode(p_word, p_category, p_result, p_mode, v_user) r;

  -- 2) enrich with hybrid daily counters (only for hybrid)
  if lower(p_mode) = 'hybrid' then
    select d.early_done, d.late_done, d.last_stage, d.same_stage_run, d.day_start
      into v_early, v_late, v_last_stage, v_same_run, v_day_start
    from public.user_hybrid_daily_state d
    where d.user_id = v_user
      and d.category_id = p_category
      and d.mode = 'hybrid'::public.srs_mode
      and d.day_start = v_today;
  end if;

  return query
  select v_stage, v_early, v_late, v_last_stage, v_same_run, v_day_start;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_review_time_mode(p_word uuid, p_category uuid, p_result boolean, p_user uuid DEFAULT NULL::uuid)
 RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_rows jsonb;
  v_stage int;
  v_due timestamptz;
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  -- 1) Reuse deine bestehende TIME-Logik (fn_user_review)
  -- fn_user_review nutzt auth.uid(), daher in der App p_user nur zum Speichern in user_word_srs relevant.
  -- (Wenn du fn_user_review auf user_words stützen willst, bleibt das so.)
  select (r->>'srs_stage')::int, (r->>'next_due_at')::timestamptz
    into v_stage, v_due
  from (
    select to_jsonb(x) as r
    from public.fn_user_review(p_word, p_result) x
    limit 1
  ) t;

  -- 2) Zusätzlich: mirror in user_word_srs als mode='time'
  insert into public.user_word_srs(
    user_id, word_id, category_id, mode,
    stage, streak, lapses, ef,
    next_due_at, last_reviewed_at, updated_at
  )
  values (
    v_user, p_word, p_category, 'time'::public.srs_mode,
    v_stage, 0, 0, 1.00,
    v_due, now(), now()
  )
  on conflict (user_id, word_id, category_id, mode)
  do update set
    stage = excluded.stage,
    next_due_at = excluded.next_due_at,
    last_reviewed_at = now(),
    updated_at = now();

  return query select v_stage, v_due;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_user_workload_today(cat uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user uuid := auth.uid();
  v_new_total int := 0;
  v_due_today int := 0;
BEGIN
  -- TODO: zähle hier "neue" und "fällige" Items nach deiner echten Logik.
  -- Platzhalter-Implementierung, damit die App wieder läuft:

  -- Beispiel: "neue" Wörter in der Kategorie (anpassen auf deine Tabellen)
  -- SELECT COUNT(*) INTO v_new_total
  -- FROM word_categories wc
  -- JOIN words w ON w.id = wc.word_id
  -- WHERE wc.category_id = cat;

  v_new_total := 0;
  v_due_today := 0;

  RETURN jsonb_build_object(
    'newTotal', v_new_total,
    'dueToday', v_due_today
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_wp_ensure_all_progress(p_mode public.srs_mode, p_user uuid, p_device_id text, p_device_seq bigint, p_updated_at timestamp with time zone)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_ins bigint;
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  if auth.uid() is null or auth.uid() <> v_user then
    raise exception 'forbidden';
  end if;

  if p_device_id is null or length(trim(p_device_id)) = 0 then
    raise exception 'device_id required';
  end if;

  if p_device_seq is null then
    raise exception 'device_seq required';
  end if;

  if p_updated_at is null then
    raise exception 'updated_at required';
  end if;

  insert into public.word_progress (
    user_id, category_id, word_id, mode,
    stage, streak_in_stage,
    ever_enrolled, is_mastered, mastered_version,
    added_to_category_at, mastered_at,
    updated_at, device_seq, device_id
  )
  select
    v_user,
    wc.category_id,
    wc.word_id,
    p_mode,
    0,
    0,
    false,
    false,
    0,
    coalesce(wc.created_at, now()),
    null,
    p_updated_at,
    p_device_seq,
    p_device_id
  from public.word_categories wc
  on conflict (user_id, category_id, word_id, mode) do nothing;

  get diagnostics v_ins = row_count;
  return v_ins;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_wp_ensure_category_progress(p_cat uuid, p_mode public.srs_mode, p_user uuid, p_device_id text, p_device_seq bigint, p_updated_at timestamp with time zone)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_ins bigint;
begin
  -- Auth / Guard
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  if auth.uid() is null or auth.uid() <> v_user then
    raise exception 'forbidden';
  end if;

  -- Required LWW/Sync fields (client-supplied)
  if p_device_id is null or length(trim(p_device_id)) = 0 then
    raise exception 'device_id required';
  end if;

  if p_device_seq is null then
    raise exception 'device_seq required';
  end if;

  if p_updated_at is null then
    raise exception 'updated_at required';
  end if;

  -- Backfill/Ensure rows (INSERT only)
  insert into public.word_progress (
    user_id, category_id, word_id, mode,
    stage, streak_in_stage,
    ever_enrolled, is_mastered, mastered_version,
    added_to_category_at, mastered_at,
    updated_at, device_seq, device_id
  )
  select
    v_user,
    wc.category_id,
    wc.word_id,
    p_mode,
    0,
    0,
    false,
    false,
    0,
    -- Prefer a stable timestamp from word_categories if present; fallback now()
    coalesce(wc.created_at, now()),
    null,
    p_updated_at,
    p_device_seq,
    p_device_id
  from public.word_categories wc
  where wc.category_id = p_cat
  on conflict (user_id, category_id, word_id, mode) do nothing;

  get diagnostics v_ins = row_count;
  return v_ins;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_wp_ensure_category_progress_guard(p_user uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  if auth.uid() is null or auth.uid() <> p_user then
    raise exception 'forbidden';
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$
;

create or replace view "public"."v_user_daily_picks" as  SELECT udp.id,
    udp.user_id,
    udp.word_id,
    udp.scheduled_for,
    udp.sent_at,
    udp.created_at,
    w.text,
    w.translation,
    w.from_lang,
    w.to_lang,
    w.domain,
    w.pos,
    w.level,
    w.tags
   FROM (public.user_daily_picks udp
     JOIN public.words w ON ((w.id = udp.word_id)))
  WHERE (udp.user_id = auth.uid());


create or replace view "public"."v_words_by_category" as  SELECT w.id,
    w.text,
    w.translation,
    w.from_lang,
    w.to_lang,
    w.level,
    w.pos,
    c.slug AS category_slug,
    w.created_at AS word_created_at
   FROM ((public.words w
     JOIN public.word_categories wc ON ((wc.word_id = w.id)))
     JOIN public.categories c ON ((c.id = wc.category_id)));


create or replace view "public"."v_words_missing_de" as  SELECT id,
    text,
    translation,
    from_lang,
    to_lang,
    level,
    pos
   FROM public.words
  WHERE ((from_lang = 'en'::text) AND (to_lang = 'de'::text) AND ((translation IS NULL) OR (btrim(translation) = ''::text)));


create or replace view "public"."v_words_user" as  SELECT w.id,
    w.text,
    w.translation,
    w.from_lang,
    w.to_lang,
    w.domain,
    w.pos,
    w.level,
    w.tags,
    w.created_at AS word_created_at,
    (uw.user_id IS NOT NULL) AS in_my_words,
    COALESCE(uw.picked, false) AS picked_user,
    COALESCE(uw.favorite, false) AS favorite_user,
    uw.created_at AS user_added_at,
    COALESCE((uw.srs_stage)::integer, 0) AS srs_stage_user,
    uw.next_due_at AS next_due_at_user,
    uw.last_reviewed_at AS last_reviewed_at_user,
    uw.last_result AS last_result_user
   FROM (public.words w
     LEFT JOIN public.user_words uw ON (((uw.word_id = w.id) AND (uw.user_id = auth.uid()))));


create or replace view "public"."v_words_user_cats" as  SELECT vu.id,
    vu.text,
    vu.translation,
    vu.from_lang,
    vu.to_lang,
    vu.domain,
    vu.pos,
    vu.level,
    vu.tags,
    vu.word_created_at,
    vu.in_my_words,
    vu.picked_user,
    vu.favorite_user,
    vu.user_added_at,
    vu.srs_stage_user,
    vu.next_due_at_user,
    vu.last_reviewed_at_user,
    vu.last_result_user,
    wc.category_id
   FROM (public.v_words_user vu
     LEFT JOIN public.word_categories wc ON ((wc.word_id = vu.id)));


create or replace view "public"."v_words_user_srs" as  WITH base AS (
         SELECT w.id AS word_id,
            w.text,
            w.translation,
            w.from_lang,
            w.to_lang,
            w.domain,
            w.pos,
            w.level,
            w.tags,
            w.created_at AS word_created_at,
            wc.category_id
           FROM (public.words w
             JOIN public.word_categories wc ON ((wc.word_id = w.id)))
        ), u AS (
         SELECT uw.word_id,
            uw.user_id,
            uw.picked,
            uw.favorite,
            uw.created_at AS user_added_at
           FROM public.user_words uw
          WHERE (uw.user_id = auth.uid())
        )
 SELECT b.word_id,
    b.text,
    b.translation,
    b.from_lang,
    b.to_lang,
    b.domain,
    b.pos,
    b.level,
    b.tags,
    b.word_created_at,
    b.category_id,
    u.user_id,
    (u.user_id IS NOT NULL) AS in_my_words,
    COALESCE(u.picked, false) AS picked_user,
    COALESCE(u.favorite, false) AS favorite_user,
    u.user_added_at,
    'adaptive'::text AS srs_mode,
    COALESCE(uws.stage, 0) AS srs_stage_user,
    uws.next_due_at AS next_due_at_user,
    uws.last_reviewed_at AS last_reviewed_at_user,
    uws.ef,
    uws.streak,
    uws.lapses
   FROM ((base b
     LEFT JOIN u ON ((u.word_id = b.word_id)))
     LEFT JOIN public.user_word_srs uws ON (((uws.word_id = b.word_id) AND (uws.category_id = b.category_id) AND (uws.user_id = auth.uid()) AND (uws.mode = 'adaptive'::public.srs_mode))))
UNION ALL
 SELECT b.word_id,
    b.text,
    b.translation,
    b.from_lang,
    b.to_lang,
    b.domain,
    b.pos,
    b.level,
    b.tags,
    b.word_created_at,
    b.category_id,
    u.user_id,
    (u.user_id IS NOT NULL) AS in_my_words,
    COALESCE(u.picked, false) AS picked_user,
    COALESCE(u.favorite, false) AS favorite_user,
    u.user_added_at,
    'time'::text AS srs_mode,
    COALESCE(uws.stage, 0) AS srs_stage_user,
    uws.next_due_at AS next_due_at_user,
    uws.last_reviewed_at AS last_reviewed_at_user,
    uws.ef,
    uws.streak,
    uws.lapses
   FROM ((base b
     LEFT JOIN u ON ((u.word_id = b.word_id)))
     LEFT JOIN public.user_word_srs uws ON (((uws.word_id = b.word_id) AND (uws.category_id = b.category_id) AND (uws.user_id = auth.uid()) AND (uws.mode = 'time'::public.srs_mode))));


create or replace view "public"."v_words_user_srs_debug" as  SELECT w.id AS word_id,
    wc.category_id,
    (uws.mode)::text AS srs_mode,
    uws.stage AS srs_stage_user,
    uws.next_due_at AS next_due_at_user
   FROM ((public.words w
     JOIN public.word_categories wc ON ((wc.word_id = w.id)))
     LEFT JOIN public.user_word_srs uws ON (((uws.word_id = w.id) AND (uws.category_id = wc.category_id) AND (uws.user_id = 'c989ee58-4bc3-4644-b432-8cd55d83b59c'::uuid))));


create or replace view "public"."v_words_with_categories" as  SELECT w.id,
    w.text,
    w.translation,
    w.from_lang,
    w.to_lang,
    w.level,
    w.pos,
    w.domain,
    c.slug AS category_slug
   FROM ((public.words w
     JOIN public.word_categories wc ON ((wc.word_id = w.id)))
     JOIN public.categories c ON ((c.id = wc.category_id)));


create or replace view "public"."words_view" as  SELECT w.id,
    w.text,
    w.translation,
    w.level,
    w.pos,
    w.created_at,
    wc.category_id,
    c.slug AS category_slug,
    c.group_slug,
    c.type AS category_type,
    c.name AS category_name
   FROM ((public.words w
     LEFT JOIN public.word_categories wc ON ((wc.word_id = w.id)))
     LEFT JOIN public.categories c ON ((c.id = wc.category_id)));


CREATE OR REPLACE FUNCTION util.mermaid_public()
 RETURNS text
 LANGUAGE sql
AS $function$
WITH wanted AS (
  SELECT unnest(ARRAY[
    'captures','categories','entries','ingest_errors',
    'lesson_words','lessons','profiles','single_session_items',
    'staging_words','user_daily_picks','user_words','word_categories','words'
  ]) AS tbl
),
colmeta_raw AS (
  SELECT n.nspname AS schema, c.relname AS table_name, a.attnum AS pos,
         a.attname AS column_name,
         pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type,
         a.attnotnull AS not_null,
         EXISTS (SELECT 1 FROM pg_index i
                 WHERE i.indrelid=c.oid AND i.indisprimary AND a.attnum = ANY(i.indkey)) AS is_pk
  FROM pg_class c
  JOIN pg_namespace n ON n.oid=c.relnamespace
  JOIN pg_attribute a ON a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped
  WHERE c.relkind='r' AND n.nspname='public' AND c.relname IN (SELECT tbl FROM wanted)
),
norm AS (
  SELECT
    schema, table_name, pos, column_name, not_null, is_pk,
    CASE
      WHEN data_type ILIKE '%[]'                          THEN 'ARRAY'
      WHEN data_type ILIKE 'uuid%'                        THEN 'UUID'
      WHEN data_type ILIKE 'text%'                        THEN 'TEXT'
      WHEN data_type ILIKE 'varchar%' OR data_type ILIKE 'character varying%' THEN 'VARCHAR'
      WHEN data_type ILIKE 'boolean%'                     THEN 'BOOLEAN'
      WHEN data_type ILIKE 'smallint%'                    THEN 'SMALLINT'
      WHEN data_type ILIKE 'integer%'                     THEN 'INTEGER'
      WHEN data_type ILIKE 'bigint%'                      THEN 'BIGINT'
      WHEN data_type ILIKE 'numeric%' OR data_type ILIKE 'decimal%' THEN 'NUMERIC'
      WHEN data_type ILIKE 'double precision%'            THEN 'FLOAT8'
      WHEN data_type ILIKE 'real%'                        THEN 'REAL'
      WHEN data_type ILIKE 'jsonb%' OR data_type ILIKE 'json%'      THEN 'JSONB'
      WHEN data_type ILIKE 'tsvector%'                    THEN 'TSVECTOR'
      WHEN data_type ILIKE 'bytea%'                       THEN 'BYTEA'
      WHEN data_type ILIKE 'inet%'                        THEN 'INET'
      WHEN data_type ILIKE 'date%'                        THEN 'DATE'
      WHEN data_type ILIKE 'timestamp with time zone%'    THEN 'TIMESTAMPTZ'
      WHEN data_type ILIKE 'timestamp without time zone%' THEN 'TIMESTAMP'
      WHEN data_type ILIKE 'time with time zone%'         THEN 'TIMETZ'
      WHEN data_type ILIKE 'time without time zone%'      THEN 'TIME'
      ELSE 'OTHER'
    END AS dtype
  FROM colmeta_raw
),
table_blocks AS (
  SELECT schema, table_name,
    '  '||table_name||' {'||E'\n'||
    string_agg(
      '    '||dtype||' '||column_name||
      CASE WHEN is_pk THEN ' PK' ELSE '' END
    , E'\n' ORDER BY pos)
    ||E'\n'||
    '  }' AS block
  FROM norm
  GROUP BY schema, table_name
),
relmeta AS (
  SELECT n.nspname AS schema,
         rel.relname AS tbl,
         frel.relname AS ref_tbl,
         string_agg(att.attname, ', ' ORDER BY k.ord)   AS local_cols,
         string_agg(att2.attname, ', ' ORDER BY fk.ord) AS ref_cols
  FROM pg_constraint con
  JOIN pg_class rel  ON rel.oid=con.conrelid
  JOIN pg_namespace n ON n.oid=rel.relnamespace
  JOIN pg_class frel ON frel.oid=con.confrelid
  JOIN unnest(con.conkey)  WITH ORDINALITY k(attnum, ord)  ON TRUE
  JOIN unnest(con.confkey) WITH ORDINALITY fk(attnum, ord) ON fk.ord=k.ord
  JOIN pg_attribute att  ON att.attrelid=rel.oid   AND att.attnum=k.attnum
  JOIN pg_attribute att2 ON att2.attrelid=frel.oid AND att2.attnum=fk.attnum
  WHERE con.contype='f'
    AND n.nspname='public'
    AND rel.relname IN (SELECT tbl FROM wanted)
    AND frel.relname IN (SELECT tbl FROM wanted)
  GROUP BY n.nspname, rel.relname, frel.relname
),
rel_lines AS (
  SELECT '  '||tbl||' }o--|| '||ref_tbl||' : "'||local_cols||' → '||ref_cols||'"' AS line
  FROM relmeta
)
SELECT
  '```mermaid' || E'\n' ||
  'erDiagram'  || E'\n' ||
  COALESCE((SELECT string_agg(block, E'\n\n' ORDER BY schema, table_name) FROM table_blocks), '') || E'\n' ||
  COALESCE((SELECT string_agg(line,  E'\n'   ORDER BY line) FROM rel_lines), '') || E'\n' ||
  '```'
$function$
;

grant delete on table "public"."a_deck_state" to "anon";

grant insert on table "public"."a_deck_state" to "anon";

grant references on table "public"."a_deck_state" to "anon";

grant select on table "public"."a_deck_state" to "anon";

grant trigger on table "public"."a_deck_state" to "anon";

grant truncate on table "public"."a_deck_state" to "anon";

grant update on table "public"."a_deck_state" to "anon";

grant delete on table "public"."a_deck_state" to "authenticated";

grant insert on table "public"."a_deck_state" to "authenticated";

grant references on table "public"."a_deck_state" to "authenticated";

grant select on table "public"."a_deck_state" to "authenticated";

grant trigger on table "public"."a_deck_state" to "authenticated";

grant truncate on table "public"."a_deck_state" to "authenticated";

grant update on table "public"."a_deck_state" to "authenticated";

grant delete on table "public"."a_deck_state" to "service_role";

grant insert on table "public"."a_deck_state" to "service_role";

grant references on table "public"."a_deck_state" to "service_role";

grant select on table "public"."a_deck_state" to "service_role";

grant trigger on table "public"."a_deck_state" to "service_role";

grant truncate on table "public"."a_deck_state" to "service_role";

grant update on table "public"."a_deck_state" to "service_role";

grant delete on table "public"."a_refill_state" to "anon";

grant insert on table "public"."a_refill_state" to "anon";

grant references on table "public"."a_refill_state" to "anon";

grant select on table "public"."a_refill_state" to "anon";

grant trigger on table "public"."a_refill_state" to "anon";

grant truncate on table "public"."a_refill_state" to "anon";

grant update on table "public"."a_refill_state" to "anon";

grant delete on table "public"."a_refill_state" to "authenticated";

grant insert on table "public"."a_refill_state" to "authenticated";

grant references on table "public"."a_refill_state" to "authenticated";

grant select on table "public"."a_refill_state" to "authenticated";

grant trigger on table "public"."a_refill_state" to "authenticated";

grant truncate on table "public"."a_refill_state" to "authenticated";

grant update on table "public"."a_refill_state" to "authenticated";

grant delete on table "public"."a_refill_state" to "service_role";

grant insert on table "public"."a_refill_state" to "service_role";

grant references on table "public"."a_refill_state" to "service_role";

grant select on table "public"."a_refill_state" to "service_role";

grant trigger on table "public"."a_refill_state" to "service_role";

grant truncate on table "public"."a_refill_state" to "service_role";

grant update on table "public"."a_refill_state" to "service_role";

grant delete on table "public"."captures" to "anon";

grant insert on table "public"."captures" to "anon";

grant references on table "public"."captures" to "anon";

grant select on table "public"."captures" to "anon";

grant trigger on table "public"."captures" to "anon";

grant truncate on table "public"."captures" to "anon";

grant update on table "public"."captures" to "anon";

grant delete on table "public"."captures" to "authenticated";

grant insert on table "public"."captures" to "authenticated";

grant references on table "public"."captures" to "authenticated";

grant select on table "public"."captures" to "authenticated";

grant trigger on table "public"."captures" to "authenticated";

grant truncate on table "public"."captures" to "authenticated";

grant update on table "public"."captures" to "authenticated";

grant delete on table "public"."captures" to "service_role";

grant insert on table "public"."captures" to "service_role";

grant references on table "public"."captures" to "service_role";

grant select on table "public"."captures" to "service_role";

grant trigger on table "public"."captures" to "service_role";

grant truncate on table "public"."captures" to "service_role";

grant update on table "public"."captures" to "service_role";

grant delete on table "public"."categories" to "anon";

grant insert on table "public"."categories" to "anon";

grant references on table "public"."categories" to "anon";

grant select on table "public"."categories" to "anon";

grant trigger on table "public"."categories" to "anon";

grant truncate on table "public"."categories" to "anon";

grant update on table "public"."categories" to "anon";

grant delete on table "public"."categories" to "authenticated";

grant insert on table "public"."categories" to "authenticated";

grant references on table "public"."categories" to "authenticated";

grant select on table "public"."categories" to "authenticated";

grant trigger on table "public"."categories" to "authenticated";

grant truncate on table "public"."categories" to "authenticated";

grant update on table "public"."categories" to "authenticated";

grant delete on table "public"."categories" to "service_role";

grant insert on table "public"."categories" to "service_role";

grant references on table "public"."categories" to "service_role";

grant select on table "public"."categories" to "service_role";

grant trigger on table "public"."categories" to "service_role";

grant truncate on table "public"."categories" to "service_role";

grant update on table "public"."categories" to "service_role";

grant delete on table "public"."category_refill_state" to "anon";

grant insert on table "public"."category_refill_state" to "anon";

grant references on table "public"."category_refill_state" to "anon";

grant select on table "public"."category_refill_state" to "anon";

grant trigger on table "public"."category_refill_state" to "anon";

grant truncate on table "public"."category_refill_state" to "anon";

grant update on table "public"."category_refill_state" to "anon";

grant delete on table "public"."category_refill_state" to "authenticated";

grant insert on table "public"."category_refill_state" to "authenticated";

grant references on table "public"."category_refill_state" to "authenticated";

grant select on table "public"."category_refill_state" to "authenticated";

grant trigger on table "public"."category_refill_state" to "authenticated";

grant truncate on table "public"."category_refill_state" to "authenticated";

grant update on table "public"."category_refill_state" to "authenticated";

grant delete on table "public"."category_refill_state" to "service_role";

grant insert on table "public"."category_refill_state" to "service_role";

grant references on table "public"."category_refill_state" to "service_role";

grant select on table "public"."category_refill_state" to "service_role";

grant trigger on table "public"."category_refill_state" to "service_role";

grant truncate on table "public"."category_refill_state" to "service_role";

grant update on table "public"."category_refill_state" to "service_role";

grant delete on table "public"."entries" to "anon";

grant insert on table "public"."entries" to "anon";

grant references on table "public"."entries" to "anon";

grant select on table "public"."entries" to "anon";

grant trigger on table "public"."entries" to "anon";

grant truncate on table "public"."entries" to "anon";

grant update on table "public"."entries" to "anon";

grant delete on table "public"."entries" to "authenticated";

grant insert on table "public"."entries" to "authenticated";

grant references on table "public"."entries" to "authenticated";

grant select on table "public"."entries" to "authenticated";

grant trigger on table "public"."entries" to "authenticated";

grant truncate on table "public"."entries" to "authenticated";

grant update on table "public"."entries" to "authenticated";

grant delete on table "public"."entries" to "service_role";

grant insert on table "public"."entries" to "service_role";

grant references on table "public"."entries" to "service_role";

grant select on table "public"."entries" to "service_role";

grant trigger on table "public"."entries" to "service_role";

grant truncate on table "public"."entries" to "service_role";

grant update on table "public"."entries" to "service_role";

grant delete on table "public"."ingest_errors" to "anon";

grant insert on table "public"."ingest_errors" to "anon";

grant references on table "public"."ingest_errors" to "anon";

grant select on table "public"."ingest_errors" to "anon";

grant trigger on table "public"."ingest_errors" to "anon";

grant truncate on table "public"."ingest_errors" to "anon";

grant update on table "public"."ingest_errors" to "anon";

grant delete on table "public"."ingest_errors" to "authenticated";

grant insert on table "public"."ingest_errors" to "authenticated";

grant references on table "public"."ingest_errors" to "authenticated";

grant select on table "public"."ingest_errors" to "authenticated";

grant trigger on table "public"."ingest_errors" to "authenticated";

grant truncate on table "public"."ingest_errors" to "authenticated";

grant update on table "public"."ingest_errors" to "authenticated";

grant delete on table "public"."ingest_errors" to "service_role";

grant insert on table "public"."ingest_errors" to "service_role";

grant references on table "public"."ingest_errors" to "service_role";

grant select on table "public"."ingest_errors" to "service_role";

grant trigger on table "public"."ingest_errors" to "service_role";

grant truncate on table "public"."ingest_errors" to "service_role";

grant update on table "public"."ingest_errors" to "service_role";

grant delete on table "public"."lesson_words" to "anon";

grant insert on table "public"."lesson_words" to "anon";

grant references on table "public"."lesson_words" to "anon";

grant select on table "public"."lesson_words" to "anon";

grant trigger on table "public"."lesson_words" to "anon";

grant truncate on table "public"."lesson_words" to "anon";

grant update on table "public"."lesson_words" to "anon";

grant delete on table "public"."lesson_words" to "authenticated";

grant insert on table "public"."lesson_words" to "authenticated";

grant references on table "public"."lesson_words" to "authenticated";

grant select on table "public"."lesson_words" to "authenticated";

grant trigger on table "public"."lesson_words" to "authenticated";

grant truncate on table "public"."lesson_words" to "authenticated";

grant update on table "public"."lesson_words" to "authenticated";

grant delete on table "public"."lesson_words" to "service_role";

grant insert on table "public"."lesson_words" to "service_role";

grant references on table "public"."lesson_words" to "service_role";

grant select on table "public"."lesson_words" to "service_role";

grant trigger on table "public"."lesson_words" to "service_role";

grant truncate on table "public"."lesson_words" to "service_role";

grant update on table "public"."lesson_words" to "service_role";

grant delete on table "public"."lessons" to "anon";

grant insert on table "public"."lessons" to "anon";

grant references on table "public"."lessons" to "anon";

grant select on table "public"."lessons" to "anon";

grant trigger on table "public"."lessons" to "anon";

grant truncate on table "public"."lessons" to "anon";

grant update on table "public"."lessons" to "anon";

grant delete on table "public"."lessons" to "authenticated";

grant insert on table "public"."lessons" to "authenticated";

grant references on table "public"."lessons" to "authenticated";

grant select on table "public"."lessons" to "authenticated";

grant trigger on table "public"."lessons" to "authenticated";

grant truncate on table "public"."lessons" to "authenticated";

grant update on table "public"."lessons" to "authenticated";

grant delete on table "public"."lessons" to "service_role";

grant insert on table "public"."lessons" to "service_role";

grant references on table "public"."lessons" to "service_role";

grant select on table "public"."lessons" to "service_role";

grant trigger on table "public"."lessons" to "service_role";

grant truncate on table "public"."lessons" to "service_role";

grant update on table "public"."lessons" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."single_session_items" to "anon";

grant insert on table "public"."single_session_items" to "anon";

grant references on table "public"."single_session_items" to "anon";

grant select on table "public"."single_session_items" to "anon";

grant trigger on table "public"."single_session_items" to "anon";

grant truncate on table "public"."single_session_items" to "anon";

grant update on table "public"."single_session_items" to "anon";

grant delete on table "public"."single_session_items" to "authenticated";

grant insert on table "public"."single_session_items" to "authenticated";

grant references on table "public"."single_session_items" to "authenticated";

grant select on table "public"."single_session_items" to "authenticated";

grant trigger on table "public"."single_session_items" to "authenticated";

grant truncate on table "public"."single_session_items" to "authenticated";

grant update on table "public"."single_session_items" to "authenticated";

grant delete on table "public"."single_session_items" to "service_role";

grant insert on table "public"."single_session_items" to "service_role";

grant references on table "public"."single_session_items" to "service_role";

grant select on table "public"."single_session_items" to "service_role";

grant trigger on table "public"."single_session_items" to "service_role";

grant truncate on table "public"."single_session_items" to "service_role";

grant update on table "public"."single_session_items" to "service_role";

grant delete on table "public"."staging_words" to "anon";

grant insert on table "public"."staging_words" to "anon";

grant references on table "public"."staging_words" to "anon";

grant select on table "public"."staging_words" to "anon";

grant trigger on table "public"."staging_words" to "anon";

grant truncate on table "public"."staging_words" to "anon";

grant update on table "public"."staging_words" to "anon";

grant delete on table "public"."staging_words" to "authenticated";

grant insert on table "public"."staging_words" to "authenticated";

grant references on table "public"."staging_words" to "authenticated";

grant select on table "public"."staging_words" to "authenticated";

grant trigger on table "public"."staging_words" to "authenticated";

grant truncate on table "public"."staging_words" to "authenticated";

grant update on table "public"."staging_words" to "authenticated";

grant delete on table "public"."staging_words" to "service_role";

grant insert on table "public"."staging_words" to "service_role";

grant references on table "public"."staging_words" to "service_role";

grant select on table "public"."staging_words" to "service_role";

grant trigger on table "public"."staging_words" to "service_role";

grant truncate on table "public"."staging_words" to "service_role";

grant update on table "public"."staging_words" to "service_role";

grant delete on table "public"."user_category_daily_budget" to "anon";

grant insert on table "public"."user_category_daily_budget" to "anon";

grant references on table "public"."user_category_daily_budget" to "anon";

grant select on table "public"."user_category_daily_budget" to "anon";

grant trigger on table "public"."user_category_daily_budget" to "anon";

grant truncate on table "public"."user_category_daily_budget" to "anon";

grant update on table "public"."user_category_daily_budget" to "anon";

grant delete on table "public"."user_category_daily_budget" to "authenticated";

grant insert on table "public"."user_category_daily_budget" to "authenticated";

grant references on table "public"."user_category_daily_budget" to "authenticated";

grant select on table "public"."user_category_daily_budget" to "authenticated";

grant trigger on table "public"."user_category_daily_budget" to "authenticated";

grant truncate on table "public"."user_category_daily_budget" to "authenticated";

grant update on table "public"."user_category_daily_budget" to "authenticated";

grant delete on table "public"."user_category_daily_budget" to "service_role";

grant insert on table "public"."user_category_daily_budget" to "service_role";

grant references on table "public"."user_category_daily_budget" to "service_role";

grant select on table "public"."user_category_daily_budget" to "service_role";

grant trigger on table "public"."user_category_daily_budget" to "service_role";

grant truncate on table "public"."user_category_daily_budget" to "service_role";

grant update on table "public"."user_category_daily_budget" to "service_role";

grant delete on table "public"."user_daily_picks" to "anon";

grant insert on table "public"."user_daily_picks" to "anon";

grant references on table "public"."user_daily_picks" to "anon";

grant select on table "public"."user_daily_picks" to "anon";

grant trigger on table "public"."user_daily_picks" to "anon";

grant truncate on table "public"."user_daily_picks" to "anon";

grant update on table "public"."user_daily_picks" to "anon";

grant delete on table "public"."user_daily_picks" to "authenticated";

grant insert on table "public"."user_daily_picks" to "authenticated";

grant references on table "public"."user_daily_picks" to "authenticated";

grant select on table "public"."user_daily_picks" to "authenticated";

grant trigger on table "public"."user_daily_picks" to "authenticated";

grant truncate on table "public"."user_daily_picks" to "authenticated";

grant update on table "public"."user_daily_picks" to "authenticated";

grant delete on table "public"."user_daily_picks" to "service_role";

grant insert on table "public"."user_daily_picks" to "service_role";

grant references on table "public"."user_daily_picks" to "service_role";

grant select on table "public"."user_daily_picks" to "service_role";

grant trigger on table "public"."user_daily_picks" to "service_role";

grant truncate on table "public"."user_daily_picks" to "service_role";

grant update on table "public"."user_daily_picks" to "service_role";

grant delete on table "public"."user_hybrid_daily_state" to "anon";

grant insert on table "public"."user_hybrid_daily_state" to "anon";

grant references on table "public"."user_hybrid_daily_state" to "anon";

grant select on table "public"."user_hybrid_daily_state" to "anon";

grant trigger on table "public"."user_hybrid_daily_state" to "anon";

grant truncate on table "public"."user_hybrid_daily_state" to "anon";

grant update on table "public"."user_hybrid_daily_state" to "anon";

grant delete on table "public"."user_hybrid_daily_state" to "authenticated";

grant insert on table "public"."user_hybrid_daily_state" to "authenticated";

grant references on table "public"."user_hybrid_daily_state" to "authenticated";

grant select on table "public"."user_hybrid_daily_state" to "authenticated";

grant trigger on table "public"."user_hybrid_daily_state" to "authenticated";

grant truncate on table "public"."user_hybrid_daily_state" to "authenticated";

grant update on table "public"."user_hybrid_daily_state" to "authenticated";

grant delete on table "public"."user_hybrid_daily_state" to "service_role";

grant insert on table "public"."user_hybrid_daily_state" to "service_role";

grant references on table "public"."user_hybrid_daily_state" to "service_role";

grant select on table "public"."user_hybrid_daily_state" to "service_role";

grant trigger on table "public"."user_hybrid_daily_state" to "service_role";

grant truncate on table "public"."user_hybrid_daily_state" to "service_role";

grant update on table "public"."user_hybrid_daily_state" to "service_role";

grant delete on table "public"."user_hybrid_daily_stats" to "anon";

grant insert on table "public"."user_hybrid_daily_stats" to "anon";

grant references on table "public"."user_hybrid_daily_stats" to "anon";

grant select on table "public"."user_hybrid_daily_stats" to "anon";

grant trigger on table "public"."user_hybrid_daily_stats" to "anon";

grant truncate on table "public"."user_hybrid_daily_stats" to "anon";

grant update on table "public"."user_hybrid_daily_stats" to "anon";

grant delete on table "public"."user_hybrid_daily_stats" to "authenticated";

grant insert on table "public"."user_hybrid_daily_stats" to "authenticated";

grant references on table "public"."user_hybrid_daily_stats" to "authenticated";

grant select on table "public"."user_hybrid_daily_stats" to "authenticated";

grant trigger on table "public"."user_hybrid_daily_stats" to "authenticated";

grant truncate on table "public"."user_hybrid_daily_stats" to "authenticated";

grant update on table "public"."user_hybrid_daily_stats" to "authenticated";

grant delete on table "public"."user_hybrid_daily_stats" to "service_role";

grant insert on table "public"."user_hybrid_daily_stats" to "service_role";

grant references on table "public"."user_hybrid_daily_stats" to "service_role";

grant select on table "public"."user_hybrid_daily_stats" to "service_role";

grant trigger on table "public"."user_hybrid_daily_stats" to "service_role";

grant truncate on table "public"."user_hybrid_daily_stats" to "service_role";

grant update on table "public"."user_hybrid_daily_stats" to "service_role";

grant delete on table "public"."user_requeue" to "anon";

grant insert on table "public"."user_requeue" to "anon";

grant references on table "public"."user_requeue" to "anon";

grant select on table "public"."user_requeue" to "anon";

grant trigger on table "public"."user_requeue" to "anon";

grant truncate on table "public"."user_requeue" to "anon";

grant update on table "public"."user_requeue" to "anon";

grant delete on table "public"."user_requeue" to "authenticated";

grant insert on table "public"."user_requeue" to "authenticated";

grant references on table "public"."user_requeue" to "authenticated";

grant select on table "public"."user_requeue" to "authenticated";

grant trigger on table "public"."user_requeue" to "authenticated";

grant truncate on table "public"."user_requeue" to "authenticated";

grant update on table "public"."user_requeue" to "authenticated";

grant delete on table "public"."user_requeue" to "service_role";

grant insert on table "public"."user_requeue" to "service_role";

grant references on table "public"."user_requeue" to "service_role";

grant select on table "public"."user_requeue" to "service_role";

grant trigger on table "public"."user_requeue" to "service_role";

grant truncate on table "public"."user_requeue" to "service_role";

grant update on table "public"."user_requeue" to "service_role";

grant delete on table "public"."user_s0_lock_state" to "anon";

grant insert on table "public"."user_s0_lock_state" to "anon";

grant references on table "public"."user_s0_lock_state" to "anon";

grant select on table "public"."user_s0_lock_state" to "anon";

grant trigger on table "public"."user_s0_lock_state" to "anon";

grant truncate on table "public"."user_s0_lock_state" to "anon";

grant update on table "public"."user_s0_lock_state" to "anon";

grant delete on table "public"."user_s0_lock_state" to "authenticated";

grant insert on table "public"."user_s0_lock_state" to "authenticated";

grant references on table "public"."user_s0_lock_state" to "authenticated";

grant select on table "public"."user_s0_lock_state" to "authenticated";

grant trigger on table "public"."user_s0_lock_state" to "authenticated";

grant truncate on table "public"."user_s0_lock_state" to "authenticated";

grant update on table "public"."user_s0_lock_state" to "authenticated";

grant delete on table "public"."user_s0_lock_state" to "service_role";

grant insert on table "public"."user_s0_lock_state" to "service_role";

grant references on table "public"."user_s0_lock_state" to "service_role";

grant select on table "public"."user_s0_lock_state" to "service_role";

grant trigger on table "public"."user_s0_lock_state" to "service_role";

grant truncate on table "public"."user_s0_lock_state" to "service_role";

grant update on table "public"."user_s0_lock_state" to "service_role";

grant delete on table "public"."user_word_srs" to "anon";

grant insert on table "public"."user_word_srs" to "anon";

grant references on table "public"."user_word_srs" to "anon";

grant select on table "public"."user_word_srs" to "anon";

grant trigger on table "public"."user_word_srs" to "anon";

grant truncate on table "public"."user_word_srs" to "anon";

grant update on table "public"."user_word_srs" to "anon";

grant delete on table "public"."user_word_srs" to "authenticated";

grant insert on table "public"."user_word_srs" to "authenticated";

grant references on table "public"."user_word_srs" to "authenticated";

grant select on table "public"."user_word_srs" to "authenticated";

grant trigger on table "public"."user_word_srs" to "authenticated";

grant truncate on table "public"."user_word_srs" to "authenticated";

grant update on table "public"."user_word_srs" to "authenticated";

grant delete on table "public"."user_word_srs" to "service_role";

grant insert on table "public"."user_word_srs" to "service_role";

grant references on table "public"."user_word_srs" to "service_role";

grant select on table "public"."user_word_srs" to "service_role";

grant trigger on table "public"."user_word_srs" to "service_role";

grant truncate on table "public"."user_word_srs" to "service_role";

grant update on table "public"."user_word_srs" to "service_role";

grant delete on table "public"."user_word_srs_lock" to "anon";

grant insert on table "public"."user_word_srs_lock" to "anon";

grant references on table "public"."user_word_srs_lock" to "anon";

grant select on table "public"."user_word_srs_lock" to "anon";

grant trigger on table "public"."user_word_srs_lock" to "anon";

grant truncate on table "public"."user_word_srs_lock" to "anon";

grant update on table "public"."user_word_srs_lock" to "anon";

grant delete on table "public"."user_word_srs_lock" to "authenticated";

grant insert on table "public"."user_word_srs_lock" to "authenticated";

grant references on table "public"."user_word_srs_lock" to "authenticated";

grant select on table "public"."user_word_srs_lock" to "authenticated";

grant trigger on table "public"."user_word_srs_lock" to "authenticated";

grant truncate on table "public"."user_word_srs_lock" to "authenticated";

grant update on table "public"."user_word_srs_lock" to "authenticated";

grant delete on table "public"."user_word_srs_lock" to "service_role";

grant insert on table "public"."user_word_srs_lock" to "service_role";

grant references on table "public"."user_word_srs_lock" to "service_role";

grant select on table "public"."user_word_srs_lock" to "service_role";

grant trigger on table "public"."user_word_srs_lock" to "service_role";

grant truncate on table "public"."user_word_srs_lock" to "service_role";

grant update on table "public"."user_word_srs_lock" to "service_role";

grant delete on table "public"."user_words" to "anon";

grant insert on table "public"."user_words" to "anon";

grant references on table "public"."user_words" to "anon";

grant select on table "public"."user_words" to "anon";

grant trigger on table "public"."user_words" to "anon";

grant truncate on table "public"."user_words" to "anon";

grant update on table "public"."user_words" to "anon";

grant delete on table "public"."user_words" to "authenticated";

grant insert on table "public"."user_words" to "authenticated";

grant references on table "public"."user_words" to "authenticated";

grant select on table "public"."user_words" to "authenticated";

grant trigger on table "public"."user_words" to "authenticated";

grant truncate on table "public"."user_words" to "authenticated";

grant update on table "public"."user_words" to "authenticated";

grant delete on table "public"."user_words" to "service_role";

grant insert on table "public"."user_words" to "service_role";

grant references on table "public"."user_words" to "service_role";

grant select on table "public"."user_words" to "service_role";

grant trigger on table "public"."user_words" to "service_role";

grant truncate on table "public"."user_words" to "service_role";

grant update on table "public"."user_words" to "service_role";

grant delete on table "public"."word_categories" to "anon";

grant insert on table "public"."word_categories" to "anon";

grant references on table "public"."word_categories" to "anon";

grant select on table "public"."word_categories" to "anon";

grant trigger on table "public"."word_categories" to "anon";

grant truncate on table "public"."word_categories" to "anon";

grant update on table "public"."word_categories" to "anon";

grant delete on table "public"."word_categories" to "authenticated";

grant insert on table "public"."word_categories" to "authenticated";

grant references on table "public"."word_categories" to "authenticated";

grant select on table "public"."word_categories" to "authenticated";

grant trigger on table "public"."word_categories" to "authenticated";

grant truncate on table "public"."word_categories" to "authenticated";

grant update on table "public"."word_categories" to "authenticated";

grant delete on table "public"."word_categories" to "service_role";

grant insert on table "public"."word_categories" to "service_role";

grant references on table "public"."word_categories" to "service_role";

grant select on table "public"."word_categories" to "service_role";

grant trigger on table "public"."word_categories" to "service_role";

grant truncate on table "public"."word_categories" to "service_role";

grant update on table "public"."word_categories" to "service_role";

grant delete on table "public"."word_progress" to "anon";

grant insert on table "public"."word_progress" to "anon";

grant references on table "public"."word_progress" to "anon";

grant select on table "public"."word_progress" to "anon";

grant trigger on table "public"."word_progress" to "anon";

grant truncate on table "public"."word_progress" to "anon";

grant update on table "public"."word_progress" to "anon";

grant delete on table "public"."word_progress" to "authenticated";

grant insert on table "public"."word_progress" to "authenticated";

grant references on table "public"."word_progress" to "authenticated";

grant select on table "public"."word_progress" to "authenticated";

grant trigger on table "public"."word_progress" to "authenticated";

grant truncate on table "public"."word_progress" to "authenticated";

grant update on table "public"."word_progress" to "authenticated";

grant delete on table "public"."word_progress" to "service_role";

grant insert on table "public"."word_progress" to "service_role";

grant references on table "public"."word_progress" to "service_role";

grant select on table "public"."word_progress" to "service_role";

grant trigger on table "public"."word_progress" to "service_role";

grant truncate on table "public"."word_progress" to "service_role";

grant update on table "public"."word_progress" to "service_role";

grant delete on table "public"."word_progress_deck_state" to "anon";

grant insert on table "public"."word_progress_deck_state" to "anon";

grant references on table "public"."word_progress_deck_state" to "anon";

grant select on table "public"."word_progress_deck_state" to "anon";

grant trigger on table "public"."word_progress_deck_state" to "anon";

grant truncate on table "public"."word_progress_deck_state" to "anon";

grant update on table "public"."word_progress_deck_state" to "anon";

grant delete on table "public"."word_progress_deck_state" to "authenticated";

grant insert on table "public"."word_progress_deck_state" to "authenticated";

grant references on table "public"."word_progress_deck_state" to "authenticated";

grant select on table "public"."word_progress_deck_state" to "authenticated";

grant trigger on table "public"."word_progress_deck_state" to "authenticated";

grant truncate on table "public"."word_progress_deck_state" to "authenticated";

grant update on table "public"."word_progress_deck_state" to "authenticated";

grant delete on table "public"."word_progress_deck_state" to "service_role";

grant insert on table "public"."word_progress_deck_state" to "service_role";

grant references on table "public"."word_progress_deck_state" to "service_role";

grant select on table "public"."word_progress_deck_state" to "service_role";

grant trigger on table "public"."word_progress_deck_state" to "service_role";

grant truncate on table "public"."word_progress_deck_state" to "service_role";

grant update on table "public"."word_progress_deck_state" to "service_role";

grant delete on table "public"."words" to "anon";

grant insert on table "public"."words" to "anon";

grant references on table "public"."words" to "anon";

grant select on table "public"."words" to "anon";

grant trigger on table "public"."words" to "anon";

grant truncate on table "public"."words" to "anon";

grant update on table "public"."words" to "anon";

grant delete on table "public"."words" to "authenticated";

grant insert on table "public"."words" to "authenticated";

grant references on table "public"."words" to "authenticated";

grant select on table "public"."words" to "authenticated";

grant trigger on table "public"."words" to "authenticated";

grant truncate on table "public"."words" to "authenticated";

grant update on table "public"."words" to "authenticated";

grant delete on table "public"."words" to "service_role";

grant insert on table "public"."words" to "service_role";

grant references on table "public"."words" to "service_role";

grant select on table "public"."words" to "service_role";

grant trigger on table "public"."words" to "service_role";

grant truncate on table "public"."words" to "service_role";

grant update on table "public"."words" to "service_role";


  create policy "public read categories"
  on "public"."categories"
  as permissive
  for select
  to public
using (true);



  create policy "read categories"
  on "public"."categories"
  as permissive
  for select
  to authenticated
using (true);



  create policy "delete_own_entries"
  on "public"."entries"
  as permissive
  for delete
  to authenticated
using ((user_id = auth.uid()));



  create policy "insert_own_entries"
  on "public"."entries"
  as permissive
  for insert
  to authenticated
with check ((user_id = auth.uid()));



  create policy "read_own_entries"
  on "public"."entries"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "update_own_entries"
  on "public"."entries"
  as permissive
  for update
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "public read lesson_words"
  on "public"."lesson_words"
  as permissive
  for select
  to public
using (true);



  create policy "public read lessons"
  on "public"."lessons"
  as permissive
  for select
  to public
using (true);



  create policy "single_session_items_modify_own"
  on "public"."single_session_items"
  as permissive
  for all
  to public
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "single_session_items_select_own"
  on "public"."single_session_items"
  as permissive
  for select
  to public
using ((user_id = auth.uid()));



  create policy "udp delete own"
  on "public"."user_daily_picks"
  as permissive
  for delete
  to public
using ((auth.uid() = user_id));



  create policy "udp insert own"
  on "public"."user_daily_picks"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "udp select own"
  on "public"."user_daily_picks"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));



  create policy "udp update own"
  on "public"."user_daily_picks"
  as permissive
  for update
  to public
using ((auth.uid() = user_id));



  create policy "hybrid_daily_state_select_own"
  on "public"."user_hybrid_daily_state"
  as permissive
  for select
  to public
using ((user_id = auth.uid()));



  create policy "hybrid_daily_state_write_own"
  on "public"."user_hybrid_daily_state"
  as permissive
  for all
  to public
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "modify_own_hybrid_daily_stats"
  on "public"."user_hybrid_daily_stats"
  as permissive
  for all
  to public
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "select_own_hybrid_daily_stats"
  on "public"."user_hybrid_daily_stats"
  as permissive
  for select
  to public
using ((user_id = auth.uid()));



  create policy "user_word_srs_select_own"
  on "public"."user_word_srs"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));



  create policy "user_word_srs_update_own"
  on "public"."user_word_srs"
  as permissive
  for update
  to public
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "user_word_srs_write_own"
  on "public"."user_word_srs"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "rw own user_words"
  on "public"."user_words"
  as permissive
  for all
  to public
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "public read word_categories"
  on "public"."word_categories"
  as permissive
  for select
  to public
using (true);



  create policy "read word categories"
  on "public"."word_categories"
  as permissive
  for select
  to authenticated
using (true);



  create policy "read word_categories"
  on "public"."word_categories"
  as permissive
  for select
  to public
using (true);



  create policy "wp_insert_own"
  on "public"."word_progress"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "wp_select_own"
  on "public"."word_progress"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));



  create policy "wp_update_own"
  on "public"."word_progress"
  as permissive
  for update
  to public
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "select_own_deck_state"
  on "public"."word_progress_deck_state"
  as permissive
  for select
  to public
using ((auth.uid() = user_id));



  create policy "update_own_deck_state"
  on "public"."word_progress_deck_state"
  as permissive
  for update
  to public
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "upsert_own_deck_state"
  on "public"."word_progress_deck_state"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "public read words"
  on "public"."words"
  as permissive
  for select
  to anon, authenticated
using (true);



  create policy "read words"
  on "public"."words"
  as permissive
  for select
  to public
using (true);


CREATE TRIGGER trg_entries_set_updated_at BEFORE UPDATE ON public.entries FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_word_srs_updated BEFORE UPDATE ON public.user_word_srs FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_word_progress_deck_state_updated_at BEFORE UPDATE ON public.word_progress_deck_state FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


