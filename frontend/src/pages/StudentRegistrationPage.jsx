import React, { useState } from 'react';
import {
  GraduationCap,
  User,
  Mail,
  Lock,
  Eye,
  EyeOff,
  Hash,
  BookOpen,
  AlertCircle,
  CheckCircle2,
  Info
} from 'lucide-react';
import PortalHeader from '../components/PortalHeader';
import StudentIllustration from '../components/illustrations/StudentIllustration';
import api from '../services/api';

export default function StudentRegistrationPage({ onNavigate, onRegisterSuccess }) {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    instituteCode: '',
    rollNumber: '',
    course: '',
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
    if (!formData.rollNumber.trim()) {
      setErrorMessage('Please enter your student Roll Number.');
      return;
    }
    if (!formData.course) {
      setErrorMessage('Please select your Class / Course.');
      return;
    }
    if (!formData.password || formData.password.length < 6) {
      setErrorMessage('Password must be at least 6 characters.');
      return;
    }

    try {
      setLoading(true);
      const res = await api.registerStudent(formData);
      const user = res?.user;
      if (!user) {
        throw new Error(res?.message || 'Student registration failed.');
      }
      setSuccessMessage('Student registered successfully in database! Redirecting to student login...');

      setTimeout(() => {
        onNavigate('student-login');
      }, 1500);
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
        <div className="portal-split-card student-theme">
          {/* Left: Illustration Column */}
          <div className="split-card-illustration student-side">
            <div className="side-banner-text">
              <span className="side-badge purple">Student Community</span>
              <h2>Empower Your Learning</h2>
              <p>Connect with your institute lectures, assignments, and grades in real-time.</p>
            </div>
            <div className="side-illustration-box">
              <StudentIllustration />
            </div>
          </div>

          {/* Right: Registration Form */}
          <div className="split-card-form">
            <div className="form-card-header">
              <div className="portal-icon-badge purple">
                <GraduationCap size={24} />
              </div>
              <h1 className="form-card-title">Student Registration</h1>
              <p className="form-card-subtitle">
                Register as a student and join your institute or class.
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
                <label className="form-label" htmlFor="student-name">
                  Full Name <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <User className="input-icon" size={17} />
                  <input
                    id="student-name"
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
                <label className="form-label" htmlFor="student-email">
                  Email Address <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <Mail className="input-icon" size={17} />
                  <input
                    id="student-email"
                    type="email"
                    placeholder="student@example.com"
                    value={formData.email}
                    onChange={(e) => handleChange('email', e.target.value)}
                    className="form-input"
                    required
                  />
                </div>
              </div>

              {/* Institute Code & Roll Number */}
              <div className="form-grid-2">
                <div className="form-group">
                  <label className="form-label" htmlFor="student-inst-code">
                    Institute Code / ID <span className="req">*</span>
                  </label>
                  <div className="input-with-icon">
                    <Hash className="input-icon" size={17} />
                    <input
                      id="student-inst-code"
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
                  <label className="form-label" htmlFor="student-roll">
                    Roll Number <span className="req">*</span>
                  </label>
                  <div className="input-with-icon">
                    <Hash className="input-icon" size={17} />
                    <input
                      id="student-roll"
                      type="text"
                      placeholder="Enter roll number"
                      value={formData.rollNumber}
                      onChange={(e) => handleChange('rollNumber', e.target.value)}
                      className="form-input"
                      required
                    />
                  </div>
                </div>
              </div>

              {/* Class / Course */}
              <div className="form-group">
                <label className="form-label" htmlFor="student-course">
                  Class / Course <span className="req">*</span>
                </label>
                <div className="input-with-icon">
                  <BookOpen className="input-icon" size={17} />
                  <select
                    id="student-course"
                    value={formData.course}
                    onChange={(e) => handleChange('course', e.target.value)}
                    className="form-select"
                    required
                  >
                    <option value="">Select class / course</option>
                    <option value="Computer Science & Engineering">Computer Science & Engineering</option>
                    <option value="Information Technology">Information Technology</option>
                    <option value="Mechanical Engineering">Mechanical Engineering</option>
                    <option value="Electrical Engineering">Electrical Engineering</option>
                    <option value="Business Administration (MBA/BBA)">Business Administration (MBA/BBA)</option>
                    <option value="Senior Secondary - Science (Grade 11/12)">Senior Secondary - Science (Grade 11/12)</option>
                    <option value="Senior Secondary - Commerce (Grade 11/12)">Senior Secondary - Commerce (Grade 11/12)</option>
                  </select>
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
                className="btn-primary btn-submit-full purple-gradient"
                disabled={loading}
              >
                {loading ? 'Submitting Registration...' : 'Register as Student'}
              </button>

              {/* Informational Footnote */}
              <div className="auth-footnote-box">
                <Info size={15} className="footnote-icon" />
                <span>
                  Student account will be activated only after enrollment is verified/approved by the institute.
                </span>
              </div>

              {/* Sign in prompt */}
              <div className="form-footer-link center">
                <span>Already have an account? </span>
                <button
                  type="button"
                  className="link-accent-btn purple"
                  onClick={() => onNavigate('student-login')}
                >
                  Student Login
                </button>
              </div>
            </form>
          </div>
        </div>
      </main>
    </div>
  );
}
