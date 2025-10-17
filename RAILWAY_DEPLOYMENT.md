# Railway Deployment Guide

## Summary

This project is configured to deploy on Railway using Docker.

## Required Files

- ✅ `Dockerfile` - Multi-stage Docker build
- ✅ `railway.json` - Railway configuration
- ✅ Debug logging added to track cookie loading

## YouTube Cookies Configuration

### ⚠️ IMPORTANT: Repository Privacy
Cookies are stored in `api/cookies.json` file in the repository. **Make sure your repository is PRIVATE** to protect your YouTube session!

### Cookie File Format

The `api/cookies.json` file should contain all YouTube cookies in this format:

```json
{
  "youtube": [
    "__Secure-1PSID=xxx; __Secure-3PSID=xxx; SID=xxx; HSID=xxx; __Secure-1PAPISID=xxx; __Secure-3PAPISID=xxx; SAPISID=xxx; __Secure-1PSIDTS=xxx; __Secure-3PSIDTS=xxx; VISITOR_INFO1_LIVE=xxx; YSC=xxx; PREF=xxx; SIDCC=xxx"
  ]
}
```

**Key points:**
- All cookies in **ONE string** (not array of separate strings)
- Separated by `; ` (semicolon + space)
- Include ALL 13 cookies for full authentication

### Required Cookies:
1. `__Secure-1PSID` - Primary Session ID
2. `__Secure-3PSID` - Alternative Session ID
3. `SID` - Session ID
4. `HSID` - Host Session ID
5. `__Secure-1PAPISID` - API Session ID
6. `__Secure-3PAPISID` - Alternative API Session ID
7. `SAPISID` - Secure API Session ID
8. `__Secure-1PSIDTS` - Timestamp cookie
9. `__Secure-3PSIDTS` - Alternative Timestamp cookie
10. `VISITOR_INFO1_LIVE` - Visitor information
11. `YSC` - Session cookie
12. `PREF` - User preferences
13. `SIDCC` - Cross-site cookie

### How to get cookies:
1. Open YouTube in Chrome/Firefox
2. Open DevTools (F12)
3. Go to **Application** → **Cookies** → `https://www.youtube.com`
4. Copy all the cookies listed above
5. Update `api/cookies.json` in your repository

## Environment Variables for Railway

### Required:
```bash
API_URL=https://your-domain.up.railway.app
COOKIE_PATH=cookies.json
```

### Recommended:
```bash
CORS_WILDCARD=1
```

## Deployment Steps

1. **Update cookies in `api/cookies.json`:**
   - Get fresh cookies from YouTube (see above)
   - Update the file with all 13 required cookies
   - **Ensure repository is PRIVATE!**

2. **Commit and push:**
   ```bash
   git add Dockerfile railway.json api/cookies.json api/src/ .dockerignore
   git commit -m "Add Railway deployment with cookies"
   git push
   ```

3. **Create service in Railway:**
   - Choose any of the 4 detected services (recommend @imput/cobalt-api)
   - Railway will automatically use `railway.json` and build with Dockerfile

4. **Configure environment variables in Railway dashboard:**
   - `API_URL` - Your Railway domain (e.g., `https://your-service.up.railway.app`)
   - `COOKIE_PATH=cookies.json`
   - `CORS_WILDCARD=1`

5. **Railway will automatically:**
   - Build using Dockerfile (with cookies included from repository)
   - Expose port 9000
   - Provide public URL
   - Load cookies from `api/cookies.json` file

## Debug Logs

The application now includes debug logging to track cookie loading:

- `[Cookie Debug]` - Shows cookie availability and count
- `[YouTube Debug]` - Shows parsed cookie keys and format
- `[YouTube Debug] LOGIN_REQUIRED` - Shows YouTube authentication errors

Check Railway logs to debug cookie issues.

## Testing

After deployment, test with:
```bash
curl -X POST "https://your-domain.up.railway.app/" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://www.youtube.com/watch?v=dQw4w9WgXcQ"}'
```

Expected response:
```json
{
  "status": "tunnel",
  "url": "https://...",
  "filename": "..."
}
```

## Troubleshooting

### Cookies not loading
- Check `COOKIE_PATH` is set to `cookies.json`
- Verify `api/cookies.json` is committed to repository
- Check Railway logs for `[✓] cookies loaded successfully!`
- Ensure `.dockerignore` has `!api/cookies.json` exception

### YouTube login errors (`youtube.login` or "bot" error)
- Verify **all 13 cookies** are present in `api/cookies.json`
- Check debug logs for `cookieKeys` array - should show all 13 keys
- Ensure cookies are in ONE string, separated by `; `
- Cookies may need to be refreshed from your browser (they expire!)
- Make sure you're logged into YouTube when copying cookies

### Debug logs showing wrong cookie count
Expected: `cookieCount: 1` with 13 keys in `cookieKeys` array
- If `cookieCount: 3` or more - you have wrong format (separate strings)
- Fix by combining all cookies into single string with `; ` separators

## Docker Changes Made

1. ✅ Removed cache mount (incompatible with Railway)
2. ✅ Added pnpm via corepack in both build and runtime stages
3. ✅ Created minimal git repo (required for version-info package)
4. ✅ Added git remote
5. ✅ Fixed cookies.json permissions
6. ✅ Added debug logging for cookie tracking

