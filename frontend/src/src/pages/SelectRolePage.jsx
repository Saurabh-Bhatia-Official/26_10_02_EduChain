import React, { useState } from 'react';
import {
  Shield,
  Users,
  GraduationCap,
  Building2,
  ArrowRight,
  LogIn,
  UserPlus,
  Sparkles,
  CheckCircle2,
  Copy,
  Check,
  LogOut,
  Bell,
  BookOpen,
  Award,
  Layers,
  ChevronRight,
  Lock
} from 'lucide-react';
import PortalHeader from '../components/PortalHeader';

export default function SelectRolePage({
  onNavigate,
  initialMode = 'login',
  currentUser,
  onLogout,
  onQuickUnlock
}) {
  const [activeMode, setActiveMode] = useState(initialMode); // 'login' | 'register'
  const [copiedCode, setCopiedCode] = useState(false);

  const instituteCode = currentUser?.instituteCode || 'INST-2025';
  const instituteName = currentUser?.instituteName || 'Apex Institute of Technology';
  const isInstituteLoggedIn = currentUser?.role === 'institute';

  const handleCopyCode = () => {
    navigator.clipboard.writeText(instituteCode);
    setCopiedCode(true);
    setTimeout(() => setCopiedCode(false), 2000);
  };

  return (
    <div className="portal-page-wrapper creative-hub-wrapper">
      {/* Top Portal Header with Back & Logout */}
      <PortalHeader
        onNavigate={onNavigate}
        backTarget={isInstituteLoggedIn ? "institute-home" : "home"}
        backLabel={isInstituteLoggedIn ? "Back to Institute Home" : "Back to Home"}
        currentUser={currentUser}
      />

      <main className="creative-hub-container">
        {/* Creative Institute Hub Banner */}
        <section className="creative-institute-banner">
          <div className="banner-backdrop-pattern" />

          <div className="banner-content-inner">
            {/* Left: Institute Avatar & Identity */}
            <div className="banner-identity-col">
              <div className="banner-avatar-box">
                <Building2 size={36} className="banner-avatar-icon" />
                <span className="live-indicator-dot" title="Live Institute" />
              </div>

              <div className="banner-text-details">
                <div className="banner-badge-row">
                  <span className="campus-badge">Verified Academic Campus</span>
                  <span className="status-pill active">● Live Portal</span>
                </div>
                <h1 className="banner-institute-name">{instituteName}</h1>
                <p className="banner-subtitle">
                  Academic Management Hub & Role Access Launchpad
                </p>
              </div>
            </div>

            {/* Right: 1-Click Institute Code Copy & Quick Logout */}
            <div className="banner-actions-col">
              {/* Copy Institute Code Pill */}
              <div className="institute-code-pill-box">
                <span className="code-pill-label">Institute Code:</span>
                <div className="code-pill-display" onClick={handleCopyCode} role="button" tabIndex={0} title="Click to copy code">
                  <span className="code-text">{instituteCode}</span>
                  <button type="button" className="btn-copy-code" aria-label="Copy institute code">
                    {copiedCode ? <Check size={14} className="check-green" /> : <Copy size={14} />}
                  </button>
                </div>
                {copiedCode && <span className="copied-tooltip">Copied to clipboard!</span>}
              </div>

              {/* Prominent Logout Button on Banner */}
              <button
                type="button"
                className="btn-hub-banner-logout"
                onClick={onLogout}
                title="Sign out from this institute"
              >
                <LogOut size={16} />
                <span>Logout Institute</span>
              </button>
            </div>
          </div>

          {/* Quick Metrics Strip */}
          <div className="banner-metrics-strip">
            <div className="metric-item">
              <div className="metric-icon-wrap blue">
                <GraduationCap size={18} />
              </div>
              <div className="metric-text">
                <span className="metric-value">1,420+</span>
                <span className="metric-label">Enrolled Students</span>
              </div>
            </div>

            <div className="metric-divider" />

            <div className="metric-item">
              <div className="metric-icon-wrap teal">
                <Users size={18} />
              </div>
              <div className="metric-text">
                <span className="metric-value">86</span>
                <span className="metric-label">Faculty Instructors</span>
              </div>
            </div>

            <div className="metric-divider" />

            <div className="metric-item">
              <div className="metric-icon-wrap purple">
                <Layers size={18} />
              </div>
              <div className="metric-text">
                <span className="metric-value">24</span>
                <span className="metric-label">Active Courses</span>
              </div>
            </div>

            <div className="metric-divider" />

            <div className="metric-item">
              <div className="metric-icon-wrap orange">
                <Award size={18} />
              </div>
              <div className="metric-text">
                <span className="metric-value">2025-2026</span>
                <span className="metric-label">Academic Year</span>
              </div>
            </div>
          </div>
        </section>

        {/* Live Announcement Ticker */}
        <div className="hub-announcement-ticker">
          <div className="ticker-badge">
            <Bell size={14} />
            <span>Campus Tip</span>
          </div>
          <p className="ticker-text">
            Share your Institute Code <strong className="ticker-highlight">{instituteCode}</strong> with your teachers and students so they can directly register and link with this campus.
          </p>
        </div>

        {/* Section Heading & Mode Switcher */}
        <div className="hub-section-header">
          <div className="hub-header-titles">
            <h2 className="hub-section-title">
              {activeMode === 'login' ? 'Role Authentication Gateway' : 'New Role Registration Hub'}
            </h2>
            <p className="hub-section-subtitle">
              {activeMode === 'login'
                ? 'Select a role to open the dedicated login interface.'
                : 'Select a role to create and link a new user profile.'}
            </p>
          </div>

          {/* Creative Switcher Tabs */}
          <div className="creative-mode-toggle">
            <button
              type="button"
              className={`toggle-tab-btn ${activeMode === 'login' ? 'active' : ''}`}
              onClick={() => setActiveMode('login')}
            >
              <LogIn size={15} />
              <span>Login as Role</span>
            </button>
            <button
              type="button"
              className={`toggle-tab-btn ${activeMode === 'register' ? 'active' : ''}`}
              onClick={() => setActiveMode('register')}
            >
              <UserPlus size={15} />
              <span>Register New User</span>
            </button>
          </div>
        </div>

        {/* 3 Creative Interactive Role Cards Grid */}
        <div className="creative-role-cards-grid">
          {/* Card 1: Admin Role */}
          <div className="creative-role-card admin-card">
            <div className="role-card-accent-bar admin" />

            <div className="role-card-top">
              <div className="role-card-badge blue">
                <Shield size={13} />
                <span>Institutional Control</span>
              </div>

              <div className="role-card-icon-bubble blue">
                <Shield size={28} />
              </div>
            </div>

            <div className="role-card-body">
              <h3 className="role-card-name">
                {activeMode === 'login' ? 'Admin Portal' : 'Institute & Admin Setup'}
              </h3>
              <p className="role-card-desc">
                {activeMode === 'login'
                  ? 'Access master administrative controls, audit logs, manage academic departments, and review faculty registrations.'
                  : 'Configure institution parameters, update licensing, and onboard system co-administrators.'}
              </p>

              {/* Feature Tags */}
              <div className="role-card-tags">
                <span className="role-tag">#SystemControls</span>
                <span className="role-tag">#FacultyRoster</span>
                <span className="role-tag">#AuditLogs</span>
              </div>
            </div>

            <div className="role-card-footer">
              {currentUser?.role === 'admin' ? (
                <button
                  type="button"
                  className="btn-role-action blue"
                  style={{ background: '#0284c7' }}
                  onClick={() => onNavigate('admin-dashboard')}
                >
                  <span>Open Admin Portal</span>
                  <ArrowRight size={16} />
                </button>
              ) : (
                <button
                  type="button"
                  className="btn-role-action blue"
                  onClick={() => onNavigate(activeMode === 'login' ? 'admin-login' : 'institute-register')}
                >
                  <span>{activeMode === 'login' ? 'Enter Admin Login' : 'Admin Profile Setup'}</span>
                  <ArrowRight size={16} />
                </button>
              )}
            </div>
          </div>

          {/* Card 2: Teacher Role */}
          <div className="creative-role-card teacher-card">
            <div className="role-card-accent-bar teacher" />

            <div className="role-card-top">
              <div className="role-card-badge teal">
                <Users size={13} />
                <span>Faculty & Academics</span>
              </div>

              <div className="role-card-icon-bubble teal">
                <Users size={28} />
              </div>
            </div>

            <div className="role-card-body">
              <h3 className="role-card-name">
                {activeMode === 'login' ? 'Teacher Portal' : 'Teacher Registration'}
              </h3>
              <p className="role-card-desc">
                {activeMode === 'login'
                  ? 'Access classroom management tools, mark daily student attendance, upload assignments, and submit exam grades.'
                  : 'Register a new instructor profile with Department, Employee ID, and specialized subject domains.'}
              </p>

              {/* Feature Tags */}
              <div className="role-card-tags">
                <span className="role-tag teal">#Classrooms</span>
                <span className="role-tag teal">#Attendance</span>
                <span className="role-tag teal">#Gradebook</span>
              </div>
            </div>

            <div className="role-card-footer split-actions">
              {currentUser?.role === 'teacher' ? (
                <button
                  type="button"
                  className="btn-role-action teal"
                  style={{ background: '#429059' }}
                  onClick={() => onNavigate('teacher-login')}
                >
                  <span>Teacher Login</span>
                  <ArrowRight size={16} />
                </button>
              ) : (
                <button
                  type="button"
                  className="btn-role-action teal"
                  onClick={() => onNavigate('teacher-login')}
                >
                  <span>Teacher Login</span>
                  <ArrowRight size={16} />
                </button>
              )}
              <button
                type="button"
                className="btn-role-subaction teal"
                onClick={() => onNavigate('teacher-register')}
              >
                Register Teacher +
              </button>
            </div>
          </div>

          {/* Card 3: Student Role */}
          <div className="creative-role-card student-card">
            <div className="role-card-accent-bar student" />

            <div className="role-card-top">
              <div className="role-card-badge purple">
                <GraduationCap size={13} />
                <span>Learner Gateway</span>
              </div>

              <div className="role-card-icon-bubble purple">
                <GraduationCap size={28} />
              </div>
            </div>

            <div className="role-card-body">
              <h3 className="role-card-name">
                {activeMode === 'login' ? 'Student Portal' : 'Student Registration'}
              </h3>
              <p className="role-card-desc">
                {activeMode === 'login'
                  ? 'Access study materials, check attendance percentage, view upcoming exam schedules, and download verified grade cards.'
                  : 'Enroll as a new student using your Roll Number, selected Course stream, and Institute ID.'}
              </p>

              {/* Feature Tags */}
              <div className="role-card-tags">
                <span className="role-tag purple">#StudyMaterials</span>
                <span className="role-tag purple">#ExamResults</span>
                <span className="role-tag purple">#Timetables</span>
              </div>
            </div>

            <div className="role-card-footer split-actions">
              <button
                type="button"
                className="btn-role-action purple"
                onClick={() => onNavigate('student-login')}
              >
                <span>Student Login</span>
                <ArrowRight size={16} />
              </button>
              <button
                type="button"
                className="btn-role-subaction purple"
                onClick={() => onNavigate('student-register')}
              >
                Register Student +
              </button>
            </div>
          </div>
        </div>

        {/* Bottom Utility Strip with Session Exit & Links */}
        <div className="hub-bottom-utility-bar">
          <div className="utility-info">
            <Building2 size={16} className="utility-icon" />
            <span>Currently managing <strong>{instituteName}</strong>. Need to switch accounts?</span>
          </div>

          <div className="utility-buttons">
            <button
              type="button"
              className="btn-utility-login"
              onClick={() => onNavigate('institute-login')}
            >
              Institute Login Page
            </button>
          </div>
        </div>
      </main>
    </div>
  );
}
