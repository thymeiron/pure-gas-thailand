# PURE GAS Thailand 🇹🇭

Community-sourced map of Thailand stations reportedly selling **ethanol-free Benzine 95** (not Gasohol 95). A mobile-first static Next.js frontend, Supabase Auth + PostgreSQL + Storage, Leaflet + OpenStreetMap, deployed on Cloudflare Pages.

> **Current project stage:** deploy-ready source scaffold / public beta candidate. No stations are preloaded, no fuel stock is guaranteed, and external services must be configured. Verify deployment and security testing before inviting public users.

## Features

- Public searchable map, station cards, GPS proximity sorting, Google Maps directions.
- Email magic-link authentication.
- Authenticated station submission with optional pump photo; pending until administrator approval.
- Member reports: confirm fuel, no longer available, wrong info.
- Admin page `/admin/`: approve/reject stations, review reports, manually mark last verified date.
- PostgreSQL RLS restricts anonymous users to approved stations, members to submitting reports, and admin-only moderation.
- Empty database by design — do not fabricate real pump locations.

## Local development

Requirements: Node.js 20+ and a new Supabase project.

```bash
npm install
cp .env.example .env.local
# Edit .env.local with Project URL and publishable/anon key from Supabase
npm run dev
```

Visit `http://localhost:3000`.

## Supabase configuration

1. Visit https://supabase.com/dashboard and create project `pure-gas-thailand`.
2. **SQL Editor → New query**: paste contents of `supabase/migrations/0001_init.sql`, run once. Ensure the storage bucket is created. Do this in a new/empty project.
3. **Project Settings → API**: copy **Project URL** into `NEXT_PUBLIC_SUPABASE_URL`, and **publishable/anon key** into `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
4. **Authentication → Providers → Email**: enable email sign in / magic links. Configure email templates and SMTP for real public usage because built-in email is rate limited.
5. **Authentication → URL Configuration**: Set Site URL to your deployed HTTPS Cloudflare Pages URL; add `http://localhost:3000/**`, `https://YOUR_PROJECT.pages.dev/**` (and custom domain when present) to Redirect URLs.
6. Sign in from your site using your own email, then locate your UUID under **Authentication → Users**.
7. In SQL Editor run below with YOUR UUID (only after authenticating yourself):

```sql
insert into public.admins (user_id) values ('YOUR-AUTH-USER-UUID');
```

8. Open `/admin/` with the same logged-in browser to review new stations.

**NEVER** place a Supabase service_role/secret key in `NEXT_PUBLIC_*`, GitHub, or the browser. Only the public/publishable/anon key belongs in frontend environment variables. RLS is mandatory.

## Cloudflare Pages deployment (static Next.js)

1. Push this project to a new GitHub repo called `pure-gas-thailand` (prefer **Private** while testing): https://github.com/new
2. Cloudflare dashboard → **Workers & Pages → Create → Pages → Connect to Git** → choose repository.
3. Framework preset: **Next.js (Static HTML Export)**.
4. Build command: `npm run build`; output directory: `out`; branch: `main`.
5. Add the two `NEXT_PUBLIC_...` environment variables to **Build variables** (Production and Preview as applicable), then **Redeploy**. Public keys become embedded in the static JS bundle, which is expected.
6. Visit the generated `*.pages.dev` URL. Configure matching Supabase Auth Redirect URLs before attempting login.
7. Set up custom domain in Cloudflare later if desired; `.org` is a domain extension, not hosting.

This uses Next.js static export; do **not** add Next.js API routes, server actions, middleware, or request-time SSR without changing the Cloudflare deployment architecture.

## GitHub commands

```bash
git init
git add .
git commit -m "Initial PURE GAS Thailand community fuel map"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/pure-gas-thailand.git
git push -u origin main
```

## Production safety checklist

- [ ] Cloudflare/Supabase HTTPS and Auth redirect verified.
- [ ] Test RLS: anonymous cannot view pending stations; member cannot approve; member cannot spoof someone else's user id or last_verified_at.
- [ ] Admins check pump photos and actual Benzine 95 vs Gasohol 95 before approval.
- [ ] Setup anti-spam/CAPTCHA and submission rate limits before broad public launch. Supabase email OTP has provider limits; configure custom SMTP.
- [ ] Setup database backups and recovery tests (Supabase Free does not provide automatic backups).
- [ ] Validate duplicate station reports and suspicious GPS locations before approval.
- [ ] Publish privacy policy, terms, moderation policy, photo rights and contact route before a large public launch.
- [ ] Review OSM tile usage policy; switch to paid/commercial tile service or suitable provider as traffic scales. Attribution must remain visible.
- [ ] Add observability, admin audit logging, stale verification labels and explicit fuel availability disclaimer.
- [ ] No one can infer realtime stock from report timestamps; consider adding last-seen reporting metadata before wide release.

## Data model

- `stations`: point, brand, address, province, workflow status, photo, last admin verification timestamp.
- `station_reports`: member verification or issue report, moderation input.
- `admins`: UUID allow-list, only manually populated from trusted SQL editor.
- Supabase Storage bucket `station-photos`: public bucket, authenticated upload to own ID prefix, up to 5 MB, image types only.

## License / ownership

No license is granted by default. Add a project and data license before opening the repository or publishing downloadable datasets. OpenStreetMap map data carries its own attribution and licensing requirements.


## Connected project (2026-11-17)

Supabase project `pdaukbcswsbtsjraumpf` (Singapore) already has the schema installed, and its security advisor returned no findings after moving the admin helper into a private schema. **Do not rerun the initial SQL migration on this project.** `.env.example` contains only a public URL and publishable key, never a secret/service-role key. Configure Cloudflare Pages environment variables with these public settings; set Auth redirect allowlists in Supabase before public launch. Admin must be enrolled explicitly after first email login.
