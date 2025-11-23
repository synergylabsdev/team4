import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadright/di/injection_container.dart';
import 'package:leadright/features/auth/data/datasources/stripe_remote_datasource.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/auth/presentation/pages/organizer_welcome_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page for setting up payment account (Stripe) for organizers.
/// This is the second step (2/3) in the organizer account setup flow.
class PaymentSetupPage extends StatefulWidget {
  const PaymentSetupPage({super.key});

  @override
  State<PaymentSetupPage> createState() => _PaymentSetupPageState();
}

class _PaymentSetupPageState extends State<PaymentSetupPage> {
  final StripeRemoteDataSource _stripeDataSource = getIt<StripeRemoteDataSource>();
  bool _isConnecting = false;

  void _handleSkipForNow() {
    // Navigate to welcome page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: const OrganizerWelcomePage(),
        ),
      ),
    );
  }

  Future<void> _handleConnectPayment() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      // Create Stripe Connect account and get onboarding URL
      final onboardingUrl = await _stripeDataSource.createStripeConnectAccount();

      // Open the onboarding URL
      final uri = Uri.parse(onboardingUrl);
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $onboardingUrl');
      }

      // Wait a bit for the user to complete onboarding
      // In a real implementation, you would:
      // 1. Use a webview with a redirect handler
      // 2. Listen for the redirect URL
      // 3. Extract the account ID from the redirect
      // For now, we'll poll for the account ID after a delay
      await Future.delayed(const Duration(seconds: 2));

      // Poll for the account ID (in production, use webhooks or redirect handling)
      String? accountId;
      for (int i = 0; i < 10; i++) {
        accountId = await _stripeDataSource.getStripeAccountId();
        if (accountId != null && accountId.isNotEmpty) {
          break;
        }
        await Future.delayed(const Duration(seconds: 2));
      }

      if (accountId != null && accountId.isNotEmpty) {
        // Save the Stripe account ID to Firebase
        context.read<AuthBloc>().add(
              ConnectStripeAccountRequested(
                stripeAccountId: accountId,
              ),
            );

        // Wait for the state to update
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to welcome page
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: const OrganizerWelcomePage(),
              ),
            ),
          );
        }
      } else {
        // Show error if account ID not found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Stripe account setup is still in progress. Please complete the onboarding process.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to connect Stripe account: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate back to sign in page when logged out
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App bar with back button, title, and step indicator
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF0F1728),
                                    size: 24,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Payment Setup',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF0F1728),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 1.75,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: Center(
                                  child: Text(
                                    '2/3',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Color(0xFF1E3A8A),
                                      fontSize: 16,
                                      fontFamily: 'Futura PT',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress bar
                          Container(
                            width: double.infinity,
                            height: 6,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFEAECF0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: 214,
                                    height: 6,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1E3A8A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          // Stripe logo/icon
                          Container(
                            width: 144,
                            height: 64,
                            padding: const EdgeInsets.only(
                              top: 16,
                              left: 32,
                              right: 32,
                            ),
                            decoration: ShapeDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(0.00, 0.00),
                                end: Alignment(1.00, 1.00),
                                colors: [
                                  Color(0xFF615EFF),
                                  Color(0xFF980FFA),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                  spreadRadius: -4,
                                ),
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 15,
                                  offset: Offset(0, 10),
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Stripe',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Title and description
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Connect Your Payment Account',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF1B388E),
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 1.50,
                                    letterSpacing: -0.45,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Connect your Stripe account to securely accept ticket payments and manage your event revenue. Stripe handles all payment processing and security.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF45556C),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    letterSpacing: -0.31,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Benefits section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF8FAFC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Secure & PCI Compliant
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      child: const Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Secure & PCI Compliant',
                                            style: const TextStyle(
                                              color: Color(0xFF0E162B),
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50,
                                              letterSpacing: -0.31,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Bank-level security for all transactions',
                                            style: const TextStyle(
                                              color: Color(0xFF45556C),
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.43,
                                              letterSpacing: -0.15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Fast Payouts
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      child: const Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Fast Payouts',
                                            style: const TextStyle(
                                              color: Color(0xFF0E162B),
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50,
                                              letterSpacing: -0.31,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Get paid quickly after your events',
                                            style: const TextStyle(
                                              color: Color(0xFF45556C),
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.43,
                                              letterSpacing: -0.15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Easy Reporting
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      child: const Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Easy Reporting',
                                            style: const TextStyle(
                                              color: Color(0xFF0E162B),
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50,
                                              letterSpacing: -0.31,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Track all revenue in one place',
                                            style: const TextStyle(
                                              color: Color(0xFF45556C),
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.43,
                                              letterSpacing: -0.15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom section with buttons and footer
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    width: 1,
                    color: Color(0xFFEAECF0),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 265,
                    child: Text(
                      'Powered by Stripe • Used by millions of businesses worldwide',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF61738D),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skip For Now button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFFCFD4DC),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x0C101828),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading ? null : _handleSkipForNow,
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              child: Text(
                                'Skip For Now',
                                style: const TextStyle(
                                  color: Color(0xFF344053),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 1.50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Connect Payment Account button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: isLoading
                              ? const Color(0xFF1E3A8A).withValues(alpha: 0.6)
                              : const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFF1E3A8A),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x0C101828),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (isLoading || _isConnecting) ? null : _handleConnectPayment,
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              child: (isLoading || _isConnecting)
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Connect Payment Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        height: 1.50,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

