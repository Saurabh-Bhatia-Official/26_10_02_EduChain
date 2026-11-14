import React from 'react';
import { Landmark, Building2, ShieldCheck, Lock } from 'lucide-react';

export default function Footer({ onNavigate }) {
  const scrollTo = (id) => {
    const el = document.getElementById(id);
    if (el) {
      el.scrollIntoView({ behavior: 'smooth' });
    } else {
      onNavigate('home');
      setTimeout(() => {
        const target = document.getElementById(id);
        if (target) target.scrollIntoView({ behavior: 'smooth' });
      }, 150);
    }
  };

  return (
    <footer className="footer-container">
      <div className="footer-inner">
        <div className="footer-brand-col">
          <div className="navbar-logo" onClick={() => onNavigate('home')} role="button" tabIndex={0}>
            <div className="logo-icon-box">
              <Landmark className="logo-icon" size={20} />
            </div>
            <span className="logo-text">Institute Portal</span>
          </div>
          <p className="footer-brand-desc">
            A smart and simple solution for academic management, designed to make education more efficient and organized.
          </p>
        </div>

        <div className="footer-links-col">
          <h4 className="footer-heading">Navigation</h4>
          <button type="button" className="footer-link" onClick={() => onNavigate('home')}>Home</button>
          <button type="button" className="footer-link" onClick={() => scrollTo('about')}>About Platform</button>
          <button type="button" className="footer-link" onClick={() => scrollTo('features')}>Management Features</button>
          <button type="button" className="footer-link" onClick={() => scrollTo('contact')}>Contact Us</button>
        </div>

        <div className="footer-links-col">
          <h4 className="footer-heading">Institute Access</h4>
          <button type="button" className="footer-link" onClick={() => onNavigate('institute-login')}>
            INSTITUTE Login
          </button>
          <button type="button" className="footer-link" onClick={() => onNavigate('institute-register')}>
            Register Institute
          </button>
          <button type="button" className="footer-link" onClick={() => onNavigate('forgot-password', { role: 'institute' })}>
            Reset Password
          </button>
        </div>

        <div className="footer-links-col">
          <h4 className="footer-heading">Role Portals</h4>
          <p style={{ fontSize: '0.8rem', color: '#64748b', lineHeight: 1.4, marginBottom: '6px' }}>
            Admin, Teacher & Student dashboards are accessible after institute verification.
          </p>
          <button type="button" className="footer-link" onClick={() => onNavigate('institute-login')}>
            Unlock with Institute Code →
          </button>
        </div>
      </div>

      <div className="footer-bottom-bar">
        <p>© 2025 Institute Portal. All rights reserved.</p>
        <div className="footer-bottom-links">
          <span className="footer-bottom-link" onClick={() => onNavigate('home')}>Home</span>
          <span className="footer-dot">•</span>
          <span className="footer-bottom-link" onClick={() => scrollTo('about')}>About</span>
          <span className="footer-dot">•</span>
          <span className="footer-bottom-link" onClick={() => scrollTo('features')}>Features</span>
          <span className="footer-dot">•</span>
          <span className="footer-bottom-link" onClick={() => scrollTo('contact')}>Contact</span>
        </div>
      </div>
    </footer>
  );
}
