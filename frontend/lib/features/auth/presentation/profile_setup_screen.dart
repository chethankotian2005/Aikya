import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../../services/firebase_service.dart';
import '../../../utils/usn_parser.dart';
import '../../../utils/academic_batch_seeder.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1 Controllers
  final _formKey1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usnController = TextEditingController();
  String? _phoneNumber;
  bool _flagForHodReview = false;

  // Step 3 Controllers
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();

  // Step 4 State
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _academicInfo;
  bool _isFetchingAcademicInfo = false;

  @override
  void initState() {
    super.initState();
    // Pre-filling will now happen safely in the build method listener.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usnController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  String? _validateUsn(String? value) {
    if (value == null || value.isEmpty) return 'USN is required';
    final parsed = UsnParser.parse(value);
    
    if (parsed != null) return null;

    final upperValue = value.toUpperCase();
    final otherBranchRegex = RegExp(r'^4MW\d{2}[A-Z]{2}\d{3}$');
    if (otherBranchRegex.hasMatch(upperValue)) {
      return 'This app is for AI & ML department students only';
    }

    return 'Format hint: 4MW21AI042';
  }

  Future<void> _fetchAcademicInfo() async {
    final parsed = UsnParser.parse(_usnController.text);
    if (parsed == null) return;

    setState(() => _isFetchingAcademicInfo = true);

    // Academic info is computed directly from the USN — no Firestore lookup needed.
    setState(() {
      _academicInfo = {
        'year': parsed.label,
        'batch': 'AI & ML',
        'isAlumni': parsed.isAlumni,
      };
      _flagForHodReview = false;
      _isFetchingAcademicInfo = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _completeProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception("User not found");

      String? photoUrl;
      
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');
        await storageRef.putFile(_profileImage!);
        photoUrl = await storageRef.getDownloadURL();
      }

      final idToken = await user.getIdToken();
      // Call Render backend as source of truth
      final response = await http.put(
        Uri.parse('http://localhost:3000/api/profile'), // Assuming local proxy/tunnel for dev
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'fullName': _nameController.text.trim(),
          'usn': _usnController.text.toUpperCase().trim(),
          'phone': _phoneNumber,
          'githubUrl': _githubController.text.trim().isEmpty ? null : _githubController.text.trim(),
          'linkedinUrl': _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
          'instagramHandle': _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
          'personalWebsite': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          'profilePictureUrl': photoUrl,
          'flagForHodReview': _flagForHodReview,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.body}');
      }

      // Invalidate the cached user doc so the router sees profileComplete: true
      ref.invalidate(currentUserDocProvider);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      print("ERROR IN COMPLETE PROFILE: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    ref.listen<AsyncValue<UserDoc?>>(currentUserDocProvider, (previous, next) {
      final userDoc = next.valueOrNull;
      if (userDoc != null) {
        if (_nameController.text.isEmpty) _nameController.text = userDoc.fullName;
        if (_usnController.text.isEmpty) _usnController.text = userDoc.usn;
        if (_phoneNumber == null && userDoc.phone != null) {
          setState(() {
            _phoneNumber = userDoc.phone;
          });
        }
        if (_githubController.text.isEmpty && userDoc.githubUrl != null) {
          _githubController.text = userDoc.githubUrl!;
        }
        if (_linkedinController.text.isEmpty && userDoc.linkedinUrl != null) {
          _linkedinController.text = userDoc.linkedinUrl!;
        }
        if (_instagramController.text.isEmpty && userDoc.instagramHandle != null) {
          _instagramController.text = userDoc.instagramHandle!;
        }
        if (_websiteController.text.isEmpty && userDoc.personalWebsite != null) {
          _websiteController.text = userDoc.personalWebsite!;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () async {
          if (_currentStep == 0) {
            if (_formKey1.currentState!.validate() && _phoneNumber != null) {
              await _fetchAcademicInfo();
              setState(() => _currentStep += 1);
            } else if (_phoneNumber == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid phone number')),
              );
            }
          } else if (_currentStep == 1) {
            setState(() => _currentStep += 1);
          } else if (_currentStep == 2) {
            setState(() => _currentStep += 1);
          } else if (_currentStep == 3) {
            _completeProfile();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 3;
          final isSocials = _currentStep == 2;
          
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                if (_isLoading || _isFetchingAcademicInfo)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(isLastStep ? 'Complete Setup' : 'Continue'),
                  ),
                const SizedBox(width: 12),
                if (_currentStep > 0 && !_isLoading && !_isFetchingAcademicInfo)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                if (isSocials || isLastStep) ...[
                  const Spacer(),
                  if (!_isLoading && !_isFetchingAcademicInfo)
                    TextButton(
                      onPressed: () {
                        if (isLastStep) {
                          _completeProfile();
                        } else {
                          setState(() => _currentStep += 1);
                        }
                      },
                      child: const Text('Skip for now'),
                    ),
                ]
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Identity'),
            isActive: _currentStep >= 0,
            content: Form(
              key: _formKey1,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usnController,
                    decoration: const InputDecoration(labelText: 'USN'),
                    onChanged: (_) {
                      _formKey1.currentState?.validate();
                    },
                    validator: _validateUsn,
                  ),
                  const SizedBox(height: 16),
                  IntlPhoneField(
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    initialCountryCode: 'IN',
                    onChanged: (phone) {
                      _phoneNumber = phone.completeNumber;
                    },
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Academic Info'),
            isActive: _currentStep >= 1,
            content: Builder(
              builder: (context) {
                if (_currentStep < 1) return const SizedBox.shrink();
                if (_isFetchingAcademicInfo) return const CircularProgressIndicator();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "We've detected you as:\n${_academicInfo?['year'] ?? 'Unknown'}, ${_academicInfo?['batch'] ?? 'AI & ML'}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        const Text("Is this right?"),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _flagForHodReview = !_flagForHodReview;
                            });
                          },
                          child: Text(
                            _flagForHodReview 
                              ? 'Flagged for HOD review. We will verify your details manually.'
                              : 'This looks wrong',
                            style: TextStyle(
                              color: _flagForHodReview ? Colors.green : Colors.red,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
          Step(
            title: const Text('Socials'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                TextField(
                  controller: _githubController,
                  decoration: const InputDecoration(labelText: 'GitHub URL', prefixIcon: Icon(Icons.code)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _linkedinController,
                  decoration: const InputDecoration(labelText: 'LinkedIn URL', prefixIcon: Icon(Icons.business_center)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _instagramController,
                  decoration: const InputDecoration(labelText: 'Instagram Handle', prefixIcon: Icon(Icons.camera_alt)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _websiteController,
                  decoration: const InputDecoration(labelText: 'Personal Website', prefixIcon: Icon(Icons.language)),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Profile Picture'),
            isActive: _currentStep >= 3,
            content: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF000080),
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Text(
                            _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
