// ============================================================
//  CardsRef configuration — fill in your Supabase project values.
//
//  The anon (public) key is DESIGNED to be shipped in the browser.
//  Your data is protected by Row Level Security (see schema.sql):
//  anyone can read, only signed-in users can write.
//
//  NEVER put the service_role key here — that key bypasses RLS.
// ============================================================
window.CARDSREF_CONFIG = {
  // From Supabase: Project Settings > API
  SUPABASE_URL: "https://tkwkkxpicfkammqbrhqq.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_LGqQbxD1-uTMvOesjOmlsQ_6xdig1cT",

  // Branding shown in the header
  APP_TITLE: "AHC CardsRef",
  APP_SUBTITLE: "AHC Cardiology Consult Reference",

  // Optional: restrict sign-in to one email domain, e.g. "hospital.org".
  // Leave "" to allow any email address.
  ALLOWED_EMAIL_DOMAIN: "atlantichealth.org"
};
