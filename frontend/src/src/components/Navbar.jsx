import React, { useState } from 'react';
import {
  Landmark,
  Building2,
  Menu,
  X,
  LogIn,
  LogOut,
  ShieldCheck,
  ChevronRight,
  GraduationCap
} from 'lucide-react';

export default function Navbar({ currentPage, onNavigate, currentUser, onLogout }) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const isInstituteLoggedIn = currentUser?.role === 'institute';
  const isStudentLoggedIn = currentUser?.role === 'student';
  const isTeacherLoggedIn = currentUser?.role === 'teacher';

  const scrollToSection = (id) => {
    if (currentPage !== 'home') {
      onNavigate('home');
      setTimeout(() => {
        const el = document.getElementById(id);
        if (el) el.scrollIntoView({ behavior: 'smooth' });
      }, 100);
    } else {
      const el = document.getElementById(id);
      if (el) el.scrollIntoView({ behavior: 'smooth' });
    }
    setMobileMenuOpen(false);
  };

  return (
    <header className="navbar-container">
      <div className="navbar-inner">
        {/* Brand Logo */}
        <div
          className="navbar-logo"
          onClick={() => onNavigate('home')}
          role="button"
          tabIndex={0}
        >
          <div className="logo-icon-box">
            <Landmark className="logo-icon" size={22} />
          </div>
          <span className="logo-text">Institute Portal</span>
        </div>

        {/* Desktop Navigation Links */}
        <nav className="navbar-nav-links">
          <button
            type="button"
            className={`nav-link ${currentPage === 'home' ? 'active' : ''}`}
            onClick={() => {
              onNavigate('home');
              window.scrollTo({ top: 0, behavior: 'smooth' });
            }}
          >
            Home
          </button>
          <button
            type="button"
            className="nav-link"
            onClick={() => scrollToSection('about')}
          >
            About
          </button>
          <button
            type="button"
            className="nav-link"
            onClick={() => scrollToSection('features')}
          >
            Features
          </button>
          <button
            type="button"
            className="nav-link"
            onClick={() => scrollToSection('contact')}
          >
            Contact
          </button>
        </nav>

        {/* Right Section: Auth Buttons / Active Profile */}
        <div className="navbar-actions">
          {isTeacherLoggedIn ? (
            <div className="navbar-logged-institute-group">
              <button
                type="button"
                className="navbar-inst-badge clickable"
                style={{ background: '#e0f2fe', color: '#0369a1', borderColor: '#bae6fd' }}
                onClick={() => onNavigate('teacher-dashboard')}
                title="Go to Instructor Dashboard"
              >
                <GraduationCap size={15} />
                <span>{currentUser?.name || 'Dr. Amit Sharma'} (Instructor)</span>
              </button>
              <button
                type="button"
                className="btn-navbar-inst-role-gateway"
                style={{ background: '#0284c7', color: '#ffffff' }}
                onClick={() => onNavigate('teacher-dashboard')}
                title="Open Instructor Portal"
              >
                <span>Instructor Portal</span>
                <ChevronRight size={14} />
              </button>
              <button
                type="button"
                className="btn-navbar-logout"
                onClick={onLogout}
                title="Logout"
              >
                <LogOut size={15} />
              </button>
            </div>
          ) : isStudentLoggedIn ? (
            <div className="navbar-logged-institute-group">
              <button
                type="button"
                className="navbar-inst-badge clickable"
                style={{ background: '#f3e8ff', color: '#7c3aed', borderColor: '#d8b4fe' }}
                onClick={() => onNavigate('student-dashboard')}
                title="Go to Student Dashboard"
              >
                <GraduationCap size={15} />
                <span>{currentUser?.name || 'Rahul Sharma'} (Student)</span>
              </button>
              <button
                type="button"
                className="btn-navbar-inst-role-gateway"
                style={{ background: '#7c3aed', color: '#ffffff' }}
                onClick={() => onNavigate('student-dashboard')}
                title="Open Student Dashboard"
              >
                <span>Student Portal</span>
                <ChevronRight size={14} />
              </button>
              <button
                type="button"
                className="btn-navbar-logout"
                onClick={onLogout}
                title="Logout"
              >
                <LogOut size={15} />
              </button>
            </div>
          ) : isInstituteLoggedIn ? (
            <div className="navbar-logged-institute-group">
              <button
                type="button"
                className="navbar-inst-badge clickable"
                onClick={() => onNavigate('institute-home')}
                title="Go to Institute Home"
              >
                <ShieldCheck size={15} />
                <span>{currentUser.instituteName || 'Apex Institute'}</span>
              </button>
              <button
                type="button"
                className="btn-navbar-inst-role-gateway"
                onClick={() => onNavigate('institute-home')}
                title="Open Institute Home Page"
              >
                <span>Institute Home</span>
                <ChevronRight size={14} />
              </button>
              <button
                type="button"
                className="btn-navbar-logout"
                onClick={onLogout}
                title="Logout from Institute"
              >
                <LogOut size={15} />
              </button>
            </div>
          ) : (
            <>
              {/* INSTITUTE Login Button matching Screen 1 */}
              <button
                type="button"
                className={`btn-navbar-inst-login ${currentPage === 'institute-login' ? 'active-btn' : ''}`}
                onClick={() => onNavigate('institute-login')}
              >
                INSTITUTE Login
              </button>

              {/* INSTITUTE Register Button matching Screen 1 */}
              <button
                type="button"
                className="btn-navbar-inst-register"
                onClick={() => onNavigate('institute-register')}
              >
                INSTITUTE Register
              </button>
            </>
          )}

          {/* Mobile Hamburger Button */}
          <button
            type="button"
            className="mobile-toggle-btn"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Toggle navigation"
          >
            {mobileMenuOpen ? <X size={22} /> : <Menu size={22} />}
          </button>
        </div>
      </div>

      {/* Mobile Drawer Menu */}
      {mobileMenuOpen && (
        <div className="mobile-drawer">
          <div className="mobile-links">
            <button
              type="button"
              className={`mobile-nav-link ${currentPage === 'home' ? 'active' : ''}`}
              onClick={() => {
                onNavigate('home');
                setMobileMenuOpen(false);
              }}
            >
              Home
            </button>
            <button
              type="button"
              className="mobile-nav-link"
              onClick={() => scrollToSection('about')}
            >
              About
            </button>
            <button
              type="button"
              className="mobile-nav-link"
              onClick={() => scrollToSection('features')}
            >
              Features
            </button>
            <button
              type="button"
              className="mobile-nav-link"
              onClick={() => scrollToSection('contact')}
            >
              Contact
            </button>
          </div>

          <div className="mobile-auth-section">
            {isInstituteLoggedIn ? (
              <>
                <button
                  type="button"
                  className="btn-mobile-signup primary"
                  onClick={() => {
                    onNavigate('institute-home');
                    setMobileMenuOpen(false);
                  }}
                >
                  <Building2 size={16} /> Institute Home
                </button>
                <button
                  type="button"
                  className="btn-mobile-signup"
                  style={{ background: '#e0f2fe', color: '#0369a1' }}
                  onClick={() => {
                    onNavigate('select-role');
                    setMobileMenuOpen(false);
                  }}
                >
                  <LogIn size={16} /> Enter Role Portals
                </button>
                <button
                  type="button"
                  className="btn-mobile-login"
                  onClick={() => {
                    onLogout();
                    setMobileMenuOpen(false);
                  }}
                >
                  <LogOut size={16} /> Logout Institute
                </button>
              </>
            ) : (
              <>
                <button
                  type="button"
                  className="btn-mobile-login"
                  onClick={() => {
                    onNavigate('institute-login');
                    setMobileMenuOpen(false);
                  }}
                >
                  <Building2 size={16} /> INSTITUTE Login
                </button>
                <button
                  type="button"
                  className="btn-mobile-signup primary"
                  onClick={() => {
                    onNavigate('institute-register');
                    setMobileMenuOpen(false);
                  }}
                >
                  <Building2 size={16} /> INSTITUTE Register
                </button>
              </>
            )}
          </div>
        </div>
      )}
    </header>
  );
}
