# CardsRef

A mobile-first, wiki-style pocket reference for a cardiology consult service — phone numbers, consult questions, documents, and workflows that anyone on the team can edit. Single static page (`index.html`, vanilla JS) backed by Supabase (Postgres + Auth + Realtime) and deployed on Vercel.

- **Browse:** open to everyone, no sign-in.
- **Edit:** sign in with a one-time email link (magic link).
- **Live:** edits sync to everyone's open tab via Supabase Realtime.
- **Markdown** in card bodies, `[[wiki-links]]` between cards, customizable categories.

If `config.js` is left with placeholder values, the app runs in **preview mode** (in-memory, edits stay on your device) so you can open it before wiring anything up.

---

## 1. Create the Supabase project

1. At [supabase.com](https://supabase.com) create a new project. Pick a region close to your users and save the database password.
2. Open **SQL Editor → New query**, paste the entire contents of [`schema.sql`](./schema.sql), and **Run**. This creates the `categories` and `entries` tables, Row Level Security policies (public read / authenticated write), Realtime, and the starter content.

## 2. Get your API keys

**Project Settings → API**, copy:

- **Project URL** → `SUPABASE_URL`
- **anon public** key → `SUPABASE_ANON_KEY`

Paste both into [`config.js`](./config.js). The anon key is meant to live in the browser — RLS is what protects your data. **Never** put the `service_role` key in `config.js`.

## 3. Configure Auth (magic link)

Email sign-in is enabled by default. Under **Authentication → URL Configuration**:

- **Site URL:** your production URL (e.g. `https://cardsref.vercel.app`). You'll get this after the first Vercel deploy — set it then.
- **Redirect URLs:** add your production URL and, for local testing, `http://localhost:3000`.

> Supabase's built-in email is rate-limited and intended for testing. For a real team, add your own SMTP under **Authentication → Emails → SMTP Settings** (Resend, Postmark, SES, etc.) so sign-in links send reliably.

To limit who can edit, set `ALLOWED_EMAIL_DOMAIN` in `config.js` (e.g. `"hospital.org"`). Anyone with an address at that domain who signs in can edit.

## 4. Deploy to Vercel

This is a static site — no build step.

**Option A — GitHub + Vercel (recommended)**
1. Push this folder to a Git repo.
2. In Vercel: **Add New → Project → Import** the repo.
3. Framework preset: **Other**. Build command: none. Output directory: `.` (root).
4. Deploy. Copy the resulting URL.

**Option B — Vercel CLI**
```bash
npm i -g vercel
cd cardsref
vercel        # follow prompts; accept defaults (no build)
vercel --prod # promote to production
```

After the first deploy, go back to **Supabase → Authentication → URL Configuration** and set **Site URL** (and Redirect URLs) to your Vercel domain so the magic-link redirect lands back on the app.

## 5. Test locally (optional)

```bash
npx serve cardsref        # serves at http://localhost:3000
```
Add `http://localhost:3000` to Supabase Redirect URLs so magic links work in dev. Opening the file directly as `file://` will load and browse, but auth redirects need a real `http(s)` origin.

---

## How it works

- **Data model.** Two tables. `categories` (`id, name, plural, icon, color, kind, position`) and `entries` (`id, cat, title, subtitle, phone, pager, ext, body, url, tags[], updated_at, updated_by, history`). Category `kind` is `contact` (shows phone/pager/extension + tap-to-call) or `content` (notes/links). Editing is per-row, so two people editing different cards never clobber each other; same-card conflicts are last-write-wins.
- **Security.** RLS: `select` is public; `insert/update/delete` require `auth.uid() is not null`. The client only ever holds the anon key.
- **Realtime.** The app subscribes to `postgres_changes` on both tables and refreshes (debounced, and never while you have an editor sheet open).
- **Attribution.** Edits are stamped with your display name (set via the account sheet) or your email name, and a per-card history (last 30 changes) is kept.

## Customizing

- **Branding:** `APP_TITLE` / `APP_SUBTITLE` in `config.js`.
- **Categories:** add/edit/reorder/delete in-app (home screen → "New category", or the ✎ gear inside a category). Icon and color are pickable.
- **Content:** the seed rows are scaffolding — replace phone numbers, consult pathways, and links with your program's real information. Nothing in the seed is authoritative clinical guidance.

## Files

| File | Purpose |
|------|---------|
| `index.html` | The entire app (HTML + CSS + JS). |
| `config.js` | Your Supabase URL / anon key + branding. |
| `schema.sql` | Tables, RLS, Realtime, seed. Run once in Supabase. |
| `vercel.json` | Static hosting config (keeps `config.js` uncached). |

## A note on clinical content

CardsRef is a community-maintained convenience reference. Verify everything against official program sources and current guidelines. It is not a substitute for clinical judgment.
