/**
 * Example Cloud Functions for Stripe Connect integration
 * 
 * This file shows how to implement the server-side Stripe Connect account creation.
 * 
 * To use this:
 * 1. Install Stripe SDK: npm install stripe
 * 2. Set your Stripe secret key as an environment variable: STRIPE_SECRET_KEY
 * 3. Deploy these functions to Firebase Cloud Functions
 * 
 * IMPORTANT: Never expose your Stripe secret key in client-side code!
 * Secret key: sk_test_51RqG4uET4NAZpFjDCURuLGf4It2doURWIXXPPIpxApkK8jGYWrjNpotmxFL6pDMz5OOIClqRiCjo7rDYhv4W3IwW00vje5t8bh
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secret_key || process.env.STRIPE_SECRET_KEY);

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Creates a Stripe Connect account and returns an onboarding URL
 * 
 * Expected request body:
 * {
 *   "userId": "user123"
 * }
 * 
 * Returns:
 * {
 *   "onboardingUrl": "https://connect.stripe.com/setup/..."
 * }
 */
exports.createStripeConnectAccount = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to create a Stripe account'
    );
  }

  const userId = context.auth.uid;
  const userEmail = context.auth.token.email;

  try {
    // Check if user already has a Stripe account
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const existingAccountId = userDoc.data()?.stripeAccountId;

    if (existingAccountId) {
      // Account already exists, create a new account link for onboarding/updates
      const accountLink = await stripe.accountLinks.create({
        account: existingAccountId,
        refresh_url: 'https://your-app.com/payment-setup?refresh=true',
        return_url: 'https://your-app.com/payment-setup?success=true',
        type: 'account_onboarding',
      });

      return { onboardingUrl: accountLink.url };
    }

    // Create a new Stripe Connect account
    const account = await stripe.accounts.create({
      type: 'express', // Use 'express' for faster onboarding
      email: userEmail,
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
      business_type: 'individual', // or 'company' based on your needs
    });

    // Create an account link for onboarding
    const accountLink = await stripe.accountLinks.create({
      account: account.id,
      refresh_url: 'https://your-app.com/payment-setup?refresh=true',
      return_url: 'https://your-app.com/payment-setup?success=true',
      type: 'account_onboarding',
    });

    // Store the account ID in Firestore (but don't mark as complete yet)
    await admin.firestore().collection('users').doc(userId).update({
      stripeAccountId: account.id,
      stripeAccountStatus: 'pending',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { onboardingUrl: accountLink.url };
  } catch (error) {
    console.error('Error creating Stripe Connect account:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to create Stripe account',
      error.message
    );
  }
});

/**
 * Gets the Stripe account ID and status for the authenticated user
 * 
 * Returns:
 * {
 *   "accountId": "acct_...",
 *   "status": "complete" | "pending"
 * }
 */
exports.getStripeAccountId = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const userId = context.auth.uid;

  try {
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const stripeAccountId = userDoc.data()?.stripeAccountId;

    if (!stripeAccountId) {
      return { accountId: null, status: 'none' };
    }

    // Check account status with Stripe
    const account = await stripe.accounts.retrieve(stripeAccountId);
    
    // Determine if onboarding is complete
    const isComplete = account.details_submitted && account.charges_enabled;

    // Update Firestore with current status
    await admin.firestore().collection('users').doc(userId).update({
      stripeAccountStatus: isComplete ? 'complete' : 'pending',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      accountId: stripeAccountId,
      status: isComplete ? 'complete' : 'pending',
    };
  } catch (error) {
    console.error('Error getting Stripe account ID:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to get Stripe account ID',
      error.message
    );
  }
});

/**
 * Webhook handler for Stripe events
 * This should be set up in Stripe Dashboard to receive events
 * 
 * Important events to handle:
 * - account.updated: When account details are updated
 * - account.application.deauthorized: When account is disconnected
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = functions.config().stripe.webhook_secret || process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  switch (event.type) {
    case 'account.updated':
      const account = event.data.object;
      // Find user by stripeAccountId and update status
      const userQuery = await admin.firestore()
        .collection('users')
        .where('stripeAccountId', '==', account.id)
        .limit(1)
        .get();

      if (!userQuery.empty) {
        const userId = userQuery.docs[0].id;
        const isComplete = account.details_submitted && account.charges_enabled;
        
        await admin.firestore().collection('users').doc(userId).update({
          stripeAccountStatus: isComplete ? 'complete' : 'pending',
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      break;

    case 'account.application.deauthorized':
      // Handle account deauthorization
      const deauthorizedAccount = event.data.object;
      const deauthQuery = await admin.firestore()
        .collection('users')
        .where('stripeAccountId', '==', deauthorizedAccount.id)
        .limit(1)
        .get();

      if (!deauthQuery.empty) {
        const userId = deauthQuery.docs[0].id;
        await admin.firestore().collection('users').doc(userId).update({
          stripeAccountId: null,
          stripeAccountStatus: 'disconnected',
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      break;

    default:
      console.log(`Unhandled event type ${event.type}`);
  }

  res.json({ received: true });
});

