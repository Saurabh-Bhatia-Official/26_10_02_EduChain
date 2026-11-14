import React, { useState, useEffect } from 'react';
import {
  LayoutDashboard,
  User,
  CheckSquare,
  Award,
  Calendar,
  BookOpen,
  FileCheck2,
  Users,
  LogOut,
  Search,
  Bell,
  Clock,
  Download,
  CheckCircle2,
  AlertCircle,
  XCircle,
  ChevronRight,
  ArrowRight,
  ArrowLeft,
  Check,
  Timer,
  Edit2,
  FileText,
  Landmark,
  ShieldCheck,
  Sparkles,
  Menu,
  X,
  ExternalLink,
  GraduationCap,
  TrendingUp,
  Flame,
  Trophy,
  Percent,
  QrCode,
  Printer,
  Video,
  MapPin,
  Phone,
  Mail,
  CalendarDays,
  Filter,
  Info,
  Eye,
  Flag,
  Share2,
  Shield
} from 'lucide-react';

export default function StudentPortalPage({ onNavigate, currentUser, onLogout, initialTab = 'dashboard' }) {
  const [activeTab, setActiveTab] = useState(initialTab);
  const [searchQuery, setSearchQuery] = useState('');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState('');
  const [showNotifications, setShowNotifications] = useState(false);
  const [selectedDay, setSelectedDay] = useState('Mon');
  const [materialFilter, setMaterialFilter] = useState('all');

  // Exam-specific states
  const [examTab, setExamTab] = useState('upcoming'); // 'upcoming' or 'past'
  const [instructionsAccepted, setInstructionsAccepted] = useState(false);
  const [currentQuestion, setCurrentQuestion] = useState(5);
  const [flaggedQuestions, setFlaggedQuestions] = useState({ 3: true, 12: true });
  const [selectedAnswers, setSelectedAnswers] = useState({
    1: 'B',
    2: 'A',
    3: 'C',
    4: 'D',
    5: 'A',
  });
  const [examTimeRemaining, setExamTimeRemaining] = useState(42332); // 11:45:32 in seconds
  const [isExamRunning, setIsExamRunning] = useState(false);
  const [showSubmitConfirmModal, setShowSubmitConfirmModal] = useState(false);

  // Modals
  const [showEditProfileModal, setShowEditProfileModal] = useState(false);
  const [showEditParentModal, setShowEditParentModal] = useState(false);
  const [showLeaveModal, setShowLeaveModal] = useState(false);
  const [showPTMModal, setShowPTMModal] = useState(false);

  // Keep activeTab in sync with initialTab prop
  useEffect(() => {
    if (initialTab) {
      setActiveTab(initialTab);
    }
  }, [initialTab]);

  // Notifications List
  const [notifications, setNotifications] = useState([
    {
      id: 1,
      title: 'DBMS Mid-Term Exam Scheduled',
      desc: 'Hall 101 allocated for May 05, 2025 at 09:00 AM.',
      time: '15 mins ago',
      unread: true,
      type: 'exam',
    },
    {
      id: 2,
      title: 'Dean’s Honor Roll Achievement',
      desc: 'Congratulations! You achieved Top 5% rank in BCA Semester 2.',
      time: '2 hours ago',
      unread: true,
      type: 'achievement',
    },
    {
      id: 3,
      title: 'New Lecture Materials Available',
      desc: 'Prof. Rajesh Gupta uploaded "Balanced BST & Graph Algorithms.pdf".',
      time: 'Yesterday',
      unread: true,
      type: 'material',
    },
    {
      id: 4,
      title: 'Monthly Attendance Verified',
      desc: 'April attendance report closed at 92%. Minimum 75% requirement satisfied.',
      time: '2 days ago',
      unread: false,
      type: 'attendance',
    },
  ]);

  // Student info from state or defaults
  const student = {
    name: currentUser?.name || 'Rahul Sharma',
    rollNumber: currentUser?.rollNumber || '1023',
    className: currentUser?.className || 'BCA - Sem 3',
    course: currentUser?.course || 'Bachelor of Computer Applications',
    semester: currentUser?.semester || 'Semester 3',
    email: currentUser?.email || 'rahul@institute.com',
    gender: currentUser?.gender || 'Male',
    dob: currentUser?.dob || '12-05-2005',
    bloodGroup: 'B+',
    admissionYear: '2023',
    instituteCode: currentUser?.instituteCode || 'INST-2025',
    instituteName: currentUser?.instituteName || 'Apex Institute of Technology',
    fatherName: currentUser?.fatherName || 'Rakesh Sharma',
    fatherPhone: currentUser?.fatherPhone || '+91 98765 43210',
    fatherEmail: currentUser?.fatherEmail || 'rakesh@example.com',
    fatherOccupation: 'Senior Project Manager, Tech Solutions',
    motherName: currentUser?.motherName || 'Pooja Sharma',
    motherPhone: currentUser?.motherPhone || '+91 98765 43211',
    motherEmail: currentUser?.motherEmail || 'pooja@example.com',
    motherOccupation: 'Professor of Economics',
    address: currentUser?.address || '123, Green Park, Delhi - 110016',
    avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=256&q=80',
    campusCover: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=1200&q=80',
  };

  const [studentInfo, setStudentInfo] = useState(student);

  // Timer countdown for Live Exam
  useEffect(() => {
    let timer;
    if (activeTab === 'exam-live') {
      timer = setInterval(() => {
        setExamTimeRemaining((prev) => (prev > 0 ? prev - 1 : 0));
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [activeTab]);

  const formatTimer = (seconds) => {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${String(hrs).padStart(2, '0')}:${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
  };

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3200);
  };

  const handleOptionSelect = (opt) => {
    setSelectedAnswers((prev) => ({
      ...prev,
      [currentQuestion]: opt,
    }));
  };

  const toggleFlagQuestion = (qNum) => {
    setFlaggedQuestions((prev) => ({
      ...prev,
      [qNum]: !prev[qNum],
    }));
    showToast(flaggedQuestions[qNum] ? `Unflagged Question ${qNum}` : `Flagged Question ${qNum} for review`);
  };

  const markAllNotificationsRead = () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, unread: false })));
    showToast('All notifications marked as read.');
  };

  const unreadCount = notifications.filter((n) => n.unread).length;

  const navItems = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'profile', label: 'My Profile', icon: User },
    { id: 'attendance', label: 'Attendance', icon: CheckSquare, badge: '92%' },
    { id: 'grades', label: 'Grades', icon: Award, badge: 'A+' },
    { id: 'schedule', label: 'Class Schedule', icon: Calendar },
    { id: 'materials', label: 'Lecture Materials', icon: BookOpen, badge: 'New' },
    { id: 'timetable', label: 'Exam Timetable', icon: Clock },
    { id: 'exams', label: 'Exams', icon: FileCheck2, badge: '2 Soon' },
    { id: 'parents', label: 'Parent Information', icon: Users },
  ];

  return (
    <div className="student-portal-root">
      {/* Toast Alert */}
      {toastMessage && (
        <div className="portal-toast-notification">
          <CheckCircle2 size={18} className="toast-icon" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Mobile Top Header Bar */}
      <div className="student-mobile-bar">
        <div className="student-brand-box">
          <div className="student-brand-icon">
            <Landmark size={20} />
          </div>
          <span className="student-brand-name">Institute Portal</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <button
            type="button"
            className="mobile-notif-btn"
            onClick={() => setShowNotifications(!showNotifications)}
            aria-label="View notifications"
          >
            <Bell size={20} />
            {unreadCount > 0 && <span className="mobile-notif-dot" />}
          </button>
          <button
            type="button"
            className="student-mobile-toggle"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Toggle navigation menu"
          >
            {mobileMenuOpen ? <X size={22} /> : <Menu size={22} />}
          </button>
        </div>
      </div>

      {/* Left Navy-Blue Sidebar */}
      <aside className={`student-sidebar ${mobileMenuOpen ? 'mobile-open' : ''}`}>
        {/* Brand Header */}
        <div className="student-brand-box">
          <div className="student-brand-icon">
            <Landmark size={22} />
          </div>
          <div className="student-brand-text-col">
            <span className="student-brand-name">Institute Portal</span>
            <span className="student-brand-sub">Academic Gateway</span>
          </div>
        </div>

        {/* Navigation Menu */}
        <nav className="student-nav-menu">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive =
              activeTab === item.id ||
              (item.id === 'exams' &&
                ['exam-instructions', 'exam-live', 'exam-submitted', 'exam-results'].includes(activeTab));

            return (
              <button
                key={item.id}
                type="button"
                className={`student-nav-item ${isActive ? 'active' : ''}`}
                onClick={() => {
                  setActiveTab(item.id);
                  setMobileMenuOpen(false);
                  setShowNotifications(false);
                }}
              >
                <Icon size={18} className="nav-icon" />
                <span className="nav-item-label">{item.label}</span>
                {item.badge && !isActive && (
                  <span className={`nav-item-badge ${item.id === 'attendance' ? 'green' : item.id === 'grades' ? 'purple' : 'blue'}`}>
                    {item.badge}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Sidebar Mini Profile Strip */}
        <div className="sidebar-student-card">
          <div className="sidebar-student-avatar-wrap">
            <img
              src={studentInfo.avatar}
              alt={studentInfo.name}
              className="sidebar-student-photo"
              onError={(e) => {
                e.target.style.display = 'none';
                e.target.nextSibling.style.display = 'flex';
              }}
            />
            <div className="sidebar-student-fallback-avatar" style={{ display: 'none' }}>
              <span>RS</span>
            </div>
            <span className="sidebar-online-dot" />
          </div>
          <div className="sidebar-student-meta">
            <span className="sidebar-student-name">{studentInfo.name}</span>
            <span className="sidebar-student-roll">Roll #{studentInfo.rollNumber}</span>
          </div>
        </div>

        {/* Sidebar Footer: Back to Portal Home & Logout */}
        <div className="student-sidebar-footer">
          <button
            type="button"
            className="student-logout-btn"
            onClick={() => {
              if (onLogout) onLogout();
              else onNavigate('institute-home');
            }}
            title="Sign out from Student Account"
          >
            <LogOut size={17} />
            <span>Sign Out</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="student-main-content">
        {/* Top Header Bar */}
        <header className="student-topbar">
          <div className="student-search-box">
            <Search size={17} className="search-icon" />
            <input
              type="text"
              placeholder="Search subjects, schedules, lecture notes..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="student-search-input"
            />
            <span className="search-shortcut-hint">Ctrl + K</span>
          </div>

          <div className="student-topbar-right">
            {/* Quick Action: Back to Main Website */}
            <button
              type="button"
              className="btn-topbar-ghost"
              onClick={() => onNavigate('institute-home')}
              title="Return to Public Website Home"
            >
              <span>Website Home</span>
            </button>

            {/* Notification Bell */}
            <div className="notification-bell-container">
              <button
                type="button"
                className={`topbar-bell-btn ${unreadCount > 0 ? 'has-unread' : ''}`}
                onClick={() => setShowNotifications(!showNotifications)}
                aria-label="View notifications"
                title="Notifications"
              >
                <Bell size={19} />
                {unreadCount > 0 && <span className="bell-badge-count">{unreadCount}</span>}
              </button>

              {/* Floating Notifications Dropdown */}
              {showNotifications && (
                <div className="notifications-dropdown-menu">
                  <div className="notif-menu-header">
                    <div className="notif-title-row">
                      <h4>Academic Notifications</h4>
                      <span className="notif-count-pill">{unreadCount} New</span>
                    </div>
                    {unreadCount > 0 && (
                      <button
                        type="button"
                        className="notif-mark-read-btn"
                        onClick={markAllNotificationsRead}
                      >
                        Mark all as read
                      </button>
                    )}
                  </div>

                  <div className="notif-items-list">
                    {notifications.map((n) => (
                      <div className={`notif-item-row ${n.unread ? 'unread' : ''}`} key={n.id}>
                        <div className={`notif-type-icon ${n.type}`}>
                          {n.type === 'exam' && <FileCheck2 size={16} />}
                          {n.type === 'achievement' && <Trophy size={16} />}
                          {n.type === 'material' && <BookOpen size={16} />}
                          {n.type === 'attendance' && <CheckCircle2 size={16} />}
                        </div>
                        <div className="notif-item-content">
                          <h5>{n.title}</h5>
                          <p>{n.desc}</p>
                          <span className="notif-timestamp">{n.time}</span>
                        </div>
                        {n.unread && <span className="notif-blue-dot" />}
                      </div>
                    ))}
                  </div>

                  <div className="notif-menu-footer">
                    <button
                      type="button"
                      className="btn-view-all-notifs"
                      onClick={() => {
                        setShowNotifications(false);
                        setActiveTab('dashboard');
                      }}
                    >
                      Close Notifications
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Student Profile Avatar */}
            <div
              className="student-topbar-profile"
              onClick={() => setActiveTab('profile')}
              role="button"
              tabIndex={0}
              title="View Student Profile"
            >
              <div className="student-avatar-box">
                <img
                  src={studentInfo.avatar}
                  alt={studentInfo.name}
                  className="topbar-avatar-img"
                  onError={(e) => {
                    e.target.style.display = 'none';
                    e.target.nextSibling.style.display = 'flex';
                  }}
                />
                <div className="topbar-avatar-fallback" style={{ display: 'none' }}>
                  <span className="avatar-text">RS</span>
                </div>
                <span className="online-indicator" />
              </div>
              <div className="student-profile-info">
                <span className="student-name">{studentInfo.name}</span>
                <span className="student-role-tag">Student</span>
              </div>
            </div>
          </div>
        </header>

        {/* Page Body Viewport */}
        <main className="student-page-body">
          {/* =========================================================
              1. STUDENT DASHBOARD (Preserves Image Mockup Exactly + Enhancements)
             ========================================================= */}
          {activeTab === 'dashboard' && (
            <div className="dashboard-view-content">
              {/* Hero Banner (Matching User's Uploaded Image) */}
              <div className="student-hero-banner">
                <div className="banner-text-col">
                  <h2>Welcome, {studentInfo.name.split(' ')[0]}!</h2>
                  <p>Keep learning, keep growing!</p>
                  <div className="banner-meta-badge-row">
                    <span className="banner-tag-pill">
                      <GraduationCap size={14} /> BCA - Semester 3
                    </span>
                    <span className="banner-tag-pill">
                      <ShieldCheck size={14} /> Enrolled ID: STD-1023
                    </span>
                  </div>
                </div>
                <div className="banner-graphic-col">
                  <div className="campus-mini-art">
                    <Landmark size={88} className="campus-art-icon" />
                  </div>
                </div>
              </div>

              {/* 3 Metric Cards (Matching User's Uploaded Image) */}
              <div className="student-metric-cards-grid">
                {/* Metric 1: Attendance */}
                <div
                  className="student-kpi-card attendance"
                  onClick={() => setActiveTab('attendance')}
                  role="button"
                  tabIndex={0}
                  title="View detailed attendance records"
                >
                  <div className="kpi-icon-circle green">
                    <CheckCircle2 size={24} />
                  </div>
                  <div className="kpi-info">
                    <span className="kpi-label">Attendance</span>
                    <span className="kpi-value green">92%</span>
                    <span className="kpi-trend green">
                      <TrendingUp size={12} /> +2.4% this month
                    </span>
                  </div>
                </div>

                {/* Metric 2: Overall Grade */}
                <div
                  className="student-kpi-card grade"
                  onClick={() => setActiveTab('grades')}
                  role="button"
                  tabIndex={0}
                  title="View complete grades transcript"
                >
                  <div className="kpi-icon-circle purple">
                    <Award size={24} />
                  </div>
                  <div className="kpi-info">
                    <span className="kpi-label">Overall Grade</span>
                    <span className="kpi-value purple">A+</span>
                    <span className="kpi-trend purple">
                      <Trophy size={12} /> CGPA: 3.88 / 4.0
                    </span>
                  </div>
                </div>

                {/* Metric 3: Upcoming Exams */}
                <div
                  className="student-kpi-card exams"
                  onClick={() => setActiveTab('exams')}
                  role="button"
                  tabIndex={0}
                  title="Open upcoming examinations"
                >
                  <div className="kpi-icon-circle blue">
                    <FileCheck2 size={24} />
                  </div>
                  <div className="kpi-info">
                    <span className="kpi-label">Upcoming Exams</span>
                    <span className="kpi-value blue">2</span>
                    <span className="kpi-trend blue">
                      <Clock size={12} /> Next: Math (May 10)
                    </span>
                  </div>
                </div>
              </div>

              {/* Recent Activities Section (Matching User's Uploaded Image) */}
              <div className="student-card-section">
                <div className="section-title-row">
                  <h3>Recent Activities</h3>
                  <span className="section-subtitle-tag">Real-time academic updates</span>
                </div>
                <div className="recent-activities-list">
                  <div className="activity-row-item">
                    <div className="activity-main">
                      <div className="activity-dot blue" />
                      <div className="activity-details">
                        <h4>Math Lecture</h4>
                        <p>Apr 26, 2025 • 09:00 AM - 10:00 AM</p>
                      </div>
                    </div>
                    <button
                      type="button"
                      className="activity-action-btn blue"
                      onClick={() => setActiveTab('schedule')}
                    >
                      Upcoming →
                    </button>
                  </div>

                  <div className="activity-row-item">
                    <div className="activity-main">
                      <div className="activity-dot green" />
                      <div className="activity-details">
                        <h4>Assignment Uploaded</h4>
                        <p>Apr 25, 2025 • 11:00 AM</p>
                      </div>
                    </div>
                    <span className="activity-status-pill green">Submitted ✓</span>
                  </div>

                  <div className="activity-row-item">
                    <div className="activity-main">
                      <div className="activity-dot slate" />
                      <div className="activity-details">
                        <h4>Exam Timetable Updated</h4>
                        <p>Apr 23, 2025 • 04:00 PM</p>
                      </div>
                    </div>
                    <button
                      type="button"
                      className="activity-action-btn slate"
                      onClick={() => setActiveTab('timetable')}
                    >
                      View Details →
                    </button>
                  </div>
                </div>
              </div>

              {/* Study Progress & Current Course Completion */}
              <div className="dashboard-grid-dual">
                {/* Left Card: Semester 3 Study Progress */}
                <div className="portal-card-block">
                  <div className="section-title-row">
                    <div className="title-with-icon">
                      <BookOpen size={18} className="title-icon blue" />
                      <h4>Current Semester Study Progress</h4>
                    </div>
                    <span className="progress-badge-highlight">72% Completed</span>
                  </div>

                  <div className="semester-timeline-progress">
                    <div className="progress-bar-track-large">
                      <div className="progress-bar-fill-large" style={{ width: '72%' }} />
                    </div>
                    <div className="timeline-labels-row">
                      <span>Week 1 (Orientation)</span>
                      <span><strong>Week 14</strong> (Current)</span>
                      <span>Week 18 (Finals)</span>
                    </div>
                  </div>

                  <div className="course-progress-mini-grid">
                    {[
                      { name: 'Data Structures & Algorithms', progress: 84, color: 'blue', code: 'BCA-301' },
                      { name: 'Database Management Systems', progress: 75, color: 'teal', code: 'BCA-302' },
                      { name: 'Web Technologies (React)', progress: 90, color: 'green', code: 'BCA-303' },
                      { name: 'Computer Networks', progress: 68, color: 'purple', code: 'BCA-304' },
                    ].map((c) => (
                      <div className="mini-course-row" key={c.code}>
                        <div className="mini-course-meta">
                          <span className="mini-course-name">{c.name}</span>
                          <span className="mini-course-code">{c.code}</span>
                        </div>
                        <div className="mini-course-bar-wrap">
                          <div className="mini-track">
                            <div
                              className={`mini-fill ${c.color}`}
                              style={{ width: `${c.progress}%` }}
                            />
                          </div>
                          <span className="mini-pct">{c.progress}%</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Right Card: Next Upcoming Class Countdown */}
                <div className="portal-card-block highlight-card">
                  <div className="section-title-row">
                    <div className="title-with-icon">
                      <Clock size={18} className="title-icon green" />
                      <h4>Next Live Class</h4>
                    </div>
                    <span className="live-pulsing-badge">In 45 Mins</span>
                  </div>

                  <div className="upcoming-class-highlight">
                    <div className="class-highlight-body">
                      <div className="class-subject-badge">BCA-302 • Core Subject</div>
                      <h3 className="class-subject-title">Database Management Systems</h3>
                      <p className="class-topic-preview">Topic: Normalization & BCNF Normal Forms</p>

                      <div className="instructor-mini-pill">
                        <img
                          src="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=100&q=80"
                          alt="Dr. Neha Verma"
                          className="instructor-avatar-xs"
                        />
                        <div className="instructor-text">
                          <span className="instructor-name">Dr. Neha Verma</span>
                          <span className="instructor-title">Associate Professor • Lab 2</span>
                        </div>
                      </div>
                    </div>

                    <div className="class-actions-strip">
                      <button
                        type="button"
                        className="btn-primary class-join-btn"
                        onClick={() => setActiveTab('schedule')}
                      >
                        <Calendar size={15} />
                        <span>View Class Schedule</span>
                      </button>
                      <button
                        type="button"
                        className="btn-outline class-notes-btn"
                        onClick={() => setActiveTab('materials')}
                      >
                        <BookOpen size={15} />
                        <span>Open Notes</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {/* Achievement Badges Strip */}
              <div className="portal-card-block achievements-strip-card">
                <div className="section-title-row">
                  <div className="title-with-icon">
                    <Trophy size={18} className="title-icon amber" />
                    <h4>Academic Honors & Achievement Badges</h4>
                  </div>
                  <span className="badge-verified-seal">
                    <ShieldCheck size={14} /> Official Institute Seals
                  </span>
                </div>

                <div className="achievements-badges-row">
                  <div className="achievement-badge-item gold">
                    <div className="badge-shield-icon gold">
                      <Trophy size={22} />
                    </div>
                    <div className="badge-content">
                      <span className="badge-honor-title">Dean’s Honor Roll</span>
                      <span className="badge-honor-desc">Top 5% Academic Rank</span>
                    </div>
                  </div>

                  <div className="achievement-badge-item green">
                    <div className="badge-shield-icon green">
                      <CheckCircle2 size={22} />
                    </div>
                    <div className="badge-content">
                      <span className="badge-honor-title">100% Attendance Star</span>
                      <span className="badge-honor-desc">Web Tech Lab Distinction</span>
                    </div>
                  </div>

                  <div className="achievement-badge-item purple">
                    <div className="badge-shield-icon purple">
                      <Flame size={22} />
                    </div>
                    <div className="badge-content">
                      <span className="badge-honor-title">Assignment Streak</span>
                      <span className="badge-honor-desc">12 On-Time Submissions</span>
                    </div>
                  </div>

                  <div className="achievement-badge-item blue">
                    <div className="badge-shield-icon blue">
                      <Award size={22} />
                    </div>
                    <div className="badge-content">
                      <span className="badge-honor-title">Certified Scholar</span>
                      <span className="badge-honor-desc">Verified Student #1023</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Campus Announcements with High-Quality Photography */}
              <div className="campus-announcement-card">
                <div
                  className="announcement-image-col"
                  style={{
                    backgroundImage: `url('https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=800&q=80')`,
                  }}
                >
                  <span className="campus-photo-pill">Apex Central Campus</span>
                </div>
                <div className="announcement-content-col">
                  <div className="announcement-badge-row">
                    <span className="announcement-tag blue">Annual Hackathon 2025</span>
                    <span className="announcement-date">Registrations Open Till May 15</span>
                  </div>
                  <h3>Apex CodeFest & Tech Innovation Summit 2025</h3>
                  <p>
                    Showcase your programming, web development, and cloud computing projects.
                    Participate in 24-hour live hackathon with cash awards, startup incubation support,
                    and industry recruitment drives.
                  </p>
                  <div className="announcement-btn-row">
                    <button
                      type="button"
                      className="btn-primary hero-btn-main"
                      onClick={() => showToast('Hackathon registration guidelines opened!')}
                    >
                      <Sparkles size={16} />
                      <span>Learn More & Register</span>
                    </button>
                    <button
                      type="button"
                      className="btn-outline"
                      onClick={() => showToast('Event schedule saved to calendar!')}
                    >
                      <CalendarDays size={16} />
                      <span>Add to Calendar</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* =========================================================
              2. STUDENT PROFILE PAGE (Enhanced with Photo, Virtual ID, Honors)
             ========================================================= */}
          {activeTab === 'profile' && (
            <div className="profile-view-content">
              {/* Profile Cover Banner */}
              <div
                className="profile-cover-banner"
                style={{
                  backgroundImage: `linear-gradient(to right, rgba(11, 25, 44, 0.9), rgba(2, 132, 199, 0.8)), url('https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=1200&q=80')`,
                }}
              >
                <div className="profile-cover-content">
                  <span className="campus-name-pill">Apex Institute of Technology</span>
                  <h2>Student Profile & Academic Credentials</h2>
                  <p>Department of Computer Science & Information Applications</p>
                </div>
              </div>

              <div className="profile-grid-layout">
                {/* Left Column: Summary Card & Virtual Student ID */}
                <div className="profile-summary-card">
                  <div className="profile-avatar-large">
                    <img
                      src={studentInfo.avatar}
                      alt={studentInfo.name}
                      className="profile-real-photo"
                      onError={(e) => {
                        e.target.style.display = 'none';
                        e.target.nextSibling.style.display = 'flex';
                      }}
                    />
                    <div className="profile-photo-fallback" style={{ display: 'none' }}>
                      <span>RS</span>
                    </div>
                    <span className="profile-status-online" title="Active Student Session" />
                  </div>

                  <h3 className="profile-name">{studentInfo.name}</h3>
                  <div className="profile-academic-subtitle">
                    <span>{studentInfo.className}</span>
                    <span>•</span>
                    <span>Roll #{studentInfo.rollNumber}</span>
                  </div>

                  <div className="profile-kpi-pill-strip">
                    <div className="profile-kpi-chip green">
                      <span className="chip-label">Attendance</span>
                      <span className="chip-val">92%</span>
                    </div>
                    <div className="profile-kpi-chip purple">
                      <span className="chip-label">CGPA</span>
                      <span className="chip-val">3.88</span>
                    </div>
                    <div className="profile-kpi-chip blue">
                      <span className="chip-label">Rank</span>
                      <span className="chip-val">#3 / 68</span>
                    </div>
                  </div>

                  <div className="profile-meta-tags">
                    <div className="profile-meta-row">
                      <span className="meta-row-label">Roll Number</span>
                      <span className="meta-row-val">{studentInfo.rollNumber}</span>
                    </div>
                    <div className="profile-meta-row">
                      <span className="meta-row-label">Course</span>
                      <span className="meta-row-val">BCA (3 Years)</span>
                    </div>
                    <div className="profile-meta-row">
                      <span className="meta-row-label">Current Term</span>
                      <span className="meta-row-val">{studentInfo.semester}</span>
                    </div>
                    <div className="profile-meta-row">
                      <span className="meta-row-label">Student Email</span>
                      <span className="meta-row-val">{studentInfo.email}</span>
                    </div>
                    <div className="profile-meta-row">
                      <span className="meta-row-label">Admission Year</span>
                      <span className="meta-row-val">{studentInfo.admissionYear}</span>
                    </div>
                    <div className="profile-meta-row">
                      <span className="meta-row-label">Blood Group</span>
                      <span className="meta-row-val">{studentInfo.bloodGroup}</span>
                    </div>
                  </div>

                  <div className="profile-actions-column">
                    <button
                      type="button"
                      className="btn-primary profile-edit-btn"
                      onClick={() => setShowEditProfileModal(true)}
                    >
                      <Edit2 size={16} />
                      <span>Edit Student Profile</span>
                    </button>
                    <button
                      type="button"
                      className="btn-outline id-card-download-btn"
                      onClick={() => showToast('Virtual Student ID Card saved as PDF!')}
                    >
                      <Download size={16} />
                      <span>Download ID Card</span>
                    </button>
                  </div>

                  {/* Virtual ID Card Preview Card */}
                  <div className="virtual-id-card-box">
                    <div className="id-card-top">
                      <Landmark size={16} className="id-logo-icon" />
                      <span className="id-inst-name">Apex Institute of Technology</span>
                    </div>
                    <div className="id-card-body">
                      <img
                        src={studentInfo.avatar}
                        alt="ID Card Photo"
                        className="id-photo"
                      />
                      <div className="id-info-col">
                        <span className="id-student-name">{studentInfo.name}</span>
                        <span className="id-roll-number">ID: {studentInfo.rollNumber}</span>
                        <span className="id-dept">Dept: Computer Science</span>
                        <span className="id-valid">Valid: 2023 - 2026</span>
                      </div>
                    </div>
                    <div className="id-card-footer">
                      <QrCode size={26} className="id-qr" />
                      <span className="id-barcode-text">||| | || |||| | ||| |||| |</span>
                    </div>
                  </div>
                </div>

                {/* Right Column: Detailed Sections */}
                <div className="profile-details-column">
                  {/* Academic Profile */}
                  <div className="portal-card-block">
                    <div className="section-title-row">
                      <h4 className="block-title">Academic & Institutional Enrollment</h4>
                      <span className="verified-status-tag">
                        <ShieldCheck size={14} /> AICTE Verified Student
                      </span>
                    </div>
                    <div className="info-fields-grid">
                      <div className="info-field-item">
                        <span className="info-label">Full Name</span>
                        <span className="info-value">{studentInfo.name}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Roll Number</span>
                        <span className="info-value">{studentInfo.rollNumber}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Degree & Branch</span>
                        <span className="info-value">{studentInfo.course}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Current Semester</span>
                        <span className="info-value">{studentInfo.className}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Academic Faculty Advisor</span>
                        <span className="info-value">Dr. Neha Verma (Associate Professor)</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Registered Campus</span>
                        <span className="info-value">Apex Main Campus (Block B)</span>
                      </div>
                    </div>
                  </div>

                  {/* Personal Information */}
                  <div className="portal-card-block">
                    <h4 className="block-title">Personal & Demographic Details</h4>
                    <div className="info-fields-grid">
                      <div className="info-field-item">
                        <span className="info-label">Date of Birth</span>
                        <span className="info-value">{studentInfo.dob}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Gender</span>
                        <span className="info-value">{studentInfo.gender}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Blood Group</span>
                        <span className="info-value">{studentInfo.bloodGroup}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Student Primary Email</span>
                        <span className="info-value">{studentInfo.email}</span>
                      </div>
                      <div className="info-field-item full-width">
                        <span className="info-label">Permanent Residential Address</span>
                        <span className="info-value">{studentInfo.address}</span>
                      </div>
                    </div>
                  </div>

                  {/* Parent / Guardian Quick Glance */}
                  <div className="portal-card-block">
                    <div className="section-title-row">
                      <h4 className="block-title">Parent / Guardian Quick Contacts</h4>
                      <button
                        type="button"
                        className="btn-link-action"
                        onClick={() => setActiveTab('parents')}
                      >
                        <span>Full Guardian Portal →</span>
                      </button>
                    </div>
                    <div className="info-fields-grid">
                      <div className="info-field-item">
                        <span className="info-label">Father Name</span>
                        <span className="info-value">{studentInfo.fatherName}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Father Phone</span>
                        <span className="info-value">{studentInfo.fatherPhone}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Mother Name</span>
                        <span className="info-value">{studentInfo.motherName}</span>
                      </div>
                      <div className="info-field-item">
                        <span className="info-label">Mother Phone</span>
                        <span className="info-value">{studentInfo.motherPhone}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* =========================================================
              3. ATTENDANCE TRACKER (Enhanced with Attendance Ring & Heatmap)
             ========================================================= */}
          {activeTab === 'attendance' && (
            <div className="attendance-view-content">
              <div className="view-header-with-filters">
                <div>
                  <h2>Attendance Tracker</h2>
                  <p className="view-subheading">
                    Monitor your daily lecture attendance, subject statistics, and minimum 75% eligibility.
                  </p>
                </div>
                <div className="view-filters-group">
                  <div className="filter-select-wrapper">
                    <label>Month</label>
                    <select className="portal-filter-select" defaultValue="April 2025">
                      <option>April 2025</option>
                      <option>March 2025</option>
                      <option>February 2025</option>
                      <option>January 2025</option>
                    </select>
                  </div>
                  <div className="filter-select-wrapper">
                    <label>Class</label>
                    <select className="portal-filter-select" defaultValue="BCA - Sem 3">
                      <option>BCA - Sem 3</option>
                      <option>All Classes</option>
                    </select>
                  </div>
                  <button
                    type="button"
                    className="btn-primary btn-sm-action"
                    onClick={() => setShowLeaveModal(true)}
                  >
                    + Apply For Leave
                  </button>
                </div>
              </div>

              {/* Attendance Ring & Statistics Card */}
              <div className="attendance-stats-card">
                <div className="gauge-side">
                  <div className="circular-progress-meter attendance-ring-large">
                    <svg viewBox="0 0 100 100" className="progress-svg">
                      <circle cx="50" cy="50" r="42" className="progress-bg" />
                      <circle
                        cx="50"
                        cy="50"
                        r="42"
                        className="progress-fill green"
                        strokeDasharray="264"
                        strokeDashoffset="21"
                      />
                    </svg>
                    <div className="progress-content">
                      <span className="progress-percentage">92%</span>
                      <span className="progress-label">Present</span>
                    </div>
                  </div>
                  <div className="gauge-status-badge green">
                    <CheckCircle2 size={15} />
                    <span>Eligible for Examinations (≥ 75%)</span>
                  </div>
                </div>

                <div className="counters-side">
                  <div className="attendance-counter-box blue">
                    <div className="counter-dot blue" />
                    <span className="counter-name">Total Classes</span>
                    <span className="counter-num">120</span>
                    <span className="counter-sub">Across 5 Subjects</span>
                  </div>
                  <div className="attendance-counter-box green">
                    <div className="counter-dot green" />
                    <span className="counter-name">Classes Attended</span>
                    <span className="counter-num">110</span>
                    <span className="counter-sub">92% Net Attendance</span>
                  </div>
                  <div className="attendance-counter-box red">
                    <div className="counter-dot red" />
                    <span className="counter-name">Unexcused Absent</span>
                    <span className="counter-num">6</span>
                    <span className="counter-sub">Safe buffer remaining</span>
                  </div>
                  <div className="attendance-counter-box amber">
                    <div className="counter-dot amber" />
                    <span className="counter-name">Approved Leave</span>
                    <span className="counter-num">4</span>
                    <span className="counter-sub">Medical & Sports</span>
                  </div>
                </div>
              </div>

              {/* Subject-Wise Attendance Progress Rings */}
              <div className="portal-card-block">
                <h4 className="block-title">Subject-Wise Attendance Breakdown</h4>
                <div className="subject-attendance-rings-grid">
                  {[
                    { subject: 'Data Structures & Algorithms', pct: 94, attended: 47, total: 50, faculty: 'Prof. Rajesh Gupta', color: 'green' },
                    { subject: 'Database Management Systems', pct: 90, attended: 36, total: 40, faculty: 'Dr. Neha Verma', color: 'green' },
                    { subject: 'Web Technologies (React.js)', pct: 96, attended: 27, total: 28, faculty: 'Prof. Swati Deshmukh', color: 'green' },
                    { subject: 'Computer Networks', pct: 91, attended: 32, total: 35, faculty: 'Prof. Amit Kumar', color: 'green' },
                    { subject: 'Discrete Mathematics', pct: 88, attended: 22, total: 25, faculty: 'Prof. Kavita Rao', color: 'blue' },
                  ].map((sub) => (
                    <div className="subject-ring-card" key={sub.subject}>
                      <div className="mini-ring-wrapper">
                        <svg viewBox="0 0 40 40" className="mini-ring-svg">
                          <circle cx="20" cy="20" r="16" className="mini-ring-bg" />
                          <circle
                            cx="20"
                            cy="20"
                            r="16"
                            className={`mini-ring-fill ${sub.color}`}
                            strokeDasharray="100"
                            strokeDashoffset={100 - sub.pct}
                          />
                        </svg>
                        <span className="mini-ring-pct">{sub.pct}%</span>
                      </div>
                      <div className="subject-ring-info">
                        <h5>{sub.subject}</h5>
                        <p>{sub.faculty}</p>
                        <span className="subject-fraction-pill">
                          {sub.attended} / {sub.total} Lectures
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Monthly Calendar Attendance Heatmap Strip */}
              <div className="portal-card-block">
                <div className="section-title-row">
                  <h4 className="block-title">April 2025 Attendance Heatmap</h4>
                  <div className="heatmap-legend">
                    <span className="legend-chip present"><span className="dot" /> Present (22)</span>
                    <span className="legend-chip absent"><span className="dot" /> Absent (2)</span>
                    <span className="legend-chip leave"><span className="dot" /> Leave (1)</span>
                    <span className="legend-chip holiday"><span className="dot" /> Weekend / Holiday (5)</span>
                  </div>
                </div>

                <div className="calendar-heatmap-row">
                  {Array.from({ length: 30 }, (_, i) => i + 1).map((day) => {
                    const isSunday = (day + 2) % 7 === 0;
                    const isSaturday = (day + 1) % 7 === 0;
                    const isAbsent = day === 14 || day === 26;
                    const isLeave = day === 18;

                    let dayStatus = 'present';
                    if (isSunday || isSaturday) dayStatus = 'holiday';
                    else if (isAbsent) dayStatus = 'absent';
                    else if (isLeave) dayStatus = 'leave';

                    return (
                      <div className={`heatmap-day-cell ${dayStatus}`} key={day} title={`Apr ${day}, 2025: ${dayStatus.toUpperCase()}`}>
                        <span className="day-num">{day}</span>
                        <span className="day-indicator" />
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Attendance Records Table */}
              <div className="portal-card-block">
                <div className="section-title-row">
                  <h4 className="block-title">Recent Session Logs</h4>
                  <button
                    type="button"
                    className="btn-outline btn-sm-action"
                    onClick={() => showToast('Attendance transcript exported as CSV!')}
                  >
                    <Download size={14} />
                    <span>Export Sheet</span>
                  </button>
                </div>

                <div className="portal-table-responsive">
                  <table className="portal-clean-table">
                    <thead>
                      <tr>
                        <th>Date</th>
                        <th>Course / Class</th>
                        <th>Subject</th>
                        <th>Instructor</th>
                        <th>Timing</th>
                        <th>Status</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td>Apr 28, 2025</td>
                        <td>BCA - Sem 3</td>
                        <td><strong>Database Management Systems</strong></td>
                        <td>Dr. Neha Verma</td>
                        <td>09:00 AM - 10:00 AM</td>
                        <td><span className="table-status-pill present">Present</span></td>
                      </tr>
                      <tr>
                        <td>Apr 27, 2025</td>
                        <td>BCA - Sem 3</td>
                        <td><strong>Web Technologies</strong></td>
                        <td>Prof. Swati Deshmukh</td>
                        <td>10:00 AM - 11:00 AM</td>
                        <td><span className="table-status-pill present">Present</span></td>
                      </tr>
                      <tr>
                        <td>Apr 26, 2025</td>
                        <td>BCA - Sem 3</td>
                        <td><strong>Mathematics (Discrete)</strong></td>
                        <td>Prof. Kavita Rao</td>
                        <td>11:00 AM - 12:00 PM</td>
                        <td><span className="table-status-pill absent">Absent</span></td>
                      </tr>
                      <tr>
                        <td>Apr 25, 2025</td>
                        <td>BCA - Sem 3</td>
                        <td><strong>Data Structures & Algorithms</strong></td>
                        <td>Prof. Rajesh Gupta</td>
                        <td>01:00 PM - 02:00 PM</td>
                        <td><span className="table-status-pill present">Present</span></td>
                      </tr>
                      <tr>
                        <td>Apr 24, 2025</td>
                        <td>BCA - Sem 3</td>
                        <td><strong>Computer Networks</strong></td>
                        <td>Prof. Amit Kumar</td>
                        <td>09:00 AM - 10:00 AM</td>
                        <td><span className="table-status-pill present">Present</span></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* =========================================================
              4. GRADES PAGE (Enhanced with Visual Grade Charts & CGPA)
             ========================================================= */}
          {activeTab === 'grades' && (
            <div className="grades-view-content">
              <div className="view-header-with-filters">
                <div>
                  <h2>Grades & Academic Performance</h2>
                  <p className="view-subheading">
                    Semester-wise scorecards, credit calculation, and class performance comparison.
                  </p>
                </div>
                <div className="view-filters-group">
                  <div className="filter-select-wrapper">
                    <label>Semester</label>
                    <select className="portal-filter-select" defaultValue="BCA - Sem 3">
                      <option>BCA - Sem 3</option>
                      <option>BCA - Sem 2</option>
                      <option>BCA - Sem 1</option>
                    </select>
                  </div>
                  <div className="filter-select-wrapper">
                    <label>Subject</label>
                    <select className="portal-filter-select" defaultValue="All Subjects">
                      <option>All Subjects</option>
                      <option>Database Management</option>
                      <option>Web Development</option>
                      <option>Mathematics</option>
                      <option>Computer Networks</option>
                      <option>English</option>
                    </select>
                  </div>
                  <button
                    type="button"
                    className="btn-primary btn-sm-action"
                    onClick={() => showToast('Official Grade Sheet PDF generated!')}
                  >
                    <Printer size={15} />
                    <span>Print Transcript</span>
                  </button>
                </div>
              </div>

              {/* CGPA & Academic Summary Card */}
              <div className="results-summary-cards-grid">
                <div className="result-kpi-card">
                  <div className="kpi-icon-circle purple">
                    <Award size={24} />
                  </div>
                  <span className="kpi-big-num">3.88 / 4.0</span>
                  <span className="kpi-title">Cumulative GPA (CGPA)</span>
                  <span className="kpi-trend green">Grade A+ (Distinction)</span>
                </div>

                <div className="result-kpi-card">
                  <div className="kpi-icon-circle blue">
                    <TrendingUp size={24} />
                  </div>
                  <span className="kpi-big-num">3.92</span>
                  <span className="kpi-title">Current SGPA (Sem 3)</span>
                  <span className="kpi-trend green">+0.07 from Sem 2</span>
                </div>

                <div className="result-kpi-card">
                  <div className="kpi-icon-circle green">
                    <Trophy size={24} />
                  </div>
                  <span className="kpi-big-num">#3 / 68</span>
                  <span className="kpi-title">Class Batch Rank</span>
                  <span className="kpi-trend purple">Top 5% Percentile</span>
                </div>

                <div className="result-kpi-card">
                  <div className="kpi-icon-circle orange">
                    <FileCheck2 size={24} />
                  </div>
                  <span className="kpi-big-num">22 / 22</span>
                  <span className="kpi-title">Credits Completed</span>
                  <span className="kpi-trend blue">100% Passing Rate</span>
                </div>
              </div>

              {/* Visual Grade Bar Chart: Student Score vs Class Average */}
              <div className="portal-card-block">
                <div className="section-title-row">
                  <div className="title-with-icon">
                    <TrendingUp size={18} className="title-icon blue" />
                    <h4>Subject Marks Comparison (Student vs Class Average)</h4>
                  </div>
                  <div className="chart-legend-box">
                    <span className="chart-legend-item student">
                      <span className="legend-color-box blue" /> Rahul Sharma (You)
                    </span>
                    <span className="chart-legend-item avg">
                      <span className="legend-color-box gray" /> Class Average
                    </span>
                  </div>
                </div>

                <div className="visual-grade-chart-container">
                  {[
                    { subject: 'Database Management', student: 89, avg: 72, grade: 'A' },
                    { subject: 'Web Technologies', student: 96, avg: 76, grade: 'A+' },
                    { subject: 'Mathematics (Discrete)', student: 84, avg: 68, grade: 'A' },
                    { subject: 'Computer Networks', student: 88, avg: 71, grade: 'A' },
                    { subject: 'Data Structures Lab', student: 98, avg: 79, grade: 'A+' },
                    { subject: 'Technical English', student: 91, avg: 74, grade: 'A+' },
                  ].map((item) => (
                    <div className="grade-chart-col" key={item.subject}>
                      <div className="chart-bars-wrap">
                        {/* Student Bar */}
                        <div
                          className="chart-bar student-bar"
                          style={{ height: `${item.student}%` }}
                          title={`Your Score: ${item.student}/100 (${item.grade})`}
                        >
                          <span className="bar-val-label">{item.student}</span>
                        </div>
                        {/* Class Average Bar */}
                        <div
                          className="chart-bar avg-bar"
                          style={{ height: `${item.avg}%` }}
                          title={`Class Average: ${item.avg}/100`}
                        >
                          <span className="bar-val-label">{item.avg}</span>
                        </div>
                      </div>
                      <span className="chart-subject-label">{item.subject.split(' ')[0]}</span>
                      <span className="chart-grade-badge">{item.grade}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Grades Table */}
              <div className="portal-card-block">
                <div className="section-title-row">
                  <h4 className="block-title">Official Semester Gradebook</h4>
                  <button
                    type="button"
                    className="btn-outline btn-sm-action"
                    onClick={() => showToast('Grade transcript exported!')}
                  >
                    <Download size={15} />
                    <span>Download Transcript</span>
                  </button>
                </div>

                <div className="portal-table-responsive">
                  <table className="portal-clean-table">
                    <thead>
                      <tr>
                        <th>Subject Name</th>
                        <th>Course Code</th>
                        <th>Credits</th>
                        <th>Internal (25)</th>
                        <th>External (75)</th>
                        <th>Total (100)</th>
                        <th>Grade</th>
                        <th>Grade Points</th>
                        <th>Status</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td><strong>Database Management Systems</strong></td>
                        <td>BCA-301</td>
                        <td>4</td>
                        <td>23</td>
                        <td>66</td>
                        <td><strong>89</strong></td>
                        <td><span className="grade-badge blue">A</span></td>
                        <td>9.0</td>
                        <td><span className="table-status-pill present">Passed</span></td>
                      </tr>
                      <tr>
                        <td><strong>Web Development (React & Node)</strong></td>
                        <td>BCA-302</td>
                        <td>4</td>
                        <td>24</td>
                        <td>72</td>
                        <td><strong>96</strong></td>
                        <td><span className="grade-badge green">A+</span></td>
                        <td>10.0</td>
                        <td><span className="table-status-pill present">Passed</span></td>
                      </tr>
                      <tr>
                        <td><strong>Mathematics (Discrete Structures)</strong></td>
                        <td>BCA-303</td>
                        <td>4</td>
                        <td>21</td>
                        <td>63</td>
                        <td><strong>84</strong></td>
                        <td><span className="grade-badge blue">A</span></td>
                        <td>9.0</td>
                        <td><span className="table-status-pill present">Passed</span></td>
                      </tr>
                      <tr>
                        <td><strong>Computer Networks & Protocols</strong></td>
                        <td>BCA-304</td>
                        <td>4</td>
                        <td>22</td>
                        <td>66</td>
                        <td><strong>88</strong></td>
                        <td><span className="grade-badge blue">A</span></td>
                        <td>9.0</td>
                        <td><span className="table-status-pill present">Passed</span></td>
                      </tr>
                      <tr>
                        <td><strong>Web Technologies Practical Lab</strong></td>
                        <td>BCA-305P</td>
                        <td>3</td>
                        <td>25</td>
                        <td>73</td>
                        <td><strong>98</strong></td>
                        <td><span className="grade-badge green">A+</span></td>
                        <td>10.0</td>
                        <td><span className="table-status-pill present">Passed</span></td>
                      </tr>
                      <tr>
                        <td><strong>Technical Communication & Ethics</strong></td>
                        <td>BCA-306</td>
                        <td>3</td>
                        <td>24</td>
                        <td>67</td>
                        <td><strong>91</strong></td>
                        <td><span className="grade-badge green">A+</span></td>
                        <td>10.0</td>
                        <td><span className="table-status-pill present">Passed</span></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* =========================================================
              5. CLASS SCHEDULE (Enhanced with Instructor Avatars & Day Selector)
             ========================================================= */}
          {activeTab === 'schedule' && (
            <div className="schedule-view-content">
              <div className="view-header-with-filters">
                <div>
                  <h2>Class Schedule & Timetable</h2>
                  <p className="view-subheading">
                    Weekly lecture schedule, classroom allocations, and faculty contacts.
                  </p>
                </div>
                <div className="view-filters-group">
                  <span className="week-range-text">Academic Week 14: Apr 28 - May 04, 2025</span>
                  <button
                    type="button"
                    className="btn-outline btn-sm-action"
                    onClick={() => showToast('Timetable synced with Google Calendar!')}
                  >
                    <CalendarDays size={15} />
                    <span>Sync Calendar</span>
                  </button>
                </div>
              </div>

              {/* Day Selector Ribbon */}
              <div className="schedule-day-selector">
                {[
                  { day: 'Mon', full: 'Monday', classes: 4, isToday: true },
                  { day: 'Tue', full: 'Tuesday', classes: 4 },
                  { day: 'Wed', full: 'Wednesday', classes: 5 },
                  { day: 'Thu', full: 'Thursday', classes: 3 },
                  { day: 'Fri', full: 'Friday', classes: 4 },
                  { day: 'Sat', full: 'Saturday (Lab)', classes: 2 },
                ].map((d) => (
                  <button
                    key={d.day}
                    type="button"
                    className={`day-tab-pill ${selectedDay === d.day ? 'active' : ''}`}
                    onClick={() => setSelectedDay(d.day)}
                  >
                    <span className="day-name">{d.full}</span>
                    <span className="day-count-badge">
                      {d.classes} Lectures {d.isToday && '• Today'}
                    </span>
                  </button>
                ))}
              </div>

              {/* Live Active Lecture Alert */}
              <div className="current-lecture-alert-banner">
                <div className="alert-left-col">
                  <span className="pulsing-live-pill">● Ongoing Lecture</span>
                  <h3>Database Management Systems (BCA-301)</h3>
                  <p>Room 101 • Scheduled 09:00 AM - 10:00 AM (40 mins elapsed)</p>
                </div>
                <div className="alert-right-col">
                  <button
                    type="button"
                    className="btn-primary"
                    onClick={() => setActiveTab('materials')}
                  >
                    <BookOpen size={16} />
                    <span>Open Lecture Slide</span>
                  </button>
                </div>
              </div>

              {/* Interactive Timeline Schedule Cards */}
              <div className="schedule-timeline-list">
                {[
                  {
                    time: '09:00 AM - 10:00 AM',
                    subject: 'Database Management Systems',
                    code: 'BCA-301',
                    room: 'Lecture Hall 101',
                    instructor: 'Dr. Neha Verma',
                    avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=100&q=80',
                    type: 'Theory',
                    status: 'active',
                  },
                  {
                    time: '10:00 AM - 11:00 AM',
                    subject: 'Web Development (React Architecture)',
                    code: 'BCA-302',
                    room: 'Computer Center 2',
                    instructor: 'Prof. Swati Deshmukh',
                    avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=100&q=80',
                    type: 'Practical Lab',
                    status: 'upcoming',
                  },
                  {
                    time: '11:00 AM - 11:30 AM',
                    subject: 'Campus Recess & Academic Break',
                    code: 'BREAK',
                    room: 'Student Lounge & Cafeteria',
                    instructor: 'Campus Commons',
                    avatar: null,
                    type: 'Break',
                    status: 'break',
                  },
                  {
                    time: '11:30 AM - 12:30 PM',
                    subject: 'Discrete Mathematics & Graph Theory',
                    code: 'BCA-303',
                    room: 'Room 204 (Block A)',
                    instructor: 'Prof. Kavita Rao',
                    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80',
                    type: 'Theory',
                    status: 'upcoming',
                  },
                  {
                    time: '01:30 PM - 03:30 PM',
                    subject: 'Computer Networks Lab & Packet Tracer',
                    code: 'BCA-304P',
                    room: 'Network Lab 3',
                    instructor: 'Prof. Amit Kumar',
                    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
                    type: 'Hands-on Lab',
                    status: 'upcoming',
                  },
                ].map((item, idx) => (
                  <div className={`timeline-schedule-card ${item.status}`} key={idx}>
                    <div className="time-badge-col">
                      <Clock size={16} className="time-icon" />
                      <span className="time-range-text">{item.time}</span>
                      <span className={`schedule-type-pill ${item.type.toLowerCase().replace(' ', '-')}`}>
                        {item.type}
                      </span>
                    </div>

                    <div className="timeline-main-details">
                      <div className="subject-head-row">
                        <h4>{item.subject}</h4>
                        <span className="subject-room-tag">
                          <MapPin size={13} /> {item.room}
                        </span>
                      </div>

                      {item.avatar && (
                        <div className="instructor-badge-row">
                          <img
                            src={item.avatar}
                            alt={item.instructor}
                            className="instructor-avatar-xs"
                          />
                          <span className="instructor-text-name">
                            Taught by <strong>{item.instructor}</strong>
                          </span>
                        </div>
                      )}
                    </div>

                    <div className="timeline-action-col">
                      {item.status !== 'break' && (
                        <button
                          type="button"
                          className="btn-outline btn-sm-action"
                          onClick={() => {
                            setActiveTab('materials');
                            showToast(`Navigating to study notes for ${item.subject}`);
                          }}
                        >
                          <BookOpen size={14} />
                          <span>Notes</span>
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* =========================================================
              6. LECTURE MATERIALS (Enhanced with Course Thumbnails & Downloads)
             ========================================================= */}
          {activeTab === 'materials' && (
            <div className="materials-view-content">
              <div className="view-header-with-filters">
                <div>
                  <h2>Lecture Materials & Resources</h2>
                  <p className="view-subheading">
                    Download verified syllabus notes, unit guides, presentation decks, and practical lab manuals.
                  </p>
                </div>
                <div className="view-filters-group">
                  <div className="filter-select-wrapper">
                    <label>Filter by Subject</label>
                    <select
                      className="portal-filter-select"
                      value={materialFilter}
                      onChange={(e) => setMaterialFilter(e.target.value)}
                    >
                      <option value="all">All Subjects (6)</option>
                      <option value="dbms">Database Management</option>
                      <option value="web">Web Development</option>
                      <option value="math">Mathematics</option>
                      <option value="networks">Computer Networks</option>
                    </select>
                  </div>
                  <div className="filter-select-wrapper">
                    <label>Semester</label>
                    <select className="portal-filter-select" defaultValue="BCA - Sem 3">
                      <option>BCA - Sem 3</option>
                    </select>
                  </div>
                </div>
              </div>

              {/* Course Materials Grid with High-Quality Thumbnails */}
              <div className="materials-cards-grid">
                {[
                  {
                    title: 'Database Management Systems - Unit 3: Normalization & SQL Queries',
                    course: 'DBMS (BCA-301)',
                    instructor: 'Dr. Neha Verma',
                    date: 'Apr 26, 2025',
                    type: 'pdf',
                    size: '4.8 MB',
                    downloads: 64,
                    thumb: 'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?auto=format&fit=crop&w=500&q=80',
                    category: 'dbms',
                  },
                  {
                    title: 'Modern Web Development - React Components, Hooks & State Management',
                    course: 'Web Tech (BCA-302)',
                    instructor: 'Prof. Swati Deshmukh',
                    date: 'Apr 22, 2025',
                    type: 'zip',
                    size: '12.4 MB',
                    downloads: 82,
                    thumb: 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?auto=format&fit=crop&w=500&q=80',
                    category: 'web',
                  },
                  {
                    title: 'Discrete Mathematics - Graph Theory, Trees & Dijkstra Algorithm',
                    course: 'Mathematics (BCA-303)',
                    instructor: 'Prof. Kavita Rao',
                    date: 'Apr 18, 2025',
                    type: 'pdf',
                    size: '3.6 MB',
                    downloads: 58,
                    thumb: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=500&q=80',
                    category: 'math',
                  },
                  {
                    title: 'Computer Networks - OSI vs TCP/IP Protocols & Subnetting Guide',
                    course: 'Networks (BCA-304)',
                    instructor: 'Prof. Amit Kumar',
                    date: 'Apr 14, 2025',
                    type: 'ppt',
                    size: '8.2 MB',
                    downloads: 71,
                    thumb: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=500&q=80',
                    category: 'networks',
                  },
                  {
                    title: 'Data Structures & Algorithms - AVL Balanced Trees & Hash Maps',
                    course: 'DSA (BCA-301)',
                    instructor: 'Prof. Rajesh Gupta',
                    date: 'Apr 10, 2025',
                    type: 'pdf',
                    size: '5.1 MB',
                    downloads: 95,
                    thumb: 'https://images.unsplash.com/photo-1516116211227-bbc03c14a84d?auto=format&fit=crop&w=500&q=80',
                    category: 'dbms',
                  },
                  {
                    title: 'Technical Communication & Professional Ethics Handout',
                    course: 'English (BCA-306)',
                    instructor: 'Dr. Sarah Wilson',
                    date: 'Apr 05, 2025',
                    type: 'pdf',
                    size: '2.4 MB',
                    downloads: 44,
                    thumb: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?auto=format&fit=crop&w=500&q=80',
                    category: 'all',
                  },
                ]
                  .filter((m) => materialFilter === 'all' || m.category === materialFilter)
                  .map((item, i) => (
                    <div className="material-modern-card" key={i}>
                      <div
                        className="material-card-thumbnail"
                        style={{ backgroundImage: `url('${item.thumb}')` }}
                      >
                        <span className={`material-filetype-badge ${item.type}`}>
                          {item.type.toUpperCase()}
                        </span>
                        <span className="material-size-pill">{item.size}</span>
                      </div>

                      <div className="material-card-body">
                        <span className="material-course-pill">{item.course}</span>
                        <h4 className="material-title">{item.title}</h4>

                        <div className="material-author-row">
                          <span className="material-author">By {item.instructor}</span>
                          <span className="material-date">• {item.date}</span>
                        </div>
                      </div>

                      <div className="material-card-footer">
                        <span className="downloads-count">
                          <Download size={13} /> {item.downloads} downloads
                        </span>
                        <button
                          type="button"
                          className="btn-primary btn-sm-download"
                          onClick={() => showToast(`Downloading: ${item.title}`)}
                          title="Download document file"
                        >
                          <Download size={14} />
                          <span>Download</span>
                        </button>
                      </div>
                    </div>
                  ))}
              </div>
            </div>
          )}

          {/* =========================================================
              7. EXAM TIMETABLE (Enhanced with Live Exam Countdown & Admit Card)
             ========================================================= */}
          {activeTab === 'timetable' && (
            <div className="timetable-view-content">
              <div className="view-header-with-filters">
                <div>
                  <h2>Official Exam Timetable</h2>
                  <p className="view-subheading">
                    Spring 2025 Mid-Term & Final Examination Schedule with Hall Allotments.
                  </p>
                </div>
                <div className="view-filters-group">
                  <div className="filter-select-wrapper">
                    <label>Semester</label>
                    <select className="portal-filter-select" defaultValue="Even Semester (Sem 3)">
                      <option>Even Semester (Sem 3)</option>
                    </select>
                  </div>
                  <button
                    type="button"
                    className="btn-primary btn-sm-action"
                    onClick={() => showToast('Official Admit Card PDF downloaded!')}
                  >
                    <Download size={15} />
                    <span>Download Hall Ticket</span>
                  </button>
                </div>
              </div>

              {/* Dynamic Exam Countdown Clock Banner */}
              <div className="exam-countdown-hero-banner">
                <div className="countdown-info-side">
                  <div className="countdown-badge-row">
                    <span className="countdown-badge-pill">
                      <Clock size={14} /> Official Examination Alert
                    </span>
                    <span className="exam-session-text">Session: Spring 2025</span>
                  </div>
                  <h3>Mid-Term Examinations Begin In:</h3>
                  <p>Check your assigned Examination Hall and Seat Numbers before test commencement.</p>
                </div>

                <div className="countdown-clock-digits-row">
                  <div className="countdown-digit-box">
                    <span className="digit-num">04</span>
                    <span className="digit-label">Days</span>
                  </div>
                  <span className="countdown-colon">:</span>
                  <div className="countdown-digit-box">
                    <span className="digit-num">14</span>
                    <span className="digit-label">Hours</span>
                  </div>
                  <span className="countdown-colon">:</span>
                  <div className="countdown-digit-box">
                    <span className="digit-num">28</span>
                    <span className="digit-label">Mins</span>
                  </div>
                  <span className="countdown-colon">:</span>
                  <div className="countdown-digit-box">
                    <span className="digit-num">45</span>
                    <span className="digit-label">Secs</span>
                  </div>
                </div>
              </div>

              {/* Timetable Cards Grid */}
              <div className="timetable-cards-grid">
                {[
                  {
                    date: 'May 05, 2025',
                    day: 'Monday',
                    subject: 'Database Management Systems',
                    code: 'BCA-301',
                    time: '09:00 AM - 11:00 AM',
                    room: 'Central Hall 101',
                    seat: 'Seat #B-24',
                    duration: '2 Hours',
                    icon: BookOpen,
                    color: 'blue',
                  },
                  {
                    date: 'May 07, 2025',
                    day: 'Wednesday',
                    subject: 'Web Technologies & Frontend Dev',
                    code: 'BCA-302',
                    time: '10:00 AM - 12:00 PM',
                    room: 'Computer Center 102',
                    seat: 'Seat #C-12',
                    duration: '2 Hours',
                    icon: FileCheck2,
                    color: 'green',
                  },
                  {
                    date: 'May 10, 2025',
                    day: 'Saturday',
                    subject: 'Discrete Mathematics & Graph Theory',
                    code: 'BCA-303',
                    time: '01:00 PM - 03:00 PM',
                    room: 'Hall 103 (Block B)',
                    seat: 'Seat #A-08',
                    duration: '2 Hours',
                    icon: Award,
                    color: 'purple',
                  },
                  {
                    date: 'May 12, 2025',
                    day: 'Monday',
                    subject: 'Computer Networks & Security',
                    code: 'BCA-304',
                    time: '02:00 PM - 04:00 PM',
                    room: 'Examination Hall 104',
                    seat: 'Seat #D-19',
                    duration: '2 Hours',
                    icon: Clock,
                    color: 'orange',
                  },
                  {
                    date: 'May 15, 2025',
                    day: 'Thursday',
                    subject: 'Technical Communication Skills',
                    code: 'BCA-306',
                    time: '04:00 PM - 06:00 PM',
                    room: 'Auditorium Hall 105',
                    seat: 'Seat #E-05',
                    duration: '2 Hours',
                    icon: FileText,
                    color: 'blue',
                  },
                ].map((paper, idx) => {
                  const Icon = paper.icon;
                  return (
                    <div className="exam-timetable-item-card" key={idx}>
                      <div className="exam-paper-date-badge">
                        <span className="exam-badge-day">{paper.day}</span>
                        <span className="exam-badge-date">{paper.date}</span>
                      </div>

                      <div className="exam-paper-details">
                        <div className="paper-header-row">
                          <div className={`paper-icon-bubble ${paper.color}`}>
                            <Icon size={20} />
                          </div>
                          <div>
                            <span className="paper-code-tag">{paper.code}</span>
                            <h4 className="paper-title">{paper.subject}</h4>
                          </div>
                        </div>

                        <div className="paper-meta-row">
                          <span className="meta-pill time">
                            <Clock size={13} /> {paper.time}
                          </span>
                          <span className="meta-pill room">
                            <MapPin size={13} /> {paper.room}
                          </span>
                          <span className="meta-pill seat">
                            <User size={13} /> {paper.seat}
                          </span>
                        </div>
                      </div>

                      <div className="exam-paper-action-col">
                        <span className="duration-tag">{paper.duration}</span>
                        <button
                          type="button"
                          className="btn-outline btn-sm-action"
                          onClick={() => {
                            setActiveTab('exam-instructions');
                            showToast(`Opening exam prep for ${paper.subject}`);
                          }}
                        >
                          <span>Syllabus & Info →</span>
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* =========================================================
              8. PARENT INFORMATION (Enhanced with Avatars & Fee Status)
             ========================================================= */}
          {activeTab === 'parents' && (
            <div className="parents-view-content">
              <div className="view-header-with-filters">
                <div>
                  <h2>Parent & Guardian Information</h2>
                  <p className="view-subheading">
                    Verified family records, communication preferences, and institutional fee status.
                  </p>
                </div>
                <div className="view-filters-group">
                  <button
                    type="button"
                    className="btn-outline btn-sm-action"
                    onClick={() => setShowPTMModal(true)}
                  >
                    <Calendar size={15} />
                    <span>Request Faculty Meeting</span>
                  </button>
                  <button
                    type="button"
                    className="btn-primary btn-sm-action"
                    onClick={() => setShowEditParentModal(true)}
                  >
                    <Edit2 size={15} />
                    <span>Update Contact Details</span>
                  </button>
                </div>
              </div>

              {/* Parents Profile Cards Grid */}
              <div className="parent-cards-grid">
                {/* Father Details Card */}
                <div className="parent-profile-card">
                  <div className="parent-card-header">
                    <img
                      src="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80"
                      alt={studentInfo.fatherName}
                      className="parent-avatar-photo"
                    />
                    <div className="parent-header-title">
                      <span className="parent-role-tag">Father / Primary Guardian</span>
                      <h3 className="parent-name">{studentInfo.fatherName}</h3>
                      <span className="parent-occupation">{studentInfo.fatherOccupation}</span>
                    </div>
                  </div>

                  <div className="parent-details-body">
                    <div className="parent-contact-row">
                      <Phone size={15} className="contact-icon blue" />
                      <span className="contact-label">Mobile Phone:</span>
                      <a href={`tel:${studentInfo.fatherPhone}`} className="contact-link">
                        {studentInfo.fatherPhone}
                      </a>
                    </div>
                    <div className="parent-contact-row">
                      <Mail size={15} className="contact-icon blue" />
                      <span className="contact-label">Email Address:</span>
                      <a href={`mailto:${studentInfo.fatherEmail}`} className="contact-link">
                        {studentInfo.fatherEmail}
                      </a>
                    </div>
                    <div className="parent-contact-row">
                      <ShieldCheck size={15} className="contact-icon green" />
                      <span className="contact-label">SMS Alerts:</span>
                      <span className="contact-value active">Active (Daily Attendance & Fees)</span>
                    </div>
                  </div>

                  <div className="parent-card-footer">
                    <button
                      type="button"
                      className="btn-outline btn-sm-action"
                      onClick={() => showToast(`Calling Father at ${studentInfo.fatherPhone}`)}
                    >
                      <Phone size={14} /> Call Father
                    </button>
                    <button
                      type="button"
                      className="btn-outline btn-sm-action"
                      onClick={() => showToast(`Email draft opened for ${studentInfo.fatherEmail}`)}
                    >
                      <Mail size={14} /> Send Email
                    </button>
                  </div>
                </div>

                {/* Mother Details Card */}
                <div className="parent-profile-card">
                  <div className="parent-card-header">
                    <img
                      src="https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80"
                      alt={studentInfo.motherName}
                      className="parent-avatar-photo"
                    />
                    <div className="parent-header-title">
                      <span className="parent-role-tag">Mother / Co-Guardian</span>
                      <h3 className="parent-name">{studentInfo.motherName}</h3>
                      <span className="parent-occupation">{studentInfo.motherOccupation}</span>
                    </div>
                  </div>

                  <div className="parent-details-body">
                    <div className="parent-contact-row">
                      <Phone size={15} className="contact-icon blue" />
                      <span className="contact-label">Mobile Phone:</span>
                      <a href={`tel:${studentInfo.motherPhone}`} className="contact-link">
                        {studentInfo.motherPhone}
                      </a>
                    </div>
                    <div className="parent-contact-row">
                      <Mail size={15} className="contact-icon blue" />
                      <span className="contact-label">Email Address:</span>
                      <a href={`mailto:${studentInfo.motherEmail}`} className="contact-link">
                        {studentInfo.motherEmail}
                      </a>
                    </div>
                    <div className="parent-contact-row">
                      <CheckCircle2 size={15} className="contact-icon green" />
                      <span className="contact-label">Communication:</span>
                      <span className="contact-value active">WhatsApp Verified</span>
                    </div>
                  </div>

                  <div className="parent-card-footer">
                    <button
                      type="button"
                      className="btn-outline btn-sm-action"
                      onClick={() => showToast(`Calling Mother at ${studentInfo.motherPhone}`)}
                    >
                      <Phone size={14} /> Call Mother
                    </button>
                    <button
                      type="button"
                      className="btn-outline btn-sm-action"
                      onClick={() => showToast(`Email draft opened for ${studentInfo.motherEmail}`)}
                    >
                      <Mail size={14} /> Send Email
                    </button>
                  </div>
                </div>

                {/* Guardian Address & Emergency Details */}
                <div className="parent-profile-card address-card full-width">
                  <div className="address-header-row">
                    <div className="parent-avatar-circle address">
                      <MapPin size={24} />
                    </div>
                    <div>
                      <h4>Registered Permanent Residence</h4>
                      <p className="address-text">{studentInfo.address}</p>
                    </div>
                  </div>
                  <div className="emergency-contact-pill">
                    <AlertCircle size={15} className="alert-amber" />
                    <span>In case of medical or campus emergency, both primary guardians receive immediate automated notification.</span>
                  </div>
                </div>
              </div>

              {/* Fee Payment Status Card for Parents */}
              <div className="portal-card-block fee-summary-card">
                <div className="section-title-row">
                  <div className="title-with-icon">
                    <ShieldCheck size={18} className="title-icon green" />
                    <h4>Academic Session 2025–2026 Tuition Fee Status</h4>
                  </div>
                  <span className="fee-status-badge-paid">
                    <CheckCircle2 size={15} /> All Dues Cleared (Receipt #REC-2025-092)
                  </span>
                </div>

                <div className="fee-details-row">
                  <div className="fee-item">
                    <span className="fee-label">Semester 3 Tuition Fee</span>
                    <span className="fee-val">₹42,000</span>
                  </div>
                  <div className="fee-item">
                    <span className="fee-label">Computer Laboratory & Library</span>
                    <span className="fee-val">₹6,500</span>
                  </div>
                  <div className="fee-item">
                    <span className="fee-label">Total Amount Paid</span>
                    <span className="fee-val highlight green">₹48,500</span>
                  </div>
                  <div className="fee-item">
                    <span className="fee-label">Payment Date</span>
                    <span className="fee-val">Jan 12, 2025</span>
                  </div>
                  <div className="fee-item action">
                    <button
                      type="button"
                      className="btn-outline btn-sm-action"
                      onClick={() => showToast('Official Fee Receipt PDF downloaded!')}
                    >
                      <Download size={14} /> Download Receipt
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* =========================================================
              9. EXAMS LIST PAGE (Group 2: Online Exam System)
             ========================================================= */}
          {activeTab === 'exams' && (
            <div className="exams-view-content">
              <div className="view-header-with-filters">
                <div>
                  <h2>Online Examinations Portal</h2>
                  <p className="view-subheading">
                    Take proctored online examinations, view question instructions, and review past scorecards.
                  </p>
                </div>

                <div className="exam-mode-tabs">
                  <button
                    type="button"
                    className={`exam-tab-btn ${examTab === 'upcoming' ? 'active' : ''}`}
                    onClick={() => setExamTab('upcoming')}
                  >
                    Upcoming Exams (2)
                  </button>
                  <button
                    type="button"
                    className={`exam-tab-btn ${examTab === 'past' ? 'active' : ''}`}
                    onClick={() => setExamTab('past')}
                  >
                    Completed Exams (2)
                  </button>
                </div>
              </div>

              {/* Exam Cards List */}
              <div className="exam-cards-list">
                {/* Exam 1: Mathematics */}
                <div className="exam-item-card featured">
                  <div className="exam-icon-circle blue">
                    <Award size={24} />
                  </div>
                  <div className="exam-info-col">
                    <div className="exam-badge-row">
                      <span className="exam-type-pill blue">Internal Assessment</span>
                      <span className="exam-class-pill">BCA - Sem 3</span>
                    </div>
                    <h3>Mathematics - Discrete Structures (Mid-Term)</h3>
                    <p className="exam-syllabus-brief">Topics: Calculus, Derivatives, Linear Systems, Graph Theory</p>
                  </div>
                  <div className="exam-meta-col">
                    <span className="exam-date-text">
                      <Calendar size={14} /> May 10, 2025
                    </span>
                    <span className="exam-time-text">
                      <Clock size={14} /> 09:00 AM - 11:00 AM
                    </span>
                  </div>
                  <div className="exam-duration-col">
                    <span className="duration-label">Duration / Marks</span>
                    <span className="duration-value">2 Hours • 100 Marks</span>
                  </div>
                  <div className="exam-action-col">
                    <button
                      type="button"
                      className="btn-primary exam-start-btn"
                      onClick={() => setActiveTab('exam-instructions')}
                    >
                      <span>Start Exam</span>
                      <ArrowRight size={16} />
                    </button>
                  </div>
                </div>

                {/* Exam 2: Web Development */}
                <div className="exam-item-card">
                  <div className="exam-icon-circle green">
                    <FileCheck2 size={24} />
                  </div>
                  <div className="exam-info-col">
                    <div className="exam-badge-row">
                      <span className="exam-type-pill green">Practical Evaluation</span>
                      <span className="exam-class-pill">BCA - Sem 3</span>
                    </div>
                    <h3>Web Development & React Framework</h3>
                    <p className="exam-syllabus-brief">Topics: React State, Hooks, REST APIs, Tailwind CSS</p>
                  </div>
                  <div className="exam-meta-col">
                    <span className="exam-date-text">
                      <Calendar size={14} /> May 07, 2025
                    </span>
                    <span className="exam-time-text">
                      <Clock size={14} /> 10:00 AM - 12:00 PM
                    </span>
                  </div>
                  <div className="exam-duration-col">
                    <span className="duration-label">Duration / Marks</span>
                    <span className="duration-value">2 Hours • 100 Marks</span>
                  </div>
                  <div className="exam-action-col">
                    <button
                      type="button"
                      className="btn-primary exam-start-btn"
                      onClick={() => setActiveTab('exam-instructions')}
                    >
                      <span>Start Exam</span>
                      <ArrowRight size={16} />
                    </button>
                  </div>
                </div>

                {/* Exam 3: Database Management (Completed) */}
                <div className="exam-item-card past">
                  <div className="exam-icon-circle purple">
                    <CheckCircle2 size={24} />
                  </div>
                  <div className="exam-info-col">
                    <div className="exam-badge-row">
                      <span className="exam-type-pill purple">Graded Completed</span>
                      <span className="exam-class-pill">Score: 85/100 (A)</span>
                    </div>
                    <h3>Database Management Systems (Mid-Term)</h3>
                    <p className="exam-syllabus-brief">Completed on Apr 28, 2025 • Verified by Dr. Neha Verma</p>
                  </div>
                  <div className="exam-meta-col">
                    <span className="exam-date-text">
                      <Calendar size={14} /> Apr 28, 2025
                    </span>
                    <span className="exam-time-text">
                      <Clock size={14} /> 09:00 AM - 11:00 AM
                    </span>
                  </div>
                  <div className="exam-duration-col">
                    <span className="duration-label">Status</span>
                    <span className="duration-value green">Rank #3</span>
                  </div>
                  <div className="exam-action-col">
                    <button
                      type="button"
                      className="btn-outline exam-details-btn"
                      onClick={() => setActiveTab('exam-results')}
                    >
                      <span>View Results</span>
                      <ChevronRight size={15} />
                    </button>
                  </div>
                </div>

                {/* Exam 4: Computer Networks (Completed) */}
                <div className="exam-item-card past">
                  <div className="exam-icon-circle orange">
                    <CheckCircle2 size={24} />
                  </div>
                  <div className="exam-info-col">
                    <div className="exam-badge-row">
                      <span className="exam-type-pill orange">Graded Completed</span>
                      <span className="exam-class-pill">Score: 88/100 (A)</span>
                    </div>
                    <h3>Computer Networks & Protocols</h3>
                    <p className="exam-syllabus-brief">Completed on Apr 22, 2025 • Verified by Prof. Amit Kumar</p>
                  </div>
                  <div className="exam-meta-col">
                    <span className="exam-date-text">
                      <Calendar size={14} /> Apr 22, 2025
                    </span>
                    <span className="exam-time-text">
                      <Clock size={14} /> 02:00 PM - 04:00 PM
                    </span>
                  </div>
                  <div className="exam-duration-col">
                    <span className="duration-label">Status</span>
                    <span className="duration-value green">Rank #4</span>
                  </div>
                  <div className="exam-action-col">
                    <button
                      type="button"
                      className="btn-outline exam-details-btn"
                      onClick={() => setActiveTab('exam-results')}
                    >
                      <span>View Results</span>
                      <ChevronRight size={15} />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* =========================================================
              10. EXAM INSTRUCTIONS PAGE
             ========================================================= */}
          {activeTab === 'exam-instructions' && (
            <div className="instructions-view-content">
              <div className="view-header">
                <h2>Exam Instructions & System Readiness Check</h2>
                <p className="view-subheading">
                  Please read the testing instructions and ensure your computer environment is configured before starting.
                </p>
              </div>

              {/* Exam Metadata Banner */}
              <div className="instructions-meta-card">
                <div className="meta-subject-row">
                  <div>
                    <span className="meta-badge-tag">Mid-Term Assessment</span>
                    <h3>Mathematics - Calculus & Discrete Structures (Mid-Term)</h3>
                  </div>
                  <div className="system-readiness-box">
                    <span className="sys-status green"><CheckCircle2 size={14} /> Camera Active</span>
                    <span className="sys-status green"><CheckCircle2 size={14} /> Audio Verified</span>
                    <span className="sys-status green"><CheckCircle2 size={14} /> Secure Browser</span>
                  </div>
                </div>

                <div className="meta-stats-strip">
                  <div className="meta-stat-item">
                    <span className="stat-label">Exam Date</span>
                    <span className="stat-val">Apr 28, 2025</span>
                  </div>
                  <div className="meta-stat-item">
                    <span className="stat-label">Scheduled Time</span>
                    <span className="stat-val">09:00 AM - 11:00 AM</span>
                  </div>
                  <div className="meta-stat-item">
                    <span className="stat-label">Total Duration</span>
                    <span className="stat-val">2 Hours (120 Mins)</span>
                  </div>
                  <div className="meta-stat-item">
                    <span className="stat-label">Total Marks</span>
                    <span className="stat-val">100 Marks (20 Qs)</span>
                  </div>
                </div>
              </div>

              {/* Instructions List Card */}
              <div className="portal-card-block instructions-card">
                <h4 className="instructions-title">Important Examination Rules:</h4>
                <ul className="instructions-bullet-list">
                  <li>
                    <span className="bullet-num">1</span>
                    <span>The examination is strictly timed. The countdown clock starts automatically when you click "Start Exam".</span>
                  </li>
                  <li>
                    <span className="bullet-num">2</span>
                    <span>Use the question navigator on the right to jump between questions or flag items for later review.</span>
                  </li>
                  <li>
                    <span className="bullet-num">3</span>
                    <span>Do NOT refresh the browser page or exit full-screen mode during the examination.</span>
                  </li>
                  <li>
                    <span className="bullet-num">4</span>
                    <span>Your answers are automatically saved to the server whenever you select an option.</span>
                  </li>
                  <li>
                    <span className="bullet-num">5</span>
                    <span>Once you confirm final submission, answers cannot be edited or reopened.</span>
                  </li>
                  <li>
                    <span className="bullet-num">6</span>
                    <span>Proctoring AI will monitor tab switches and display warnings if multiple screens are detected.</span>
                  </li>
                </ul>

                <div className="instructions-consent-box">
                  <label className="consent-checkbox-label">
                    <input
                      type="checkbox"
                      checked={instructionsAccepted}
                      onChange={(e) => setInstructionsAccepted(e.target.checked)}
                    />
                    <span>I confirm that I have read and agree to all academic integrity instructions and guidelines.</span>
                  </label>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="instructions-actions-bar">
                <button
                  type="button"
                  className="btn-outline back-btn"
                  onClick={() => setActiveTab('exams')}
                >
                  ← Back to Exams
                </button>
                <button
                  type="button"
                  className={`btn-primary start-exam-now-btn ${!instructionsAccepted ? 'disabled' : ''}`}
                  disabled={!instructionsAccepted}
                  onClick={() => {
                    setActiveTab('exam-live');
                    setIsExamRunning(true);
                  }}
                >
                  <span>Start Examination Now</span>
                  <ArrowRight size={18} />
                </button>
              </div>
            </div>
          )}

          {/* =========================================================
              11. LIVE EXAM INTERFACE (With Live Timer & Palette)
             ========================================================= */}
          {activeTab === 'exam-live' && (
            <div className="live-exam-view-content">
              {/* Exam Live Header Strip */}
              <div className="live-exam-header-strip">
                <div className="live-exam-identity">
                  <div className="identity-badge-row">
                    <span className="live-pulsing-badge">● LIVE PROCTORED TEST</span>
                    <span className="session-tag">BCA-301 Mid-Term</span>
                  </div>
                  <h3>Mathematics - Calculus & Discrete Structures</h3>
                </div>

                <div className="live-exam-timer-box">
                  <div className="timer-icon-wrap">
                    <Timer size={20} />
                  </div>
                  <div className="timer-text-wrap">
                    <span className="timer-label">Time Remaining</span>
                    <span className="timer-digits">{formatTimer(examTimeRemaining)}</span>
                  </div>
                </div>
              </div>

              {/* Split Content: Question Panel vs Navigator */}
              <div className="live-exam-body-grid">
                {/* Left: Active Question Panel */}
                <div className="question-main-panel">
                  <div className="question-number-header">
                    <div className="q-badge-group">
                      <span className="q-badge">Question {currentQuestion} of 20</span>
                      <span className="q-type-pill">Multiple Choice (+5 Marks, -1 Negative)</span>
                    </div>
                    <button
                      type="button"
                      className={`btn-flag-q ${flaggedQuestions[currentQuestion] ? 'flagged' : ''}`}
                      onClick={() => toggleFlagQuestion(currentQuestion)}
                    >
                      <Flag size={14} />
                      <span>{flaggedQuestions[currentQuestion] ? 'Flagged for Review' : 'Flag Question'}</span>
                    </button>
                  </div>

                  <div className="question-prompt-text">
                    {currentQuestion === 5 && (
                      <>Which of the following is the correct derivative of function <strong>f(x) = x²</strong>?</>
                    )}
                    {currentQuestion === 1 && (
                      <>What is the cardinality of the power set of a set with <strong>n</strong> elements?</>
                    )}
                    {currentQuestion === 2 && (
                      <>In graph theory, an Euler path visits every __________ in a finite graph exactly once.</>
                    )}
                    {currentQuestion === 3 && (
                      <>What is the limit of <strong>sin(x) / x</strong> as <strong>x approaches 0</strong>?</>
                    )}
                    {currentQuestion === 4 && (
                      <>Which of the following matrices has an inverse?</>
                    )}
                    {currentQuestion > 5 && (
                      <>Consider the binary search recurrence relation <strong>T(n) = T(n/2) + O(1)</strong>. What is its asymptotic time complexity?</>
                    )}
                  </div>

                  <div className="question-options-list">
                    {(currentQuestion === 5
                      ? [
                          { key: 'A', text: '2x' },
                          { key: 'B', text: 'x' },
                          { key: 'C', text: 'x²' },
                          { key: 'D', text: '2x²' },
                        ]
                      : currentQuestion === 1
                      ? [
                          { key: 'A', text: 'n²' },
                          { key: 'B', text: '2ⁿ' },
                          { key: 'C', text: '2n' },
                          { key: 'D', text: 'n!' },
                        ]
                      : currentQuestion === 2
                      ? [
                          { key: 'A', text: 'Edge' },
                          { key: 'B', text: 'Vertex' },
                          { key: 'C', text: 'Cycle' },
                          { key: 'D', text: 'Component' },
                        ]
                      : [
                          { key: 'A', text: 'O(log n)' },
                          { key: 'B', text: 'O(n)' },
                          { key: 'C', text: 'O(n log n)' },
                          { key: 'D', text: 'O(1)' },
                        ]
                    ).map((opt) => (
                      <label
                        key={opt.key}
                        className={`option-choice-item ${selectedAnswers[currentQuestion] === opt.key ? 'selected' : ''}`}
                        onClick={() => handleOptionSelect(opt.key)}
                      >
                        <input
                          type="radio"
                          name={`q-${currentQuestion}`}
                          value={opt.key}
                          checked={selectedAnswers[currentQuestion] === opt.key}
                          onChange={() => handleOptionSelect(opt.key)}
                        />
                        <span className="option-letter">{opt.key}.</span>
                        <span className="option-text">{opt.text}</span>
                      </label>
                    ))}
                  </div>

                  {/* Navigation Actions */}
                  <div className="question-navigation-actions">
                    <button
                      type="button"
                      className="btn-outline q-nav-btn"
                      disabled={currentQuestion === 1}
                      onClick={() => setCurrentQuestion((prev) => Math.max(1, prev - 1))}
                    >
                      ← Previous Question
                    </button>
                    <button
                      type="button"
                      className="btn-primary q-nav-btn next"
                      onClick={() => setCurrentQuestion((prev) => Math.min(20, prev + 1))}
                    >
                      <span>Next Question →</span>
                    </button>
                    <button
                      type="button"
                      className="btn-danger finish-exam-btn"
                      onClick={() => setShowSubmitConfirmModal(true)}
                    >
                      <CheckCircle2 size={16} />
                      <span>Finish & Submit</span>
                    </button>
                  </div>
                </div>

                {/* Right: Question Navigator Panel */}
                <div className="question-navigator-panel">
                  <h4>Question Navigator Palette</h4>
                  <div className="navigator-grid-20">
                    {Array.from({ length: 20 }, (_, i) => i + 1).map((num) => {
                      const isCurrent = num === currentQuestion;
                      const isAnswered = selectedAnswers[num] !== undefined;
                      const isFlagged = flaggedQuestions[num];

                      let statusClass = 'unanswered';
                      if (isCurrent) statusClass = 'current';
                      else if (isFlagged) statusClass = 'flagged';
                      else if (isAnswered) statusClass = 'answered';

                      return (
                        <button
                          key={num}
                          type="button"
                          className={`nav-grid-num ${statusClass}`}
                          onClick={() => setCurrentQuestion(num)}
                          title={`Question ${num}`}
                        >
                          {num}
                        </button>
                      );
                    })}
                  </div>

                  <div className="navigator-legend-list">
                    <div className="legend-row">
                      <span className="legend-dot green" />
                      <span className="legend-name">Answered</span>
                      <span className="legend-count">{Object.keys(selectedAnswers).length}</span>
                    </div>
                    <div className="legend-row">
                      <span className="legend-dot amber" />
                      <span className="legend-name">Flagged for Review</span>
                      <span className="legend-count">{Object.keys(flaggedQuestions).filter((k) => flaggedQuestions[k]).length}</span>
                    </div>
                    <div className="legend-row">
                      <span className="legend-dot blue" />
                      <span className="legend-name">Current Question</span>
                      <span className="legend-count">#{currentQuestion}</span>
                    </div>
                    <div className="legend-row">
                      <span className="legend-dot gray" />
                      <span className="legend-name">Unanswered</span>
                      <span className="legend-count">{20 - Object.keys(selectedAnswers).length}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Submit Confirmation Modal */}
          {showSubmitConfirmModal && (
            <div className="portal-modal-backdrop">
              <div className="portal-modal-card">
                <div className="modal-header">
                  <h3>Confirm Exam Submission</h3>
                  <button
                    type="button"
                    className="modal-close-btn"
                    onClick={() => setShowSubmitConfirmModal(false)}
                  >
                    ✕
                  </button>
                </div>
                <div className="modal-confirm-body">
                  <p>Are you sure you want to finalize and submit your examination?</p>
                  <div className="submission-summary-pill-box">
                    <span>Total Questions: <strong>20</strong></span>
                    <span>Answered: <strong>{Object.keys(selectedAnswers).length}</strong></span>
                    <span>Unanswered: <strong>{20 - Object.keys(selectedAnswers).length}</strong></span>
                  </div>
                  <p className="confirm-warning-subtext">You will not be able to return to this test after submission.</p>
                </div>
                <div className="modal-actions-row">
                  <button
                    type="button"
                    className="btn-outline"
                    onClick={() => setShowSubmitConfirmModal(false)}
                  >
                    Cancel & Return to Test
                  </button>
                  <button
                    type="button"
                    className="btn-primary"
                    onClick={() => {
                      setShowSubmitConfirmModal(false);
                      setActiveTab('exam-submitted');
                    }}
                  >
                    Yes, Final Submit
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* =========================================================
              12. SUBMISSION SUCCESS PAGE
             ========================================================= */}
          {activeTab === 'exam-submitted' && (
            <div className="submitted-view-content">
              <div className="submission-card-center">
                <div className="submission-check-graphic">
                  <div className="outer-pulse-ring" />
                  <div className="check-icon-circle">
                    <CheckCircle2 size={56} className="big-check" />
                  </div>
                </div>

                <h2>Exam Submitted Successfully!</h2>
                <p className="submission-subtext">
                  Your responses have been recorded on the secure server. Receipt #EXM-2025-9948.
                </p>

                <div className="submitted-meta-box">
                  <div className="s-meta-item">
                    <span className="s-label">Subject</span>
                    <span className="s-val">Mathematics - Calculus</span>
                  </div>
                  <div className="s-meta-item">
                    <span className="s-label">Assessment</span>
                    <span className="s-val">Mid-Term Evaluation</span>
                  </div>
                  <div className="s-meta-item">
                    <span className="s-label">Submission Date</span>
                    <span className="s-val">Apr 28, 2025</span>
                  </div>
                  <div className="s-meta-item">
                    <span className="s-label">Questions Answered</span>
                    <span className="s-val">20 / 20 Questions</span>
                  </div>
                </div>

                <div className="submission-actions-row">
                  <button
                    type="button"
                    className="btn-primary view-results-btn"
                    onClick={() => setActiveTab('exam-results')}
                  >
                    <Award size={16} />
                    <span>View Performance & Scorecard</span>
                  </button>
                  <button
                    type="button"
                    className="btn-outline back-exams-btn"
                    onClick={() => setActiveTab('exams')}
                  >
                    Back to Exams Hub
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* =========================================================
              13. EXAM RESULTS PAGE (Score Ring, Class Rank, Breakdown)
             ========================================================= */}
          {activeTab === 'exam-results' && (
            <div className="results-view-content">
              <div className="view-header">
                <div>
                  <h2>Examination Results & Analytics</h2>
                  <p className="view-subheading">
                    Detailed answer analysis, percentiles, and subject performance metrics.
                  </p>
                </div>
                <div className="results-subject-tag">
                  <span>Mathematics - Mid Term</span>
                  <span>•</span>
                  <span>Apr 28, 2025</span>
                </div>
              </div>

              {/* 4 Summary Cards */}
              <div className="results-summary-cards-grid">
                {/* Score Circular Gauge */}
                <div className="result-kpi-card gauge-card">
                  <div className="score-ring-wrapper">
                    <svg viewBox="0 0 100 100" className="score-svg">
                      <circle cx="50" cy="50" r="42" className="score-bg" />
                      <circle
                        cx="50"
                        cy="50"
                        r="42"
                        className="score-fill green"
                        strokeDasharray="264"
                        strokeDashoffset="39"
                      />
                    </svg>
                    <div className="score-text-inner">
                      <span className="score-num">85%</span>
                    </div>
                  </div>
                  <span className="kpi-title">Overall Score</span>
                </div>

                {/* Card 2: Marks Obtained */}
                <div className="result-kpi-card">
                  <div className="kpi-icon-circle green">
                    <Award size={22} />
                  </div>
                  <span className="kpi-big-num">85 / 100</span>
                  <span className="kpi-title">Marks Obtained</span>
                </div>

                {/* Card 3: Total Questions */}
                <div className="result-kpi-card">
                  <div className="kpi-icon-circle purple">
                    <FileText size={22} />
                  </div>
                  <span className="kpi-big-num">17 / 20</span>
                  <span className="kpi-title">Correct Questions</span>
                </div>

                {/* Card 4: Class Rank */}
                <div className="result-kpi-card">
                  <div className="kpi-icon-circle orange">
                    <Trophy size={22} />
                  </div>
                  <span className="kpi-big-num">#3 / 45</span>
                  <span className="kpi-title">Batch Rank</span>
                </div>
              </div>

              {/* Detailed Grid: Question Analysis & Subject Marks */}
              <div className="results-detailed-grid">
                {/* Left: Question-wise Performance Table */}
                <div className="portal-card-block">
                  <h4 className="block-title">Question-by-Question Response Audit</h4>
                  <div className="portal-table-responsive">
                    <table className="portal-clean-table results-table">
                      <thead>
                        <tr>
                          <th>Q.No</th>
                          <th>Topic</th>
                          <th>Your Choice</th>
                          <th>Correct Key</th>
                          <th>Marks</th>
                          <th>Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td>1</td>
                          <td>Set Theory (Power Set)</td>
                          <td><strong>B</strong></td>
                          <td><strong>B</strong></td>
                          <td>+5</td>
                          <td><span className="result-status-pill correct">Correct</span></td>
                        </tr>
                        <tr>
                          <td>2</td>
                          <td>Euler Path (Graph Theory)</td>
                          <td><strong>A</strong></td>
                          <td><strong>A</strong></td>
                          <td>+5</td>
                          <td><span className="result-status-pill correct">Correct</span></td>
                        </tr>
                        <tr>
                          <td>3</td>
                          <td>Limits & Continuity</td>
                          <td><strong>C</strong></td>
                          <td><strong>C</strong></td>
                          <td>+5</td>
                          <td><span className="result-status-pill correct">Correct</span></td>
                        </tr>
                        <tr>
                          <td>4</td>
                          <td>Matrix Inverses</td>
                          <td><strong>D</strong></td>
                          <td><strong>B</strong></td>
                          <td>-1</td>
                          <td><span className="result-status-pill incorrect">Incorrect</span></td>
                        </tr>
                        <tr>
                          <td>5</td>
                          <td>Derivative of x²</td>
                          <td><strong>A</strong></td>
                          <td><strong>A</strong></td>
                          <td>+5</td>
                          <td><span className="result-status-pill correct">Correct</span></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>

                  <div className="results-actions-bar">
                    <button
                      type="button"
                      className="btn-primary download-report-btn"
                      onClick={() => showToast('Full Performance Report PDF downloaded!')}
                    >
                      <Download size={16} />
                      <span>Download Full Performance Report</span>
                    </button>
                    <button
                      type="button"
                      className="btn-outline back-exams-btn"
                      onClick={() => setActiveTab('exams')}
                    >
                      Back to Exams Hub
                    </button>
                  </div>
                </div>

                {/* Right: Subject-wise Marks Breakdown */}
                <div className="portal-card-block">
                  <h4 className="block-title">Topic-wise Score Distribution</h4>
                  <div className="subject-progress-list">
                    {[
                      { subject: 'Differential Calculus', score: 28, total: 30, color: 'blue' },
                      { subject: 'Graph Theory & Trees', score: 25, total: 30, color: 'green' },
                      { subject: 'Set Theory & Combinatorics', score: 18, total: 20, color: 'purple' },
                      { subject: 'Matrices & Linear Algebra', score: 14, total: 20, color: 'orange' },
                    ].map((sub) => (
                      <div className="subject-progress-item" key={sub.subject}>
                        <div className="sub-header-row">
                          <span className="sub-name">{sub.subject}</span>
                          <span className="sub-score">
                            {sub.score} / {sub.total} Marks
                          </span>
                        </div>
                        <div className="progress-track">
                          <div
                            className={`progress-fill-bar ${sub.color}`}
                            style={{ width: `${(sub.score / sub.total) * 100}%` }}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* Edit Profile Modal */}
      {showEditProfileModal && (
        <div className="portal-modal-backdrop">
          <div className="portal-modal-card">
            <div className="modal-header">
              <h3>Edit Student Profile Details</h3>
              <button
                type="button"
                className="modal-close-btn"
                onClick={() => setShowEditProfileModal(false)}
              >
                ✕
              </button>
            </div>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                setShowEditProfileModal(false);
                showToast('Student profile updated successfully!');
              }}
              className="modal-form-body"
            >
              <div className="form-group-item">
                <label>Full Name</label>
                <input
                  type="text"
                  value={studentInfo.name}
                  onChange={(e) => setStudentInfo({ ...studentInfo, name: e.target.value })}
                  required
                />
              </div>
              <div className="form-group-item">
                <label>Student Email Address</label>
                <input
                  type="email"
                  value={studentInfo.email}
                  onChange={(e) => setStudentInfo({ ...studentInfo, email: e.target.value })}
                  required
                />
              </div>
              <div className="form-group-item">
                <label>Gender</label>
                <select
                  value={studentInfo.gender}
                  onChange={(e) => setStudentInfo({ ...studentInfo, gender: e.target.value })}
                >
                  <option>Male</option>
                  <option>Female</option>
                  <option>Other</option>
                </select>
              </div>
              <div className="form-group-item">
                <label>Date of Birth</label>
                <input
                  type="text"
                  value={studentInfo.dob}
                  onChange={(e) => setStudentInfo({ ...studentInfo, dob: e.target.value })}
                />
              </div>
              <div className="form-group-item">
                <label>Blood Group</label>
                <input
                  type="text"
                  value={studentInfo.bloodGroup}
                  onChange={(e) => setStudentInfo({ ...studentInfo, bloodGroup: e.target.value })}
                />
              </div>
              <div className="modal-actions-row">
                <button
                  type="button"
                  className="btn-outline"
                  onClick={() => setShowEditProfileModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary">
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Parent Modal */}
      {showEditParentModal && (
        <div className="portal-modal-backdrop">
          <div className="portal-modal-card">
            <div className="modal-header">
              <h3>Update Guardian Contact Information</h3>
              <button
                type="button"
                className="modal-close-btn"
                onClick={() => setShowEditParentModal(false)}
              >
                ✕
              </button>
            </div>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                setShowEditParentModal(false);
                showToast('Guardian contact details saved successfully!');
              }}
              className="modal-form-body"
            >
              <div className="form-group-item">
                <label>Father's Name</label>
                <input
                  type="text"
                  value={studentInfo.fatherName}
                  onChange={(e) => setStudentInfo({ ...studentInfo, fatherName: e.target.value })}
                  required
                />
              </div>
              <div className="form-group-item">
                <label>Father's Phone Number</label>
                <input
                  type="text"
                  value={studentInfo.fatherPhone}
                  onChange={(e) => setStudentInfo({ ...studentInfo, fatherPhone: e.target.value })}
                  required
                />
              </div>
              <div className="form-group-item">
                <label>Father's Email</label>
                <input
                  type="email"
                  value={studentInfo.fatherEmail}
                  onChange={(e) => setStudentInfo({ ...studentInfo, fatherEmail: e.target.value })}
                  required
                />
              </div>
              <div className="form-group-item">
                <label>Mother's Name</label>
                <input
                  type="text"
                  value={studentInfo.motherName}
                  onChange={(e) => setStudentInfo({ ...studentInfo, motherName: e.target.value })}
                />
              </div>
              <div className="form-group-item">
                <label>Mother's Phone Number</label>
                <input
                  type="text"
                  value={studentInfo.motherPhone}
                  onChange={(e) => setStudentInfo({ ...studentInfo, motherPhone: e.target.value })}
                />
              </div>
              <div className="form-group-item">
                <label>Permanent Residential Address</label>
                <textarea
                  rows={2}
                  value={studentInfo.address}
                  onChange={(e) => setStudentInfo({ ...studentInfo, address: e.target.value })}
                  required
                />
              </div>
              <div className="modal-actions-row">
                <button
                  type="button"
                  className="btn-outline"
                  onClick={() => setShowEditParentModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary">
                  Save Guardian Information
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Apply Leave Modal */}
      {showLeaveModal && (
        <div className="portal-modal-backdrop">
          <div className="portal-modal-card">
            <div className="modal-header">
              <h3>Apply For Excused Absence / Leave</h3>
              <button
                type="button"
                className="modal-close-btn"
                onClick={() => setShowLeaveModal(false)}
              >
                ✕
              </button>
            </div>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                setShowLeaveModal(false);
                showToast('Leave application submitted to Department Coordinator!');
              }}
              className="modal-form-body"
            >
              <div className="form-group-item">
                <label>Leave Reason</label>
                <select required defaultValue="Medical Leave">
                  <option>Medical Leave / Illness</option>
                  <option>Family Emergency</option>
                  <option>Official College Sports / Cultural Activity</option>
                  <option>Academic Conference / Hackathon</option>
                </select>
              </div>
              <div className="form-group-item">
                <label>Leave From Date</label>
                <input type="date" defaultValue="2025-05-02" required />
              </div>
              <div className="form-group-item">
                <label>Leave To Date</label>
                <input type="date" defaultValue="2025-05-03" required />
              </div>
              <div className="form-group-item">
                <label>Explanation / Comments</label>
                <textarea rows={3} placeholder="Provide details for leave consideration..." required />
              </div>
              <div className="modal-actions-row">
                <button type="button" className="btn-outline" onClick={() => setShowLeaveModal(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn-primary">
                  Submit Leave Request
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Request PTM Modal */}
      {showPTMModal && (
        <div className="portal-modal-backdrop">
          <div className="portal-modal-card">
            <div className="modal-header">
              <h3>Schedule Parent-Faculty Meeting (PTM)</h3>
              <button
                type="button"
                className="modal-close-btn"
                onClick={() => setShowPTMModal(false)}
              >
                ✕
              </button>
            </div>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                setShowPTMModal(false);
                showToast('Parent-Faculty meeting request sent to Dr. Neha Verma!');
              }}
              className="modal-form-body"
            >
              <div className="form-group-item">
                <label>Select Faculty / Advisor</label>
                <select required defaultValue="Dr. Neha Verma">
                  <option>Dr. Neha Verma (Faculty Advisor)</option>
                  <option>Prof. Rajesh Gupta (Data Structures)</option>
                  <option>Prof. Swati Deshmukh (Web Technologies)</option>
                  <option>Dr. Amit Kumar (Computer Networks)</option>
                </select>
              </div>
              <div className="form-group-item">
                <label>Preferred Date & Time</label>
                <input type="datetime-local" defaultValue="2025-05-06T15:00" required />
              </div>
              <div className="form-group-item">
                <label>Meeting Mode</label>
                <select required defaultValue="Offline Campus">
                  <option>In-Person (Department Office Block B)</option>
                  <option>Online Video Call (Google Meet)</option>
                </select>
              </div>
              <div className="modal-actions-row">
                <button type="button" className="btn-outline" onClick={() => setShowPTMModal(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn-primary">
                  Confirm Meeting Request
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
