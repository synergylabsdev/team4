# Stripe Connect Integration Setup Guide

This guide will help you complete the Stripe Connect integration setup.

## ✅ What's Already Done

1. ✅ Stripe publishable key added to `AppConstants`
2. ✅ Stripe SDK initialized in `main.dart`
3. ✅ `stripeAccountId` field added to User entity and model
4. ✅ Stripe Connect flow implemented in `payment_setup_page.dart`
5. ✅ AuthBloc updated to handle Stripe account connection
6. ✅ Cloud Functions example code provided

## 🔧 Required Setup Steps

### 1. Run Code Generation

The `UserModel` has a new field that requires JSON serialization code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Configure iOS Merchant Identifier (for Apple Pay)

If you plan to use Apple Pay, you need to:

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Create a Merchant ID (e.g., `merchant.com.leadright`)
3. Update `lib/main.dart` with your actual merchant identifier:
   ```dart
   Stripe.merchantIdentifier = 'merchant.com.leadright'; // Update this
   ```
4. Configure the merchant ID in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select Runner target → Signing & Capabilities
   - Add "Apple Pay" capability
   - Select your Merchant ID

### 3. Set Up Cloud Functions

#### 3.1 Install Dependencies

```bash
cd functions
npm install stripe firebase-functions firebase-admin
```

#### 3.2 Configure Stripe Secret Key

**⚠️ IMPORTANT: Never commit your secret key to version control!**

Set the secret key as a Firebase Functions config:

```bash
firebase functions:config:set stripe.secret_key="sk_test_51RqG4uET4NAZpFjDCURuLGf4It2doURWIXXPPIpxApkK8jGYWrjNpotmxFL6pDMz5OOIClqRiCjo7rDYhv4W3IwW00vje5t8bh"
```

#### 3.3 Update Return URLs

Edit `functions/stripe-connect-example.js` and update the return URLs:

```javascript
refresh_url: 'https://your-app.com/payment-setup?refresh=true',
return_url: 'https://your-app.com/payment-setup?success=true',
```

For mobile apps, you can use deep links:
- iOS: `yourapp://payment-setup?success=true`
- Android: `yourapp://payment-setup?success=true`

#### 3.4 Deploy Functions

```bash
firebase deploy --only functions
```

After deployment, note your function URLs. They will look like:
- `https://us-central1-YOUR_PROJECT.cloudfunctions.net/createStripeConnectAccount`
- `https://us-central1-YOUR_PROJECT.cloudfunctions.net/getStripeAccountId`

### 4. Update Client Code with Function URLs

Edit `lib/features/auth/data/datasources/stripe_remote_datasource.dart`:

Replace the placeholder URLs:

```dart
// Replace this:
const cloudFunctionUrl = 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/createStripeConnectAccount';

// With your actual function URL:
const cloudFunctionUrl = 'https://us-central1-YOUR_PROJECT.cloudfunctions.net/createStripeConnectAccount';
```

Do the same for `getStripeAccountId` function.

### 5. (Optional) Set Up Stripe Webhooks

For real-time account status updates, set up webhooks:

1. Go to [Stripe Dashboard](https://dashboard.stripe.com) → Developers → Webhooks
2. Click "Add endpoint"
3. Enter your webhook URL: `https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/stripeWebhook`
4. Select events:
   - `account.updated`
   - `account.application.deauthorized`
5. Copy the webhook signing secret
6. Set it as a config:
   ```bash
   firebase functions:config:set stripe.webhook_secret="whsec_..."
   ```
7. Redeploy functions:
   ```bash
   firebase deploy --only functions
   ```

## 🧪 Testing

### Test Stripe Connect Flow

1. Run the app: `flutter run`
2. Navigate to the payment setup page
3. Tap "Connect Payment Account"
4. Complete the Stripe onboarding flow
5. Verify the account ID is saved to Firestore

### Test in Stripe Dashboard

1. Go to [Stripe Dashboard](https://dashboard.stripe.com/test/connect/accounts)
2. You should see the connected account
3. Check account status and capabilities

## 📝 Current Implementation Notes

### How It Works

1. **User taps "Connect Payment Account"**
   - Calls `createStripeConnectAccount()` Cloud Function
   - Function creates a Stripe Express account
   - Returns an onboarding URL

2. **User completes onboarding**
   - Opens in external browser (can be improved with webview)
   - User completes Stripe's onboarding form
   - Stripe redirects back to return URL

3. **App polls for account ID**
   - After onboarding, app polls `getStripeAccountId()` function
   - Function checks Stripe account status
   - Returns account ID when ready

4. **Account ID saved to Firebase**
   - AuthBloc saves `stripeAccountId` to user document
   - User navigates to welcome page

### Limitations & Future Improvements

- **Current**: Uses external browser for onboarding
  - **Better**: Use webview with redirect handling for better UX

- **Current**: Polls for account ID
  - **Better**: Use webhooks for real-time updates

- **Current**: Basic error handling
  - **Better**: Add retry logic and better error messages

## 🔐 Security Checklist

- ✅ Secret key only in Cloud Functions (server-side)
- ✅ Publishable key in client code (safe to expose)
- ✅ User authentication verified in Cloud Functions
- ✅ HTTPS used for all API calls
- ⚠️ **TODO**: Add rate limiting to Cloud Functions
- ⚠️ **TODO**: Add input validation in Cloud Functions

## 📚 Resources

- [Stripe Connect Documentation](https://stripe.com/docs/connect)
- [Stripe Express Accounts](https://stripe.com/docs/connect/express-accounts)
- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Flutter Stripe Package](https://pub.dev/packages/flutter_stripe)

## 🆘 Troubleshooting

### "Could not launch URL"
- Check if `url_launcher` is properly configured
- Verify URL format is correct

### "Failed to create Stripe account"
- Verify Cloud Function is deployed
- Check Firebase Functions logs: `firebase functions:log`
- Verify Stripe secret key is set correctly

### "Account ID not found"
- Check if onboarding was completed
- Verify webhook is set up (if using)
- Check Stripe Dashboard for account status

### Build errors after adding stripeAccountId
- Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
- Clean build: `flutter clean && flutter pub get`

## 📞 Support

If you encounter issues:
1. Check Firebase Functions logs
2. Check Stripe Dashboard for account status
3. Review Cloud Functions code in `functions/stripe-connect-example.js`

