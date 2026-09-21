import Foundation

// The Project URL and publishable key from Project Settings → API Keys.
// This key is meant to be public (it only allows what the database's RLS
// policies permit — read-only on duas/info_cards — and what the deployed
// Edge Functions choose to do), unlike the OpenAI key, which never appears
// in the app at all. Note: this is the newer `sb_publishable_...` key, not
// the legacy anon JWT — the deployed Edge Functions (via the `withSupabase`
// helper) only accept the new key format, confirmed against the live
// project on 2026-08-25.
enum SupabaseConfig {
    static let projectURL = URL(string: "https://agwfkynpzoaoexbytblz.supabase.co")!
    static let anonKey = "sb_publishable_u8Qd_arOfWXyh2CMvSpRzQ_lqTsoCZh"

    static func functionURL(_ name: String) -> URL {
        projectURL.appendingPathComponent("functions/v1/\(name)")
    }

    static func restURL(table: String) -> URL {
        projectURL.appendingPathComponent("rest/v1/\(table)")
    }

    static func authorizedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apiKey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        return request
    }
}
