import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mock-trip-model.dart';

enum PaymentMethod { mtn, airtel, card }

class BookingDetailsViewModel extends ChangeNotifier {
  BookingDetailsViewModel({required this.trip}) {
    seatsController.addListener(notifyListeners);
  }

  final TripSummary trip;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final seatsController = TextEditingController(text: '1');
  final phoneController = TextEditingController();
  final cardNumberController = TextEditingController();
  final cardExpiryController = TextEditingController();
  final cardCvvController = TextEditingController();

  PaymentMethod? selectedPayment;
  String? paymentError;
  bool isSubmitting = false;

  int get seats => int.tryParse(seatsController.text) ?? 1;
  int get total => seats * trip.amount;

  void setSeats(int value) {
    final clamped = value.clamp(1, trip.spotsAvailable);
    seatsController.text = clamped.toString();
    notifyListeners();
  }

  void selectPayment(PaymentMethod method) {
    selectedPayment = method;
    paymentError = null;
    notifyListeners();
  }

  // ── Validators ────────────────────────────────────────────────────────────
  String? validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 3) return 'Enter your full name';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return 'Name can only contain letters';
    return null;
  }

  String? validatePhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 10) return 'Enter a valid phone number';
    return null;
  }

  String? validateCardNumber(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Card number is required';
    if (digits.length < 13 || digits.length > 16) return 'Enter a valid card number';
    return null;
  }

  String? validateExpiry(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Expiry is required';
    final match = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').firstMatch(v);
    if (match == null) return 'Use MM/YY format';
    final month = int.parse(match.group(1)!);
    final year = int.parse('20${match.group(2)!}');
    if (DateTime(year, month + 1).isBefore(DateTime.now())) return 'Card has expired';
    return null;
  }

  String? validateCvv(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'CVV is required';
    if (!RegExp(r'^\d{3,4}$').hasMatch(v)) return 'Enter a valid CVV';
    return null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static const _bookedSeats = {3, 7, 11, 15, 18, 22, 26};

  int randomSeat() {
    final available = List.generate(32, (i) => i + 1)
        .where((s) => !_bookedSeats.contains(s))
        .toList();
    return available[Random().nextInt(available.length)];
  }

  String get paymentLabel {
    switch (selectedPayment) {
      case PaymentMethod.mtn:    return 'MTN MoMo';
      case PaymentMethod.airtel: return 'Airtel Money';
      case PaymentMethod.card:   return 'Credit Card';
      case null:                 return 'Not selected';
    }
  }

  IconData get paymentIcon {
    if (selectedPayment == PaymentMethod.card) return Icons.credit_card_rounded;
    return Icons.phone_android_rounded;
  }

  Color paymentBrandColor(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.mtn:    return const Color(0xFFFFCC00);
      case PaymentMethod.airtel: return const Color(0xFFED1C24);
      case PaymentMethod.card:   return const Color(0xFF0E2B67);
    }
  }

  /// Returns booking result map on success, null on validation failure.
  /// Throws on unexpected error.
  Future<Map<String, dynamic>?> submit(ScrollController scrollCtrl) async {
    paymentError = selectedPayment == null ? 'Please select a payment method' : null;
    notifyListeners();

    final formValid = formKey.currentState?.validate() ?? false;
    if (!formValid || paymentError != null) {
      if (paymentError != null) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent * 0.4,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      return null;
    }

    if (seats > trip.spotsAvailable) {
      throw Exception('Only ${trip.spotsAvailable} seat(s) available');
    }

    isSubmitting = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      return {
        'seat': randomSeat(),
        'ref': 'ISZ${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'passengerName': nameController.text.trim(),
        'paymentMethod': selectedPayment!,
      };
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    seatsController.dispose();
    phoneController.dispose();
    cardNumberController.dispose();
    cardExpiryController.dispose();
    cardCvvController.dispose();
    super.dispose();
  }
}
