# Stripe Connect Cloud Functions Setup

This directory contains example Cloud Functions for Stripe Connect integration.

## Setup Instructions

### 1. Install Dependencies

```bash
cd functions
npm install stripe firebase-functions firebase-admin
```

### 2. Configure Stripe Secret Key

Set your Stripe secret key as an environment variable:

```bash
# Using Firebase CLI
firebase functions:config:set stripe.secret_key="sk_test_51RqG4uET4NAZpFjDCURuLGf4It2doURWIXXPPIpxApkK8jGYWrjNpotmxFL6pDMz5OOIClqRiCjo7rDYhv4W3IwW00vje5t8bh"

# Or set in .env file (for local development)
STRIPE_SECRET_KEY=sk_test_51RqG4uET4NAZpFjDCURuLGf4It2doURWIXXPPIpxApkK8jGYWrjNpotmxFL6pDMz5OOIClqRiCjo7rDYhv4W3IwW00vje5t8bh
```

### 3. Update URLs

Update the `refresh_url` and `return_url` in `stripe-connect-example.js` to match your app's URLs:

```javascript
refresh_url: 'https://your-app.com/payment-setup?refresh=true',
return_url: 'https://your-app.com/payment-setup?success=true',
```

### 4. Deploy Functions

```bash
firebase deploy --only functions
```

### 5. Update Client Code

After deploying, update the Cloud Function URLs in:
- `lib/features/auth/data/datasources/stripe_remote_datasource.dart`

Replace `YOUR_REGION-YOUR_PROJECT` with your actual Firebase project details.

### 6. Set Up Stripe Webhook (Optional but Recommended)

1. Go to Stripe Dashboard → Developers → Webhooks
2. Add endpoint: `https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/stripeWebhook`
3. Select events:
   - `account.updated`
   - `account.application.deauthorized`
4. Copy the webhook signing secret
5. Set it as an environment variable:
   ```bash
   firebase functions:config:set stripe.webhook_secret="whsec_..."
   ```

## Security Notes

- ⚠️ **Never commit your Stripe secret key to version control**
- ⚠️ **Never use the secret key in client-side code**
- ✅ Always use environment variables or Firebase Functions config
- ✅ Verify user authentication in all Cloud Functions
- ✅ Use HTTPS for all webhook endpoints

## Testing

You can test the functions locally using the Firebase Emulator Suite:

```bash
firebase emulators:start --only functions
```

Then update your client code to point to the emulator URL during development.

