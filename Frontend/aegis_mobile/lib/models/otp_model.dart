class OtpAccount {
  final String label;
  final String account;
  final String secret;

  OtpAccount({
    required this.label,
    required this.account,
    required this.secret,
  });

  factory OtpAccount.fromOtpAuthUri(String raw) {
    final uri = Uri.parse(raw);

    // 1️⃣ Validate scheme (case-insensitive)
    if (uri.scheme.toLowerCase() != 'otpauth') {
      throw FormatException('Not an OTP auth URI');
    }

    // 2️⃣ Validate type (totp or hotp)
    final type = uri.host.toLowerCase();
    if (type != 'totp' && type != 'hotp') {
      throw FormatException('Unsupported OTP type');
    }

    // 3️⃣ Decode label safely
    final decodedPath = Uri.decodeComponent(
      uri.path.startsWith('/') ? uri.path.substring(1) : uri.path,
    );

    String issuerFromPath = '';
    String accountName = decodedPath;

    if (decodedPath.contains(':')) {
      final parts = decodedPath.split(':');
      issuerFromPath = parts.first;
      accountName = parts.sublist(1).join(':');
    }

    // 4️⃣ Extract query params
    final qp = uri.queryParameters;

    final secretRaw = qp['secret'];
    if (secretRaw == null || secretRaw.isEmpty) {
      throw FormatException('Missing secret');
    }

    // Normalize secret (Google Authenticator tolerant)
    final secret = secretRaw
        .replaceAll(' ', '')
        .toUpperCase();

    // Issuer priority:
    // query param > path > fallback
    final label = qp['issuer']?.isNotEmpty == true
        ? qp['issuer']!
        : issuerFromPath.isNotEmpty
            ? issuerFromPath
            : 'Unknown';

    return OtpAccount(
      label: label,
      account: accountName.isNotEmpty ? accountName : 'Account',
      secret: secret,
    );
  }
}
