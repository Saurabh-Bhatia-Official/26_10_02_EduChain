import React from 'react';
import {
  Building2,
  Users,
  GraduationCap,
  FileCheck2,
  Shield,
  Zap,
  Lock,
  Smartphone,
  Sparkles,
  LogIn,
  CheckCircle2,
  ShieldCheck,
  Mail,
  Phone,
  MapPin,
  ArrowRight,
  BookOpen,
} from 'lucide-react';

import InstituteBuildingIllustration from '../components/illustrations/InstituteBuildingIllustration';

export default function HomePage({ onNavigate, currentUser }) {
  const isInstituteLoggedIn = currentUser?.role === 'institute';

  const features = [
    {
      title: 'Institute Management',
      description:
        'Manage institute administration, campus settings, and role-based access controls efficiently.',
      status: 'Institute Administration',
      color: 'blue',
      Icon: Building2,
    },
    {
      title: 'Teacher Management',
      description:
        'Manage classes, faculty schedules, lesson planning, and student marks grading.',
      status: 'Faculty Management',
      color: 'teal',
      Icon: Users,
    },
    {
      title: 'Student Management',
      description:
        'Access learning resources, timetable schedules, course progress, and exam results.',
      status: 'Student Dashboard',
      color: 'purple',
      Icon: GraduationCap,
    },
    {
      title: 'Examination & Results',
      description:
        'Manage online assessments, generate verified report cards, and monitor academic analytics.',
      status: 'Academic Analytics',
      color: 'orange',
      Icon: FileCheck2,
    },
  ];

  const whyChooseItems = [
    {
      icon: Shield,
      title: 'Secure & Reliable',
      description: 'Your institution data is protected with role authentication and audit trails.',
    },
    {
      icon: Zap,
      title: 'Easy to Use',
      description: 'Clean, intuitive user interface designed for fast daily academic operations.',
    },
    {
      icon: Lock,
      title: 'Role Based Access',
      description: 'Dedicated and separated portals for Institute, Admin, Teacher, and Student.',
    },
    {
      icon: Smartphone,
      title: 'Access Anywhere',
      description: 'Fully responsive system available across desktops, tablets, and smartphones.',
    },
  ];

  return (
    <div className="home-page-container">
      {/* If Institute is logged in, show verified session banner */}
      {isInstituteLoggedIn && (
        <aside className="institute-active-banner">
          <div className="active-banner-info">
            <span className="active-badge">Institute Verified</span>
            <span>
              Logged in to <strong>{currentUser.instituteName || 'Apex Institute'}</strong> ({currentUser.instituteCode || 'INST-2025'})
            </span>
          </div>
          <button
            type="button"
            className="btn-enter-role-portal"
            onClick={() => onNavigate('institute-home')}
          >
            <span>Open Institute Dashboard</span>
            <ArrowRight size={16} />
          </button>
        </aside>
      )}

      {/* Hero Section */}
      <section className="hero-section" id="home">
        <div className="hero-content">
          <div className="hero-badge">
            <Sparkles size={14} className="badge-sparkle" />
            <span>Academic Management Platform</span>
          </div>

          <h1 className="hero-title">
            Welcome to <br />
            <span className="hero-title-highlight">Institute Portal</span>
          </h1>

          <p className="hero-lead-text">
            Manage your institute, teachers and students from one platform.
          </p>

          <p className="hero-subtitle">
            A smart and simple solution for academic management,
            designed to make education more efficient and organized.
          </p>

          <div className="hero-actions">
            {isInstituteLoggedIn ? (
              <>
                <button
                  type="button"
                  className="btn-primary hero-btn-main"
                  onClick={() => onNavigate('institute-home')}
                >
                  <Building2 size={18} />
                  <span>Go to Institute Dashboard</span>
                </button>
                <button
                  type="button"
                  className="btn-secondary hero-btn-register"
                  onClick={() => onNavigate('select-role')}
                >
                  <Users size={18} />
                  <span>Open Role Gateway</span>
                </button>
              </>
            ) : (
              <>
                <button
                  type="button"
                  className="btn-primary hero-btn-main"
                  onClick={() => onNavigate('institute-login')}
                >
                  <LogIn size={18} />
                  <span>INSTITUTE Login</span>
                </button>
                <button
                  type="button"
                  className="btn-secondary hero-btn-register"
                  onClick={() => onNavigate('institute-register')}
                >
                  <Building2 size={18} />
                  <span>INSTITUTE Register</span>
                </button>
              </>
            )}
          </div>
        </div>

        <div className="hero-illustration-col">
          <InstituteBuildingIllustration />
        </div>
      </section>

      {/* Features Section */}
      <section className="management-cards-section" id="features">
        <div className="home-section-heading">
          <span className="home-section-label">OUR FEATURES</span>
          <h2>Everything You Need in One Portal</h2>
          <p>
            Simplify academic administration with tools designed for institutes, teachers, and students.
          </p>
        </div>

        <div className="cards-grid-4">
          {features.map((feature) => {
            const Icon = feature.Icon;
            return (
              <div className="portal-feature-card" key={feature.title}>
                <div className={`feature-card-icon-box ${feature.color}`}>
                  <Icon size={26} />
                </div>
                <h3 className="feature-card-title">{feature.title}</h3>
                <p className="feature-card-desc">{feature.description}</p>
                <div className={`feature-card-status ${feature.color}`}>
                  <CheckCircle2 size={14} className={`status-check ${feature.color}`} />
                  <span>{feature.status}</span>
                </div>
              </div>
            );
          })}
        </div>
      </section>

      {/* Why Choose Institute Portal Section */}
      <section className="why-choose-section">
        <h2 className="why-choose-title">Why Choose Institute Portal?</h2>
        <div className="why-choose-grid">
          {whyChooseItems.map((item) => {
            const Icon = item.icon;
            return (
              <div className="why-pill-card" key={item.title}>
                <div className="why-pill-icon blue">
                  <Icon size={20} />
                </div>
                <div className="why-pill-text">
                  <h4>{item.title}</h4>
                  <p>{item.description}</p>
                </div>
              </div>
            );
          })}
        </div>
      </section>

      {/* About Section */}
      <section className="home-about-section" id="about">
        <div className="home-about-content">
          <span className="home-section-label">ABOUT US</span>
          <h2>
            Making Academic Management{' '}
            <span className="hero-title-highlight">Simple and Smart</span>
          </h2>
          <p>
            Institute Portal is designed to bring essential academic activities together in one organized platform.
            It helps institutes manage administration and supports teachers and students with a centralized digital experience.
          </p>
          <p>
            Our goal is to simplify everyday academic tasks, improve coordination, and make important educational information easier to manage.
          </p>

          <div className="home-about-benefits">
            <div className="home-about-benefit">
              <ShieldCheck size={20} />
              <span>Organized access management</span>
            </div>
            <div className="home-about-benefit">
              <BookOpen size={20} />
              <span>Centralized academic resources</span>
            </div>
            <div className="home-about-benefit">
              <Users size={20} />
              <span>Support for teachers and students</span>
            </div>
          </div>

          <button
            type="button"
            className="btn-primary home-about-btn"
            onClick={() =>
              onNavigate(
                isInstituteLoggedIn
                  ? 'institute-home'
                  : 'institute-register'
              )
            }
          >
            <span>
              {isInstituteLoggedIn
                ? 'Open Institute Dashboard'
                : 'Register Your Institute'}
            </span>
            <ArrowRight size={17} />
          </button>
        </div>
      </section>

      {/* Clean Institute Onboarding CTA Section */}
      <section className="institute-cta-section">
        <div className="institute-cta-card">
          <div className="institute-cta-text">
            <h3>Get Started with Institute Portal</h3>
            <p>
              Log in to your verified institute account to access dedicated admin, faculty, and student portals.
            </p>
          </div>
          <div className="institute-cta-actions">
            {isInstituteLoggedIn ? (
              <>
                <button
                  type="button"
                  className="btn-primary btn-cta-inst"
                  onClick={() => onNavigate('institute-home')}
                >
                  Open Institute Dashboard
                </button>
                <button
                  type="button"
                  className="btn-secondary btn-cta-reg"
                  onClick={() => onNavigate('select-role')}
                >
                  Role Gateway
                </button>
              </>
            ) : (
              <>
                <button
                  type="button"
                  className="btn-primary btn-cta-inst"
                  onClick={() => onNavigate('institute-login')}
                >
                  INSTITUTE Login
                </button>
                <button
                  type="button"
                  className="btn-secondary btn-cta-reg"
                  onClick={() => onNavigate('institute-register')}
                >
                  Register Institute
                </button>
              </>
            )}
          </div>
        </div>
      </section>

      {/* Contact Details Section */}
      <section className="home-contact-section" id="contact">
        <div className="home-section-heading">
          <span className="home-section-label">CONTACT US</span>
          <h2>Get in Touch with Our Team</h2>
          <p>
            Have questions about Institute Portal or need assistance setting up your campus? Contact our support team.
          </p>
        </div>

        <div className="home-contact-grid">
          {/* Email */}
          <div className="home-contact-card">
            <div className="home-contact-icon">
              <Mail size={24} />
            </div>
            <h3>Email Us</h3>
            <p>Send us your questions or inquiries anytime.</p>
            <a href="mailto:support@yourinstituteportal.com">
              support@yourinstituteportal.com
            </a>
          </div>

          {/* Phone */}
          <div className="home-contact-card">
            <div className="home-contact-icon">
              <Phone size={24} />
            </div>
            <h3>Call Us</h3>
            <p>Contact our support team for direct assistance.</p>
            <a href="tel:+910000000000">
              +91 00000 00000
            </a>
          </div>

          {/* Address */}
          <div className="home-contact-card">
            <div className="home-contact-icon">
              <MapPin size={24} />
            </div>
            <h3>Our Campus Office</h3>
            <p>
              Institute Portal Support Office
              <br />
              Tech City Campus, Innovation Tower, Suite 400
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
