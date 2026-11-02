import React, { useState } from 'react';
import {
  Building2,
  Mail,
  Lock,
  Eye,
  EyeOff,
  Hash,
  Shield,
  Users,
  GraduationCap,
  AlertCircle,
  CheckCircle2,
  ArrowRight,
  Sparkles,
  Zap,
  Check,
  ShieldCheck
} from 'lucide-react';
import PortalHeader from '../components/PortalHeader';
import InstituteBuildingIllustration from '../components/illustrations/InstituteBuildingIllustration';
import api from '../services/api';

export default function InstituteLoginPage({ onNavigate, onLoginSuccess }) {
  const [instituteCode, setInstituteCode] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const [autoFilled, setAutoFilled] = useState(false);

  const handleDemoFill = () => {
    setInstituteCode('INST-2025');
    setEmail('admin@apex.edu');
    setPassword('password123');
    setAutoFilled(true);
    setErrorMessage('');
    setTimeout(() => setAutoFilled(false), 2200);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setSuccessMessage('');

    if (!instituteCode.trim()) {
      setErrorMessage('Please enter your Institute Code / ID.');
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      setErrorMessage('Please enter a valid administrator email address.');
      return;
    }
    if (!password) {
      setErrorMessage('Please enter your password.');
      return;
    }

    try {
      setLoading(true);
      const res = await api.loginInstitute({
        instituteCode: instituteCode.trim(),
        email: email.trim(),
        password,
      });

      const instUser = res?.user;
      if (!instUser) {
        throw new Error(res?.message || 'Institute login failed: Institute not found in database.');
      }

      setSuccessMessage('Institute verified! Opening Institute Portal...');

      if (onLoginSuccess) {
        onLoginSuccess(instUser);
      } else {
        setTimeout(() => {
          onNavigate('institute-home');
        }, 1000);
      }
    } catch (err) {
      setErrorMessage(err.message || 'Login failed. Please verify institute credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="portal-page-wrapper creative-inst-login-wrapper">
      <PortalHeader onNavigate={onNavigate} backTarget="home" backLabel="Back to Home" />

      <main className="creative-inst-login-container">
        <div className="creative-inst-login-card">
          {/* LEFT: Midnight-cyan campus showcase (matches Role Hub) */}
          <div className="creative-inst-left-panel">
            <div className="panel-glow-pattern" />

            <div className="panel-top-badges">
              <span className="inst-badge-pill cyan">
                <ShieldCheck size={13} />
                <span>Verified Academic Network</span>
              </span>
              <span className="inst-badge-pill green">
                <span>● Live Secure Gateway</span>
              </span>
            </div>

            <div className="panel-identity-row">
              <div className="panel-avatar-box">
                <Building2 size={28} />
                <span className="live-indicator-dot" title="Portal Online" />
              </div>
              <div className="panel-headings">
                <h1 className="panel-main-title">
                  Institute Portal
                </h1>
                <p className="panel-description">
                  Authenticate your campus to unlock Admin, Teacher, and Student role gateways.
                </p>
              </div>
            </div>

            <div className="panel-building-graphic">
              <InstituteBuildingIllustration variant="compact" />
            </div>

            <div className="panel-metrics-strip">
              <div className="panel-metric-box">
                <span className="p-metric-val">2,500+</span>
                <span className="p-metric-lbl">Partner Campuses</span>
              </div>
              <div className="p-metric-divider" />
              <div className="panel-metric-box">
                <span className="p-metric-val">1.4M+</span>
                <span className="p-metric-lbl">Verified Learners</span>
              </div>
              <div className="p-metric-divider" />
              <div className="panel-metric-box">
                <span className="p-metric-val">99.9%</span>
                <span className="p-metric-lbl">Uptime SLA</span>
              </div>
            </div>

            <div className="panel-demo-autofill-box">
              <div className="autofill-text">
                <Zap size={14} className="autofill-bolt" />
                <span>Testing this portal?</span>
              </div>
              <button
                type="button"
                className="btn-autofill-chip"
                onClick={handleDemoFill}
                title="Populate test institute code & credentials"
              >
                {autoFilled ? (
                  <>
                    <Check size={13} className="check-icon-green" />
                    <span>Credentials Filled!</span>
                  </>
                ) : (
                  <>
                    <Sparkles size={13} />
                    <span>1-Click Demo Fill (INST-2025)</span>
                  </>
                )}
              </button>
            </div>
          </div>

          {/* RIGHT: Form + role unlock preview */}
          <div className="creative-inst-right-form">
            <div className="form-card-header">
              <div className="portal-icon-badge blue">
                <Building2 size={26} />
              </div>
              <h2 className="form-card-title">Institute Portal Login</h2>
              <p className="form-card-subtitle">
                Enter your institute code and administrator credentials to proceed.
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
              <div className="form-group">
                <div className="form-label-row">
                  <label className="form-label" htmlFor="inst-code-input">
                    Institute Code / ID <span className="req">*</span>
                  </label>
                  <span
                    className="code-hint-chip"
                    onClick={handleDemoFill}
                    onKeyDown={(e) => e.key === 'Enter' && handleDemoFill()}
                    role="button"
                    tabIndex={0}
                  >
                    e.g. INST-2025
                  </span>
                </div>
                <div className="input-with-icon">
                  <Hash className="input-icon" size={17} />
                  <input
                    id="inst-code-input"
                    type="text"
                    placeholder="Enter institute code (e.g. INST-2025)"
                    value={instituteCode}
                    onChange={(e) => {
                      setInstituteCode(e.target.value);
                      setErrorMessage('');
                    }}
                    className="form-input code-input-styled"
                    required
                  />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label" htmlFor="inst-email-input">
                  Admin Email Address <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Mail className="input-icon" size={17} />
                  <input
                    id="inst-email-input"
                    type="email"
                    placeholder="admin@institute.edu"
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

              <div className="form-group">
                <label className="form-label" htmlFor="inst-pass-input">
                  Master Password <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Lock className="input-icon" size={17} />
                  <input
                    id="inst-pass-input"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="Enter master password"
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

              <div className="form-aux-row">
                <label className="checkbox-container">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                  />
                  <span className="checkbox-label-text">Remember this institute</span>
                </label>

                <button
                  type="button"
                  className="link-subtle-btn"
                  onClick={() => onNavigate('forgot-password', { role: 'institute' })}
                >
                  Forgot password?
                </button>
              </div>

              <button
                type="submit"
                className="btn-primary btn-submit-full btn-glowing-blue"
                disabled={loading}
              >
                {loading ? (
                  'Verifying Institute Credentials...'
                ) : (
                  <>
                    <span>Authenticate & Open Portal</span>
                    <ArrowRight size={17} />
                  </>
                )}
              </button>
            </form>

            <div className="role-unlock-preview-box">
              <div className="unlock-header">
                <Sparkles size={14} className="unlock-sparkle" />
                <span>Unlocked Upon Authentication:</span>
              </div>

              <div className="unlock-pills-row">
                <div className="unlock-pill blue" title="Admin dashboard unlocked">
                  <Shield size={14} />
                  <span>Admin</span>
                </div>
                <div className="unlock-pill teal" title="Teacher portal unlocked">
                  <Users size={14} />
                  <span>Teacher</span>
                </div>
                <div className="unlock-pill purple" title="Student gateway unlocked">
                  <GraduationCap size={14} />
                  <span>Student</span>
                </div>
              </div>
            </div>

            <div className="form-footer-link center">
              <span>Don't have a registered institute? </span>
              <button
                type="button"
                className="link-accent-btn"
                onClick={() => onNavigate('institute-register')}
              >
                Register Institute
              </button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
