import React, { useState } from 'react';
import {
  Users,
  Mail,
  Lock,
  Eye,
  EyeOff,
  AlertCircle,
  CheckCircle2,
  Shield,
  GraduationCap,
  Sparkles
} from 'lucide-react';
import PortalHeader from '../components/PortalHeader';
import TeacherIllustration from '../components/illustrations/TeacherIllustration';
import api from '../services/api';

export default function TeacherLoginPage({ onNavigate, onLoginSuccess }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setSuccessMessage('');

    if (!email.trim() || !email.includes('@')) {
      setErrorMessage('Please enter a valid teacher email address.');
      return;
    }
    if (!password) {
      setErrorMessage('Please enter your password.');
      return;
    }

    try {
      setLoading(true);
      const res = await api.loginRole({
        email: email.trim(),
        password,
        role: 'teacher',
      });

      const teacherUser = res?.user;
      if (!teacherUser) {
        throw new Error(res?.message || 'Teacher login failed: Account details not found in database.');
      }

      setSuccessMessage('Teacher authentication successful! Opening instructor dashboard...');

      if (onLoginSuccess) {
        onLoginSuccess(teacherUser);
      }

      setTimeout(() => {
        onNavigate('teacher-dashboard');
      }, 900);
    } catch (err) {
      setErrorMessage(err.message || 'Login failed. Please verify teacher credentials.');
    } finally {
      setLoading(false);
    }
  };

  const handleQuickDemoLogin = async () => {
    setEmail('amit.sharma@institute.com');
    setPassword('teacher123');
    setErrorMessage('');
    setSuccessMessage('Authenticating as Dr. Amit Sharma (Instructor)...');
    try {
      setLoading(true);
      const res = await api.loginRole({
        email: 'amit.sharma@institute.com',
        password: 'password123',
        role: 'teacher',
      });
      const teacherUser = res?.user;
      if (!teacherUser) {
        throw new Error(res?.message || 'Instructor account not found in database.');
      }
      if (onLoginSuccess) {
        onLoginSuccess(teacherUser);
      }
      setTimeout(() => {
        onNavigate('teacher-dashboard');
      }, 700);
    } catch (err) {
      setErrorMessage(err.message || 'Quick login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="portal-page-wrapper">
      <PortalHeader onNavigate={onNavigate} backTarget="select-role" backLabel="Back to Home" />

      <main className="portal-form-container wide">
        <div className="portal-split-card teacher-theme">
          {/* Left Panel: Deep Teal/Green with Teacher illustration */}
          <div className="split-brand-panel teacher-panel">
            <div className="brand-panel-content">
              <div className="brand-panel-icon-circle teacher">
                <Users size={32} />
              </div>

              <h2 className="brand-panel-title">Teacher Login</h2>
              <p className="brand-panel-desc">
                Access your teacher dashboard and manage your classes.
              </p>

              {/* Role switcher inside panel */}
              <div className="panel-role-switcher">
                <span className="panel-switch-label">Switch role:</span>
                <div className="panel-switch-buttons">
                  <button
                    type="button"
                    className="panel-role-pill"
                    onClick={() => onNavigate('admin-login')}
                    title="Switch to Admin Login"
                  >
                    <Shield size={13} /> Admin
                  </button>
                  <button
                    type="button"
                    className="panel-role-pill"
                    onClick={() => onNavigate('student-login')}
                    title="Switch to Student Login"
                  >
                    <GraduationCap size={13} /> Student
                  </button>
                </div>
              </div>

              {/* Teacher Graphic */}
              <div className="brand-panel-graphic">
                <TeacherIllustration />
              </div>
            </div>
          </div>

          {/* Right Panel: Login Form */}
          <div className="split-card-form">
            <div className="form-card-header">
              <h1 className="form-card-title">Login to Your Account</h1>
              <p className="form-card-subtitle">
                Enter your teacher credentials.
              </p>
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
              {/* Email Address */}
              <div className="form-group">
                <label className="form-label" htmlFor="teacher-email">
                  Email Address <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Mail className="input-icon" size={17} />
                  <input
                    id="teacher-email"
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

              {/* Password */}
              <div className="form-group">
                <label className="form-label" htmlFor="teacher-password">
                  Password <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Lock className="input-icon" size={17} />
                  <input
                    id="teacher-password"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="Enter password"
                    value={password}
                    onChange={(e) => {
                      setPassword(e.target.value);
                      setErrorMessage('');
                    }}
                    className="form-input"
                    required
                  />
                  <button
                    type="button"
                    className="input-action-btn"
                    onClick={() => setShowPassword(!showPassword)}
                    aria-label="Toggle password visibility"
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              {/* Remember Me & Forgot Password */}
              <div className="form-aux-row">
                <label className="checkbox-container">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                  />
                  <span className="checkbox-label-text">Remember me</span>
                </label>

                <button
                  type="button"
                  className="link-subtle-btn"
                  onClick={() => onNavigate('forgot-password', { role: 'teacher' })}
                >
                  Forgot password?
                </button>
              </div>

              {/* Login Button */}
              <button
                type="submit"
                className="btn-primary btn-submit-full teal-btn"
                disabled={loading}
              >
                {loading ? 'Authenticating Teacher...' : 'Login'}
              </button>

              {/* 1-Click Instant Demo Login */}
              <button
                type="button"
                className="btn-quick-unlock-subtle"
                style={{
                  width: '100%',
                  marginTop: '10px',
                  padding: '9px 12px',
                  borderRadius: '8px',
                  border: '1px dashed #0284c7',
                  background: '#f0f9ff',
                  color: '#0369a1',
                  fontWeight: '600',
                  fontSize: '0.825rem',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  cursor: 'pointer'
                }}
                onClick={handleQuickDemoLogin}
                disabled={loading}
              >
                <Sparkles size={15} color="#0284c7" />
                <span>1-Click Demo Login (Dr. Amit Sharma)</span>
              </button>

              {/* Footer Links */}
              <div className="form-footer-link center">
                <span>Don't have an account? </span>
                <button
                  type="button"
                  className="link-accent-btn teal"
                  onClick={() => onNavigate('teacher-register')}
                >
                  Register as Teacher
                </button>
              </div>
            </form>
          </div>
        </div>
      </main>
    </div>
  );
}
