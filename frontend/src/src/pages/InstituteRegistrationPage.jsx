import React, { useState } from 'react';
import {
  Building2,
  Landmark,
  Mail,
  Phone,
  MapPin,
  User,
  Lock,
  Eye,
  EyeOff,
  AlertCircle,
  CheckCircle2,
  ArrowRight,
  ShieldCheck,
  Check,
  Sparkles,
  Zap,
  Award,
  Users,
  Copy
} from 'lucide-react';
import PortalHeader from '../components/PortalHeader';
import InstituteBuildingIllustration from '../components/illustrations/InstituteBuildingIllustration';
import api from '../services/api';

export default function InstituteRegistrationPage({ onNavigate, onRegisterSuccess }) {
  const [formData, setFormData] = useState({
    instituteName: '',
    instituteType: '',
    instituteEmail: '',
    phoneNumber: '',
    address: '',
    adminName: '',
    adminEmail: '',
    institutePassword: '',
    adminPassword: '',
  });

  const [agreeTerms, setAgreeTerms] = useState(true);
  const [showInstitutePassword, setShowInstitutePassword] = useState(false);
  const [showAdminPassword, setShowAdminPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successData, setSuccessData] = useState(null);
  const [autoFilled, setAutoFilled] = useState(false);
  const [copiedCode, setCopiedCode] = useState(false);

  const calculatePasswordStrength = (pass) => {
    if (!pass) return { score: 0, label: '', color: '' };
    if (pass.length < 6) return { score: 1, label: 'Too Short', color: '#ef4444' };
    let score = 1;
    if (pass.length >= 8) score++;
    if (/[0-9]/.test(pass)) score++;
    if (/[^A-Za-z0-9]/.test(pass) || /[A-Z]/.test(pass)) score++;

    if (score <= 2) return { score: 2, label: 'Fair', color: '#f59e0b' };
    if (score === 3) return { score: 3, label: 'Good', color: '#0ea5e9' };
    return { score: 4, label: 'Strong', color: '#10b981' };
  };

  const instStrength = calculatePasswordStrength(formData.institutePassword);
  const adminStrength = calculatePasswordStrength(formData.adminPassword);

  const handleChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    setErrorMessage('');
  };

  const handleDemoFill = () => {
    setFormData({
      instituteName: 'St. Xavier Institute of Technology',
      instituteType: 'College',
      instituteEmail: 'info@stxavier.edu',
      phoneNumber: '+1 (555) 782-9011',
      address: '420 University Avenue, Cambridge Campus',
      adminName: 'Dr. Robert Vance (Dean)',
      adminEmail: 'admin@stxavier.edu',
      institutePassword: 'InstPassword@2025',
      adminPassword: 'AdminPassword@2025',
    });
    setAgreeTerms(true);
    setAutoFilled(true);
    setErrorMessage('');
    setTimeout(() => setAutoFilled(false), 2200);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');

    if (!formData.instituteName.trim()) {
      setErrorMessage('Please enter the official institute name.');
      return;
    }
    if (!formData.instituteType) {
      setErrorMessage('Please select the institute classification/type.');
      return;
    }
    if (!formData.instituteEmail.trim() || !formData.instituteEmail.includes('@')) {
      setErrorMessage('Please enter a valid official institute email.');
      return;
    }
    if (!formData.phoneNumber.trim()) {
      setErrorMessage('Please enter a contact phone number.');
      return;
    }
    if (!formData.address.trim()) {
      setErrorMessage('Please enter the primary campus location.');
      return;
    }
    if (!formData.adminName.trim()) {
      setErrorMessage('Please enter the administrator name.');
      return;
    }
    if (!formData.adminEmail.trim() || !formData.adminEmail.includes('@')) {
      setErrorMessage('Please enter a valid administrator email.');
      return;
    }
    if (!formData.institutePassword || formData.institutePassword.length < 6) {
      setErrorMessage('Institute Password is required and must be at least 6 characters long.');
      return;
    }
    if (!formData.adminPassword || formData.adminPassword.length < 6) {
      setErrorMessage('Admin Password is required and must be at least 6 characters long.');
      return;
    }
    if (formData.institutePassword === formData.adminPassword) {
      setErrorMessage('Institute and Admin passwords must be different.');
      return;
    }
    if (!agreeTerms) {
      setErrorMessage('Please accept the institutional representation declaration.');
      return;
    }

    try {
      setLoading(true);
      const payload = {
        ...formData,
        password: formData.institutePassword,
      };
      const res = await api.registerInstitute(payload);
      const user = res?.user;
      if (!user) {
        throw new Error(res?.message || 'Institute registration failed.');
      }
      setSuccessData(user);
    } catch (err) {
      setErrorMessage(err.message || 'Registration failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleCopyCode = () => {
    if (!successData?.instituteCode) return;
    navigator.clipboard.writeText(successData.instituteCode);
    setCopiedCode(true);
    setTimeout(() => setCopiedCode(false), 2000);
  };

  return (
    <div className="portal-page-wrapper creative-inst-login-wrapper">
      <PortalHeader onNavigate={onNavigate} backTarget="home" backLabel="Back to Home" />

      <main className="creative-inst-reg-container">
        <div className="creative-inst-reg-card">
          {/* LEFT: Midnight-cyan campus showcase */}
          <div className="creative-inst-left-panel">
            <div className="panel-glow-pattern" />

            <div className="panel-top-badges">
              <span className="inst-badge-pill cyan">
                <ShieldCheck size={13} />
                <span>Accredited Campus Registration</span>
              </span>
              <span className="inst-badge-pill green">
                <span>● Instant Verification</span>
              </span>
            </div>

            <div className="panel-identity-row">
              <div className="panel-avatar-box">
                <Landmark size={28} />
                <span className="live-indicator-dot" title="Onboarding Active" />
              </div>
              <div className="panel-headings">
                <h1 className="panel-main-title">
                  Register Institute
                </h1>
                <p className="panel-description">
                  Launch your verified digital campus. Generate an official access code to unify your
                  administrators, faculty, and students.
                </p>
              </div>
            </div>

            <div className="panel-building-graphic">
              <InstituteBuildingIllustration variant="compact" />
            </div>

            {/* Registration Benefits Highlights */}
            <div className="reg-perks-box">
              <div className="reg-perk-item">
                <div className="perk-icon-circle blue">
                  <Zap size={14} />
                </div>
                <div className="perk-text">
                  <strong>Instant Access Code:</strong>
                  <span>Auto-generates unique ID (e.g. INST-XXXX) for role registration.</span>
                </div>
              </div>

              <div className="reg-perk-item">
                <div className="perk-icon-circle green">
                  <ShieldCheck size={14} />
                </div>
                <div className="perk-text">
                  <strong>Role Isolation:</strong>
                  <span>Individual portal workspaces for Admin, Teachers, and Students.</span>
                </div>
              </div>

              <div className="reg-perk-item">
                <div className="perk-icon-circle purple">
                  <Award size={14} />
                </div>
                <div className="perk-text">
                  <strong>Institutional Verification:</strong>
                  <span>Accredited digital certificate and compliance verification.</span>
                </div>
              </div>
            </div>

            {/* Live Metrics */}
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
                <span className="p-metric-val">100%</span>
                <span className="p-metric-lbl">RBAC Security</span>
              </div>
            </div>

            {/* Quick Demo Autofill */}
            <div className="panel-demo-autofill-box">
              <div className="autofill-text">
                <Sparkles size={14} className="autofill-bolt" />
                <span>Need test data?</span>
              </div>
              <button
                type="button"
                className="btn-autofill-chip"
                onClick={handleDemoFill}
                title="Populate sample institute credentials with one click"
              >
                {autoFilled ? (
                  <>
                    <Check size={13} className="check-icon-green" />
                    <span>Sample Data Populated!</span>
                  </>
                ) : (
                  <>
                    <Sparkles size={13} />
                    <span>1-Click Demo Fill (St. Xavier Tech)</span>
                  </>
                )}
              </button>
            </div>
          </div>

          {/* RIGHT: Registration Form or Success Screen */}
          <div className="creative-inst-reg-right-form">
            {successData ? (
              /* Success Confirmation View */
              <div className="reg-success-container">
                <div className="success-icon-seal">
                  <ShieldCheck size={48} />
                </div>

                <span className="success-kicker">Registration Confirmed</span>
                <h2 className="success-title">{successData.instituteName}</h2>
                <p className="success-subtitle">
                  Your institution has been registered and verified on the Academic Management Platform.
                </p>

                {/* Generated Code Display Card */}
                <div className="success-code-card">
                  <span className="code-label-top">Your Official Institute Access Code</span>
                  <div className="code-value-row">
                    <span className="highlight-code">{successData.instituteCode}</span>
                    <button
                      type="button"
                      className={`btn-copy-code-chip ${copiedCode ? 'copied' : ''}`}
                      onClick={handleCopyCode}
                    >
                      {copiedCode ? (
                        <>
                          <Check size={14} />
                          <span>Copied</span>
                        </>
                      ) : (
                        <>
                          <Copy size={14} />
                          <span>Copy Code</span>
                        </>
                      )}
                    </button>
                  </div>
                  <p className="code-note">
                    Share this code with your teachers and students. They will use this code to register and access their portals.
                  </p>
                </div>

                <div className="success-details-list">
                  <div className="success-detail-row">
                    <span>Institute Type:</span>
                    <strong>{successData.instituteType || 'College / University'}</strong>
                  </div>
                  <div className="success-detail-row">
                    <span>Admin Profile:</span>
                    <strong>{successData.name} ({successData.email})</strong>
                  </div>
                  <div className="success-detail-row">
                    <span>Status:</span>
                    <strong className="status-green">● Officially Verified</strong>
                  </div>
                </div>

                <div className="success-actions-row">
                  <button
                    type="button"
                    className="btn-primary btn-success-login"
                    onClick={() => {
                      if (onRegisterSuccess) onRegisterSuccess(successData);
                      else onNavigate('institute-home');
                    }}
                  >
                    <span>Open Institute Home Dashboard</span>
                    <ArrowRight size={16} />
                  </button>
                  <button
                    type="button"
                    className="btn-secondary btn-success-outline"
                    onClick={() => onNavigate('institute-login')}
                  >
                    <span>Go to Institute Login</span>
                  </button>
                </div>
              </div>
            ) : (
              /* Standard Registration Form */
              <>
                <div className="form-card-header">
                  <div className="portal-icon-badge blue">
                    <Building2 size={24} />
                  </div>
                  <h2 className="form-card-title">Register Your Institute</h2>
                  <p className="form-card-subtitle">
                    Create your institution profile and set up your master administrator account.
                  </p>
                </div>

                {errorMessage && (
                  <div className="auth-alert error" role="alert">
                    <AlertCircle size={16} />
                    <span>{errorMessage}</span>
                  </div>
                )}

                <form onSubmit={handleSubmit} className="reg-modern-form">
                  {/* Section 1: Institute Information */}
                  <div className="form-fieldset">
                    <div className="fieldset-header">
                      <span className="fieldset-step-badge">1</span>
                      <div>
                        <h3 className="fieldset-title">Institute Information</h3>
                        <p className="fieldset-desc">Official profile & contact details</p>
                      </div>
                    </div>

                    <div className="form-grid-2">
                      <div className="form-group">
                        <label className="form-label" htmlFor="reg-inst-name">
                          Institute Name <span className="req">*</span>
                        </label>
                        <div className="input-with-icon">
                          <Landmark className="input-icon" size={17} />
                          <input
                            id="reg-inst-name"
                            type="text"
                            placeholder="e.g. Apex Institute of Technology"
                            value={formData.instituteName}
                            onChange={(e) => handleChange('instituteName', e.target.value)}
                            className="form-input"
                            required
                          />
                        </div>
                      </div>

                      <div className="form-group">
                        <label className="form-label" htmlFor="reg-inst-type">
                          Institute Type <span className="req">*</span>
                        </label>
                        <select
                          id="reg-inst-type"
                          value={formData.instituteType}
                          onChange={(e) => handleChange('instituteType', e.target.value)}
                          className="form-select"
                          required
                        >
                          <option value="">Select category</option>
                          <option value="College">College / Degree Institute</option>
                          <option value="University">University</option>
                          <option value="School">School (K-12 / High School)</option>
                          <option value="Coaching Institute">Coaching / Training Academy</option>
                          <option value="Polytechnic">Polytechnic / Vocational</option>
                        </select>
                      </div>
                    </div>

                    <div className="form-grid-2">
                      <div className="form-group">
                        <label className="form-label" htmlFor="reg-inst-email">
                          Official Institute Email <span className="req">*</span>
                        </label>
                        <div className="input-with-icon">
                          <Mail className="input-icon" size={17} />
                          <input
                            id="reg-inst-email"
                            type="email"
                            placeholder="info@institution.edu"
                            value={formData.instituteEmail}
                            onChange={(e) => handleChange('instituteEmail', e.target.value)}
                            className="form-input"
                            required
                          />
                        </div>
                      </div>

                      <div className="form-group">
                        <label className="form-label" htmlFor="reg-inst-phone">
                          Phone Number <span className="req">*</span>
                        </label>
                        <div className="input-with-icon">
                          <Phone className="input-icon" size={17} />
                          <input
                            id="reg-inst-phone"
                            type="tel"
                            placeholder="+1 (555) 000-0000"
                            value={formData.phoneNumber}
                            onChange={(e) => handleChange('phoneNumber', e.target.value)}
                            className="form-input"
                            required
                          />
                        </div>
                      </div>
                    </div>

                    <div className="form-group">
                      <label className="form-label" htmlFor="reg-inst-address">
                        Campus Location / Address <span className="req">*</span>
                      </label>
                      <div className="input-with-icon">
                        <MapPin className="input-icon" size={17} />
                        <input
                          id="reg-inst-address"
                          type="text"
                          placeholder="Complete campus address, city, state"
                          value={formData.address}
                          onChange={(e) => handleChange('address', e.target.value)}
                          className="form-input"
                          required
                        />
                      </div>
                    </div>

                    {/* Field: Institute Password (for Institute Login) */}
                    <div className="form-group" style={{ marginTop: '0.75rem' }}>
                      <div className="form-label-row">
                        <label className="form-label" htmlFor="reg-inst-pass">
                          Institute Password (for Institute Login) <span className="req">*</span>
                        </label>
                        {formData.institutePassword && (
                          <span
                            className="strength-tag"
                            style={{ color: instStrength.color }}
                          >
                            Strength: {instStrength.label}
                          </span>
                        )}
                      </div>
                      <div className="input-with-icon">
                        <Lock className="input-icon" size={17} />
                        <input
                          id="reg-inst-pass"
                          name="institutePassword"
                          type={showInstitutePassword ? 'text' : 'password'}
                          placeholder="Create Institute login password (min 6 chars)"
                          value={formData.institutePassword}
                          onChange={(e) => handleChange('institutePassword', e.target.value)}
                          className="form-input"
                          minLength={6}
                          required
                        />
                        <button
                          type="button"
                          className="input-action-btn"
                          onClick={() => setShowInstitutePassword(!showInstitutePassword)}
                          aria-label="Toggle institute password view"
                        >
                          {showInstitutePassword ? <EyeOff size={18} /> : <Eye size={18} />}
                        </button>
                      </div>
                      {formData.institutePassword && (
                        <div className="password-meter-track">
                          <div
                            className="password-meter-fill"
                            style={{
                              width: `${(instStrength.score / 4) * 100}%`,
                              backgroundColor: instStrength.color,
                            }}
                          />
                        </div>
                      )}
                      <span className="form-field-hint" style={{ fontSize: '0.78rem', color: '#64748b', marginTop: '0.25rem', display: 'block' }}>
                        Used exclusively for official Institute Portal Login
                      </span>
                    </div>
                  </div>

                  {/* Section 2: Administrator Profile */}
                  <div className="form-fieldset">
                    <div className="fieldset-header">
                      <span className="fieldset-step-badge blue">2</span>
                      <div>
                        <h3 className="fieldset-title">Master Administrator Profile</h3>
                        <p className="fieldset-desc">Primary account holder managing the portal</p>
                      </div>
                    </div>

                    <div className="form-grid-2">
                      <div className="form-group">
                        <label className="form-label" htmlFor="reg-admin-name">
                          Admin Full Name <span className="req">*</span>
                        </label>
                        <div className="input-with-icon">
                          <User className="input-icon" size={17} />
                          <input
                            id="reg-admin-name"
                            type="text"
                            placeholder="Dr. / Prof. / Principal Name"
                            value={formData.adminName}
                            onChange={(e) => handleChange('adminName', e.target.value)}
                            className="form-input"
                            required
                          />
                        </div>
                      </div>

                      <div className="form-group">
                        <label className="form-label" htmlFor="reg-admin-email">
                          Admin Work Email <span className="req">*</span>
                        </label>
                        <div className="input-with-icon">
                          <Mail className="input-icon" size={17} />
                          <input
                            id="reg-admin-email"
                            type="email"
                            placeholder="admin@institution.edu"
                            value={formData.adminEmail}
                            onChange={(e) => handleChange('adminEmail', e.target.value)}
                            className="form-input"
                            required
                          />
                        </div>
                      </div>
                    </div>

                    {/* Field: Admin Password (for Admin Login) */}
                    <div className="form-group">
                      <div className="form-label-row">
                        <label className="form-label" htmlFor="reg-admin-pass">
                          Admin Password (for Admin Login) <span className="req">*</span>
                        </label>
                        {formData.adminPassword && (
                          <span
                            className="strength-tag"
                            style={{ color: adminStrength.color }}
                          >
                            Strength: {adminStrength.label}
                          </span>
                        )}
                      </div>
                      <div className="input-with-icon">
                        <Lock className="input-icon" size={17} />
                        <input
                          id="reg-admin-pass"
                          name="adminPassword"
                          type={showAdminPassword ? 'text' : 'password'}
                          placeholder="Create Admin login password (min 6 chars, different from Institute password)"
                          value={formData.adminPassword}
                          onChange={(e) => handleChange('adminPassword', e.target.value)}
                          className="form-input"
                          minLength={6}
                          required
                        />
                        <button
                          type="button"
                          className="input-action-btn"
                          onClick={() => setShowAdminPassword(!showAdminPassword)}
                          aria-label="Toggle admin password view"
                        >
                          {showAdminPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                        </button>
                      </div>

                      {formData.adminPassword && (
                        <div className="password-meter-track">
                          <div
                            className="password-meter-fill"
                            style={{
                              width: `${(adminStrength.score / 4) * 100}%`,
                              backgroundColor: adminStrength.color,
                            }}
                          />
                        </div>
                      )}
                      <span className="form-field-hint" style={{ fontSize: '0.78rem', color: '#64748b', marginTop: '0.25rem', display: 'block' }}>
                        Used exclusively for Administrator Module Login (must be different from Institute password)
                      </span>
                    </div>
                  </div>

                  {/* Declaration Checkbox */}
                  <label className="reg-terms-row">
                    <input
                      type="checkbox"
                      checked={agreeTerms}
                      onChange={(e) => setAgreeTerms(e.target.checked)}
                      className="terms-checkbox"
                    />
                    <span className="terms-text">
                      I confirm that I am an authorized representative of this institution and agree to the platform guidelines and accreditation standards.
                    </span>
                  </label>

                  {/* Submit Button */}
                  <button
                    type="submit"
                    className="btn-primary btn-submit-full btn-glowing-blue"
                    disabled={loading}
                  >
                    {loading ? (
                      <span>Registering Institute & Generating Code...</span>
                    ) : (
                      <>
                        <span>Complete Registration & Generate Code</span>
                        <ArrowRight size={17} />
                      </>
                    )}
                  </button>

                  {/* Footer link to Login */}
                  <div className="form-footer-link center">
                    <span>Already have an institute account? </span>
                    <button
                      type="button"
                      className="link-accent-btn"
                      onClick={() => onNavigate('institute-login')}
                    >
                      Institute Login
                    </button>
                  </div>
                </form>
              </>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
