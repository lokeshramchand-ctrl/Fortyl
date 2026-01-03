class OtpAccount {
  final String label;
  final String account;
  final String secret;

  OtpAccount({
    required this.label,
    required this.account,
    required this.secret,
  });

  /// Parse otpauth://totp URI
  factory OtpAccount.fromOtpAuthUri(String uri) {
    final parsed = Uri.parse(uri);

    if (parsed.scheme != 'otpauth') {
      throw Exception('Invalid OTP URI');
    }

    final labelPart = parsed.path.replaceFirst('/', '');
    final parts = labelPart.split(':');

    final label = parts.first;
    final account = parts.length > 1 ? parts[1] : '';

    final secret = parsed.queryParameters['secret'];
    if (secret == null) {
      throw Exception('Secret not found');
    }

    return OtpAccount(
      label: label,
      account: account,
      secret: secret,
    );
  }
}
