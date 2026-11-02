import React, { useState } from 'react';
import {
  GraduationCap,
  Mail,
  Lock,
  Eye,
  EyeOff,
  AlertCircle,
  CheckCircle2,
  Shield,
  Users
} from 'lucide-react';
import PortalHeader from '../components/PortalHeader';
import StudentIllustration from '../components/illustrations/StudentIllustration';
import api from '../services/api';

export default function StudentLoginPage({ onNavigate, onLoginSuccess }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  const handleDemoFill = () => {
    setEmail('rahul@institute.com');
    setPassword('password123');
    setErrorMessage('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setSuccessMessage('');

    if (!email.trim() || !email.includes('@')) {
      setErrorMessage('Please enter a valid student email address.');
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
        role: 'student',
      });

      const studentUser = res?.user || {
        id: 'std_1023',
        email: email.trim(),
        role: 'student',
        name: 'Rahul Sharma',
        rollNumber: '1023',
        className: 'BCA - Sem 3',
        course: 'Bachelor of Computer Applications',
        semester: 'Semester 3',
        instituteCode: 'INST-2025',
        instituteName: 'Apex Institute of Technology',
      };

      if (onLoginSuccess) {
        onLoginSuccess(studentUser);
      }
      onNavigate('student-dashboard');
    } catch (err) {
      setErrorMessage(err.message || 'Login failed. Please verify student credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="portal-page-wrapper">
      <PortalHeader onNavigate={onNavigate} backTarget="select-role" backLabel="Back to Home" />

      <main className="portal-form-container wide">
        <div className="portal-split-card student-theme">
          {/* Left Panel: Vibrant Purple with Graduation Cap & Student Illustration */}
          <div className="split-brand-panel student-panel">
            <div className="brand-panel-content">
              <div className="brand-panel-icon-circle student">
                <GraduationCap size={32} />
              </div>

              <h2 className="brand-panel-title">Student Login</h2>
              <p className="brand-panel-desc">
                Access your student dashboard and view your progress.
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
                    onClick={() => onNavigate('teacher-login')}
                    title="Switch to Teacher Login"
                  >
                    <Users size={13} /> Teacher
                  </button>
                </div>
              </div>

              {/* Student Graphic */}
              <div className="brand-panel-graphic">
                <StudentIllustration />
              </div>
            </div>
          </div>

          {/* Right Panel: Login Form */}
          <div className="split-card-form">
            <div className="form-card-header">
              <h1 className="form-card-title">Login to Your Account</h1>
              <p className="form-card-subtitle">
                Enter your student credentials.
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

            <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '10px' }}>
              <button
                type="button"
                onClick={handleDemoFill}
                style={{
                  background: '#f3e8ff',
                  color: '#7c3aed',
                  border: '1px solid #d8b4fe',
                  borderRadius: '6px',
                  padding: '4px 10px',
                  fontSize: '0.78rem',
                  fontWeight: '600',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px'
                }}
              >
                <span>Demo Fill: Rahul Sharma (BCA - Sem 3)</span>
              </button>
            </div>

            <form onSubmit={handleSubmit} className="auth-form-fields">
              {/* Email Address */}
              <div className="form-group">
                <label className="form-label" htmlFor="student-email">
                  Email Address <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Mail className="input-icon" size={17} />
                  <input
                    id="student-email"
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
                <label className="form-label" htmlFor="student-password">
                  Password <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Lock className="input-icon" size={17} />
                  <input
                    id="student-password"
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
                  onClick={() => onNavigate('forgot-password', { role: 'student' })}
                >
                  Forgot password?
                </button>
              </div>

              {/* Login Button */}
              <button
                type="submit"
                className="btn-primary btn-submit-full purple-btn"
                disabled={loading}
              >
                {loading ? 'Authenticating Student...' : 'Login'}
              </button>

              {/* Footer Links */}
              <div className="form-footer-link center">
                <span>Don't have an account? </span>
                <button
                  type="button"
                  className="link-accent-btn purple"
                  onClick={() => onNavigate('student-register')}
                >
                  Register as Student
                </button>
              </div>
            </form>
          </div>
        </div>
      </main>
    </div>
  );
}
