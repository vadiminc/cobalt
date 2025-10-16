# Railway Deployment Guide

## Summary

This project is configured to deploy on Railway using Docker.

## Required Files

- ✅ `Dockerfile` - Multi-stage Docker build
- ✅ `railway.json` - Railway configuration
- ✅ Debug logging added to track cookie loading

## Environment Variables for Railway

### Required:
```bash
API_URL=https://your-domain.up.railway.app
COOKIE_PATH=/app/cookies.json
```

### Recommended:
```bash
CORS_WILDCARD=1
```

### YouTube Cookies (if needed):

**IMPORTANT:** Cookies must be in a single string, separated by `; ` (semicolon + space)

**✅ Correct format:**
```json
{
  "youtube": ["__Secure-1PSID=xxx; __Secure-1PAPISID=yyy; __Secure-1PSIDTS=zzz"]
}
```

**❌ Incorrect format (array of separate cookies):**
```json
{
  "youtube": ["__Secure-1PSID=xxx", "__Secure-1PAPISID=yyy", "__Secure-1PSIDTS=zzz"]
}
```

Set as environment variable:
```bash
ALL_COOKIES={"youtube":["__Secure-1PSID=xxx; __Secure-1PAPISID=yyy; __Secure-1PSIDTS=zzz"]}
```

## Deployment Steps

1. **Commit changes:**
   ```bash
   git add Dockerfile railway.json api/src/
   git commit -m "Add Railway deployment with debug logging"
   git push
   ```

2. **Create service in Railway:**
   - Choose any of the 4 detected services (recommend @imput/cobalt-api)
   - Railway will automatically use `railway.json` and build with Dockerfile

3. **Configure environment variables in Railway dashboard:**
   - `API_URL` - Your Railway domain
   - `COOKIE_PATH=/app/cookies.json`
   - `ALL_COOKIES` - YouTube cookies in correct format (see above)
   - `CORS_WILDCARD=1`

4. **Railway will automatically:**
   - Build using Dockerfile
   - Expose port 9000
   - Provide public URL

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
- Check `COOKIE_PATH` is set to `/app/cookies.json`
- Verify `ALL_COOKIES` format (single string with `;` separators)
- Check Railway logs for `[✓] cookies loaded successfully!`

### YouTube login errors
- Verify all 3 required cookies are present: `__Secure-1PSID`, `__Secure-1PAPISID`, `__Secure-1PSIDTS`
- Check debug logs for `cookieKeys` array
- Cookies may need to be refreshed from your browser

## Docker Changes Made

1. ✅ Removed cache mount (incompatible with Railway)
2. ✅ Added pnpm via corepack in both build and runtime stages
3. ✅ Created minimal git repo (required for version-info package)
4. ✅ Added git remote
5. ✅ Fixed cookies.json permissions
6. ✅ Added debug logging for cookie tracking

