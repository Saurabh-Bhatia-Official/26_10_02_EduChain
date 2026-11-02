import React, { useState, useEffect } from 'react';
import Navbar from './components/Navbar';
import Footer from './components/Footer';

// The 10 Dedicated Pages matching User's Flowchart Diagram + Dedicated Institute Home
import HomePage from './pages/HomePage';
import InstituteHomePage from './pages/InstituteHomePage';
import InstituteRegistrationPage from './pages/InstituteRegistrationPage';
import InstituteLoginPage from './pages/InstituteLoginPage';
import SelectRolePage from './pages/SelectRolePage';
import StudentRegistrationPage from './pages/StudentRegistrationPage';
import TeacherRegistrationPage from './pages/TeacherRegistrationPage';
import AdminLoginPage from './pages/AdminLoginPage';
import TeacherLoginPage from './pages/TeacherLoginPage';
import StudentLoginPage from './pages/StudentLoginPage';
import ForgotPasswordPage from './pages/ForgotPasswordPage';
import StudentPortalPage from './pages/StudentPortalPage';
import TeacherPortalPage from './pages/TeacherPortalPage';
import AdminPortalPage from './pages/AdminPortalPage';

import api from './services/api';
import './App.css';

export default function App() {
  // Page state can be any of the screen IDs:
  // 'home', 'institute-home', 'institute-register', 'institute-login', 'select-role',
  // 'student-register', 'teacher-register', 'admin-login', 'teacher-login',
  // 'student-login', 'forgot-password', 'student-dashboard', etc.
  // Always start on 'home' page
  const [currentPage, setCurrentPage] = useState(() => {
    const hash = window.location.hash.replace('#', '');
    const validPages = [
      'home',
      'institute-home',
      'institute-register',
      'institute-login',
      'select-role',
      'student-register',
      'teacher-register',
      'admin-login',
      'teacher-login',
      'student-login',
      'forgot-password',
      // Student Portal Module & Exam Pages
      'student-dashboard',
      'student-profile',
      'student-attendance',
      'student-grades',
      'student-schedule',
      'student-materials',
      'student-timetable',
      'student-exams',
      'student-parents',
      'student-exam-instructions',
      'student-exam-live',
      'student-exam-submitted',
      'student-exam-results',
      // Teacher / Instructor Portal Module Pages (12 Screens)
      'teacher-dashboard',
      'teacher-classes',
      'teacher-students',
      'teacher-add-student',
      'teacher-student-detail',
      'teacher-courses',
      'teacher-add-course',
      'teacher-remove-course',
      'teacher-course-details',
      'teacher-lectures',
      'teacher-update-lecture',
      'teacher-profile',
      'instructor-dashboard',
      'instructor-classes',
      'instructor-students',
      'instructor-courses',
      'instructor-lectures',
      'instructor-profile',
      // Admin Portal Module Pages (15 Screens)
      'admin-dashboard',
      'admin-students',
      'admin-student-records',
      'admin-add-student',
      'admin-student-detail',
      'admin-instructors',
      'admin-instructor-records',
      'admin-instructor-tracking',
      'admin-add-instructor',
      'admin-classes',
      'admin-class-management',
      'admin-academic-planning',
      'admin-lecture-schedule',
      'admin-exam-timetable',
      'admin-create-exam',
      'admin-cross-module',
      'admin-global-records',
      'admin-reports',
      'admin-analytics',
      'admin-profile',
      'admin-settings',
      // backward compatibility aliases
      'login',
    ];
    // Start page of this website is ALWAYS 'home' unless explicitly navigating to another valid sub-page
    if (hash && hash !== 'institute-home' && validPages.includes(hash)) {
      if (hash === 'login') return 'select-role';
      return hash;
    }
    // Clean URL hash if it was pointing to institute-home so user starts on home page
    if (window.location.hash === '#institute-home') {
      window.history.replaceState(null, '', window.location.pathname);
    }
    return 'home';
  });

  const [pageParams, setPageParams] = useState({});
  const [currentUser, setCurrentUser] = useState(() => api.getCurrentUser());

  // Sync state with URL hash
  useEffect(() => {
    // If URL hash was pointing to #institute-home on initial load, reset to clean URL
    if (window.location.hash === '#institute-home') {
      window.history.replaceState(null, '', window.location.pathname);
    }

    const handleHashChange = () => {
      const hash = window.location.hash.replace('#', '');
      const validPages = [
        'home',
        'institute-home',
        'institute-register',
        'institute-login',
        'select-role',
        'student-register',
        'teacher-register',
        'admin-login',
        'teacher-login',
        'student-login',
        'forgot-password',
        // Student Portal
        'student-dashboard',
        'student-profile',
        'student-attendance',
        'student-grades',
        'student-schedule',
        'student-materials',
        'student-timetable',
        'student-exams',
        'student-parents',
        'student-exam-instructions',
        'student-exam-live',
        'student-exam-submitted',
        'student-exam-results',
        // Teacher / Instructor Portal
        'teacher-dashboard',
        'teacher-classes',
        'teacher-students',
        'teacher-add-student',
        'teacher-student-detail',
        'teacher-courses',
        'teacher-add-course',
        'teacher-remove-course',
        'teacher-course-details',
        'teacher-lectures',
        'teacher-update-lecture',
        'teacher-profile',
        'instructor-dashboard',
        'instructor-classes',
        'instructor-students',
        'instructor-courses',
        'instructor-lectures',
        'instructor-profile',
        // Admin Portal Module Pages (15 Screens)
        'admin-dashboard',
        'admin-students',
        'admin-student-records',
        'admin-add-student',
        'admin-student-detail',
        'admin-instructors',
        'admin-instructor-records',
        'admin-instructor-tracking',
        'admin-add-instructor',
        'admin-classes',
        'admin-class-management',
        'admin-academic-planning',
        'admin-lecture-schedule',
        'admin-exam-timetable',
        'admin-create-exam',
        'admin-cross-module',
        'admin-global-records',
        'admin-reports',
        'admin-analytics',
        'admin-profile',
        'admin-settings',
        'login',
      ];
      if (validPages.includes(hash)) {
        if (hash === 'login') {
          setCurrentPage('select-role');
        } else {
          setCurrentPage(hash);
        }
      } else {
        setCurrentPage('home');
      }
    };

    window.addEventListener('hashchange', handleHashChange);
    return () => window.removeEventListener('hashchange', handleHashChange);
  }, []);

  const navigateTo = (page, params = {}) => {
    let targetPage = page;
    if (page === 'login') {
      if (params.role === 'admin') targetPage = 'admin-login';
      else if (params.role === 'teacher') targetPage = 'teacher-login';
      else if (params.role === 'student') targetPage = 'student-login';
      else if (params.role === 'institute') targetPage = 'institute-login';
      else targetPage = 'select-role';
    } else if (page === 'register') {
      if (params.role === 'teacher') targetPage = 'teacher-register';
      else if (params.role === 'student') targetPage = 'student-register';
      else if (params.role === 'institute' || params.role === 'admin') targetPage = 'institute-register';
      else targetPage = 'select-role';
    }

    setPageParams(params);
    setCurrentPage(targetPage);
    if (targetPage === 'home') {
      window.history.replaceState(null, '', window.location.pathname);
    } else {
      window.location.hash = targetPage;
    }
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleLoginSuccess = (user) => {
    setCurrentUser(user);
    if (user?.role === 'student') {
      navigateTo('student-dashboard');
    } else if (user?.role === 'teacher') {
      navigateTo('teacher-dashboard');
    } else if (user?.role === 'admin') {
      navigateTo('admin-dashboard');
    } else if (user?.role === 'institute') {
      navigateTo('institute-home');
    } else {
      navigateTo('institute-home');
    }
  };

  const handleRegisterSuccess = (user) => {
    setCurrentUser(user);
    if (user?.role === 'student') {
      navigateTo('student-dashboard');
    } else if (user?.role === 'teacher') {
      navigateTo('teacher-dashboard');
    } else if (user?.role === 'admin') {
      navigateTo('admin-dashboard');
    } else if (user?.role === 'institute') {
      navigateTo('institute-home');
    } else {
      navigateTo('institute-home');
    }
  };

  const handleLogout = () => {
    api.logout();
    setCurrentUser(null);
    navigateTo('institute-home');
  };

  const isStudentPortal =
    currentPage.startsWith('student-') &&
    currentPage !== 'student-login' &&
    currentPage !== 'student-register';

  const isTeacherPortal =
    (currentPage.startsWith('teacher-') || currentPage.startsWith('instructor-')) &&
    currentPage !== 'teacher-login' &&
    currentPage !== 'teacher-register';

  const isAdminPortal =
    currentPage.startsWith('admin-') &&
    currentPage !== 'admin-login';

  return (
    <div className="app-root">

      {/* Main Navigation (Rendered on Home page) */}
      {currentPage === 'home' && (
        <Navbar
          currentPage={currentPage}
          onNavigate={navigateTo}
          currentUser={currentUser}
          onLogout={handleLogout}
        />
      )}

      {/* Dynamic Page Views matching All 10 Screens */}
      <main className="main-content-area">
        {/* 1. Home Page (Clean Public Website Landing Page) */}
        {currentPage === 'home' && (
          <HomePage
            onNavigate={navigateTo}
            currentUser={currentUser}
          />
        )}

        {/* Dedicated Institute Home Page (Personalized with Institute Name & Verification) */}
        {currentPage === 'institute-home' && (
          <InstituteHomePage
            onNavigate={navigateTo}
            currentUser={currentUser}
            onLogout={handleLogout}
          />
        )}

        {/* 2. Institute Registration Page */}
        {currentPage === 'institute-register' && (
          <InstituteRegistrationPage
            onNavigate={navigateTo}
            onRegisterSuccess={handleRegisterSuccess}
          />
        )}

        {/* 3. Institute Login Page */}
        {currentPage === 'institute-login' && (
          <InstituteLoginPage
            onNavigate={navigateTo}
            onLoginSuccess={handleLoginSuccess}
          />
        )}

        {/* 4. Select Role Page (Unlocked via Institute Login) */}
        {currentPage === 'select-role' && (
          <SelectRolePage
            onNavigate={navigateTo}
            initialMode={pageParams.mode || 'login'}
            currentUser={currentUser}
            onLogout={handleLogout}
            onQuickUnlock={() =>
              handleLoginSuccess({
                role: 'institute',
                instituteCode: 'INST-2025',
                name: 'Institute Admin',
                instituteName: 'Apex Institute',
              })
            }
          />
        )}

        {/* 5. Student Registration Page */}
        {currentPage === 'student-register' && (
          <StudentRegistrationPage
            onNavigate={navigateTo}
            onRegisterSuccess={handleRegisterSuccess}
          />
        )}

        {/* 6. Teacher Registration Page */}
        {currentPage === 'teacher-register' && (
          <TeacherRegistrationPage
            onNavigate={navigateTo}
            onRegisterSuccess={handleRegisterSuccess}
          />
        )}

        {/* 7. Admin Login Page */}
        {currentPage === 'admin-login' && (
          <AdminLoginPage
            onNavigate={navigateTo}
            onLoginSuccess={handleLoginSuccess}
          />
        )}

        {/* 8. Teacher Login Page */}
        {currentPage === 'teacher-login' && (
          <TeacherLoginPage
            onNavigate={navigateTo}
            onLoginSuccess={handleLoginSuccess}
          />
        )}

        {/* 9. Student Login Page */}
        {currentPage === 'student-login' && (
          <StudentLoginPage
            onNavigate={navigateTo}
            onLoginSuccess={handleLoginSuccess}
          />
        )}

        {/* 10. Forgot Password Page */}
        {currentPage === 'forgot-password' && (
          <ForgotPasswordPage
            onNavigate={navigateTo}
            initialRole={pageParams.role || 'student'}
          />
        )}

        {/* Student Module & Exam Pages (From Diagram) */}
        {isStudentPortal && (
          <StudentPortalPage
            onNavigate={navigateTo}
            currentUser={currentUser}
            onLogout={handleLogout}
            initialTab={currentPage.replace('student-', '') || 'dashboard'}
          />
        )}

        {/* Teacher / Instructor Module (From 12-Screen Diagram) */}
        {isTeacherPortal && (
          <TeacherPortalPage
            onNavigate={navigateTo}
            currentUser={currentUser}
            onLogout={handleLogout}
            initialTab={currentPage.replace('teacher-', '').replace('instructor-', '') || 'dashboard'}
          />
        )}
 
        {/* Admin Module (From 15-Screen Design Pages Specification) */}
        {isAdminPortal && (
          <AdminPortalPage
            onNavigate={navigateTo}
            currentUser={currentUser}
            onLogout={handleLogout}
            initialTab={currentPage.replace('admin-', '') || 'dashboard'}
          />
        )}
      </main>

      {/* Consistent Footer on Public Pages (Hidden on full-screen dashboard portals) */}
      {!isStudentPortal && !isTeacherPortal && !isAdminPortal && currentPage !== 'institute-home' && (
        <Footer onNavigate={navigateTo} />
      )}
    </div>
  );
}
