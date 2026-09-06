import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

/// Event data model used across Events Hub and Event Detail screens.
class EventModel {
  final String id;
  final String title;
  final String description;
  final String bannerAsset;
  final DateTime dateTime;
  final DateTime? endTime;
  final String venue;
  final String tag; // Hackathon, Workshop, Seminar, etc.
  final Color tagColor;
  final Color tagBg;
  final int totalSeats;
  final int filledSeats;
  final bool isRegistered;
  final List<RegistrationField> registrationFields;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerAsset,
    required this.dateTime,
    this.endTime,
    required this.venue,
    required this.tag,
    required this.tagColor,
    required this.tagBg,
    required this.totalSeats,
    required this.filledSeats,
    this.isRegistered = false,
    this.registrationFields = const [],
  });

  double get fillRatio => filledSeats / totalSeats;
  int get seatsRemaining => totalSeats - filledSeats;
  bool get isPast => dateTime.isBefore(DateTime.now());
  bool get isNearCapacity => fillRatio >= 0.8;
  bool get isFull => filledSeats >= totalSeats;
}

/// A single field in a dynamic registration form.
class RegistrationField {
  final String label;
  final String hint;
  final FieldType type;
  final List<String> options; // for dropdown
  final bool isRequired;

  const RegistrationField({
    required this.label,
    required this.hint,
    required this.type,
    this.options = const [],
    this.isRequired = true,
  });
}

enum FieldType { text, email, phone, dropdown, multiline }

// ─── Sample Data ────────────────────────────────────────────────────

