"use client";

import React, { useState, useEffect, useCallback, useRef } from 'react';

type AppState = 'enrolling' | 'confirming' | 'success' | 'error';

export default function Enrollment() {
  const [state, setState] = useState<AppState>('enrolling');
  const [qrCode, setQrCode] = useState<string | null>(null);
  const [otp, setOtp] = useState<string[]>(new Array(6).fill(''));
  const [error, setError] = useState<string | null>(null);

  // ==================== RANDOM USER GENERATION START ====================
  // Generates a unique user ID on each component mount
  // Format: user_<timestamp_base36>_<random_string>
  // Example: user_lm5x8k_9a3f2e1d
  const generateRandomUserId = () => {
    const timestamp = Date.now().toString(36);
    const randomStr = Math.random().toString(36).substring(2, 10);
    return `user_${timestamp}_${randomStr}`;
  };
  const [userId] = useState<string>(generateRandomUserId());
  // ==================== RANDOM USER GENERATION END ====================

  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);
  const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080/api';

  // Log API configuration and generated user ID for debugging
  useEffect(() => {
    console.log('API_BASE:', API_BASE);
    console.log('Generated userId:', userId);
  }, [userId]);

  const fetchEnrollment = useCallback(async () => {
    setError(null);
    try {
      const response = await fetch(`${API_BASE}/mfa/enroll`, {
        method: 'POST',
        headers: { 'X-User-Id': userId },
      });
      if (!response.ok) throw new Error('Failed to initialize enrollment');
      const data = await response.json();

      // Log the response to see what field names are returned
      console.log('Enrollment response:', data);

      // Try different possible field names
      const qrCodeData = data.qrCodeBase64 || data.qrCode || data.qr_code || data.qrCodeDataUrl;

      if (qrCodeData) {
        // Check if it already has the data URI prefix
        if (qrCodeData.startsWith('data:image')) {
          setQrCode(qrCodeData);
        } else {
          setQrCode(`data:image/png;base64,${qrCodeData}`);
        }
      } else {
        throw new Error('QR code not found in response');
      }
    } catch (err) {
      console.error('Enrollment error:', err);
      setError('Connection failed. Please refresh to try again.');
      setState('error');
    }
  }, [userId, API_BASE]);

  // Trigger enrollment API call when component mounts
  useEffect(() => {
    fetchEnrollment();
  }, [fetchEnrollment]);


  const handleOtpChange = (value: string, index: number) => {
    // Only allow numbers
    const cleanValue = value.replace(/[^0-9]/g, '');
    if (!cleanValue && value !== '') return;

    const newOtp = [...otp];
    newOtp[index] = cleanValue.substring(cleanValue.length - 1);
    setOtp(newOtp);

    // Auto-focus next input
    if (cleanValue && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>, index: number) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handlePaste = (e: React.ClipboardEvent) => {
    e.preventDefault();
    const data = e.clipboardData.getData('text').replace(/[^0-9]/g, '').slice(0, 6).split('');
    const newOtp = [...otp];
    data.forEach((char, i) => {
      newOtp[i] = char;
    });
    setOtp(newOtp);
    const nextIdx = Math.min(data.length, 5);
    inputRefs.current[nextIdx]?.focus();
  };

  const handleConfirm = async (e: React.FormEvent) => {
    e.preventDefault();
    const code = otp.join('');
    if (code.length !== 6) return;

    setError(null);
    setState('confirming');

    try {
      const response = await fetch(`${API_BASE}/mfa/confirm`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId, code }),
      });

      if (!response.ok) throw new Error('Invalid verification code. Please try again.');
      setState('success');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Verification failed');
      setState('enrolling');
    }
  };

  const isSubmitDisabled = otp.join('').length !== 6 || state === 'confirming' || state === 'success';

  return (
    <div className="app-container">
      <style>{`
        :root {
          --bg-main: #0a0a0a;
          --bg-card: #111111;
          --bg-input: #1a1a1a;
          --border-color: rgba(255, 255, 255, 0.08);
          --text-primary: #ffffff;
          --text-secondary: #94a3b8;
          --accent-color: #6366f1;
          --success-color: #10b981;
          --error-bg: rgba(239, 68, 68, 0.1);
          --error-text: #f87171;
          --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        * {
          box-sizing: border-box;
          margin: 0;
          padding: 0;
        }

        .app-container {
          min-height: 100vh;
          background-color: var(--bg-main);
          color: var(--text-secondary);
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 1.5rem;
          font-family: var(--font-sans);
        }

        .card {
          max-width: 900px;
          width: 100%;
          background-color: var(--bg-card);
          border: 1px solid var(--border-color);
          border-radius: 1.25rem;
          display: flex;
          flex-direction: column;
          overflow: hidden;
          box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.7);
        }

        @media (min-width: 768px) {
          .card { flex-direction: row; }
        }

        .card-left {
          flex: 1;
          padding: 3.5rem;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          background: linear-gradient(145deg, #141414 0%, #0a0a0a 100%);
          border-bottom: 1px solid var(--border-color);
        }

        @media (min-width: 768px) {
          .card-left { 
            border-bottom: none; 
            border-right: 1px solid var(--border-color); 
          }
        }

        .status-badge {
          display: inline-flex;
          align-items: center;
          gap: 0.6rem;
          margin-bottom: 1rem;
          padding: 0.4rem 0.8rem;
          background: rgba(255, 255, 255, 0.03);
          border-radius: 100px;
          border: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .dot {
          width: 6px;
          height: 6px;
          background-color: var(--accent-color);
          border-radius: 50%;
          box-shadow: 0 0 8px var(--accent-color);
          animation: pulse 2s infinite;
        }

        @keyframes pulse {
          0%, 100% { opacity: 1; transform: scale(1); }
          50% { opacity: 0.4; transform: scale(0.9); }
        }

        .badge-text {
          font-size: 10px;
          text-transform: uppercase;
          letter-spacing: 0.15em;
          font-weight: 700;
          color: #64748b;
        }

        .brand-title {
          font-size: 1.75rem;
          font-weight: 700;
          color: var(--text-primary);
          margin-bottom: 2.5rem;
          letter-spacing: -0.02em;
        }

        .qr-wrapper {
          position: relative;
          padding: 1.25rem;
          background: white;
          border-radius: 1rem;
          width: 260px;
          height: 260px;
          display: flex;
          align-items: center;
          justify-content: center;
          box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }

        .qr-image {
          max-width: 100%;
          height: auto;
          image-rendering: pixelated;
        }

        .spinner {
          border: 3px solid #f1f5f9;
          border-top: 3px solid var(--accent-color);
          border-radius: 50%;
          width: 2.5rem;
          height: 2.5rem;
          animation: spin 0.8s linear infinite;
        }

        @keyframes spin { to { transform: rotate(360deg); } }

        .qr-footer {
          margin-top: 2.5rem;
          font-size: 0.8rem;
          text-align: center;
          max-width: 260px;
          line-height: 1.6;
          color: #64748b;
        }

        .card-right {
          flex: 1.2;
          padding: 3.5rem;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }

        .header-section {
          margin-bottom: 2.5rem;
        }

        .section-title {
          font-size: 1.25rem;
          font-weight: 600;
          color: var(--text-primary);
          margin-bottom: 1rem;
        }

        .instruction-list {
          list-style: none;
        }

        .instruction-item {
          display: flex;
          gap: 1rem;
          margin-bottom: 1.25rem;
          font-size: 0.9rem;
          line-height: 1.5;
          color: var(--text-secondary);
        }

        .step-marker {
          flex-shrink: 0;
          width: 22px;
          height: 22px;
          border: 1px solid rgba(255, 255, 255, 0.1);
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 10px;
          font-weight: 700;
          color: #cbd5e1;
          background: rgba(255, 255, 255, 0.02);
        }

        .otp-container {
          display: flex;
          gap: 0.75rem;
          margin-bottom: 2rem;
        }

        .otp-input {
          width: 100%;
          height: 4rem;
          text-align: center;
          font-size: 1.5rem;
          font-weight: 600;
          background-color: var(--bg-input);
          border: 1px solid rgba(255, 255, 255, 0.1);
          border-radius: 0.75rem;
          color: white;
          outline: none;
          transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .otp-input:focus {
          border-color: var(--accent-color);
          background-color: #222;
          box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
        }

        .otp-input:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .error-alert {
          background-color: var(--error-bg);
          border: 1px solid rgba(239, 68, 68, 0.2);
          color: var(--error-text);
          padding: 1rem;
          border-radius: 0.75rem;
          font-size: 0.85rem;
          margin-bottom: 2rem;
          display: flex;
          align-items: center;
          gap: 0.75rem;
        }

        .submit-button {
          width: 100%;
          padding: 1rem;
          background-color: white;
          color: black;
          border: none;
          border-radius: 0.75rem;
          font-size: 1rem;
          font-weight: 600;
          cursor: pointer;
          transition: all 0.2s;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 0.75rem;
        }

        .submit-button:hover:not(:disabled) {
          background-color: #f1f5f9;
          transform: translateY(-1px);
        }

        .submit-button:active:not(:disabled) {
          transform: translateY(0);
        }

        .submit-button:disabled {
          background-color: #1e293b;
          color: #475569;
          cursor: not-allowed;
        }

        .success-panel {
          text-align: center;
          padding: 1rem 0;
          animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1);
        }

        @keyframes slideUp {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }

        .success-circle {
          width: 80px;
          height: 80px;
          background-color: rgba(16, 185, 129, 0.1);
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          margin: 0 auto 2rem;
          color: var(--success-color);
        }

        .footer-tagline {
          position: fixed;
          bottom: 2rem;
          font-size: 10px;
          text-transform: uppercase;
          letter-spacing: 0.2em;
          color: #334155;
          pointer-events: none;
        }
      `}</style>

      <div className="card">
        <div className="card-left">
          <div className="status-badge">
            <div className="dot"></div>
            <span className="badge-text">Encrypted Channel</span>
          </div>
          <h1 className="brand-title">Aegis</h1>

          <div className="qr-wrapper">
            {qrCode ? (
              <img className="qr-image" src={qrCode} alt="MFA QR Code" />
            ) : (
              <div className="spinner"></div>
            )}
          </div>

          <p className="qr-footer">
            Scan this unique QR code with your authenticator app to establish a secure link with your account.
          </p>
        </div>

        <div className="card-right">
          {state === 'success' ? (
            <div className="success-panel">
              <div className="success-circle">
                <svg width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <h2 className="section-title">Activation Successful</h2>
              <p style={{ fontSize: '0.95rem', lineHeight: '1.6' }}>
                Multi-factor authentication is now active on your account. Please ensure you have your recovery codes stored safely.
              </p>
            </div>
          ) : (
            <>
              <div className="header-section">
                <h2 className="section-title">Enable MFA</h2>
                <ul className="instruction-list">
                  <li className="instruction-item">
                    <span className="step-marker">1</span>
                    <span>Open your preferred TOTP app (Google Authenticator, Aegis, Authy, etc).</span>
                  </li>
                  <li className="instruction-item">
                    <span className="step-marker">2</span>
                    <span>Scan the code on the left and enter the 6-digit confirmation key.</span>
                  </li>
                </ul>
              </div>

              <form onSubmit={handleConfirm}>
                <div className="otp-container" onPaste={handlePaste}>
                  {otp.map((digit, idx) => (
                    <input
                      key={idx}
                      ref={(el) => { inputRefs.current[idx] = el; }}
                      type="text"
                      inputMode="numeric"
                      autoComplete="one-time-code"
                      className="otp-input"
                      value={digit}
                      disabled={state === 'confirming'}
                      onChange={(e) => handleOtpChange(e.target.value, idx)}
                      onKeyDown={(e) => handleKeyDown(e, idx)}
                      required
                    />
                  ))}
                </div>

                {error && (
                  <div className="error-alert">
                    <svg width="18" height="18" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
                    </svg>
                    <span>{error}</span>
                  </div>
                )}

                <button type="submit" className="submit-button" disabled={isSubmitDisabled}>
                  {state === 'confirming' ? (
                    <>
                      <div className="spinner" style={{ width: '1.2rem', height: '1.2rem', borderWidth: '2px', borderColor: '#000', borderTopColor: 'transparent' }}></div>
                      <span>Verifying...</span>
                    </>
                  ) : (
                    <span>Confirm Activation</span>
                  )}
                </button>
              </form>
            </>
          )}
        </div>
      </div>

      <div className="footer-tagline">
        Aegis Security Protocol v4.0 &bull; Signal Isolated
      </div>
    </div>
  );
}