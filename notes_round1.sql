-- หน้าโน้ต รอบ 1 · รันแล้วบน Supabase (da-learning-map) เมื่อ 16 ต.ค. 2026 · migration ชื่อ notes_round1
-- ต่างจาก spec เล็กน้อยตามคำแนะนำของ Supabase:
--   pg_trgm อยู่ใน schema extensions · policy ใช้ (select auth.uid()) และจำกัด to authenticated
--   ฟังก์ชัน trigger ตั้ง search_path · เพิ่ม index ให้ foreign key · grant ให้ authenticated ชัดเจน
create extension if not exists pg_trgm with schema extensions;

create table public.sources (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
    type        text not null check (type in ('book','course','video','article','class','claude','other')),
    name        text not null,
    url         text,
    author      text,
    note        text,
    created_at  timestamptz not null default now()
);

create table public.notes (
    id                uuid primary key default gen_random_uuid(),
    user_id           uuid not null default auth.uid() references auth.users(id) on delete cascade,
    title             text,
    content           jsonb not null default '[]'::jsonb,
    content_text      text not null default '',
    search_text       text generated always as (coalesce(title, '') || ' ' || content_text) stored,
    highlight_colors  text[] not null default '{}',
    source_id         uuid references public.sources(id) on delete set null,
    source_locator    text,
    created_at        timestamptz not null default now(),
    updated_at        timestamptz not null default now(),
    deleted_at        timestamptz
);

create table public.tags (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
    name        text not null,
    tag_group   text not null default 'other' check (tag_group in ('topic','note_type','status','other')),
    created_at  timestamptz not null default now()
);
create unique index tags_unique_name on public.tags (user_id, lower(trim(name)));

create table public.note_tags (
    note_id  uuid not null references public.notes(id) on delete cascade,
    tag_id   uuid not null references public.tags(id) on delete cascade,
    primary key (note_id, tag_id)
);

create index notes_search_idx  on public.notes using gin (search_text extensions.gin_trgm_ops);
create index notes_recent_idx  on public.notes (user_id, updated_at desc) where deleted_at is null;
create index notes_source_idx  on public.notes (source_id);
create index sources_user_idx  on public.sources (user_id);
create index note_tags_tag_idx on public.note_tags (tag_id);

create or replace function public.set_updated_at() returns trigger
    language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end; $$;
create trigger notes_updated_at before update on public.notes
    for each row execute function public.set_updated_at();

alter table public.sources   enable row level security;
alter table public.notes     enable row level security;
alter table public.tags      enable row level security;
alter table public.note_tags enable row level security;

create policy own_sources on public.sources for all to authenticated
    using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy own_notes on public.notes for all to authenticated
    using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy own_tags on public.tags for all to authenticated
    using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy own_note_tags on public.note_tags for all to authenticated
    using (exists (select 1 from public.notes n where n.id = note_id and n.user_id = (select auth.uid())))
    with check (
        exists (select 1 from public.notes n where n.id = note_id and n.user_id = (select auth.uid()))
        and exists (select 1 from public.tags t where t.id = tag_id and t.user_id = (select auth.uid()))
    );

grant select, insert, update, delete on public.sources, public.notes, public.tags, public.note_tags to authenticated;

-- รอบ 1.5 (16 ต.ค. 2026) · migration ชื่อ notes_pin_icon
alter table public.notes add column if not exists pinned boolean not null default false;
alter table public.notes add column if not exists icon text;
