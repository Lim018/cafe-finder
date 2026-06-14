import 'dart:io';
import 'package:flutter/services.dart';

class ExceptionHandler {
  /// Translates raw exceptions into user-friendly, human-readable error messages.
  static String getMessage(dynamic exception) {
    if (exception is SocketException) {
      return 'Please check your internet connection and try again.';
    } else if (exception is HttpException) {
      return 'We are having trouble reaching our servers. Please try again later.';
    } else if (exception is FormatException) {
      return 'There was a problem processing the data. Please ensure your app is up to date.';
    } else if (exception is TimeoutException) {
      return 'The connection timed out. Please try again.';
    } else if (exception is ServerException) {
      return exception.message;
    } else if (exception is PlatformException) {
      return exception.message ?? 'A platform specific error occurred.';
    } else {
      // Catch-all for unknown exceptions
      return 'An unexpected error occurred. Our team has been notified. Please try again later.';
    }
  }
}

// Custom Exceptions

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Connection timeout']);
  
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final int statusCode;
  final String message;

  ServerException({required this.statusCode, required this.message});
  
  @override
  String toString() => message;
}
