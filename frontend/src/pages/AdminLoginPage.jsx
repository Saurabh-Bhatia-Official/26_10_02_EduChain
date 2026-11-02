import React, { useState } from 'react';
import {
  Shield,
  Mail,
  Lock,
  Eye,
  EyeOff,
  AlertCircle,
  CheckCircle2,
  Building2,
  Users,
  GraduationCap
} from 'lucide-react';
import PortalHeader from '../components/PortalHeader';
import InstituteBuildingIllustration from '../components/illustrations/InstituteBuildingIllustration';
import api from '../services/api';

export default function AdminLoginPage({ onNavigate, onLoginSuccess }) {
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
      setErrorMessage('Please enter a valid admin email address.');
      return;
    }
    if (!password) {
      setErrorMessage('Please enter your admin password.');
      return;
    }

    try {
      setLoading(true);
      const res = await api.loginRole({
        email: email.trim(),
        password,
        role: 'admin',
      });

      const adminUser = res?.user;
      if (!adminUser) {
        throw new Error(res?.message || 'Admin login failed: Account details not found in database.');
      }

      setSuccessMessage('Admin authentication successful! Opening dashboard...');

      if (onLoginSuccess) {
        onLoginSuccess(adminUser);
      }

      setTimeout(() => {
        onNavigate('admin-dashboard');
      }, 1200);
    } catch (err) {
      setErrorMessage(err.message || 'Login failed. Please verify admin credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="portal-page-wrapper">
      <PortalHeader onNavigate={onNavigate} backTarget="select-role" backLabel="Back to Home" />

      <main className="portal-form-container wide">
        <div className="portal-split-card admin-theme">
          {/* Left Panel: Deep Blue with Shield and Building illustration */}
          <div className="split-brand-panel admin-panel">
            <div className="brand-panel-content">
              <div className="brand-panel-icon-circle admin">
                <Shield size={32} />
              </div>

              <h2 className="brand-panel-title">Admin Login</h2>
              <p className="brand-panel-desc">
                Access your admin dashboard and manage your institute.
              </p>

              {/* Role switcher inside panel */}
              <div className="panel-role-switcher">
                <span className="panel-switch-label">Switch role:</span>
                <div className="panel-switch-buttons">
                  <button
                    type="button"
                    className="panel-role-pill"
                    onClick={() => onNavigate('teacher-login')}
                    title="Switch to Teacher Login"
                  >
                    <Users size={13} /> Teacher
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

              {/* Institute Building Graphic */}
              <div className="brand-panel-graphic">
                <InstituteBuildingIllustration variant="compact" />
              </div>
            </div>
          </div>

          {/* Right Panel: Login Form */}
          <div className="split-card-form">
            <div className="form-card-header">
              <h1 className="form-card-title">Login to Your Account</h1>
              <p className="form-card-subtitle">
                Enter your admin credentials.
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
                <label className="form-label" htmlFor="admin-email">
                  Email Address <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Mail className="input-icon" size={17} />
                  <input
                    id="admin-email"
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
                <label className="form-label" htmlFor="admin-password">
                  Password <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Lock className="input-icon" size={17} />
                  <input
                    id="admin-password"
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
                  onClick={() => onNavigate('forgot-password', { role: 'admin' })}
                >
                  Forgot password?
                </button>
              </div>

              {/* Login Button */}
              <button
                type="submit"
                className="btn-primary btn-submit-full"
                disabled={loading}
              >
                {loading ? 'Authenticating Admin...' : 'Login'}
              </button>

              {/* Footer Links */}
              <div className="form-footer-link center">
                <span>Don't have an account? </span>
                <button
                  type="button"
                  className="link-accent-btn"
                  onClick={() => onNavigate('institute-register')}
                >
                  Register your Institute
                </button>
              </div>

              <div className="form-secondary-link center">
                <span>Need to access central portal? </span>
                <button
                  type="button"
                  className="link-subtle-btn"
                  onClick={() => onNavigate('institute-login')}
                >
                  Institute Login
                </button>
              </div>
            </form>
          </div>
        </div>
      </main>
    </div>
  );
}
