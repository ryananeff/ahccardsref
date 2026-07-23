-- ============================================================
--  CardsRef — Supabase schema
--  Run in Supabase: Dashboard > SQL Editor > New query > paste > Run.
--  Safe to re-run: uses IF NOT EXISTS / ON CONFLICT / idempotent guards.
-- ============================================================

-- ---------- Tables ----------
create table if not exists public.categories (
  id         text primary key,
  name       text not null,
  plural     text not null default 'items',
  icon       text not null default 'doc',
  color      text not null default '#64748b',
  kind       text not null default 'content' check (kind in ('contact','content')),
  position   int  not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.entries (
  id         text primary key,
  cat        text not null,
  title      text not null,
  subtitle   text default '',
  phone      text default '',
  pager      text default '',
  ext        text default '',
  body       text default '',
  url        text default '',
  tags       text[] not null default '{}',
  updated_at timestamptz not null default now(),
  updated_by text,
  history    jsonb not null default '[]'::jsonb
);

create index if not exists entries_cat_idx        on public.entries (cat);
create index if not exists categories_position_idx on public.categories (position);

-- ---------- Row Level Security ----------
-- Anyone (even signed-out) may READ. Only signed-in users may WRITE.
alter table public.categories enable row level security;
alter table public.entries    enable row level security;

drop policy if exists cat_read  on public.categories;
drop policy if exists cat_write on public.categories;
drop policy if exists ent_read  on public.entries;
drop policy if exists ent_write on public.entries;

create policy cat_read  on public.categories for select using (true);
create policy ent_read  on public.entries    for select using (true);

create policy cat_write on public.categories for all
  using (auth.uid() is not null) with check (auth.uid() is not null);
create policy ent_write on public.entries for all
  using (auth.uid() is not null) with check (auth.uid() is not null);

-- ---------- Realtime (live sync across open clients) ----------
do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname='supabase_realtime' and schemaname='public' and tablename='categories') then
    alter publication supabase_realtime add table public.categories;
  end if;
  if not exists (select 1 from pg_publication_tables
                 where pubname='supabase_realtime' and schemaname='public' and tablename='entries') then
    alter publication supabase_realtime add table public.entries;
  end if;
end $$;

-- ============================================================
--  Seed data (mirrors the app's starter content; edit freely later)
-- ============================================================
-- Seed categories
insert into public.categories (id,name,plural,icon,color,kind,position) values
  ('call','Who to Call','contacts','phone','#dc2626','contact',0),
  ('consult','Consult Questions','topics','help','#0e7490','content',1),
  ('docs','Documents & Links','documents','doc','#4f46e5','content',2),
  ('workflow','Workflows','workflows','list','#059669','content',3)
on conflict (id) do nothing;

-- Seed entries
insert into public.entries (id,cat,title,subtitle,phone,pager,ext,body,url,tags,updated_by,history) values
  ('mrwlz4rmqobwm','call','CCU Fellow','Cardiac ICU coverage & escalation','x-0000','00000','','','',ARRAY['on-call','CCU']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmeeo4q','call','Interventional / Cath Lab','STEMI activation · urgent PCI','x-0000','00000','','Activate for confirmed STEMI. Edit to add your program''s exact activation line and after-hours pathway.','',ARRAY['STEMI','urgent']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmrbw0e','call','EP Fellow','Arrhythmia · device interrogation','x-0000','00000','','','',ARRAY['EP','devices']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmxvycw','call','Echo Lab / Reading Room','TTE/TEE scheduling · wet reads','x-0000','','','','',ARRAY['echo']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmae6d1','call','Heart Failure / Transplant','Advanced HF · MCS · transplant eval','x-0000','00000','','','',ARRAY['HF']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rm0samp','call','Cardiac Surgery','Valve · CABG · surgical consults','x-0000','00000','','','',ARRAY[]::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmpxoad','call','Attending on call','Escalation / staffing','x-0000','','','','',ARRAY['escalation']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rm95hst','consult','New atrial fibrillation','Rate vs rhythm · anticoagulation','','','','Placeholder scaffold — replace with your program''s pathway.
- Confirm rhythm and hemodynamic stability
- Gather: onset/duration, triggers, prior episodes, meds, renal/hepatic function
- Rate vs rhythm decision per stability and symptoms
- Anticoagulation: apply your institution''s risk-stratification tool
- Document reasoning and disposition

Related: [[Troponin elevation]]','',ARRAY['AF','arrhythmia']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmluhbh','consult','Troponin elevation','Ischemic vs non-ischemic','','','','Scaffold — edit with your program''s approach.
- Frame the pretest probability and clinical context
- Trend the biomarker; correlate with ECG and symptoms
- Differential: type 1 vs type 2 vs non-ischemic causes
- Decide monitoring level and who to loop in','',ARRAY['ACS','troponin']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmkb3cb','consult','Syncope','Risk stratification & disposition','','','','Scaffold — edit for local practice.
- History/exam and ECG first
- Separate benign from high-risk features
- Decide admit vs monitored vs discharge with follow-up','',ARRAY['syncope']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmeorql','consult','Pre-operative cardiac evaluation','Peri-operative risk','','','','Scaffold — add your program''s preferred framework and any local order sets.','',ARRAY['pre-op']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmqa15o','consult','Chest pain triage from the floor','When to escalate','','','','Scaffold — edit with escalation criteria and who to call.','',ARRAY['chest pain','triage']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rm0hele','docs','Cardiology consult note template','Standard note skeleton','','','','Paste the link to your shared note template (Drive/EMR smartphrase). Edit this entry and drop the URL in the link field.','',ARRAY['template','notes']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rm4l9g3','docs','Anticoagulation drip protocols','Heparin / bivalirudin references','','','','Link your institution''s official protocol here — do not rely on memorized numbers.','',ARRAY['anticoagulation']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmcgm69','docs','ACLS algorithms','Code references','','','','','https://cpr.heart.org',ARRAY['ACLS','code']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmy2l28','docs','ACC/AHA guideline hub','Guideline quick links','','','','','https://www.acc.org/guidelines',ARRAY['guidelines']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmkoj9y','workflow','Place a cardiology consult','Intake steps','','','','## Intake steps
1. Confirm the **exact question** the primary team is asking
2. Gather chart, labs, imaging, and a callback number
3. Enter the consult order and page the covering fellow
4. Document recommendations and follow-up

> Tip: tap a linked page below to jump straight there.

Related pages: [[Order a TTE / TEE]] · [[Sign out the consult list]]','',ARRAY['intake']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmxea1w','workflow','Order a TTE / TEE','Echo request steps','','','','Edit with your EMR-specific order path, indications, and how urgent reads are requested.','',ARRAY['echo']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rm9xt3g','workflow','Request device interrogation','Pacemaker / ICD via EP','','','','Edit with the EP pathway for inpatient interrogation and after-hours coverage.','',ARRAY['EP','devices']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb),
  ('mrwlz4rmb7j2f','workflow','Sign out the consult list','Handoff expectations','','','','Scaffold — add your service''s handoff format and what a good sign-out includes.','',ARRAY['handoff']::text[],'seed','[{"by":"seed","at":1784756561890,"action":"created"}]'::jsonb)
on conflict (id) do nothing;
