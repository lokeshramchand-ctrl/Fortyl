"use client";

import React, { useState, useEffect, useRef } from 'react';

type AppState = 'idle' | 'verifying' | 'success';

export default function Verify() {
  const [state, setState] = useState<AppState>('idle');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [otp, setOtp] = useState<string[]>(new Array(6).fill(''));
  const [error, setError] = useState<string | null>(null);

  // Generate a random userId for the session (required by the backend DTO)
  const generateRandomUserId = () => {
    const timestamp = Date.now().toString(36);
    const randomStr = Math.random().toString(36).substring(2, 10);
    return `user_${timestamp}_${randomStr}`;
  };
  const [userId] = useState<string>(generateRandomUserId());

  const cardRef = useRef<HTMLDivElement>(null);
  const formRef = useRef<HTMLDivElement>(null);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

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

  // ==================== LOGIC: OTP HANDLING ====================
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

  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    const code = otp.join('');
    
    if (code.length !== 6) {
      setError("Please enter the 6-digit verification code.");
      return;
    }

    setError(null);
    setState('verifying');

    try {
      // Connects to: @PostMapping("/verify") 
      // Sends: MfaConfirmRequest(String userId, String code)
      const response = await fetch(`${API_BASE}/mfa/verify`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          userId: userId, 
          code: code 
        }),
      });

      if (!response.ok) throw new Error('Authentication failed. Verify token.');
      
      // Handle response string "MFA verified"
      setState('success');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Verification failed');
      setState('idle');
      
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

  const isSubmitDisabled = state === 'verifying' || state === 'success';

  return (
    <div className="aegis-root">
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
      
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
          max-width: 1100px;
          width: 100%;
          background: var(--glass-bg);
          backdrop-filter: blur(50px) saturate(210%);
          -webkit-backdrop-filter: blur(50px) saturate(210%);
          border-radius: 48px;
          border: 1px solid rgba(255, 255, 255, 0.4);
          box-shadow: 0 40px 100px -20px rgba(0, 0, 0, 0.08);
          display: flex;
          flex-direction: column;
          overflow: hidden;
          opacity: 0;
          min-height: 600px;
          position: relative;
        }

        @media (min-width: 900px) {
          .aegis-card { flex-direction: row; }
        }

        .aegis-left {
          flex: 1;
          padding: 72px;
          display: flex;
          flex-direction: column;
          justify-content: center;
          background: rgba(250, 250, 251, 0.5);
          border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }

        @media (min-width: 900px) {
          .aegis-left { border-bottom: none; border-right: 1px solid rgba(0, 0, 0, 0.05); }
        }

        .aegis-right {
          flex: 1.1;
          padding: 72px;
          display: flex;
          flex-direction: column;
          justify-content: center;
          background: rgba(255, 255, 255, 0.3);
        }

        .title {
          font-size: 48px;
          font-weight: 800;
          letter-spacing: -2.5px;
          margin-bottom: 8px;
          color: var(--apple-text);
        }

        .subtitle {
          color: var(--apple-grey);
          font-size: 17px;
          font-weight: 500;
          margin-bottom: 48px;
          letter-spacing: -0.2px;
        }

        .input-group {
          margin-bottom: 24px;
        }

        .input-label {
          display: block;
          font-size: 11px;
          font-weight: 700;
          text-transform: uppercase;
          letter-spacing: 1.2px;
          color: var(--apple-grey);
          margin-bottom: 10px;
        }

        .apple-input {
          width: 100%;
          height: 56px;
          background: #F5F5F7;
          border: 1px solid transparent;
          border-radius: 16px;
          padding: 0 20px;
          color: var(--apple-text);
          font-size: 16px;
          font-weight: 500;
          outline: none;
          transition: all 0.2s ease;
        }

        .apple-input:focus {
          background: white;
          border-color: var(--apple-blue);
          box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.1);
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
          transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
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
          width: 24px;
          height: 24px;
          border: 3px solid rgba(255,255,255,0.3);
          border-top-color: white;
          border-radius: 50%;
          animation: spin 0.8s linear infinite;
        }

        @keyframes spin { to { transform: rotate(360deg); } }
        
        .fade-in { animation: fadeIn 0.8s ease-out forwards; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }

        .success-overlay {
          position: absolute;
          inset: 0;
          background: white;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          z-index: 100;
          animation: fadeIn 0.5s ease;
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
          margin-bottom: 32px;
        }
      `}</style>

      <div ref={cardRef} className="aegis-card">
        {state === 'success' && (
          <div className="success-overlay">
            <div className="success-icon">
              <svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                <polyline points="20 6 9 17 4 12" />
              </svg>
            </div>
            <h1 className="title">Success</h1>
            <p className="subtitle">Authorized access to secure enclave.</p>
            <button 
              className="btn-primary" 
              style={{ width: '220px', background: '#1D1D1F' }} 
              onClick={() => window.location.reload()}
            >
              Continue
            </button>
          </div>
        )}

        <form onSubmit={handleVerify} style={{ display: 'contents' }}>
          {/* Left Panel: UI only credentials */}
          <div className="aegis-left fade-in">
            <h1 className="title">Sign In.</h1>
            <p className="subtitle">Enter your vault credentials.</p>
            
            <div className="input-group">
              <label className="input-label">Identity</label>
              <input 
                type="email" 
                className="apple-input" 
                placeholder="Email Address" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
            <div className="input-group">
              <label className="input-label">Passkey</label>
              <input 
                type="password" 
                className="apple-input" 
                placeholder="Secret Password" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
          </div>

          {/* Right Panel: Functional MFA Verification */}
          <div className="aegis-right fade-in" ref={formRef}>
            <h1 className="title">Verify.</h1>
            <p className="subtitle">Confirm the 6-digit MFA token.</p>

            <div className="otp-grid">
              {otp.map((digit, idx) => (
                <input
                  key={idx}
                  ref={(el) => { inputRefs.current[idx] = el; }}
                  type="text"
                  inputMode="numeric"
                  className="otp-cell"
                  value={digit}
                  disabled={state === 'verifying'}
                  onChange={(e) => handleOtpChange(e.target.value, idx)}
                  onKeyDown={(e) => handleKeyDown(e, idx)}
                  required
                />
              ))}
            </div>

            {error && (
              <div className="error-msg">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                  <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                {error}
              </div>
            )}

            <button type="submit" className="btn-primary" disabled={isSubmitDisabled}>
              {state === 'verifying' ? <div className="loader" style={{ margin: '0 auto' }}></div> : 'Unlock Vault'}
            </button>
          </div>
        </form>
      </div>

    </div>
  );
}