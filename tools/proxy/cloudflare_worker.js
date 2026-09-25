/**
 * Cloudflare Worker Reverse Proxy untuk LokLok Streaming API (CineFlow)
 * 
 * Manfaat:
 * 1. Menembus blokir ISP Indonesia (Internet Positif / SNI filter) tanpa perlu VPN.
 * 2. 100% Gratis di Cloudflare (kuota 100.000 request per hari).
 * 3. Menyediakan CORS terbuka untuk semua client.
 * 
 * Cara Pasang (Hanya 1 Menit):
 * 1. Buka dash.cloudflare.com -> Masuk ke menu "Workers & Pages".
 * 2. Klik "Create Application" -> "Create Worker".
 * 3. Hapus kode default, paste seluruh isi file ini, lalu klik "Save and Deploy".
 * 4. Salin URL Worker Anda (misal: https://cineflow-proxy.username.workers.dev).
 * 5. Masukkan URL tersebut ke LOKLOK_PROXY_URL di .env atau baseUrl di LoklokStreamProvider.
 */

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // Target gateway resmi LokLok CMS
    const targetBase = 'https://ga-mobile-api.loklok.tv/cms/app';
    const targetUrl = targetBase + url.pathname + url.search;

    // Salin header request dan lengkapi identitas client LokLok
    const headers = new Headers(request.headers);
    headers.set('Host', 'ga-mobile-api.loklok.tv');
    if (!headers.has('lang')) headers.set('lang', 'en');
    if (!headers.has('versioncode')) headers.set('versioncode', '11');
    if (!headers.has('clienttype')) headers.set('clienttype', 'ios_jike_default');

    try {
      const response = await fetch(targetUrl, {
        method: request.method,
        headers: headers,
        body: request.method === 'POST' ? await request.text() : undefined,
      });

      const responseHeaders = new Headers(response.headers);
      responseHeaders.set('Access-Control-Allow-Origin', '*');
      responseHeaders.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      responseHeaders.set('Access-Control-Allow-Headers', '*');

      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: responseHeaders,
      });
    } catch (err) {
      return new Response(JSON.stringify({ error: 'Proxy fetch failed', message: err.message }), {
        status: 502,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }
  },
};
