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
  APP_SUBTITLE: "Cardiology Consult Reference",

  // ---- Sign-in methods ----
  // Turn on the ones you want. OAuth and password need NO email sending at all,
  // which is the way to go if SMTP is blocked or your provider suspended you.
  // If all are false, magic link is used as the fallback.
  AUTH_MICROSOFT: true,    // Microsoft Entra ID / Azure AD — for Microsoft 365 institutions
  AUTH_GOOGLE: false,      // Google OAuth — for Google Workspace institutions
  AUTH_PASSWORD: false,     // Email + password (disable "Confirm email" in Supabase)
  AUTH_MAGIC_LINK: false,  // Emailed one-time link — requires working SMTP

  // Optional: restrict editing to one email domain, e.g. "hospital.org".
  // Enforced after sign-in for every method (and passed to Google as a hint).
  // For Microsoft, ALSO set the Azure Tenant URL in Supabase so only your
  // organization's tenant can authenticate at all. Leave "" to allow any address.
  ALLOWED_EMAIL_DOMAIN: "atlantichealth.org"
};
