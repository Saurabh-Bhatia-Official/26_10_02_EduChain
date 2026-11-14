import React, { useState } from 'react';
import {
  KeyRound,
  Mail,
  Shield,
  Users,
  GraduationCap,
  Building2,
  AlertCircle,
  CheckCircle2,
  ArrowLeft,
  Send
} from 'lucide-react';
import PortalHeader from '../components/PortalHeader';
import api from '../services/api';

export default function ForgotPasswordPage({ onNavigate, initialRole = 'student' }) {
  const [selectedRole, setSelectedRole] = useState(initialRole);
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  const getBackLoginTarget = () => {
    switch (selectedRole) {
      case 'admin':
        return 'admin-login';
      case 'teacher':
        return 'teacher-login';
      case 'institute':
        return 'institute-login';
      default:
        return 'student-login';
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setSuccessMessage('');

    if (!email.trim() || !email.includes('@')) {
      setErrorMessage('Please enter a valid email address.');
      return;
    }

    try {
      setLoading(true);
      await api.forgotPassword({ email: email.trim(), role: selectedRole });
      setSuccessMessage(
        `Reset link sent! We have emailed instructions to ${email.trim()}. Please check your inbox and spam folder.`
      );
    } catch (err) {
      setErrorMessage(err.message || 'Unable to process reset request. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="portal-page-wrapper">
      <PortalHeader
        onNavigate={onNavigate}
        backTarget={getBackLoginTarget()}
        backLabel="Back to Login"
      />

      <main className="portal-form-container">
        <div className="portal-split-card reset-theme">
          {/* Left badge & summary */}
          <div className="split-brand-panel reset-panel">
            <div className="brand-panel-content">
              <div className="brand-panel-icon-circle reset">
                <KeyRound size={32} />
              </div>

              <h2 className="brand-panel-title">Reset Your Password</h2>
              <p className="brand-panel-desc">
                Get back to your account in a few simple steps. We will verify your identity securely.
              </p>

              <div className="reset-steps-list">
                <div className="reset-step-item">
                  <span className="step-num-badge">1</span>
                  <span>Select your registered portal role</span>
                </div>
                <div className="reset-step-item">
                  <span className="step-num-badge">2</span>
                  <span>Enter your verified email address</span>
                </div>
                <div className="reset-step-item">
                  <span className="step-num-badge">3</span>
                  <span>Receive one-click password reset token</span>
                </div>
              </div>
            </div>
          </div>

          {/* Right form */}
          <div className="split-card-form">
            <div className="form-card-header">
              <h1 className="form-card-title">Forgot Password</h1>
              <p className="form-card-subtitle">
                Enter your email address and we'll send you a link to reset your password.
              </p>
            </div>

            {/* Role selector chips */}
            <div className="reset-role-pills">
              <span className="reset-pills-label">Account role:</span>
              <div className="reset-pills-group">
                <button
                  type="button"
                  className={`reset-role-chip ${selectedRole === 'admin' ? 'active blue' : ''}`}
                  onClick={() => setSelectedRole('admin')}
                >
                  <Shield size={14} /> Admin
                </button>
                <button
                  type="button"
                  className={`reset-role-chip ${selectedRole === 'teacher' ? 'active teal' : ''}`}
                  onClick={() => setSelectedRole('teacher')}
                >
                  <Users size={14} /> Teacher
                </button>
                <button
                  type="button"
                  className={`reset-role-chip ${selectedRole === 'student' ? 'active purple' : ''}`}
                  onClick={() => setSelectedRole('student')}
                >
                  <GraduationCap size={14} /> Student
                </button>
                <button
                  type="button"
                  className={`reset-role-chip ${selectedRole === 'institute' ? 'active navy' : ''}`}
                  onClick={() => setSelectedRole('institute')}
                >
                  <Building2 size={14} /> Institute
                </button>
              </div>
            </div>

            {errorMessage && (
              <div className="auth-alert error" role="alert">
                <AlertCircle size={16} />
                <span>{errorMessage}</span>
              </div>
            )}

            {successMessage && (
              <div className="auth-alert success" role="status">
                <CheckCircle2 size={16} />
                <span>{successMessage}</span>
              </div>
            )}

            <form onSubmit={handleSubmit} className="auth-form-fields">
              <div className="form-group">
                <label className="form-label" htmlFor="reset-email">
                  Email Address <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Mail className="input-icon" size={17} />
                  <input
                    id="reset-email"
                    type="email"
                    placeholder="Enter your email"
                    value={email}
                    onChange={(e) => {
                      setEmail(e.target.value);
                      setErrorMessage('');
                    }}
                    className="form-input"
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                className="btn-primary btn-submit-full"
                disabled={loading}
              >
                {loading ? 'Sending Reset Link...' : (
                  <>
                    <Send size={16} />
                    <span>Send Reset Link</span>
                  </>
                )}
              </button>

              <div className="form-footer-link center">
                <button
                  type="button"
                  className="btn-back-to-login"
                  onClick={() => onNavigate(getBackLoginTarget())}
                >
                  <ArrowLeft size={16} />
                  <span>Return to {selectedRole.charAt(0).toUpperCase() + selectedRole.slice(1)} Login</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </main>
    </div>
  );
}