final List<EventModel> sampleEvents = [
  EventModel(
    id: '1',
    title: 'Neural Hack 2026 — 24hr AI Build Sprint',
    description:
        'The flagship annual hackathon of the AI & ML department. Build an end-to-end AI solution in 24 hours — from ideation to a working demo.\n\n'
        '**Theme:** Responsible AI for Healthcare\n\n'
        '**Prizes:**\n'
        '• 1st Place: ₹15,000 + internship referral\n'
        '• 2nd Place: ₹10,000\n'
        '• 3rd Place: ₹5,000\n'
        '• Best First-Time Hacker: ₹3,000\n\n'
        '**Rules:**\n'
        '• Teams of 2-4 members (cross-department allowed)\n'
        '• Must use at least one ML/AI component\n'
        '• Pre-trained models allowed, but document what you used\n'
        '• All code must be written during the event\n\n'
        '**What to bring:** Laptop, charger, valid college ID. Food and beverages will be provided.\n\n'
        'Mentors from Google, Microsoft, and NVIDIA will be available for guidance during the event.',
    bannerAsset: 'assets/images/event_hackathon.jpg',
    dateTime: DateTime(2026, 9, 15, 9, 0),
    endTime: DateTime(2026, 9, 16, 9, 0),
    venue: 'Seminar Hall A, 3rd Floor',
    tag: 'Hackathon',
    tagColor: AppColors.accent,
    tagBg: AppColors.accentMuted,
    totalSeats: 50,
    filledSeats: 42,
    registrationFields: [
      const RegistrationField(
          label: 'Team Name', hint: 'e.g. Neural Ninjas', type: FieldType.text),
      const RegistrationField(
          label: 'Team Size',
          hint: 'Select team size',
          type: FieldType.dropdown,
          options: ['2 members', '3 members', '4 members']),
      const RegistrationField(
          label: 'Team Lead USN',
          hint: '4MW21AI0XX',
          type: FieldType.text),
      const RegistrationField(
          label: 'Team Lead Phone',
          hint: '+91 XXXXX XXXXX',
          type: FieldType.phone),
      const RegistrationField(
          label: 'Project Idea (Brief)',
          hint: 'Describe your idea in 2-3 sentences',
          type: FieldType.multiline,
          isRequired: false),
    ],
  ),
  EventModel(
    id: '2',
    title: 'Hands-on: Fine-tuning LLMs with LoRA',
    description:
        'A hands-on workshop covering the theory and practice of Parameter-Efficient Fine-Tuning (PEFT) using LoRA and QLoRA.\n\n'
        '**Prerequisites:**\n'
        '• Basic Python and PyTorch knowledge\n'
        '• Familiarity with transformer architecture (helpful, not mandatory)\n'
        '• Google Colab account (we\'ll use free-tier GPUs)\n\n'
        '**What you\'ll learn:**\n'
        '• How LoRA works — low-rank adaptation explained\n'
        '• Setting up Hugging Face Transformers + PEFT library\n'
        '• Fine-tuning Llama 3.1 8B on a custom dataset\n'
        '• Evaluating and deploying your fine-tuned model\n\n'
        '**Instructor:** Prof. Aditya K., with research experience at IISc Bangalore.',
    bannerAsset: 'assets/images/event_workshop.jpg',
    dateTime: DateTime(2026, 9, 22, 14, 0),
    endTime: DateTime(2026, 9, 22, 17, 0),
    venue: 'AI Lab, Room 204',
    tag: 'Workshop',
    tagColor: AppColors.secondary,
    tagBg: const Color(0x1A1F5C99),
    totalSeats: 40,
    filledSeats: 28,
    registrationFields: [
      const RegistrationField(
          label: 'Full Name', hint: 'As per college records', type: FieldType.text),
      const RegistrationField(
          label: 'Email', hint: 'name@smvitm.ac.in', type: FieldType.email),
      const RegistrationField(
          label: 'Year / Semester',
          hint: 'Select',
          type: FieldType.dropdown,
          options: ['3rd Year / 5th Sem', '3rd Year / 6th Sem', '4th Year / 7th Sem', '4th Year / 8th Sem']),
      const RegistrationField(
          label: 'PyTorch Experience',
          hint: 'Select',
          type: FieldType.dropdown,
          options: ['Beginner', 'Intermediate', 'Advanced']),
    ],
  ),
  EventModel(
    id: '3',
    title: 'Vision Transformers in Medical Imaging',
    description:
        'A research seminar by Dr. Priya Sharma (IIIT Hyderabad) on the application of Vision Transformers (ViT) in medical image analysis.\n\n'
        '**Topics covered:**\n'
        '• Evolution from CNNs to ViTs in medical imaging\n'
        '• Attention mechanisms and their interpretability in diagnosis\n'
        '• Case studies: retinal disease detection, tumor segmentation\n'
        '• Open research problems and future directions\n\n'
        'Open to all departments. No registration fee.',
    bannerAsset: 'assets/images/event_seminar.jpg',
    dateTime: DateTime(2026, 9, 29, 10, 30),
    endTime: DateTime(2026, 9, 29, 12, 0),
    venue: 'Auditorium, Main Block',
    tag: 'Seminar',
    tagColor: AppColors.warning,
    tagBg: const Color(0x1AF0A500),
    totalSeats: 60,
    filledSeats: 15,
    registrationFields: [
      const RegistrationField(
          label: 'Full Name', hint: 'Your name', type: FieldType.text),
      const RegistrationField(
          label: 'USN', hint: '4MW21AI0XX', type: FieldType.text),
      const RegistrationField(
          label: 'Department',
          hint: 'Select',
          type: FieldType.dropdown,
          options: ['AI & ML', 'CSE', 'ISE', 'ECE', 'ME', 'Civil', 'Other']),
    ],
  ),
  EventModel(
    id: '4',
    title: 'Intro to Computer Vision with OpenCV',
    description: 'A beginner-friendly workshop covering the fundamentals of computer vision using Python and OpenCV.',
    bannerAsset: 'assets/images/event_seminar.jpg',
    dateTime: DateTime(2026, 8, 10, 14, 0),
    endTime: DateTime(2026, 8, 10, 17, 0),
    venue: 'AI Lab, Room 204',
    tag: 'Workshop',
    tagColor: AppColors.secondary,
    tagBg: const Color(0x1A1F5C99),
    totalSeats: 35,
    filledSeats: 35,
    isRegistered: true,
    registrationFields: [],
  ),
  EventModel(
    id: '5',
    title: 'Department Orientation — Batch of 2026',
    description: 'Welcome session for new AI & ML students.',
    bannerAsset: 'assets/images/event_hackathon.jpg',
    dateTime: DateTime(2026, 7, 20, 10, 0),
    venue: 'Auditorium, Main Block',
    tag: 'General',
    tagColor: const Color(0xFF6B7194),
    tagBg: const Color(0x1A6B7194),
    totalSeats: 120,
    filledSeats: 118,
    isRegistered: true,
    registrationFields: [],
  ),
];
