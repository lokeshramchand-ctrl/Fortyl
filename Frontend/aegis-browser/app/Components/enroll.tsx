"use client";

import React, { useState, useEffect, useCallback, useRef } from 'react';

type AppState = 'enrolling' | 'confirming' | 'success' | 'error';

export default function App() {
  const [state, setState] = useState<AppState>('enrolling');
  const [qrCode, setQrCode] = useState<string | null>(null);
  const [otp, setOtp] = useState<string[]>(new Array(6).fill(''));
  const [error, setError] = useState<string | null>(null);

  const cardRef = useRef<HTMLDivElement>(null);
  const formRef = useRef<HTMLDivElement>(null);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  // ==================== LOGIC: RANDOM USER GENERATION ====================
  const generateRandomUserId = () => {
    const timestamp = Date.now().toString(36);
    const randomStr = Math.random().toString(36).substring(2, 10);
    return `user_${timestamp}_${randomStr}`;
  };
  const [userId] = useState<string>(generateRandomUserId());
  const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';

  // ==================== ANIMATIONS: ENTRANCE ====================
  useEffect(() => {
    if (cardRef.current) {
      cardRef.current.animate([
        { opacity: 0, transform: 'translateY(40px) scale(0.98)' },
        { opacity: 1, transform: 'translateY(0) scale(1)' }
      ], {
        duration: 1000,
        easing: 'cubic-bezier(0.16, 1, 0.3, 1)',
        fill: 'forwards'
      });
    }
  }, []);

  // ==================== LOGIC: API CALLS ====================
  const fetchEnrollment = useCallback(async () => {
    setError(null);
    try {
      const response = await fetch(`${API_BASE}/mfa/enroll`, {
        method: 'POST',
        headers: { 'X-User-Id': userId },
      });
      if (!response.ok) throw new Error('Failed to initialize enrollment');
      const data = await response.json();
      
      const qrCodeData = data.qrCodeBase64 || data.qrCode || data.qr_code || data.qrCodeDataUrl;

      if (qrCodeData) {
        setQrCode(qrCodeData.startsWith('data:image') ? qrCodeData : `data:image/png;base64,${qrCodeData}`);
      } else {
        throw new Error('QR code not found in response');
      }
    } catch (err) {
      setError('Connection failed. Please refresh the page.');
      setState('error');
    }
  }, [userId, API_BASE]);

  useEffect(() => {
    fetchEnrollment();
  }, [fetchEnrollment]);

  const handleOtpChange = (value: string, index: number) => {
    const cleanValue = value.replace(/[^0-9]/g, '');
    if (!cleanValue && value !== '') return;

    const newOtp = [...otp];
    newOtp[index] = cleanValue.substring(cleanValue.length - 1);
    setOtp(newOtp);

    if (cleanValue && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>, index: number) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
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

      if (!response.ok) throw new Error('Invalid verification code.');
      setState('success');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Verification failed');
      setState('enrolling');
      
      // Error Shake Animation
      if (formRef.current) {
        formRef.current.animate([
          { transform: 'translateX(0)' },
          { transform: 'translateX(-10px)' },
          { transform: 'translateX(10px)' },
          { transform: 'translateX(-10px)' },
          { transform: 'translateX(10px)' },
          { transform: 'translateX(0)' }
        ], { duration: 400, easing: 'ease-in-out' });
      }
    }
  };

  const isSubmitDisabled = otp.join('').length !== 6 || state === 'confirming' || state === 'success';

  return (
    <div className="aegis-root">
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
      
      <style>{`
        .aegis-root {
          --apple-bg: #F5F5F7;
          --apple-text: #1D1D1F;
          --apple-grey: #86868B;
          --apple-blue: #0071E3;
          --glass-bg: rgba(255, 255, 255, 0.7);
          
          min-height: 100vh;
          background-color: var(--apple-bg);
          color: var(--apple-text);
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 24px;
          font-family: 'Inter', -apple-system, sans-serif;
          -webkit-font-smoothing: antialiased;
        }

        .aegis-card {
          max-width: 1000px;
          width: 100%;
          background: var(--glass-bg);
          backdrop-filter: blur(40px) saturate(180%);
          -webkit-backdrop-filter: blur(40px) saturate(180%);
          border-radius: 44px;
          border: 1px solid rgba(255, 255, 255, 0.4);
          box-shadow: 0 40px 100px -20px rgba(0, 0, 0, 0.08);
          display: flex;
          flex-direction: column;
          overflow: hidden;
          opacity: 0; /* Start hidden for JS animation */
        }

        @media (min-width: 768px) {
          .aegis-card { flex-direction: row; }
        }

        .aegis-left {
          flex: 1;
          background: rgba(250, 250, 251, 0.5);
          padding: 64px;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          position: relative;
          border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }

        @media (min-width: 768px) {
          .aegis-left { border-bottom: none; border-right: 1px solid rgba(0, 0, 0, 0.05); }
        }

        .secure-badge {
          position: absolute;
          top: 40px;
          left: 40px;
          display: flex;
          align-items: center;
          gap: 10px;
        }

        .pulse-dot {
          width: 8px;
          height: 8px;
          background: var(--apple-blue);
          border-radius: 50%;
          box-shadow: 0 0 10px rgba(0, 113, 227, 0.4);
          animation: apple-pulse 2s infinite;
        }

        @keyframes apple-pulse {
          0% { transform: scale(1); opacity: 1; }
          50% { transform: scale(1.2); opacity: 0.5; }
          100% { transform: scale(1); opacity: 1; }
        }

        .badge-label {
          font-size: 11px;
          font-weight: 700;
          text-transform: uppercase;
          letter-spacing: 0.2em;
          color: var(--apple-grey);
        }

        .qr-frame {
          background: white;
          padding: 40px;
          border-radius: 40px;
          box-shadow: 0 20px 40px -10px rgba(0,0,0,0.05);
          transition: transform 0.6s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .qr-frame:hover { transform: scale(1.02); }

        .qr-img {
          width: 220px;
          height: 220px;
          object-fit: contain;
          animation: fadeIn 1s ease-out;
        }

        .aegis-right {
          flex: 1.3;
          padding: 64px;
          display: flex;
          flex-direction: column;
          justify-content: center;
          background: rgba(255, 255, 255, 0.3);
        }

        .title {
          font-size: 48px;
          font-weight: 700;
          letter-spacing: -0.03em;
          margin-bottom: 8px;
        }

        .subtitle {
          color: var(--apple-grey);
          font-size: 20px;
          font-weight: 500;
          margin-bottom: 48px;
        }

        .instruction-step {
          display: flex;
          gap: 20px;
          margin-bottom: 24px;
        }

        .step-num {
          width: 28px;
          height: 28px;
          background: #F5F5F7;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 12px;
          font-weight: 700;
          flex-shrink: 0;
        }

        .step-text {
          font-size: 15px;
          line-height: 1.5;
          color: #424245;
          font-weight: 500;
        }

        .otp-grid {
          display: flex;
          gap: 12px;
          margin: 40px 0;
        }

        .otp-cell {
          width: 100%;
          height: 72px;
          background: #F5F5F7;
          border: 2px solid transparent;
          border-radius: 20px;
          text-align: center;
          font-size: 28px;
          font-weight: 700;
          color: var(--apple-text);
          outline: none;
          transition: all 0.2s ease;
        }

        .otp-cell:focus {
          background: white;
          border-color: var(--apple-blue);
          box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.1);
        }

        .btn-primary {
          width: 100%;
          height: 64px;
          background: var(--apple-blue);
          color: white;
          border: none;
          border-radius: 32px;
          font-size: 17px;
          font-weight: 600;
          cursor: pointer;
          transition: all 0.3s ease;
          box-shadow: 0 10px 20px -5px rgba(0, 113, 227, 0.3);
        }

        .btn-primary:hover:not(:disabled) {
          background: #0077ED;
          transform: translateY(-1px);
        }

        .btn-primary:active:not(:disabled) {
          transform: scale(0.98);
        }

        .btn-primary:disabled {
          opacity: 0.3;
          cursor: not-allowed;
          filter: grayscale(1);
        }

        .error-msg {
          background: #FFF1F0;
          border: 1px solid #FFCCC7;
          color: #E02020;
          padding: 16px;
          border-radius: 20px;
          font-size: 14px;
          font-weight: 600;
          margin-bottom: 24px;
          display: flex;
          align-items: center;
          gap: 10px;
          animation: fadeIn 0.3s ease;
        }

        .loader {
          width: 20px;
          height: 20px;
          border: 3px solid rgba(255,255,255,0.3);
          border-top-color: white;
          border-radius: 50%;
          animation: spin 0.8s linear infinite;
        }

        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        .success-view {
          text-align: center;
          animation: fadeIn 0.8s ease;
        }

        .success-icon {
          width: 96px;
          height: 96px;
          background: #E8F5E9;
          color: #2E7D32;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          margin: 0 auto 32px;
        }
      `}</style>

      <div ref={cardRef} className="aegis-card">
        {/* Left Visuals */}
        <div className="aegis-left">
          <div className="secure-badge">
            <div className="pulse-dot"></div>
            <span className="badge-label">Aegis Secure</span>
          </div>

          <div className="qr-frame">
            {qrCode ? (
              <img className="qr-img" src={qrCode} alt="MFA QR Code" />
            ) : (
              <div style={{ width: 220, height: 220, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <div className="loader" style={{ borderColor: '#E5E5E5', borderTopColor: '#0071E3' }}></div>
              </div>
            )}
          </div>

          <p style={{ marginTop: 40, color: 'var(--apple-grey)', fontSize: 13, textAlign: 'center', maxWidth: 240, lineHeight: 1.6 }}>
            Scan this secure key to link your physical device with your identity.
          </p>
        </div>

        {/* Right Interaction */}
        <div className="aegis-right">
          {state === 'success' ? (
            <div className="success-view">
              <div className="success-icon">
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                  <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
              </div>
              <h2 className="title" style={{ fontSize: 32 }}>Securely Linked</h2>
              <p className="subtitle" style={{ fontSize: 17 }}>Your identity is now fortified with 2FA.</p>
              <button className="btn-primary" style={{ background: '#1D1D1F', marginTop: 24 }} onClick={() => window.location.reload()}>
                Continue
              </button>
            </div>
          ) : (
            <>
              <h1 className="title">Sign In.</h1>
              <p className="subtitle">Verify your identity.</p>

              <div className="instruction-step">
                <div className="step-num">1</div>
                <p className="step-text">Open your preferred TOTP app (Authenticator, Aegis, or Authy).</p>
              </div>
              <div className="instruction-step">
                <div className="step-num">2</div>
                <p className="step-text">Scan the QR code and enter the 6-digit confirmation key.</p>
              </div>

              <form onSubmit={handleConfirm}>
                <div className="otp-grid">
                  {otp.map((digit, idx) => (
                    <input
                      key={idx}
                      ref={(el) => { inputRefs.current[idx] = el; }}
                      type="text"
                      inputMode="numeric"
                      className="otp-cell"
                      value={digit}
                      disabled={state === 'confirming'}
                      onChange={(e) => handleOtpChange(e.target.value, idx)}
                      onKeyDown={(e) => handleKeyDown(e, idx)}
                      required
                    />
                  ))}
                </div>

                {error && (
                  <div className="error-msg" ref={formRef}>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                      <circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line>
                    </svg>
                    {error}
                  </div>
                )}

                <button type="submit" className="btn-primary" disabled={isSubmitDisabled}>
                  {state === 'confirming' ? <div className="loader" style={{ margin: '0 auto' }}></div> : 'Complete Activation'}
                </button>
              </form>
            </>
          )}
        </div>
      </div>

      <div style={{ position: 'fixed', bottom: 32, fontSize: 11, fontWeight: 700, color: 'var(--apple-grey)', letterSpacing: '0.4em', textTransform: 'uppercase', pointerEvents: 'none', opacity: 0.5 }}>
        Aegis Security Protocol v4.0
      </div>
    </div>
  );
}