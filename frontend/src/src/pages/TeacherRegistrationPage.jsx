import React, { useState } from 'react';
import {
  Users,
  User,
  Mail,
  Lock,
  Eye,
  EyeOff,
  Hash,
  Briefcase,
  Phone,
  AlertCircle,
  CheckCircle2,
  Info
} from 'lucide-react';
import PortalHeader from '../components/PortalHeader';
import TeacherIllustration from '../components/illustrations/TeacherIllustration';
import api from '../services/api';

export default function TeacherRegistrationPage({ onNavigate, onRegisterSuccess }) {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    instituteCode: '',
    employeeId: '',
    department: '',
    phoneNumber: '',
    password: '',
  });

  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  const handleChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    setErrorMessage('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setSuccessMessage('');

    if (!formData.fullName.trim()) {
      setErrorMessage('Please enter your full name.');
      return;
    }
    if (!formData.email.trim() || !formData.email.includes('@')) {
      setErrorMessage('Please enter a valid email address.');
      return;
    }
    if (!formData.instituteCode.trim()) {
      setErrorMessage('Please enter your Institute Code / ID.');
      return;
    }
    if (!formData.employeeId.trim()) {
      setErrorMessage('Please enter your Employee ID.');
      return;
    }
    if (!formData.department) {
      setErrorMessage('Please select your Subject / Department.');
      return;
    }
    if (!formData.phoneNumber.trim()) {
      setErrorMessage('Please enter your phone number.');
      return;
    }
    if (!formData.password || formData.password.length < 6) {
      setErrorMessage('Password must be at least 6 characters.');
      return;
    }

    try {
      setLoading(true);
      const res = await api.registerTeacher(formData);
      setSuccessMessage('Teacher registration submitted! Your institute administrator will verify your profile.');

      if (onRegisterSuccess) {
        onRegisterSuccess(res?.user || { ...formData, role: 'teacher' });
      }

      setTimeout(() => {
        onNavigate('teacher-login');
      }, 1600);
    } catch (err) {
      setErrorMessage(err.message || 'Registration failed. Please check information.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="portal-page-wrapper">
      <PortalHeader onNavigate={onNavigate} backTarget="select-role" backLabel="Back to Home" />

      <main className="portal-form-container wide">
        <div className="portal-split-card teacher-theme">
          {/* Left: Illustration Column */}
          <div className="split-card-illustration teacher-side">
            <div className="side-banner-text">
              <span className="side-badge teal">Faculty Portal</span>
              <h2>Educate and Inspire</h2>
              <p>Manage curriculum, track student attendance, and publish grades easily.</p>
            </div>
            <div className="side-illustration-box">
              <TeacherIllustration />
            </div>
          </div>

          {/* Right: Registration Form */}
          <div className="split-card-form">
            <div className="form-card-header">
              <div className="portal-icon-badge teal">
                <Users size={24} />
              </div>
              <h1 className="form-card-title">Teacher Registration</h1>
              <p className="form-card-subtitle">
                Register as a teacher and request to join an institute.
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
              {/* Full Name */}
              <div className="form-group">
                <label className="form-label" htmlFor="teacher-name">
                  Full Name <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <User className="input-icon" size={17} />
                  <input
                    id="teacher-name"
                    type="text"
                    placeholder="Enter your full name"
                    value={formData.fullName}
                    onChange={(e) => handleChange('fullName', e.target.value)}
                    className="form-input"
                    required
                  />
                </div>
              </div>

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
                    placeholder="teacher@example.com"
                    value={formData.email}
                    onChange={(e) => handleChange('email', e.target.value)}
                    className="form-input"
                    required
                  />
                </div>
              </div>

              {/* Institute Code & Employee ID */}
              <div className="form-grid-2">
                <div className="form-group">
                  <label className="form-label" htmlFor="teacher-inst-code">
                    Institute Code / ID <span className="req">*</span>
                  </label>
                  <div className="input-with-icon">
                    <Hash className="input-icon" size={17} />
                    <input
                      id="teacher-inst-code"
                      type="text"
                      placeholder="Enter institute code"
                      value={formData.instituteCode}
                      onChange={(e) => handleChange('instituteCode', e.target.value)}
                      className="form-input"
                      required
                    />
                  </div>
                </div>

                <div className="form-group">
                  <label className="form-label" htmlFor="teacher-emp-id">
                    Employee ID <span className="req">*</span>
                  </label>
                  <div className="input-with-icon">
                    <Hash className="input-icon" size={17} />
                    <input
                      id="teacher-emp-id"
                      type="text"
                      placeholder="Enter employee ID"
                      value={formData.employeeId}
                      onChange={(e) => handleChange('employeeId', e.target.value)}
                      className="form-input"
                      required
                    />
                  </div>
                </div>
              </div>

              {/* Subject / Department & Phone */}
              <div className="form-grid-2">
                <div className="form-group">
                  <label className="form-label" htmlFor="teacher-dept">
                    Subject / Department <span className="req">*</span>
                  </label>
                  <div className="input-with-icon">
                    <Briefcase className="input-icon" size={17} />
                    <select
                      id="teacher-dept"
                      value={formData.department}
                      onChange={(e) => handleChange('department', e.target.value)}
                      className="form-select"
                      required
                    >
                      <option value="">Select subject / department</option>
                      <option value="Computer Science">Computer Science & IT</option>
                      <option value="Mathematics">Mathematics & Statistics</option>
                      <option value="Physics">Physics</option>
                      <option value="Chemistry">Chemistry</option>
                      <option value="Biology & Life Sciences">Biology & Life Sciences</option>
                      <option value="Literature & Languages">Literature & Languages</option>
                      <option value="Business & Economics">Business & Economics</option>
                    </select>
                  </div>
                </div>

                <div className="form-group">
                  <label className="form-label" htmlFor="teacher-phone">
                    Phone Number <span className="req">*</span>
                  </label>
                  <div className="input-with-icon">
                    <Phone className="input-icon" size={17} />
                    <input
                      id="teacher-phone"
                      type="tel"
                      placeholder="Enter phone number"
                      value={formData.phoneNumber}
                      onChange={(e) => handleChange('phoneNumber', e.target.value)}
                      className="form-input"
                      required
                    />
                  </div>
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
                    placeholder="Create a strong password"
                    value={formData.password}
                    onChange={(e) => handleChange('password', e.target.value)}
                    className="form-input"
                    minLength={6}
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

              {/* Submit Button */}
              <button
                type="submit"
                className="btn-primary btn-submit-full teal-gradient"
                disabled={loading}
              >
                {loading ? 'Submitting Registration...' : 'Register as Teacher'}
              </button>

              {/* Informational Footnote */}
              <div className="auth-footnote-box teal">
                <Info size={15} className="footnote-icon teal" />
                <span>Your account will be verified by the institute admin.</span>
              </div>

              {/* Sign in prompt */}
              <div className="form-footer-link center">
                <span>Already have an account? </span>
                <button
                  type="button"
                  className="link-accent-btn teal"
                  onClick={() => onNavigate('teacher-login')}
                >
                  Teacher Login
                </button>
              </div>
            </form>
          </div>
        </div>
      </main>
    </div>
  );
}
