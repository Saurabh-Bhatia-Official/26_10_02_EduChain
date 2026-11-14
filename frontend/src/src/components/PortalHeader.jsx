import React from 'react';
import { Landmark, ArrowLeft, Home, LogOut } from 'lucide-react';

export default function PortalHeader({
  onNavigate,
  backTarget = 'home',
  backLabel = 'Back to Home',
  currentUser,
  onLogout,
}) {
  return (
    <header className="portal-header">
      <div className="portal-header-inner">
        {/* Brand Logo */}
        <div
          className="portal-brand-clickable"
          onClick={() => onNavigate('home')}
          role="button"
          tabIndex={0}
          title="Return to Home Page"
        >
          <div className="portal-brand-icon-box">
            <Landmark size={20} className="portal-brand-icon" />
          </div>
          <span className="portal-brand-title">Institute Portal</span>
        </div>

        {/* Action Buttons: Back + Optional Logout */}
        <div className="portal-header-actions">
          <button
            type="button"
            className="btn-portal-back"
            onClick={() => onNavigate(backTarget)}
          >
            {backTarget === 'home' ? (
              <Home size={15} />
            ) : (
              <ArrowLeft size={15} />
            )}
            <span>{backLabel}</span>
          </button>

          {onLogout && currentUser && (
            <button
              type="button"
              className="btn-portal-logout"
              onClick={onLogout}
              title="Logout from current session"
            >
              <LogOut size={15} />
              <span>Logout</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
