import React, { useState } from 'react';
import {
  Building2,
  ShieldCheck,
  CheckCircle2,
  Users,
  GraduationCap,
  Award,
  BookOpen,
  Copy,
  Check,
  LogOut,
  ExternalLink,
  ChevronRight,
  ArrowRight,
  Layers,
  Landmark,
  FileText,
  CheckCheck,
  BellRing,
  Shield
} from 'lucide-react';

export default function InstituteHomePage({ onNavigate, currentUser, onLogout }) {
  const [copiedCode, setCopiedCode] = useState(false);
  const [showCertificateModal, setShowCertificateModal] = useState(false);
  const [announcementText, setAnnouncementText] = useState('');
  const [announcementSent, setAnnouncementSent] = useState(false);

  const instituteName = currentUser?.instituteName || 'Apex Institute of Technology';
  const instituteCode = currentUser?.instituteCode || 'INST-2025';
  const verificationId = currentUser?.verificationId || `VRF-${instituteCode.replace(/[^A-Za-z0-9]/g, '')}-2025`;
  const accreditation = currentUser?.accreditation || 'AICTE & UGC Recognized • Grade A+ NAAC Accredited';
  const verificationDate = currentUser?.verificationDate || 'Academic Session 2025–2026';
  const adminEmail = currentUser?.email || 'admin@apex.edu';

  const handleCopyCode = () => {
    navigator.clipboard.writeText(instituteCode);
    setCopiedCode(true);
    setTimeout(() => setCopiedCode(false), 2200);
  };

  const handleSendAnnouncement = (e) => {
    e.preventDefault();
    if (!announcementText.trim()) return;
    setAnnouncementSent(true);
    setTimeout(() => {
      setAnnouncementText('');
      setAnnouncementSent(false);
    }, 3000);
  };

  return (
    <div className="institute-home-page-root">
      {/* Top Institute Header Bar */}
      <header className="inst-home-topbar">
        <div className="inst-home-topbar-inner">
          <div className="inst-brand-identity">
            <div className="inst-brand-avatar">
              <Building2 size={24} />
            </div>
            <div className="inst-brand-details">
              <div className="inst-title-row">
                <h1 className="inst-official-name">{instituteName}</h1>
                <span className="inst-verified-pill" title="Officially Verified Institution">
                  <ShieldCheck size={14} className="verified-shield-icon" />
                  <span>Verified Institute</span>
                </span>
              </div>
              <p className="inst-meta-subtitle">
                Official Campus Portal • Code: <strong className="code-tag">{instituteCode}</strong> • {accreditation}
              </p>
            </div>
          </div>

          <div className="inst-topbar-actions">
            

            

            <button
              type="button"
              className="btn-inst-primary"
              onClick={() => onNavigate('select-role')}
            >
              <Layers size={16} />
              <span>Role Gateway</span>
              <ChevronRight size={14} />
            </button>

            {onLogout && (
              <button
                type="button"
                className="btn-inst-logout"
                onClick={onLogout}
                title="Sign out of institute session"
              >
                <LogOut size={16} />
                <span>Logout</span>
              </button>
            )}
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="inst-home-main-content">
        {/* Verification Status & Quick Info Hero */}
        <section className="inst-verification-hero">
          <div className="inst-hero-backdrop-pattern" />

          <div className="inst-hero-content-grid">
            <div className="inst-hero-left">
              <div className="inst-verification-status-badge">
                <CheckCircle2 size={16} className="status-sparkle-icon" />
                <span>Institutional Verification Status: <strong>Active & Confirmed</strong></span>
              </div>

              <h2 className="inst-hero-heading">
                Welcome to {instituteName}
              </h2>

              <p className="inst-hero-description">
                Your institution is officially verified with full administrative privileges. Use this centralized portal
                to access dedicated workspaces for Administrators, Faculty, and Students, distribute your official campus
                institute code, and monitor academic operations.
              </p>

              {/* Institute Code & Verification Details Strip */}
              <div className="inst-code-strip">
                <div className="code-box-wrapper">
                  <span className="code-label">Institute Access Code</span>
                  <div className="code-display-value">
                    <span className="code-string">{instituteCode}</span>
                    <button
                      type="button"
                      className={`btn-code-copy ${copiedCode ? 'copied' : ''}`}
                      onClick={handleCopyCode}
                    >
                      {copiedCode ? (
                        <>
                          <Check size={14} />
                          <span>Copied!</span>
                        </>
                      ) : (
                        <>
                          <Copy size={14} />
                          <span>Copy Code</span>
                        </>
                      )}
                    </button>
                  </div>
                  <span className="code-helper-text">
                    Share this code with your teachers and students for role-based account registration.
                  </span>
                </div>

                <div className="inst-security-box">
                  <div className="security-icon-circle">
                    <ShieldCheck size={28} />
                  </div>
                  <div className="security-info">
                    <h4>Institutional Credential</h4>
                    <p>Certificate: <code>{verificationId}</code></p>
                    <span className="validity-badge">Valid for {verificationDate}</span>
                  </div>
                  <button
                    type="button"
                    className="btn-view-certificate"
                    onClick={() => setShowCertificateModal(true)}
                  >
                    View Official Seal
                  </button>
                </div>
              </div>
            </div>

            {/* Quick Summary Card */}
            <div className="inst-hero-right">
              <div className="inst-summary-card">
                <div className="summary-card-header">
                  <Landmark size={20} className="summary-card-icon" />
                  <h3>Campus Registry Profile</h3>
                </div>

                <ul className="summary-info-list">
                  <li>
                    <span className="info-label">Institute Name:</span>
                    <strong className="info-value">{instituteName}</strong>
                  </li>
                  <li>
                    <span className="info-label">Institute Code:</span>
                    <strong className="info-value highlight-cyan">{instituteCode}</strong>
                  </li>
                  <li>
                    <span className="info-label">Admin Email:</span>
                    <span className="info-value">{adminEmail}</span>
                  </li>
                  <li>
                    <span className="info-label">Accreditation:</span>
                    <span className="info-value">{accreditation}</span>
                  </li>
                  <li>
                    <span className="info-label">Verification ID:</span>
                    <span className="info-value code-snippet">{verificationId}</span>
                  </li>
                  <li>
                    <span className="info-label">Academic Status:</span>
                    <span className="info-value status-active">
                      <span className="status-dot green" />
                      Active & Enrolling
                    </span>
                  </li>
                </ul>

                <button
                  type="button"
                  className="btn-summary-role-hub"
                  onClick={() => onNavigate('select-role')}
                >
                  <Layers size={16} />
                  <span>Open Role Selection Gateway</span>
                  <ArrowRight size={15} />
                </button>
              </div>
            </div>
          </div>
        </section>

        {/* 4 Primary Operational Metric Counters */}
        <section className="inst-metrics-section">
          <div className="inst-metric-card blue">
            <div className="metric-icon-box">
              <Users size={24} />
            </div>
            <div className="metric-data">
              <span className="metric-value">1,420</span>
              <span className="metric-label">Enrolled Students</span>
            </div>
            <div className="metric-footer-note">
              <span>98% Verified Admissions</span>
            </div>
          </div>

          <div className="inst-metric-card teal">
            <div className="metric-icon-box">
              <GraduationCap size={24} />
            </div>
            <div className="metric-data">
              <span className="metric-value">86</span>
              <span className="metric-label">Faculty Members</span>
            </div>
            <div className="metric-footer-note">
              <span>Across 8 Departments</span>
            </div>
          </div>

          <div className="inst-metric-card purple">
            <div className="metric-icon-box">
              <BookOpen size={24} />
            </div>
            <div className="metric-data">
              <span className="metric-value">8</span>
              <span className="metric-label">Active Departments</span>
            </div>
            <div className="metric-footer-note">
              <span>Computer Science, Eng, Mgmt...</span>
            </div>
          </div>

          <div className="inst-metric-card green">
            <div className="metric-icon-box">
              <ShieldCheck size={24} />
            </div>
            <div className="metric-data">
              <span className="metric-value">100%</span>
              <span className="metric-label">Verification Health</span>
            </div>
            <div className="metric-footer-note">
              <span>Full Access Unlocked</span>
            </div>
          </div>
        </section>

        {/* Institutional Tools: Announcements & Verification Certificate */}
        <section className="inst-tools-grid-section">
          {/* Quick Broadcast Announcement */}
          <div className="inst-tool-card announcement-tool">
            <div className="tool-card-header">
              <div className="tool-icon-circle blue">
                <BellRing size={20} />
              </div>
              <div>
                <h3>Broadcast Announcement to Campus</h3>
                <p>Send an instant notification to all registered faculty and students of {instituteName}.</p>
              </div>
            </div>

            <form onSubmit={handleSendAnnouncement} className="announcement-form">
              <textarea
                className="announcement-textarea"
                rows={3}
                placeholder="Type your official announcement here (e.g. Mid-term examination schedule released)..."
                value={announcementText}
                onChange={(e) => setAnnouncementText(e.target.value)}
              />

              <div className="announcement-form-footer">
                {announcementSent ? (
                  <div className="announcement-success">
                    <CheckCircle2 size={16} />
                    <span>Announcement successfully broadcasted!</span>
                  </div>
                ) : (
                  <span className="announcement-hint">Visible on student and teacher dashboards.</span>
                )}
                <button
                  type="submit"
                  className="btn-send-announcement"
                  disabled={!announcementText.trim() || announcementSent}
                >
                  <span>Broadcast Now</span>
                  <ArrowRight size={15} />
                </button>
              </div>
            </form>
          </div>

          {/* Institutional Compliance Card */}
          <div className="inst-tool-card compliance-tool">
            <div className="tool-card-header">
              <div className="tool-icon-circle green">
                <Award size={20} />
              </div>
              <div>
                <h3>Accreditation & Compliance</h3>
                <p>Digital institutional credentials validated for official operation.</p>
              </div>
            </div>

            <div className="compliance-checklist">
              <div className="compliance-row">
                <CheckCheck size={18} className="compliance-check-icon" />
                <div>
                  <strong>Campus Verification Token</strong>
                  <p>Certified ID: <code>{verificationId}</code></p>
                </div>
              </div>

              <div className="compliance-row">
                <CheckCheck size={18} className="compliance-check-icon" />
                <div>
                  <strong>Accreditation Level</strong>
                  <p>{accreditation}</p>
                </div>
              </div>

              <div className="compliance-row">
                <CheckCheck size={18} className="compliance-check-icon" />
                <div>
                  <strong>Role Isolation & Access Security</strong>
                  <p>Admin, Teacher, and Student databases separated with strict RBAC rules.</p>
                </div>
              </div>
            </div>

            <button
              type="button"
              className="btn-open-cert-modal"
              onClick={() => setShowCertificateModal(true)}
            >
              <FileText size={16} />
              <span>Inspect Official Certificate</span>
            </button>
          </div>
        </section>
      </main>

      {/* Official Certificate Modal */}
      {showCertificateModal && (
        <div className="inst-modal-backdrop" onClick={() => setShowCertificateModal(false)}>
          <div className="inst-certificate-modal" onClick={(e) => e.stopPropagation()}>
            <button
              type="button"
              className="btn-close-modal"
              onClick={() => setShowCertificateModal(false)}
            >
              ✕
            </button>

            <div className="cert-inner-frame">
              <div className="cert-header">
                <div className="cert-seal">
                  <ShieldCheck size={42} />
                </div>
                <span className="cert-kicker">Academic Management Platform Verification Certificate</span>
                <h2 className="cert-institution-title">{instituteName}</h2>
                <span className="cert-badge">Officially Verified & Accredited Institution</span>
              </div>

              <div className="cert-body">
                <p>
                  This is to certify that <strong>{instituteName}</strong> (Institutional ID: <code>{instituteCode}</code>)
                  has successfully undergone validation and verification on the Academic Management Portal.
                </p>
                <div className="cert-details-grid">
                  <div className="cert-detail-item">
                    <span>Certificate Serial</span>
                    <strong>{verificationId}</strong>
                  </div>
                  <div className="cert-detail-item">
                    <span>Validation Period</span>
                    <strong>{verificationDate}</strong>
                  </div>
                  <div className="cert-detail-item">
                    <span>Status</span>
                    <strong className="status-valid">Active & Verified</strong>
                  </div>
                  <div className="cert-detail-item">
                    <span>Accreditation</span>
                    <strong>{accreditation}</strong>
                  </div>
                </div>
              </div>

              <div className="cert-footer">
                <div className="cert-signature">
                  <div className="signature-line" />
                  <span>Central Accreditation Board</span>
                </div>
                <button
                  type="button"
                  className="btn-cert-done"
                  onClick={() => setShowCertificateModal(false)}
                >
                  Close Certificate
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
