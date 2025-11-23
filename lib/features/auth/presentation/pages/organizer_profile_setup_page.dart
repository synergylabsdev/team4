import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leadright/core/utils/constants.dart';
import 'package:leadright/di/injection_container.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/auth/presentation/pages/payment_setup_page.dart';
import 'package:uuid/uuid.dart';

/// Page for completing organizer profile setup after sign up.
class OrganizerProfileSetupPage extends StatefulWidget {
  const OrganizerProfileSetupPage({super.key});

  @override
  State<OrganizerProfileSetupPage> createState() =>
      _OrganizerProfileSetupPageState();
}

class _OrganizerProfileSetupPageState extends State<OrganizerProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  static const int _maxBioLength = 250;
  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _contactEmailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? _validateBio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bio is required';
    }
    if (value.trim().length < 10) {
      return 'Bio must be at least 10 characters';
    }
    if (value.length > _maxBioLength) {
      return 'Bio must not exceed $_maxBioLength characters';
    }
    return null;
  }

  String? _validateContactEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateWebsite(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final url = value.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return 'Website must start with http:// or https://';
      }
      if (!RegExp(r'^https?://[^\s/$.?#].[^\s]*$').hasMatch(url)) {
        return 'Please enter a valid website URL';
      }
    }
    return null;
  }

  int get _remainingBioChars {
    return _maxBioLength - _bioController.text.length;
  }

  /// Upload profile image to Firebase Storage and return the download URL.
  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final firebaseAuth = firebase_auth.FirebaseAuth.instance;
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final storage = getIt<FirebaseStorage>();
      final imageId = const Uuid().v4();
      final imageExtension = imageFile.path.split('.').last;
      final storagePath = '${AppConstants.userAvatarsPath}/${user.uid}/$imageId.$imageExtension';

      final ref = storage.ref().child(storagePath);
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _handleSaveAndContinue() async {
    if (_formKey.currentState?.validate() ?? false && !_isSaving) {
      setState(() {
        _isSaving = true;
      });

      String? photoUrl;

      // Upload profile image if selected
      if (_profileImage != null) {
        photoUrl = await _uploadProfileImage(_profileImage!);
        if (photoUrl == null) {
          // Image upload failed, but don't block the flow
          // User can continue without image
        }
      }

      // Dispatch update profile event
      context.read<AuthBloc>().add(
            UpdateProfileRequested(
              displayName: _fullNameController.text.trim(),
              photoUrl: photoUrl,
              bio: _bioController.text.trim(),
              contactEmail: _contactEmailController.text.trim(),
              website: _websiteController.text.trim().isEmpty
                  ? null
                  : _websiteController.text.trim(),
            ),
          );
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
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthAuthenticated && _isSaving) {
          // Profile update successful, navigate to payment setup page
          setState(() {
            _isSaving = false;
          });
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: const PaymentSetupPage(),
                ),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
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
                            // Status bar placeholder
                            const SizedBox(height: 0),
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
                                    'Profile Setup',
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
                                      '1/3',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: const Color(0xFF1E3A8A),
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
                                      width: 114,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            // Profile Preview section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Profile Preview',
                                  style: TextStyle(
                                    color: Color(0xFF0E162B),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 1.50,
                                    letterSpacing: -0.31,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF8F9FB),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFEAECF0),
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 96,
                                            height: 96,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              color: Colors.white.withValues(
                                                  alpha: 0),
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                    width: 4,
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(48),
                                              ),
                                            ),
                                            child: _profileImage != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            48),
                                                    child: Image.file(
                                                      _profileImage!,
                                                      width: 88,
                                                      height: 88,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Container(
                                                    height: 88,
                                                    decoration:
                                                        const ShapeDecoration(
                                                      color: Color(0xFFDBEAFE),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(44),
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 48,
                                                        color: Color(0xFF1E3A8A),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: 170.73,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 24,
                                                  child: Center(
                                                    child: Text(
                                                      _fullNameController
                                                              .text.isNotEmpty
                                                          ? _fullNameController
                                                              .text
                                                          : 'Your Name',
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Color(0xFF0E162B),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.50,
                                                        letterSpacing: -0.31,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 20,
                                                  child: Center(
                                                    child: Text(
                                                      _bioController
                                                              .text.isNotEmpty
                                                          ? _bioController.text
                                                          : 'Your bio will appear here...',
                                                      textAlign: TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Color(0xFF45556C),
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.43,
                                                        letterSpacing: -0.15,
                                                      ),
                                                    ),
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
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  height: 66,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17, vertical: 15),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF8F9FB),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFEAECF0),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Color(0xFF667084),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Your first event will require admin approval before it goes live.',
                                          style: const TextStyle(
                                            color: Color(0xFF667084),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.43,
                                            letterSpacing: -0.15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Complete Your Profile section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Complete Your Profile',
                                  style: TextStyle(
                                    color: Color(0xFF0E162B),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 1.50,
                                    letterSpacing: -0.31,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Profile Photo
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Profile Photo',
                                          style: TextStyle(
                                            color: Color(0xFF314157),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            height: 1,
                                            letterSpacing: -0.15,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 64,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: GestureDetector(
                                                  onTap: _pickImage,
                                                  child: Container(
                                                    width: 64,
                                                    height: 64,
                                                    clipBehavior: Clip.antiAlias,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: const BorderSide(
                                                          width: 2,
                                                          color:
                                                              Color(0xFFE1E8F0),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                32),
                                                      ),
                                                    ),
                                                    child: _profileImage != null
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            child: Image.file(
                                                              _profileImage!,
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Container(
                                                            height: 60,
                                                            decoration:
                                                                const ShapeDecoration(
                                                              color: Color(
                                                                  0xFFF1F5F9),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius.circular(
                                                                      30),
                                                                ),
                                                              ),
                                                            ),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 32,
                                                                color: Color(
                                                                    0xFF1E3A8A),
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 80,
                                                top: 14,
                                                child: GestureDetector(
                                                  onTap: _pickImage,
                                                  child: Container(
                                                    width: 147.55,
                                                    height: 36,
                                                    decoration: ShapeDecoration(
                                                      color: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        side: const BorderSide(
                                                          width: 1,
                                                          color:
                                                              Color(0xFFCAD5E2),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.upload,
                                                          size: 16,
                                                          color:
                                                              Color(0xFF0A0A0A),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Text(
                                                          'Upload Photo',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                Color(0xFF0A0A0A),
                                                            fontSize: 14,
                                                            fontFamily: 'Inter',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 1.43,
                                                            letterSpacing:
                                                                -0.15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Full Name
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Full Name *',
                                          style: TextStyle(
                                            color: Color(0xFF314157),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            height: 1,
                                            letterSpacing: -0.15,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _fullNameController,
                                          validator: _validateFullName,
                                          enabled: !isLoading,
                                          onChanged: (_) => setState(() {}),
                                          style: const TextStyle(
                                            color: Color(0xFF0A0A0A),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                            letterSpacing: -0.31,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color(0xFFF3F3F5),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCAD5E2),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCAD5E2),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            errorStyle: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Bio
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Bio *',
                                              style: TextStyle(
                                                color: Color(0xFF314157),
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                height: 1,
                                                letterSpacing: -0.15,
                                              ),
                                            ),
                                            Text(
                                              '$_remainingBioChars characters remaining',
                                              style: const TextStyle(
                                                color: Color(0xFF61738D),
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                height: 1.43,
                                                letterSpacing: -0.15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _bioController,
                                          validator: _validateBio,
                                          enabled: !isLoading,
                                          maxLength: _maxBioLength,
                                          maxLines: 4,
                                          onChanged: (_) => setState(() {}),
                                          style: const TextStyle(
                                            color: Color(0xFF0A0A0A),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                            letterSpacing: -0.31,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color(0xFFF3F3F5),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                            hintText:
                                                'Tell us about yourself and your organization...',
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF0A0A0A),
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50,
                                              letterSpacing: -0.31,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCAD5E2),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCAD5E2),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            errorStyle: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                            ),
                                            counterText: '',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Contact Email
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Contact Email *',
                                          style: TextStyle(
                                            color: Color(0xFF314157),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            height: 1,
                                            letterSpacing: -0.15,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _contactEmailController,
                                          validator: _validateContactEmail,
                                          enabled: !isLoading,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: const TextStyle(
                                            color: Color(0xFF0A0A0A),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                            letterSpacing: -0.31,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color(0xFFF3F3F5),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCAD5E2),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCAD5E2),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            errorStyle: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Website
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Website (Optional)',
                                          style: TextStyle(
                                            color: Color(0xFF314157),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            height: 1,
                                            letterSpacing: -0.15,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _websiteController,
                                          validator: _validateWebsite,
                                          enabled: !isLoading,
                                          keyboardType: TextInputType.url,
                                          style: const TextStyle(
                                            color: Color(0xFF0A0A0A),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                            letterSpacing: -0.31,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color(0xFFF3F3F5),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCAD5E2),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFCAD5E2),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 1,
                                                color: Colors.red,
                                              ),
                                            ),
                                            errorStyle: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 80),
                            // Save Profile & Continue button
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
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
                                  onTap: isLoading ? null : _handleSaveAndContinue,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Center(
                                    child: isLoading
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
                                            'Save Profile & Continue',
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
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

