# YouTube Cookies Setup Guide

## ⚠️ IMPORTANT
**Make sure your repository is PRIVATE** before committing cookies!

## Quick Setup

### 1. Get Cookies from Browser

1. Open [YouTube](https://youtube.com) in Chrome/Firefox
2. Make sure you're **logged in**
3. Press **F12** to open DevTools
4. Go to **Application** tab → **Cookies** → `https://www.youtube.com`
5. Copy these 13 cookies:

| Cookie Name | Example |
|------------|---------|
| `__Secure-1PSID` | g.a000... |
| `__Secure-3PSID` | g.a000... |
| `SID` | g.a000... |
| `HSID` | AWW441... |
| `__Secure-1PAPISID` | niN3sey... |
| `__Secure-3PAPISID` | niN3sey... |
| `SAPISID` | niN3sey... |
| `__Secure-1PSIDTS` | sidts-... |
| `__Secure-3PSIDTS` | sidts-... |
| `VISITOR_INFO1_LIVE` | nkA8Le7... |
| `YSC` | sSAHxQ... |
| `PREF` | f4=4010... |
| `SIDCC` | AKEyXz... |

### 2. Format Cookies

Combine ALL cookies into ONE string, separated by `; ` (semicolon + space):

```
__Secure-1PSID=xxx; __Secure-3PSID=xxx; SID=xxx; HSID=xxx; __Secure-1PAPISID=xxx; __Secure-3PAPISID=xxx; SAPISID=xxx; __Secure-1PSIDTS=xxx; __Secure-3PSIDTS=xxx; VISITOR_INFO1_LIVE=xxx; YSC=xxx; PREF=xxx; SIDCC=xxx
```

### 3. Update `cookies.json`

Edit `api/cookies.json`:

```json
{
  "youtube": [
    "YOUR_COMBINED_COOKIE_STRING_HERE"
  ]
}
```

**✅ Correct:** One string with all cookies
```json
{
  "youtube": ["__Secure-1PSID=xxx; __Secure-3PSID=yyy; ..."]
}
```

**❌ Wrong:** Multiple separate strings
```json
{
  "youtube": ["__Secure-1PSID=xxx", "__Secure-3PSID=yyy", "..."]
}
```

### 4. Verify

Build and run locally to test:

```bash
docker build -t cobalt-api .
docker run -p 9000:9000 -e API_URL=http://localhost:9000 -e COOKIE_PATH=cookies.json cobalt-api
```

Check logs for:
```
[✓] cookies loaded successfully!
```

Make a test request:
```bash
curl -X POST "http://localhost:9000/" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://www.youtube.com/watch?v=dQw4w9WgXcQ"}'
```

Should return `{"status":"tunnel","url":"..."}` instead of `{"error":"youtube.login"}`

## Troubleshooting

### Still getting "bot" errors?

Check debug logs after making request:
- `cookieCount` should be **1** (not 3 or 13)
- `cookieKeys` array should have **13 items**

If `cookieCount` is 3 or more → you have wrong format (separate strings instead of one combined string)

### Cookies expired?

YouTube cookies expire. If you get login errors:
1. Log out and log back into YouTube
2. Get fresh cookies
3. Update `api/cookies.json`
4. Commit and redeploy

## Cookie Lifespan

Most YouTube cookies last ~1 year, but some may expire sooner:
- `__Secure-1PSIDTS`, `__Secure-3PSIDTS` - timestamp cookies (expire after ~1 month)
- `YSC` - session cookie (expires when browser closes)

Update cookies when you see authentication errors.

