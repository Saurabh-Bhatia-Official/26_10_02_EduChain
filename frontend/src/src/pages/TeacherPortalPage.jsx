import React, { useState, useEffect } from 'react';
import {
  LayoutDashboard,
  BookOpen,
  Users,
  Award,
  Calendar,
  Clock,
  User,
  LogOut,
  Search,
  Plus,
  Edit2,
  Trash2,
  Eye,
  CheckCircle2,
  AlertCircle,
  ChevronLeft,
  ChevronRight,
  Filter,
  Check,
  X,
  GraduationCap,
  Sparkles,
  Phone,
  Mail,
  MapPin,
  FileText,
  Save,
  ArrowLeft,
  CalendarDays,
  School,
  TrendingUp,
  Layers,
  ChevronDown,
  UploadCloud,
  FileUp,
  Download,
  ExternalLink,
  Megaphone,
  CheckSquare,
  Bell,
  Play,
  Radio,
  FileCheck2,
  Share2,
  Landmark
} from 'lucide-react';
import InstituteBuildingIllustration from '../components/illustrations/InstituteBuildingIllustration';
import { studentService, dashboardService } from '../services/api';

export default function TeacherPortalPage({
  onNavigate,
  currentUser,
  onLogout,
  initialTab = 'dashboard'
}) {
  // Active screen / view state matching the 12 screens
  // 'dashboard' (1), 'classes' (2), 'students' (3), 'add-student' (4), 'student-detail' (5),
  // 'courses' (6), 'add-course' (7), 'remove-course' (8), 'course-details' (9),
  // 'lectures' (10), 'update-lecture' (11), 'profile' (12)
  const [activeScreen, setActiveScreen] = useState(() => {
    if (initialTab === 'classes' || initialTab === 'my-classes') return 'classes';
    if (initialTab === 'students' || initialTab === 'student-records') return 'students';
    if (initialTab === 'add-student') return 'add-student';
    if (initialTab === 'student-detail') return 'student-detail';
    if (initialTab === 'courses' || initialTab === 'course-management') return 'courses';
    if (initialTab === 'add-course') return 'add-course';
    if (initialTab === 'remove-course') return 'remove-course';
    if (initialTab === 'course-details' || initialTab === 'course-detail') return 'course-details';
    if (initialTab === 'lectures' || initialTab === 'lecture-management') return 'lectures';
    if (initialTab === 'update-lecture' || initialTab === 'update-lecture-schedule') return 'update-lecture';
    if (initialTab === 'profile') return 'profile';
    return 'dashboard';
  });

  const [toastMessage, setToastMessage] = useState('');
  const [globalSearch, setGlobalSearch] = useState('');
  const [showDiagramNavigator, setShowDiagramNavigator] = useState(true);

  // Sync with initialTab prop
  useEffect(() => {
    if (initialTab) {
      if (initialTab === 'classes' || initialTab === 'my-classes') setActiveScreen('classes');
      else if (initialTab === 'students' || initialTab === 'student-records') setActiveScreen('students');
      else if (initialTab === 'add-student') setActiveScreen('add-student');
      else if (initialTab === 'student-detail') setActiveScreen('student-detail');
      else if (initialTab === 'courses' || initialTab === 'course-management') setActiveScreen('courses');
      else if (initialTab === 'add-course') setActiveScreen('add-course');
      else if (initialTab === 'remove-course') setActiveScreen('remove-course');
      else if (initialTab === 'course-details' || initialTab === 'course-detail') setActiveScreen('course-details');
      else if (initialTab === 'lectures' || initialTab === 'lecture-management') setActiveScreen('lectures');
      else if (initialTab === 'update-lecture') setActiveScreen('update-lecture');
      else if (initialTab === 'profile') setActiveScreen('profile');
      else setActiveScreen('dashboard');
    }
  }, [initialTab]);

  // Load dynamic students from database
  useEffect(() => {
    let isMounted = true;
    const fetchStudents = async () => {
      try {
        const data = await studentService.getAll();
        if (isMounted && Array.isArray(data) && data.length > 0) {
          const mapped = data.map((s) => ({
            id: s.id,
            name: s.name,
            rollNo: s.rollNumber || `BCA-${s.id}`,
            class: s.className || 'BCA - Sem 3',
            course: s.course || 'BCA',
            semester: s.semester || '3',
            attendance: 92,
            performance: 'A',
            status: s.status || 'Active',
            email: s.email,
            phone: s.phone || '+91 98765 43210',
            address: s.address || 'Academic Campus',
            fatherName: s.fatherName || 'Parent Name',
            fatherPhone: s.fatherPhone || '+91 98765 43210',
            recentAttendance: [{ date: 'Apr 25, 2025', status: 'Present' }]
          }));
          setStudents(mapped);
        }
      } catch (err) {
        console.warn('Teacher portal student load warning:', err);
      }
    };
    fetchStudents();
    return () => { isMounted = false; };
  }, []);

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3200);
  };

  // Instructor Profile state (Screen 12)
  const [instructorProfile, setInstructorProfile] = useState({
    name: currentUser?.name || 'Dr. Amit Sharma',
    instructorId: currentUser?.instructorId || 'INS-001',
    designation: currentUser?.designation || 'Assistant Professor',
    department: currentUser?.department || 'Computer Science',
    email: currentUser?.email || 'amit.sharma@institute.com',
    phone: currentUser?.phone || '+91 98765 43210',
    joiningDate: currentUser?.joiningDate || 'Jan 14, 2020',
    qualification: currentUser?.qualification || 'Ph.D - Computer Science',
    experience: currentUser?.experience || '5 Years',
    about:
      currentUser?.about ||
      'Passionate educator with 5+ years of experience in teaching and research. Focused on building strong technical foundations and real-world skills in students.'
  });

  const [isEditProfileModalOpen, setIsEditProfileModalOpen] = useState(false);
  const [profileFormData, setProfileFormData] = useState({ ...instructorProfile });

  // Classes & Courses Data (Screens 2, 6, 8, 9)
  const [courses, setCourses] = useState([
    {
      id: 1,
      name: 'Web Development',
      code: 'BCA-301',
      department: 'CS',
      deptFull: 'Computer Science',
      semester: '3',
      students: 32,
      status: 'Active',
      credits: 4,
      room: 'Lab 2',
      time: '08:00 AM - 10:00 AM',
      description:
        'This course covers web technologies, modern frameworks, and full-stack development practices.'
    },
    {
      id: 2,
      name: 'Mathematics',
      code: 'BCA-201',
      department: 'Mathematics',
      deptFull: 'Mathematics',
      semester: '3',
      students: 39,
      status: 'Active',
      credits: 4,
      room: 'Room 101',
      time: '10:30 AM - 12:00 PM',
      description:
        'Discrete mathematics, linear algebra, graph theory, and mathematical foundations for computer science.'
    },
    {
      id: 3,
      name: 'Database Management',
      code: 'BCA-302',
      department: 'CS',
      deptFull: 'Computer Science',
      semester: '3',
      students: 30,
      status: 'Active',
      credits: 4,
      room: 'Lab 3',
      time: '01:00 PM - 02:30 PM',
      description:
        'Relational database design, SQL querying, indexing, transactions, and normalization.'
    },
    {
      id: 4,
      name: 'Computer Networks',
      code: 'BCA-303',
      department: 'CS',
      deptFull: 'Computer Science',
      semester: '3',
      students: 26,
      status: 'Active',
      credits: 3,
      room: 'Room 102',
      time: '03:00 PM - 04:30 PM',
      description:
        'OSI model, TCP/IP protocol suite, subnetting, network security, and routing protocols.'
    },
    {
      id: 5,
      name: 'Operating Systems',
      code: 'BCA-304',
      department: 'CS',
      deptFull: 'Computer Science',
      semester: '3',
      students: 25,
      status: 'Active',
      credits: 3,
      room: 'Lab 1',
      time: '11:00 AM - 12:30 PM',
      description:
        'Process management, memory virtualization, concurrency, file systems, and scheduling algorithms.'
    },
    {
      id: 6,
      name: 'English',
      code: 'BCA-101',
      department: 'Languages',
      deptFull: 'Languages',
      semester: '1',
      students: 30,
      status: 'Active',
      credits: 2,
      room: 'Room 204',
      time: '02:00 PM - 03:00 PM',
      description:
        'Professional communication, technical writing, presentation skills, and business correspondence.'
    }
  ]);

  // Selected course for Screen 9: Course Details
  const [selectedCourse, setSelectedCourse] = useState(courses[0]);
  const [courseDetailTab, setCourseDetailTab] = useState('Overview');

  // Selected courses for Screen 8: Remove Course
  const [selectedCourseIdsToRemove, setSelectedCourseIdsToRemove] = useState([1]);

  // Students Data (Screens 3, 4, 5)
  const [students, setStudents] = useState([
    {
      id: 1,
      name: 'Rahul Sharma',
      rollNo: 'BCA-301',
      class: 'BCA - Sem 3',
      semester: '3',
      attendance: 92,
      presentDays: 46,
      absentDays: 4,
      leaveDays: 2,
      status: 'Active',
      dob: '12/05/2004',
      gender: 'Male',
      fatherName: 'Rajesh Sharma',
      fatherPhone: '+91 98765 43210',
      motherName: 'Sunita Sharma',
      motherPhone: '+91 98765 43211',
      email: 'rajesh.sharma@example.com',
      studentEmail: 'rahul.sharma@institute.com',
      recentAttendance: [
        { date: 'Apr 25, 2025', status: 'Present' },
        { date: 'Apr 24, 2025', status: 'Present' },
        { date: 'Apr 23, 2025', status: 'Absent' },
        { date: 'Apr 20, 2025', status: 'Present' },
        { date: 'Apr 19, 2025', status: 'Present' }
      ]
    },
    {
      id: 2,
      name: 'Priya Singh',
      rollNo: 'BCA-302',
      class: 'BCA - Sem 3',
      semester: '3',
      attendance: 88,
      presentDays: 44,
      absentDays: 6,
      leaveDays: 2,
      status: 'Active',
      dob: '21/08/2004',
      gender: 'Female',
      fatherName: 'Manoj Singh',
      fatherPhone: '+91 98765 43212',
      motherName: 'Kavita Singh',
      motherPhone: '+91 98765 43213',
      email: 'priya.singh@example.com',
      studentEmail: 'priya.singh@institute.com',
      recentAttendance: [
        { date: 'Apr 25, 2025', status: 'Present' },
        { date: 'Apr 24, 2025', status: 'Present' },
        { date: 'Apr 23, 2025', status: 'Present' },
        { date: 'Apr 20, 2025', status: 'Present' },
        { date: 'Apr 19, 2025', status: 'Present' }
      ]
    },
    {
      id: 3,
      name: 'Amit Kumar',
      rollNo: 'BCA-303',
      class: 'BCA - Sem 3',
      semester: '3',
      attendance: 95,
      presentDays: 48,
      absentDays: 2,
      leaveDays: 2,
      status: 'Active',
      dob: '05/02/2004',
      gender: 'Male',
      fatherName: 'Suresh Kumar',
      fatherPhone: '+91 98765 43214',
      motherName: 'Rekha Devi',
      motherPhone: '+91 98765 43215',
      email: 'amit.kumar@example.com',
      studentEmail: 'amit.kumar@institute.com',
      recentAttendance: [
        { date: 'Apr 25, 2025', status: 'Present' },
        { date: 'Apr 24, 2025', status: 'Present' },
        { date: 'Apr 23, 2025', status: 'Present' },
        { date: 'Apr 20, 2025', status: 'Present' },
        { date: 'Apr 19, 2025', status: 'Present' }
      ]
    },
    {
      id: 4,
      name: 'Neha Patel',
      rollNo: 'BCA-304',
      class: 'BCA - Sem 3',
      semester: '3',
      attendance: 90,
      presentDays: 45,
      absentDays: 5,
      leaveDays: 2,
      status: 'Active',
      dob: '18/11/2004',
      gender: 'Female',
      fatherName: 'Vikram Patel',
      fatherPhone: '+91 98765 43216',
      motherName: 'Meena Patel',
      motherPhone: '+91 98765 43217',
      email: 'neha.patel@example.com',
      studentEmail: 'neha.patel@institute.com',
      recentAttendance: [
        { date: 'Apr 25, 2025', status: 'Present' },
        { date: 'Apr 24, 2025', status: 'Present' },
        { date: 'Apr 23, 2025', status: 'Present' },
        { date: 'Apr 20, 2025', status: 'Absent' },
        { date: 'Apr 19, 2025', status: 'Present' }
      ]
    },
    {
      id: 5,
      name: 'Sahil Verma',
      rollNo: 'BCA-305',
      class: 'BCA - Sem 3',
      semester: '3',
      attendance: 81,
      presentDays: 40,
      absentDays: 9,
      leaveDays: 3,
      status: 'Active',
      dob: '29/09/2004',
      gender: 'Male',
      fatherName: 'Anil Verma',
      fatherPhone: '+91 98765 43218',
      motherName: 'Sunita Verma',
      motherPhone: '+91 98765 43219',
      email: 'sahil.verma@example.com',
      studentEmail: 'sahil.verma@institute.com',
      recentAttendance: [
        { date: 'Apr 25, 2025', status: 'Absent' },
        { date: 'Apr 24, 2025', status: 'Present' },
        { date: 'Apr 23, 2025', status: 'Present' },
        { date: 'Apr 20, 2025', status: 'Present' },
        { date: 'Apr 19, 2025', status: 'Present' }
      ]
    }
  ]);

  // Selected student for Screen 5: Student Detail
  const [selectedStudent, setSelectedStudent] = useState(students[0]);
  const [studentDetailTab, setStudentDetailTab] = useState('Overview');

  // Form state for Screen 4: Add / Edit Student
  const [editingStudentId, setEditingStudentId] = useState(null);
  const [studentFormData, setStudentFormData] = useState({
    fullName: '',
    rollNumber: '',
    studentClass: '',
    semester: '',
    dob: '',
    gender: 'Male',
    fatherName: '',
    motherName: '',
    phoneNumber: '',
    email: ''
  });

  // Filters for Student Records (Screen 3)
  const [studentClassFilter, setStudentClassFilter] = useState('All Classes');
  const [studentSemesterFilter, setStudentSemesterFilter] = useState('All Semesters');
  const [studentStatusFilter, setStudentStatusFilter] = useState('All Status');
  const [studentSearch, setStudentSearch] = useState('');

  // Course Filters (Screen 6)
  const [courseDeptFilter, setCourseDeptFilter] = useState('All Departments');
  const [courseSemFilter, setCourseSemFilter] = useState('All Semesters');
  const [courseSearch, setCourseSearch] = useState('');

  // Add Course Form State (Screen 7)
  const [newCourseData, setNewCourseData] = useState({
    name: '',
    code: '',
    department: '',
    semester: '',
    description: '',
    instructor: 'Dr. Amit Sharma'
  });

  // Lecture Management State (Screens 10 & 11)
  const [selectedLectureDate, setSelectedLectureDate] = useState('Apr 25, 2025');
  const [lectures, setLectures] = useState([
    {
      id: 1,
      time: '08:00 - 10:00',
      timeSlot: '09:00 AM - 10:00 AM',
      course: 'Web Development',
      class: '301',
      room: 'Lab 2',
      duration: '2 Hours',
      status: 'Ongoing',
      date: 'Apr 25, 2025',
      notes: 'Lab session on React state management and component lifecycle.'
    },
    {
      id: 2,
      time: '10:30 - 12:00',
      timeSlot: '10:30 AM - 12:00 PM',
      course: 'Mathematics',
      class: 'Class',
      room: 'Room 101',
      duration: '1.5 Hours',
      status: 'Upcoming',
      date: 'Apr 25, 2025',
      notes: 'Graph theory, planar graphs theorems and Euler circuits.'
    },
    {
      id: 3,
      time: '01:00 - 02:30',
      timeSlot: '01:00 PM - 02:30 PM',
      course: 'Database Management',
      class: '302',
      room: 'Lab 3',
      duration: '1.5 Hours',
      status: 'Upcoming',
      date: 'Apr 25, 2025',
      notes: 'B-Tree indexing practicals and transaction isolation levels.'
    },
    {
      id: 4,
      time: '03:00 - 04:30',
      timeSlot: '03:00 PM - 04:30 PM',
      course: 'Computer Networks',
      class: '303',
      room: 'Room 102',
      duration: '1.5 Hours',
      status: 'Upcoming',
      date: 'Apr 25, 2025',
      notes: 'Subnet masking exercises and packet routing simulation.'
    }
  ]);

  // Editing lecture for Screen 11: Update Lecture Schedule
  const [editingLecture, setEditingLecture] = useState(lectures[0]);
  const [lectureFormData, setLectureFormData] = useState({
    course: 'Web Development',
    date: 'Apr 25, 2025',
    time: '09:00 AM - 10:00 AM',
    room: 'Lab 2',
    duration: '2 Hours',
    status: 'Ongoing',
    notes: ''
  });

  // Modal for + Add Class (from Screen 2)
  const [showAddClassModal, setShowAddClassModal] = useState(false);
  const [newClassData, setNewClassData] = useState({
    name: '',
    code: '',
    semester: '3',
    students: 30,
    department: 'Computer Science'
  });

  // Course Upload Material State
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [uploadFormData, setUploadFormData] = useState({
    courseId: 1,
    title: '',
    category: 'Lecture Notes',
    module: 'Unit 3: Modern Web Stack',
    fileName: 'React_FullStack_Architecture.pdf',
    fileSize: '4.2 MB',
    externalLink: '',
    description: '',
    visibility: 'Immediate'
  });

  // Uploaded Course Materials List
  const [courseMaterials, setCourseMaterials] = useState([
    {
      id: 1,
      title: 'Full-Stack React & Node Architecture Notes.pdf',
      courseName: 'Web Development',
      courseCode: 'BCA-301',
      category: 'Lecture Notes',
      size: '4.2 MB',
      type: 'PDF',
      uploadedAt: 'Today, 10:15 AM',
      downloads: 32,
      link: '#'
    },
    {
      id: 2,
      title: 'Graph Theory & Planar Graphs Problem Set.docx',
      courseName: 'Mathematics',
      courseCode: 'BCA-201',
      category: 'Assignment',
      size: '1.8 MB',
      type: 'DOCX',
      uploadedAt: 'Yesterday, 03:40 PM',
      downloads: 39,
      link: '#'
    },
    {
      id: 3,
      title: 'SQL Indexing, EXPLAIN Plans & Transactions.pdf',
      courseName: 'Database Management',
      courseCode: 'BCA-302',
      category: 'Lecture Notes',
      size: '5.1 MB',
      type: 'PDF',
      uploadedAt: 'Oct 15, 2026',
      downloads: 28,
      link: '#'
    },
    {
      id: 4,
      title: 'Subnet Masking & Packet Tracing Lab Manual.zip',
      courseName: 'Computer Networks',
      courseCode: 'BCA-303',
      category: 'Lab Manual',
      size: '12.4 MB',
      type: 'ZIP',
      uploadedAt: 'Oct 13, 2026',
      downloads: 26,
      link: '#'
    }
  ]);

  // Quick Attendance Modal State
  const [showQuickAttendanceModal, setShowQuickAttendanceModal] = useState(false);
  const [quickAttendanceCourse, setQuickAttendanceCourse] = useState(courses[0]);
  const [quickAttendanceRoster, setQuickAttendanceRoster] = useState([
    { id: 1, name: 'Rahul Sharma', rollNo: 'BCA-301', present: true },
    { id: 2, name: 'Priya Singh', rollNo: 'BCA-302', present: true },
    { id: 3, name: 'Amit Kumar', rollNo: 'BCA-303', present: true },
    { id: 4, name: 'Neha Patel', rollNo: 'BCA-304', present: true },
    { id: 5, name: 'Sahil Verma', rollNo: 'BCA-305', present: false }
  ]);

  // Quick Announcement Modal State
  const [showAnnouncementModal, setShowAnnouncementModal] = useState(false);
  const [announcementFormData, setAnnouncementFormData] = useState({
    title: '',
    course: 'All Classes',
    message: '',
    urgent: false
  });

  // Handle Course Material Upload
  const handleUploadCourseMaterial = (e) => {
    e.preventDefault();
    if (!uploadFormData.title.trim()) {
      showToast('Please enter a title for the course material.');
      return;
    }
    const targetCourse = courses.find((c) => c.id === Number(uploadFormData.courseId)) || courses[0];
    const newMaterial = {
      id: courseMaterials.length + 1,
      title: uploadFormData.title.endsWith('.pdf') || uploadFormData.title.endsWith('.docx') || uploadFormData.title.endsWith('.zip')
        ? uploadFormData.title
        : `${uploadFormData.title}.pdf`,
      courseName: targetCourse.name,
      courseCode: targetCourse.code,
      category: uploadFormData.category,
      size: uploadFormData.fileSize || '3.5 MB',
      type: uploadFormData.category === 'Assignment' ? 'DOCX' : 'PDF',
      uploadedAt: 'Just now',
      downloads: 0,
      link: uploadFormData.externalLink || '#'
    };
    setCourseMaterials([newMaterial, ...courseMaterials]);
    setShowUploadModal(false);
    setUploadFormData({
      courseId: 1,
      title: '',
      category: 'Lecture Notes',
      module: 'Unit 3: Modern Web Stack',
      fileName: 'React_FullStack_Architecture.pdf',
      fileSize: '4.2 MB',
      externalLink: '',
      description: '',
      visibility: 'Immediate'
    });
    showToast(`Course material successfully uploaded & published to ${targetCourse.name}!`);
  };

  // Handle Quick Attendance Save
  const handleSaveQuickAttendance = (e) => {
    e.preventDefault();
    const presentCount = quickAttendanceRoster.filter((s) => s.present).length;
    showToast(`Attendance recorded! ${presentCount} of ${quickAttendanceRoster.length} students marked present for ${quickAttendanceCourse.name}.`);
    setShowQuickAttendanceModal(false);
  };

  // Handle Send Announcement
  const handleSendAnnouncement = (e) => {
    e.preventDefault();
    if (!announcementFormData.title.trim() || !announcementFormData.message.trim()) {
      showToast('Please fill in announcement title and message.');
      return;
    }
    showToast(`Announcement "${announcementFormData.title}" published to ${announcementFormData.course}!`);
    setShowAnnouncementModal(false);
    setAnnouncementFormData({
      title: '',
      course: 'All Classes',
      message: '',
      urgent: false
    });
  };

  // ===================== Handlers =====================

  // Navigation helpers
  const goToScreen = (screenName) => {
    setActiveScreen(screenName);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Open Screen 4: Add Student
  const handleOpenAddStudent = () => {
    setEditingStudentId(null);
    setStudentFormData({
      fullName: '',
      rollNumber: '',
      studentClass: '',
      semester: '',
      dob: '',
      gender: 'Male',
      fatherName: '',
      motherName: '',
      phoneNumber: '',
      email: ''
    });
    goToScreen('add-student');
  };

  // Open Screen 4: Edit Student
  const handleOpenEditStudent = (student) => {
    setEditingStudentId(student.id);
    setStudentFormData({
      fullName: student.name,
      rollNumber: student.rollNo,
      studentClass: student.class,
      semester: student.semester,
      dob: student.dob,
      gender: student.gender,
      fatherName: student.fatherName,
      motherName: student.motherName,
      phoneNumber: student.fatherPhone.replace('+91 ', ''),
      email: student.email
    });
    goToScreen('add-student');
  };

  // Save Student (Screen 4 submit)
  const handleSaveStudent = async (e) => {
    e.preventDefault();
    if (!studentFormData.fullName.trim() || !studentFormData.rollNumber.trim()) {
      showToast('Please fill out all required student details.');
      return;
    }

    try {
      if (editingStudentId) {
        // Update existing
        const payload = {
          name: studentFormData.fullName,
          rollNumber: studentFormData.rollNumber,
          className: studentFormData.studentClass,
          semester: studentFormData.semester,
          dob: studentFormData.dob,
          gender: studentFormData.gender,
          fatherName: studentFormData.fatherName,
          motherName: studentFormData.motherName,
          fatherPhone: studentFormData.phoneNumber,
          email: studentFormData.email
        };
        await studentService.update(editingStudentId, payload);

        setStudents((prev) =>
          prev.map((s) =>
            s.id === editingStudentId
              ? {
                  ...s,
                  name: studentFormData.fullName,
                  rollNo: studentFormData.rollNumber,
                  class: studentFormData.studentClass || s.class,
                  semester: studentFormData.semester || s.semester,
                  dob: studentFormData.dob,
                  gender: studentFormData.gender,
                  fatherName: studentFormData.fatherName,
                  motherName: studentFormData.motherName,
                  fatherPhone: studentFormData.phoneNumber.startsWith('+91')
                    ? studentFormData.phoneNumber
                    : `+91 ${studentFormData.phoneNumber}`,
                  email: studentFormData.email
                }
              : s
          )
        );
        showToast(`Student ${studentFormData.fullName} updated in database!`);
      } else {
        // Create new in PostgreSQL
        const payload = {
          name: studentFormData.fullName,
          rollNumber: studentFormData.rollNumber,
          className: studentFormData.studentClass || 'BCA - Sem 3',
          course: 'BCA',
          semester: studentFormData.semester || '3',
          dob: studentFormData.dob || '2005-01-01',
          gender: studentFormData.gender || 'Male',
          fatherName: studentFormData.fatherName,
          motherName: studentFormData.motherName,
          fatherPhone: studentFormData.phoneNumber,
          email: studentFormData.email || `${studentFormData.fullName.toLowerCase().replace(/[^a-z0-9]/g, '')}@institute.com`,
          status: 'Active'
        };
        const saved = await studentService.create(payload);

        const newStudentObj = {
          id: saved?.id || (students.length + 1),
          name: saved?.name || studentFormData.fullName,
          rollNo: saved?.rollNumber || studentFormData.rollNumber,
          class: studentFormData.studentClass || 'BCA - Sem 3',
          semester: studentFormData.semester || '3',
          attendance: 100,
          presentDays: 1,
          absentDays: 0,
          leaveDays: 0,
          status: 'Active',
          dob: studentFormData.dob || '01/01/2005',
          gender: studentFormData.gender,
          fatherName: studentFormData.fatherName || 'Guardian',
          fatherPhone: studentFormData.phoneNumber.startsWith('+91')
            ? studentFormData.phoneNumber
            : `+91 ${studentFormData.phoneNumber}`,
          motherName: studentFormData.motherName || 'Guardian',
          motherPhone: '+91 98765 00000',
          email: saved?.email || studentFormData.email,
          studentEmail: `${studentFormData.fullName.toLowerCase().replace(/\s+/g, '.')}@institute.com`,
          recentAttendance: [{ date: 'Apr 25, 2025', status: 'Present' }]
        };
        setStudents([newStudentObj, ...students]);
        showToast(`New student ${studentFormData.fullName} saved to database!`);
      }
    } catch (err) {
      showToast('Notice: ' + err.message);
    }

    goToScreen('students');
  };

  // View Student Details (Screen 5)
  const handleViewStudentDetail = (student) => {
    setSelectedStudent(student);
    setStudentDetailTab('Overview');
    goToScreen('student-detail');
  };

  // Delete Student
  const handleDeleteStudent = (studentId, studentName) => {
    if (window.confirm(`Are you sure you want to remove ${studentName} from student records?`)) {
      setStudents((prev) => prev.filter((s) => s.id !== studentId));
      showToast(`Student ${studentName} was removed.`);
    }
  };

  // View Course Details (Screen 9)
  const handleViewCourseDetails = (course) => {
    setSelectedCourse(course);
    setCourseDetailTab('Overview');
    goToScreen('course-details');
  };

  // Save New Course (Screen 7 submit)
  const handleSaveCourse = (e) => {
    e.preventDefault();
    if (!newCourseData.name.trim() || !newCourseData.code.trim()) {
      showToast('Please enter both course name and course code.');
      return;
    }

    const newCourseObj = {
      id: courses.length + 1,
      name: newCourseData.name,
      code: newCourseData.code,
      department: newCourseData.department || 'CS',
      deptFull: newCourseData.department || 'Computer Science',
      semester: newCourseData.semester || '3',
      students: 30,
      status: 'Active',
      credits: 3,
      room: 'Room 201',
      time: '09:00 AM - 10:30 AM',
      description:
        newCourseData.description || 'Comprehensive curriculum for academic advancement.'
    };

    setCourses([...courses, newCourseObj]);
    setNewCourseData({
      name: '',
      code: '',
      department: '',
      semester: '',
      description: '',
      instructor: 'Dr. Amit Sharma'
    });
    showToast(`Course "${newCourseObj.name}" added successfully!`);
    goToScreen('courses');
  };

  // Handle Remove Course (Screen 8)
  const handleToggleCourseSelectionToRemove = (id) => {
    if (selectedCourseIdsToRemove.includes(id)) {
      setSelectedCourseIdsToRemove(selectedCourseIdsToRemove.filter((item) => item !== id));
    } else {
      setSelectedCourseIdsToRemove([...selectedCourseIdsToRemove, id]);
    }
  };

  const handleExecuteRemoveCourses = () => {
    if (selectedCourseIdsToRemove.length === 0) {
      showToast('Please select at least one course to remove.');
      return;
    }
    const count = selectedCourseIdsToRemove.length;
    setCourses((prev) => prev.filter((c) => !selectedCourseIdsToRemove.includes(c.id)));
    setSelectedCourseIdsToRemove([]);
    showToast(`${count} course${count > 1 ? 's' : ''} unassigned successfully!`);
    goToScreen('courses');
  };

  // Open Screen 11: Update Lecture Schedule
  const handleOpenUpdateLecture = (lecture) => {
    setEditingLecture(lecture);
    setLectureFormData({
      course: lecture.course,
      date: lecture.date || 'Apr 25, 2025',
      time: lecture.timeSlot || '09:00 AM - 10:00 AM',
      room: lecture.room,
      duration: lecture.duration,
      status: lecture.status,
      notes: lecture.notes || ''
    });
    goToScreen('update-lecture');
  };

  // Save Lecture Schedule (Screen 11 submit)
  const handleSaveLectureSchedule = (e) => {
    e.preventDefault();
    if (!editingLecture) return;

    setLectures((prev) =>
      prev.map((lec) =>
        lec.id === editingLecture.id
          ? {
              ...lec,
              course: lectureFormData.course,
              date: lectureFormData.date,
              timeSlot: lectureFormData.time,
              room: lectureFormData.room,
              duration: lectureFormData.duration,
              status: lectureFormData.status,
              notes: lectureFormData.notes
            }
          : lec
      )
    );
    showToast('Lecture schedule updated successfully!');
    goToScreen('lectures');
  };

  // Save Profile Changes (Screen 12)
  const handleSaveProfile = (e) => {
    e.preventDefault();
    setInstructorProfile({ ...profileFormData });
    setIsEditProfileModalOpen(false);
    showToast('Instructor profile updated successfully!');
  };

  // Save Add Class Modal
  const handleSaveNewClass = (e) => {
    e.preventDefault();
    if (!newClassData.name.trim() || !newClassData.code.trim()) {
      showToast('Please enter class name and code.');
      return;
    }
    const newCourseObj = {
      id: courses.length + 1,
      name: newClassData.name,
      code: newClassData.code,
      department: 'CS',
      deptFull: newClassData.department,
      semester: newClassData.semester,
      students: Number(newClassData.students) || 30,
      status: 'Active',
      credits: 3,
      room: 'Room 105',
      time: '11:00 AM - 12:30 PM',
      description: 'Newly assigned academic class.'
    };
    setCourses([...courses, newCourseObj]);
    setShowAddClassModal(false);
    setNewClassData({
      name: '',
      code: '',
      semester: '3',
      students: 30,
      department: 'Computer Science'
    });
    showToast(`Class "${newCourseObj.name}" added to your classes!`);
  };

  // Filtered Students (Screen 3)
  const filteredStudents = students.filter((s) => {
    const matchesSearch =
      s.name.toLowerCase().includes(studentSearch.toLowerCase()) ||
      s.rollNo.toLowerCase().includes(studentSearch.toLowerCase());
    const matchesClass =
      studentClassFilter === 'All Classes' || s.class.includes(studentClassFilter);
    const matchesSemester =
      studentSemesterFilter === 'All Semesters' || s.semester === studentSemesterFilter;
    const matchesStatus =
      studentStatusFilter === 'All Status' || s.status === studentStatusFilter;
    return matchesSearch && matchesClass && matchesSemester && matchesStatus;
  });

  // Filtered Courses (Screen 6)
  const filteredCourses = courses.filter((c) => {
    const matchesSearch =
      c.name.toLowerCase().includes(courseSearch.toLowerCase()) ||
      c.code.toLowerCase().includes(courseSearch.toLowerCase());
    const matchesDept =
      courseDeptFilter === 'All Departments' ||
      c.department.toLowerCase() === courseDeptFilter.toLowerCase() ||
      c.deptFull.toLowerCase().includes(courseDeptFilter.toLowerCase());
    const matchesSem = courseSemFilter === 'All Semesters' || c.semester === courseSemFilter;
    return matchesSearch && matchesDept && matchesSem;
  });

  // Map active screen to primary sidebar tab
  const getActiveSidebarTab = () => {
    if (activeScreen === 'dashboard') return 'dashboard';
    if (activeScreen === 'classes') return 'classes';
    if (
      activeScreen === 'students' ||
      activeScreen === 'add-student' ||
      activeScreen === 'student-detail'
    )
      return 'students';
    if (
      activeScreen === 'courses' ||
      activeScreen === 'add-course' ||
      activeScreen === 'remove-course' ||
      activeScreen === 'course-details'
    )
      return 'courses';
    if (activeScreen === 'lectures' || activeScreen === 'update-lecture') return 'lectures';
    if (activeScreen === 'profile') return 'profile';
    return 'dashboard';
  };

  const activeSidebarTab = getActiveSidebarTab();

  return (
    <div className="teacher-portal-root">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="teacher-portal-toast" role="status">
          <CheckCircle2 size={18} />
          <span>{toastMessage}</span>
        </div>
      )}

      <div className="teacher-portal-layout">
        {/* Left Dark Navy Sidebar */}
        <aside className="teacher-sidebar">
          {/* Logo Header */}
          <div className="teacher-sidebar-brand" onClick={() => goToScreen('dashboard')}>
            <div className="teacher-brand-icon-box">
              <GraduationCap size={22} className="teacher-brand-icon" />
            </div>
            <div className="teacher-brand-titles">
              <span className="teacher-brand-main">Institute Portal</span>
              <span className="teacher-brand-tag">Faculty Edition</span>
            </div>
          </div>

          {/* Nav List */}
          <nav className="teacher-nav-menu">
            <button
              type="button"
              className={`teacher-nav-item ${activeSidebarTab === 'dashboard' ? 'active' : ''}`}
              onClick={() => goToScreen('dashboard')}
            >
              <LayoutDashboard size={19} className="nav-icon" />
              <span>Instructor Dashboard</span>
            </button>

            <button
              type="button"
              className={`teacher-nav-item ${activeSidebarTab === 'classes' ? 'active' : ''}`}
              onClick={() => goToScreen('classes')}
            >
              <BookOpen size={19} className="nav-icon" />
              <span>My Classes</span>
            </button>

            <button
              type="button"
              className={`teacher-nav-item ${activeSidebarTab === 'students' ? 'active' : ''}`}
              onClick={() => goToScreen('students')}
            >
              <Users size={19} className="nav-icon" />
              <span>Student Records</span>
            </button>

            <button
              type="button"
              className={`teacher-nav-item ${activeSidebarTab === 'courses' ? 'active' : ''}`}
              onClick={() => goToScreen('courses')}
            >
              <Award size={19} className="nav-icon" />
              <span>Course Management</span>
            </button>

            <button
              type="button"
              className={`teacher-nav-item ${activeSidebarTab === 'lectures' ? 'active' : ''}`}
              onClick={() => goToScreen('lectures')}
            >
              <Calendar size={19} className="nav-icon" />
              <span>Lecture Management</span>
            </button>

            <button
              type="button"
              className={`teacher-nav-item ${activeSidebarTab === 'profile' ? 'active' : ''}`}
              onClick={() => goToScreen('profile')}
            >
              <User size={19} className="nav-icon" />
              <span>Profile</span>
            </button>
          </nav>

          {/* Sidebar Footer with Institute Home & Logout */}
          <div className="teacher-sidebar-footer">
            <button
              type="button"
              className="teacher-nav-item teacher-inst-home-btn"
              onClick={() => onNavigate('institute-home')}
              title="Return to Institute Home Portal"
              style={{ marginBottom: '6px' }}
            >
              <Landmark size={18} className="nav-icon" />
              <span>Institute Home</span>
            </button>
            <button
              type="button"
              className="teacher-logout-btn"
              onClick={() => {
                if (window.confirm('Are you sure you want to log out from Instructor Portal?')) {
                  if (onLogout) onLogout();
                  else if (onNavigate) onNavigate('institute-home');
                }
              }}
            >
              <LogOut size={18} />
              <span>Logout</span>
            </button>
          </div>
        </aside>

        {/* Main Content Area */}
        <div className="teacher-main-wrapper">
          {/* Top Bar Header */}
          <header className="teacher-topbar">
            <div className="teacher-topbar-search">
              <Search size={18} className="search-icon" />
              <input
                type="text"
                placeholder={
                  activeScreen === 'classes'
                    ? 'Search classes...'
                    : activeScreen === 'students'
                    ? 'Search by name, roll number...'
                    : activeScreen === 'courses' || activeScreen === 'remove-course'
                    ? 'Search Course...'
                    : 'Search classes, students, course material...'
                }
                value={globalSearch}
                onChange={(e) => {
                  setGlobalSearch(e.target.value);
                  if (activeScreen === 'students') setStudentSearch(e.target.value);
                  if (activeScreen === 'courses') setCourseSearch(e.target.value);
                }}
                className="topbar-search-input"
              />
            </div>

            <div className="teacher-topbar-actions">
              <button
                type="button"
                className="btn-topbar-institute-link"
                onClick={() => onNavigate('institute-home')}
                title="Go to Institute Home Page"
              >
                <Landmark size={15} />
                <span>Institute Home</span>
              </button>

              <div className="teacher-topbar-profile" onClick={() => goToScreen('profile')}>
                <div className="teacher-avatar-circle">
                  <span className="teacher-avatar-text">AS</span>
                </div>
                <div className="teacher-profile-info">
                  <span className="teacher-name">{instructorProfile.name}</span>
                  <span className="teacher-role-tag">Instructor</span>
                </div>
              </div>
            </div>
          </header>

          {/* Dynamic Content Views (Matching Screens 1-12) */}
          <main className="teacher-content-container">
            {/* ========================================================
                SCREEN 1: INSTRUCTOR DASHBOARD (Clean & Streamlined)
               ======================================================== */}
            {activeScreen === 'dashboard' && (
              <div className="screen-view screen-dashboard">
                {/* Clean Welcome Banner */}
                <div className="teacher-greeting-banner">
                  <div className="greeting-text-col">
                    <h1 className="greeting-heading">
                      Good Morning, {instructorProfile.name}!
                    </h1>
                    <p className="greeting-subtext">
                      Welcome to your faculty dashboard. Here's your schedule and class summary for today.
                    </p>
                  </div>
                  <div className="greeting-illustration-col">
                    <InstituteBuildingIllustration variant="compact" />
                  </div>
                </div>

                {/* 3 Clean KPI Stat Cards */}
                <div className="teacher-stats-row">
                  <div className="teacher-stat-card" onClick={() => goToScreen('classes')}>
                    <div className="stat-icon-square blue">
                      <BookOpen size={24} />
                    </div>
                    <div className="stat-content">
                      <div className="stat-num-row">
                        <span className="stat-number">6</span>
                        <span className="stat-trend-tag green">4 Active</span>
                      </div>
                      <span className="stat-label">Assigned Classes</span>
                    </div>
                  </div>

                  <div className="teacher-stat-card" onClick={() => goToScreen('students')}>
                    <div className="stat-icon-square teal">
                      <Users size={24} />
                    </div>
                    <div className="stat-content">
                      <div className="stat-num-row">
                        <span className="stat-number">186</span>
                        <span className="stat-trend-tag blue">Verified</span>
                      </div>
                      <span className="stat-label">Enrolled Students</span>
                    </div>
                  </div>

                  <div className="teacher-stat-card" onClick={() => goToScreen('students')}>
                    <div className="stat-icon-square cyan">
                      <TrendingUp size={24} />
                    </div>
                    <div className="stat-content">
                      <div className="stat-num-row">
                        <span className="stat-number">92%</span>
                        <span className="stat-trend-tag green">↑ Present</span>
                      </div>
                      <span className="stat-label">Average Attendance</span>
                    </div>
                  </div>
                </div>

                {/* Two Columns: Today's Classes + Quick Actions & Recent Activity */}
                <div className="dashboard-grid-two-col">
                  {/* Left Column: Today's Classes */}
                  <div className="dashboard-card todays-classes-card">
                    <div className="dashboard-card-header">
                      <div>
                        <h2 className="dashboard-card-title">Today's Classes</h2>
                        <span className="header-subtitle-tag">
                          4 Lectures Scheduled for Today
                        </span>
                      </div>
                      <button
                        type="button"
                        className="btn-link-sm"
                        onClick={() => goToScreen('lectures')}
                      >
                        View Full Schedule →
                      </button>
                    </div>

                    <div className="classes-timeline-list">
                      {/* Class 1: Ongoing */}
                      <div className="today-class-item ongoing">
                        <div className="class-status-badge ongoing">Ongoing</div>
                        <div className="class-item-details">
                          <h3 className="class-item-name">Web Development</h3>
                          <div className="class-item-meta">
                            <span className="meta-time">08:00 AM - 10:00 AM</span>
                            <span className="meta-dot">•</span>
                            <span className="meta-room">Lab 2</span>
                            <span className="meta-dot">•</span>
                            <span className="meta-code">BCA-301</span>
                          </div>
                        </div>
                        <button
                          type="button"
                          className="btn-sm-quick-pill green"
                          onClick={() => {
                            setQuickAttendanceCourse(courses[0]);
                            setShowQuickAttendanceModal(true);
                          }}
                          title="Take Attendance"
                        >
                          <CheckSquare size={14} />
                          <span>Attendance</span>
                        </button>
                      </div>

                      {/* Class 2: Upcoming */}
                      <div className="today-class-item upcoming">
                        <div className="class-status-badge upcoming">Upcoming</div>
                        <div className="class-item-details">
                          <h3 className="class-item-name">Mathematics</h3>
                          <div className="class-item-meta">
                            <span className="meta-time">10:30 AM - 12:00 PM</span>
                            <span className="meta-dot">•</span>
                            <span className="meta-room">Room 101</span>
                            <span className="meta-dot">•</span>
                            <span className="meta-code">BCA-201</span>
                          </div>
                        </div>
                        <button
                          type="button"
                          className="btn-action-icon"
                          onClick={() => handleViewCourseDetails(courses[1])}
                          title="View Course Details"
                        >
                          <ChevronRight size={18} />
                        </button>
                      </div>

                      {/* Class 3: Upcoming */}
                      <div className="today-class-item upcoming">
                        <div className="class-status-badge upcoming">Upcoming</div>
                        <div className="class-item-details">
                          <h3 className="class-item-name">Database Management</h3>
                          <div className="class-item-meta">
                            <span className="meta-time">01:00 PM - 02:30 PM</span>
                            <span className="meta-dot">•</span>
                            <span className="meta-room">Lab 3</span>
                            <span className="meta-dot">•</span>
                            <span className="meta-code">BCA-302</span>
                          </div>
                        </div>
                        <button
                          type="button"
                          className="btn-action-icon"
                          onClick={() => handleViewCourseDetails(courses[2])}
                          title="View Course Details"
                        >
                          <ChevronRight size={18} />
                        </button>
                      </div>

                      {/* Class 4: Upcoming */}
                      <div className="today-class-item upcoming">
                        <div className="class-status-badge upcoming">Upcoming</div>
                        <div className="class-item-details">
                          <h3 className="class-item-name">Computer Networks</h3>
                          <div className="class-item-meta">
                            <span className="meta-time">03:00 PM - 04:30 PM</span>
                            <span className="meta-dot">•</span>
                            <span className="meta-room">Room 102</span>
                            <span className="meta-dot">•</span>
                            <span className="meta-code">BCA-303</span>
                          </div>
                        </div>
                        <button
                          type="button"
                          className="btn-action-icon"
                          onClick={() => handleViewCourseDetails(courses[3])}
                          title="View Course Details"
                        >
                          <ChevronRight size={18} />
                        </button>
                      </div>
                    </div>
                  </div>

                  {/* Right Column: Quick Actions + Recent Activity */}
                  <div className="dashboard-right-col-stack">
                    {/* Quick Actions Card */}
                    <div className="dashboard-card quick-actions-card">
                      <div className="dashboard-card-header">
                        <h2 className="dashboard-card-title">Quick Actions</h2>
                      </div>
                      <div className="quick-actions-buttons-grid">
                        <button
                          type="button"
                          className="quick-action-btn"
                          onClick={() => setShowUploadModal(true)}
                        >
                          <div className="qa-icon-wrap blue">
                            <UploadCloud size={18} />
                          </div>
                          <span>Upload Material</span>
                        </button>

                        <button
                          type="button"
                          className="quick-action-btn"
                          onClick={() => {
                            setQuickAttendanceCourse(courses[0]);
                            setShowQuickAttendanceModal(true);
                          }}
                        >
                          <div className="qa-icon-wrap green">
                            <CheckSquare size={18} />
                          </div>
                          <span>Mark Attendance</span>
                        </button>

                        <button
                          type="button"
                          className="quick-action-btn"
                          onClick={() => setShowAnnouncementModal(true)}
                        >
                          <div className="qa-icon-wrap purple">
                            <Megaphone size={18} />
                          </div>
                          <span>Announcement</span>
                        </button>

                        <button
                          type="button"
                          className="quick-action-btn"
                          onClick={() => goToScreen('courses')}
                        >
                          <div className="qa-icon-wrap orange">
                            <BookOpen size={18} />
                          </div>
                          <span>My Courses</span>
                        </button>
                      </div>
                    </div>

                    {/* Recent Activity Card */}
                    <div className="dashboard-card recent-activity-card">
                      <div className="dashboard-card-header">
                        <h2 className="dashboard-card-title">Recent Activity</h2>
                        <span className="activity-live-pill">Live Feed</span>
                      </div>

                      <div className="activities-list">
                        <div className="activity-item">
                          <div className="activity-dot green" />
                          <div className="activity-details">
                            <span className="activity-action">Attendance marked</span>
                            <span className="activity-subject">Web Development &bull; Lab 2</span>
                          </div>
                          <span className="activity-time">09:45 AM</span>
                        </div>

                        <div className="activity-item">
                          <div className="activity-dot blue" />
                          <div className="activity-details">
                            <span className="activity-action">Course material uploaded</span>
                            <span className="activity-subject">React Architecture Notes</span>
                          </div>
                          <span className="activity-time">10:15 AM</span>
                        </div>

                        <div className="activity-item">
                          <div className="activity-dot purple" />
                          <div className="activity-details">
                            <span className="activity-action">New student enrolled</span>
                            <span className="activity-subject">Rahul Sharma &bull; BCA-301</span>
                          </div>
                          <span className="activity-time">1 hour ago</span>
                        </div>

                        <div className="activity-item">
                          <div className="activity-dot orange" />
                          <div className="activity-details">
                            <span className="activity-action">Grade updated</span>
                            <span className="activity-subject">Mathematics &bull; BCA-201</span>
                          </div>
                          <span className="activity-time">3 hours ago</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 2: MY CLASSES
               ======================================================== */}
            {activeScreen === 'classes' && (
              <div className="screen-view screen-classes">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-page-title">My Classes</h1>
                    <p className="screen-page-subtitle">
                      Manage all assigned lecture classes, active enrollments and sections.
                    </p>
                  </div>
                  <button
                    type="button"
                    className="btn-primary-blue"
                    onClick={() => setShowAddClassModal(true)}
                  >
                    <Plus size={16} />
                    <span>Add Class</span>
                  </button>
                </div>

                {/* 3 Status Counters */}
                <div className="classes-counter-row">
                  <div className="class-counter-box blue">
                    <div className="counter-circle blue">6</div>
                    <span className="counter-label">Total Classes</span>
                  </div>
                  <div className="class-counter-box green">
                    <div className="counter-circle green">4</div>
                    <span className="counter-label">Active</span>
                  </div>
                  <div className="class-counter-box amber">
                    <div className="counter-circle amber">2</div>
                    <span className="counter-label">Upcoming</span>
                  </div>
                </div>

                {/* Classes Table */}
                <div className="teacher-table-card">
                  <table className="teacher-data-table">
                    <thead>
                      <tr>
                        <th style={{ width: '50px' }}>#</th>
                        <th>Course Name</th>
                        <th>Code</th>
                        <th>Semester</th>
                        <th>Students</th>
                        <th>Status</th>
                        <th style={{ textAlign: 'center' }}>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {courses.map((course, idx) => (
                        <tr key={course.id}>
                          <td>{idx + 1}</td>
                          <td>
                            <span
                              className="table-link-name"
                              onClick={() => handleViewCourseDetails(course)}
                            >
                              {course.name}
                            </span>
                          </td>
                          <td>
                            <span className="table-code-pill">{course.code}</span>
                          </td>
                          <td>{course.semester}</td>
                          <td>
                            <span className="student-count-badge">{course.students}</span>
                          </td>
                          <td>
                            <span className="status-badge-pill active">{course.status}</span>
                          </td>
                          <td>
                            <div className="table-actions-group center">
                              <button
                                type="button"
                                className="action-btn edit"
                                onClick={() => handleViewCourseDetails(course)}
                                title="Edit Class Details"
                              >
                                <Edit2 size={15} />
                              </button>
                              <button
                                type="button"
                                className="action-btn view"
                                onClick={() => handleViewCourseDetails(course)}
                                title="View Course Details"
                              >
                                <Eye size={15} />
                              </button>
                              <button
                                type="button"
                                className="action-btn delete"
                                onClick={() => {
                                  setSelectedCourseIdsToRemove([course.id]);
                                  goToScreen('remove-course');
                                }}
                                title="Remove Class"
                              >
                                <Trash2 size={15} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>

                  <div className="table-pagination-footer">
                    <span className="pagination-info">Showing 1-6 of 6 classes</span>
                    <div className="pagination-controls">
                      <button type="button" className="page-nav-btn disabled" disabled>
                        <ChevronLeft size={16} />
                      </button>
                      <button type="button" className="page-num-btn active">
                        1
                      </button>
                      <button type="button" className="page-nav-btn disabled" disabled>
                        <ChevronRight size={16} />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 3: STUDENT RECORDS (View / Search / Filter)
               ======================================================== */}
            {activeScreen === 'students' && (
              <div className="screen-view screen-students">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-page-title">Student Records</h1>
                    <p className="screen-page-subtitle">
                      View, search and manage student details.
                    </p>
                  </div>
                  <button
                    type="button"
                    className="btn-primary-blue"
                    onClick={handleOpenAddStudent}
                  >
                    <Plus size={16} />
                    <span>Add Student</span>
                  </button>
                </div>

                {/* Filter Controls Row */}
                <div className="records-filter-bar">
                  <div className="filter-search-box">
                    <Search size={16} className="filter-icon" />
                    <input
                      type="text"
                      placeholder="Search by name, roll number..."
                      value={studentSearch}
                      onChange={(e) => setStudentSearch(e.target.value)}
                      className="filter-search-input"
                    />
                  </div>

                  <div className="filter-dropdowns-group">
                    <select
                      value={studentClassFilter}
                      onChange={(e) => setStudentClassFilter(e.target.value)}
                      className="filter-select"
                    >
                      <option value="All Classes">All Classes</option>
                      <option value="BCA-301">BCA-301</option>
                      <option value="BCA-302">BCA-302</option>
                      <option value="BCA-303">BCA-303</option>
                      <option value="BCA-304">BCA-304</option>
                      <option value="BCA-305">BCA-305</option>
                    </select>

                    <select
                      value={studentSemesterFilter}
                      onChange={(e) => setStudentSemesterFilter(e.target.value)}
                      className="filter-select"
                    >
                      <option value="All Semesters">All Semesters</option>
                      <option value="1">Semester 1</option>
                      <option value="2">Semester 2</option>
                      <option value="3">Semester 3</option>
                      <option value="4">Semester 4</option>
                    </select>

                    <select
                      value={studentStatusFilter}
                      onChange={(e) => setStudentStatusFilter(e.target.value)}
                      className="filter-select"
                    >
                      <option value="All Status">All Status</option>
                      <option value="Active">Active</option>
                      <option value="Inactive">Inactive</option>
                    </select>
                  </div>
                </div>

                {/* Students Table */}
                <div className="teacher-table-card">
                  <table className="teacher-data-table">
                    <thead>
                      <tr>
                        <th style={{ width: '40px' }}>#</th>
                        <th style={{ width: '60px' }}>Photo</th>
                        <th>Name</th>
                        <th>Roll No.</th>
                        <th>Class</th>
                        <th>Attendance</th>
                        <th>Status</th>
                        <th style={{ textAlign: 'center' }}>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredStudents.length > 0 ? (
                        filteredStudents.map((student, idx) => (
                          <tr key={student.id}>
                            <td>{idx + 1}</td>
                            <td>
                              <div className="student-table-avatar">
                                <span className="student-avatar-initials">
                                  {student.name
                                    .split(' ')
                                    .map((n) => n[0])
                                    .join('')}
                                </span>
                              </div>
                            </td>
                            <td>
                              <span
                                className="table-link-name"
                                onClick={() => handleViewStudentDetail(student)}
                              >
                                {student.name}
                              </span>
                            </td>
                            <td>
                              <span className="table-code-pill">{student.rollNo}</span>
                            </td>
                            <td>{student.semester}</td>
                            <td>
                              <span
                                className={`attendance-pct-pill ${
                                  student.attendance >= 90
                                    ? 'high'
                                    : student.attendance >= 75
                                    ? 'medium'
                                    : 'low'
                                }`}
                              >
                                {student.attendance}%
                              </span>
                            </td>
                            <td>
                              <span className="status-badge-pill active">{student.status}</span>
                            </td>
                            <td>
                              <div className="table-actions-group center">
                                <button
                                  type="button"
                                  className="action-btn edit"
                                  onClick={() => handleOpenEditStudent(student)}
                                  title="Edit Student Info"
                                >
                                  <Edit2 size={15} />
                                </button>
                                <button
                                  type="button"
                                  className="action-btn view"
                                  onClick={() => handleViewStudentDetail(student)}
                                  title="View Full Profile & Attendance"
                                >
                                  <Eye size={15} />
                                </button>
                                <button
                                  type="button"
                                  className="action-btn delete"
                                  onClick={() => handleDeleteStudent(student.id, student.name)}
                                  title="Delete Student"
                                >
                                  <Trash2 size={15} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))
                      ) : (
                        <tr>
                          <td colSpan="8" className="empty-table-state">
                            No students found matching your search and filter criteria.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>

                  <div className="table-pagination-footer">
                    <span className="pagination-info">
                      Showing 1-{filteredStudents.length} of 186
                    </span>
                    <div className="pagination-controls">
                      <button type="button" className="page-nav-btn disabled" disabled>
                        <ChevronLeft size={16} />
                      </button>
                      <button type="button" className="page-num-btn active">
                        1
                      </button>
                      <button type="button" className="page-num-btn">
                        2
                      </button>
                      <button type="button" className="page-num-btn">
                        3
                      </button>
                      <button type="button" className="page-num-btn">
                        4
                      </button>
                      <button type="button" className="page-num-btn">
                        5
                      </button>
                      <button type="button" className="page-nav-btn">
                        <ChevronRight size={16} />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 4: ADD / EDIT STUDENT
               ======================================================== */}
            {activeScreen === 'add-student' && (
              <div className="screen-view screen-form-page">
                <div className="form-page-container">
                  <div className="form-page-header">
                    <div className="form-header-icon-box blue">
                      <Users size={24} />
                    </div>
                    <div>
                      <h1 className="form-page-title">
                        {editingStudentId ? 'Edit Student Details' : 'Add / Edit Student'}
                      </h1>
                      <p className="form-page-subtitle">Enter or update student information.</p>
                    </div>
                  </div>

                  <form onSubmit={handleSaveStudent} className="form-page-card">
                    {/* Section 1: Personal Information */}
                    <div className="form-section-group">
                      <h3 className="form-section-title">Personal Information</h3>
                      <div className="form-grid-two-col">
                        <div className="teacher-form-field">
                          <label className="field-label">
                            Full Name <span className="req">*</span>
                          </label>
                          <input
                            type="text"
                            placeholder="Enter full name"
                            value={studentFormData.fullName}
                            onChange={(e) =>
                              setStudentFormData({ ...studentFormData, fullName: e.target.value })
                            }
                            className="teacher-field-input"
                            required
                          />
                        </div>

                        <div className="teacher-form-field">
                          <label className="field-label">
                            Roll Number <span className="req">*</span>
                          </label>
                          <input
                            type="text"
                            placeholder="Enter roll number (e.g. BCA-301)"
                            value={studentFormData.rollNumber}
                            onChange={(e) =>
                              setStudentFormData({
                                ...studentFormData,
                                rollNumber: e.target.value
                              })
                            }
                            className="teacher-field-input"
                            required
                          />
                        </div>

                        <div className="teacher-form-field">
                          <label className="field-label">Class</label>
                          <select
                            value={studentFormData.studentClass}
                            onChange={(e) =>
                              setStudentFormData({
                                ...studentFormData,
                                studentClass: e.target.value
                              })
                            }
                            className="teacher-field-input"
                          >
                            <option value="">Select class</option>
                            <option value="BCA - Sem 1">BCA - Sem 1</option>
                            <option value="BCA - Sem 2">BCA - Sem 2</option>
                            <option value="BCA - Sem 3">BCA - Sem 3</option>
                            <option value="BCA - Sem 4">BCA - Sem 4</option>
                          </select>
                        </div>

                        <div className="teacher-form-field">
                          <label className="field-label">Semester</label>
                          <select
                            value={studentFormData.semester}
                            onChange={(e) =>
                              setStudentFormData({ ...studentFormData, semester: e.target.value })
                            }
                            className="teacher-field-input"
                          >
                            <option value="">Select semester</option>
                            <option value="1">Semester 1</option>
                            <option value="2">Semester 2</option>
                            <option value="3">Semester 3</option>
                            <option value="4">Semester 4</option>
                          </select>
                        </div>

                        <div className="teacher-form-field">
                          <label className="field-label">Date of Birth</label>
                          <input
                            type="text"
                            placeholder="dd / mm / yyyy"
                            value={studentFormData.dob}
                            onChange={(e) =>
                              setStudentFormData({ ...studentFormData, dob: e.target.value })
                            }
                            className="teacher-field-input"
                          />
                        </div>

                        <div className="teacher-form-field">
                          <label className="field-label">Gender</label>
                          <div className="radio-options-row">
                            {['Male', 'Female', 'Other'].map((g) => (
                              <label key={g} className="radio-option-item">
                                <input
                                  type="radio"
                                  name="gender"
                                  value={g}
                                  checked={studentFormData.gender === g}
                                  onChange={() =>
                                    setStudentFormData({ ...studentFormData, gender: g })
                                  }
                                />
                                <span>{g}</span>
                              </label>
                            ))}
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Section 2: Parent / Guardian Information */}
                    <div className="form-section-group">
                      <h3 className="form-section-title">Parent / Guardian Information</h3>
                      <div className="form-grid-two-col">
                        <div className="teacher-form-field">
                          <label className="field-label">Father's Name</label>
                          <input
                            type="text"
                            placeholder="Enter father's name"
                            value={studentFormData.fatherName}
                            onChange={(e) =>
                              setStudentFormData({
                                ...studentFormData,
                                fatherName: e.target.value
                              })
                            }
                            className="teacher-field-input"
                          />
                        </div>

                        <div className="teacher-form-field">
                          <label className="field-label">Mother's Name</label>
                          <input
                            type="text"
                            placeholder="Enter mother's name"
                            value={studentFormData.motherName}
                            onChange={(e) =>
                              setStudentFormData({
                                ...studentFormData,
                                motherName: e.target.value
                              })
                            }
                            className="teacher-field-input"
                          />
                        </div>

                        <div className="teacher-form-field">
                          <label className="field-label">Phone Number</label>
                          <div className="phone-input-prefix-box">
                            <span className="phone-prefix">+91</span>
                            <input
                              type="tel"
                              placeholder="Enter phone number"
                              value={studentFormData.phoneNumber}
                              onChange={(e) =>
                                setStudentFormData({
                                  ...studentFormData,
                                  phoneNumber: e.target.value
                                })
                              }
                              className="teacher-field-input prefix"
                            />
                          </div>
                        </div>

                        <div className="teacher-form-field">
                          <label className="field-label">Email</label>
                          <input
                            type="email"
                            placeholder="Enter email"
                            value={studentFormData.email}
                            onChange={(e) =>
                              setStudentFormData({ ...studentFormData, email: e.target.value })
                            }
                            className="teacher-field-input"
                          />
                        </div>
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="form-actions-footer">
                      <button
                        type="button"
                        className="btn-outline-cancel"
                        onClick={() => goToScreen('students')}
                      >
                        Cancel
                      </button>
                      <button type="submit" className="btn-primary-blue">
                        <Save size={16} />
                        <span>Save Student</span>
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 5: STUDENT DETAIL (Attendance & Parent/Guardian Info)
               ======================================================== */}
            {activeScreen === 'student-detail' && (
              <div className="screen-view screen-student-detail">
                {/* Back Link */}
                <div className="back-navigation-bar">
                  <button
                    type="button"
                    className="btn-back-link"
                    onClick={() => goToScreen('students')}
                  >
                    <ArrowLeft size={16} />
                    <span>Back to Student Records</span>
                  </button>
                </div>

                {/* Profile Header Card */}
                <div className="student-profile-header-card">
                  <div className="profile-header-left">
                    <div className="student-large-avatar">
                      <span>
                        {selectedStudent.name
                          .split(' ')
                          .map((n) => n[0])
                          .join('')}
                      </span>
                    </div>
                    <div className="student-header-meta">
                      <div className="name-status-row">
                        <h2 className="student-display-name">{selectedStudent.name}</h2>
                        <span className="status-badge-pill active">
                          {selectedStudent.status}
                        </span>
                      </div>
                      <div className="sub-meta-row">
                        <span className="roll-text">Roll No: {selectedStudent.rollNo}</span>
                        <span className="meta-separator">•</span>
                        <span className="class-text">Class: {selectedStudent.class}</span>
                      </div>
                    </div>
                  </div>

                  <button
                    type="button"
                    className="btn-outline-edit"
                    onClick={() => handleOpenEditStudent(selectedStudent)}
                  >
                    <Edit2 size={15} />
                    <span>Edit</span>
                  </button>
                </div>

                {/* Tabs */}
                <div className="detail-tabs-bar">
                  {['Overview', 'Attendance', 'Grades', 'Parent Information'].map((tab) => (
                    <button
                      key={tab}
                      type="button"
                      className={`detail-tab-btn ${studentDetailTab === tab ? 'active' : ''}`}
                      onClick={() => setStudentDetailTab(tab)}
                    >
                      {tab}
                    </button>
                  ))}
                </div>

                {/* Tab Content */}
                <div className="student-detail-content-grid">
                  {/* Left Box: Attendance Overview (Screen 5 Circular Gauge) */}
                  <div className="detail-card attendance-overview-card">
                    <h3 className="detail-card-title">Attendance Overview</h3>
                    <div className="gauge-center-wrapper">
                      <div className="circular-donut-container">
                        <svg viewBox="0 0 120 120" className="donut-svg">
                          <circle
                            cx="60"
                            cy="60"
                            r="48"
                            fill="none"
                            stroke="#e2e8f0"
                            strokeWidth="12"
                          />
                          <circle
                            cx="60"
                            cy="60"
                            r="48"
                            fill="none"
                            stroke="#0284c7"
                            strokeWidth="12"
                            strokeDasharray="301.59"
                            strokeDashoffset={301.59 * (1 - selectedStudent.attendance / 100)}
                            strokeLinecap="round"
                            transform="rotate(-90 60 60)"
                          />
                        </svg>
                        <div className="donut-center-text">
                          <span className="donut-percent">{selectedStudent.attendance}%</span>
                          <span className="donut-label">Present</span>
                        </div>
                      </div>

                      <div className="donut-legend-row">
                        <div className="legend-item">
                          <span className="legend-dot green" />
                          <span className="legend-name">Present</span>
                          <span className="legend-val">({selectedStudent.presentDays})</span>
                        </div>
                        <div className="legend-item">
                          <span className="legend-dot red" />
                          <span className="legend-name">Absent</span>
                          <span className="legend-val">({selectedStudent.absentDays})</span>
                        </div>
                        <div className="legend-item">
                          <span className="legend-dot blue" />
                          <span className="legend-name">Leave</span>
                          <span className="legend-val">({selectedStudent.leaveDays})</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Right Box: Recent Attendance */}
                  <div className="detail-card recent-attendance-card">
                    <h3 className="detail-card-title">Recent Attendance</h3>
                    <div className="recent-attendance-list">
                      {selectedStudent.recentAttendance.map((rec, i) => (
                        <div key={i} className="attendance-log-row">
                          <span className="log-date">{rec.date}</span>
                          <span
                            className={`log-badge ${
                              rec.status === 'Present' ? 'present' : 'absent'
                            }`}
                          >
                            {rec.status}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Bottom Box: Parent / Guardian Information */}
                  <div className="detail-card parent-guardian-card full-width">
                    <h3 className="detail-card-title">Parent / Guardian Information</h3>
                    <div className="parent-info-three-col">
                      <div className="parent-info-block">
                        <span className="parent-label">Father:</span>
                        <div className="parent-name-phone">
                          <span className="p-name">{selectedStudent.fatherName}</span>
                          <span className="p-phone">{selectedStudent.fatherPhone}</span>
                        </div>
                      </div>

                      <div className="parent-info-block">
                        <span className="parent-label">Mother:</span>
                        <div className="parent-name-phone">
                          <span className="p-name">{selectedStudent.motherName}</span>
                          <span className="p-phone">{selectedStudent.motherPhone}</span>
                        </div>
                      </div>

                      <div className="parent-info-block">
                        <span className="parent-label">Email:</span>
                        <span className="p-email">{selectedStudent.email}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 6: COURSE MANAGEMENT (Overview)
               ======================================================== */}
            {activeScreen === 'courses' && (
              <div className="screen-view screen-courses">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-page-title">Course Management</h1>
                    <p className="screen-page-subtitle">View, edit and manage your courses.</p>
                  </div>
                  <div className="header-actions-group">
                    <button
                      type="button"
                      className="btn-outline-danger"
                      onClick={() => goToScreen('remove-course')}
                    >
                      <Trash2 size={16} />
                      <span>Remove Course</span>
                    </button>
                    <button
                      type="button"
                      className="btn-primary-blue"
                      onClick={() => goToScreen('add-course')}
                    >
                      <Plus size={16} />
                      <span>Add Course</span>
                    </button>
                  </div>
                </div>

                {/* Filters */}
                <div className="records-filter-bar">
                  <div className="filter-search-box">
                    <Search size={16} className="filter-icon" />
                    <input
                      type="text"
                      placeholder="Search Course..."
                      value={courseSearch}
                      onChange={(e) => setCourseSearch(e.target.value)}
                      className="filter-search-input"
                    />
                  </div>

                  <div className="filter-dropdowns-group">
                    <select
                      value={courseDeptFilter}
                      onChange={(e) => setCourseDeptFilter(e.target.value)}
                      className="filter-select"
                    >
                      <option value="All Departments">All Departments</option>
                      <option value="CS">Computer Science</option>
                      <option value="Mathematics">Mathematics</option>
                      <option value="Languages">Languages</option>
                    </select>

                    <select
                      value={courseSemFilter}
                      onChange={(e) => setCourseSemFilter(e.target.value)}
                      className="filter-select"
                    >
                      <option value="All Semesters">All Semesters</option>
                      <option value="1">Semester 1</option>
                      <option value="2">Semester 2</option>
                      <option value="3">Semester 3</option>
                      <option value="4">Semester 4</option>
                    </select>
                  </div>
                </div>

                {/* 3 Metric Cards */}
                <div className="courses-kpi-row">
                  <div className="course-kpi-card">
                    <span className="kpi-label">Total Courses</span>
                    <span className="kpi-value">{courses.length}</span>
                  </div>
                  <div className="course-kpi-card">
                    <span className="kpi-label">Active</span>
                    <span className="kpi-value green">{courses.length - 1}</span>
                  </div>
                  <div className="course-kpi-card">
                    <span className="kpi-label">Inactive</span>
                    <span className="kpi-value red">1</span>
                  </div>
                </div>

                {/* Courses Table */}
                <div className="teacher-table-card">
                  <table className="teacher-data-table">
                    <thead>
                      <tr>
                        <th style={{ width: '40px' }}>#</th>
                        <th>Course Name</th>
                        <th>Code</th>
                        <th>Department</th>
                        <th>Semester</th>
                        <th>Students</th>
                        <th>Status</th>
                        <th style={{ textAlign: 'center' }}>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredCourses.map((course, idx) => (
                        <tr key={course.id}>
                          <td>{idx + 1}</td>
                          <td>
                            <span
                              className="table-link-name"
                              onClick={() => handleViewCourseDetails(course)}
                            >
                              {course.name}
                            </span>
                          </td>
                          <td>
                            <span className="table-code-pill">{course.code}</span>
                          </td>
                          <td>{course.department}</td>
                          <td>{course.semester}</td>
                          <td>
                            <span className="student-count-badge">{course.students}</span>
                          </td>
                          <td>
                            <span className="status-badge-pill active">{course.status}</span>
                          </td>
                          <td>
                            <div className="table-actions-group center">
                              <button
                                type="button"
                                className="action-btn edit"
                                onClick={() => handleViewCourseDetails(course)}
                                title="Edit Course"
                              >
                                <Edit2 size={15} />
                              </button>
                              <button
                                type="button"
                                className="action-btn view"
                                onClick={() => handleViewCourseDetails(course)}
                                title="View Course Details"
                              >
                                <Eye size={15} />
                              </button>
                              <button
                                type="button"
                                className="action-btn delete"
                                onClick={() => {
                                  setSelectedCourseIdsToRemove([course.id]);
                                  goToScreen('remove-course');
                                }}
                                title="Remove Course"
                              >
                                <Trash2 size={15} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 7: ADD COURSE
               ======================================================== */}
            {activeScreen === 'add-course' && (
              <div className="screen-view screen-form-page">
                <div className="form-page-container">
                  <div className="form-page-header">
                    <div className="form-header-icon-box blue">
                      <Award size={24} />
                    </div>
                    <div>
                      <h1 className="form-page-title">Add New Course</h1>
                      <p className="form-page-subtitle">
                        Create a new course and assign it to departments.
                      </p>
                    </div>
                  </div>

                  <form onSubmit={handleSaveCourse} className="form-page-card">
                    <div className="form-grid-two-col">
                      <div className="teacher-form-field">
                        <label className="field-label">
                          Course Name <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="Enter course name"
                          value={newCourseData.name}
                          onChange={(e) =>
                            setNewCourseData({ ...newCourseData, name: e.target.value })
                          }
                          className="teacher-field-input"
                          required
                        />
                      </div>

                      <div className="teacher-form-field">
                        <label className="field-label">
                          Course Code <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. BCA-301"
                          value={newCourseData.code}
                          onChange={(e) =>
                            setNewCourseData({ ...newCourseData, code: e.target.value })
                          }
                          className="teacher-field-input"
                          required
                        />
                      </div>

                      <div className="teacher-form-field">
                        <label className="field-label">Department</label>
                        <select
                          value={newCourseData.department}
                          onChange={(e) =>
                            setNewCourseData({ ...newCourseData, department: e.target.value })
                          }
                          className="teacher-field-input"
                        >
                          <option value="">Select department</option>
                          <option value="Computer Science">Computer Science</option>
                          <option value="Mathematics">Mathematics</option>
                          <option value="Languages">Languages</option>
                          <option value="Management Studies">Management Studies</option>
                        </select>
                      </div>

                      <div className="teacher-form-field">
                        <label className="field-label">Semester</label>
                        <select
                          value={newCourseData.semester}
                          onChange={(e) =>
                            setNewCourseData({ ...newCourseData, semester: e.target.value })
                          }
                          className="teacher-field-input"
                        >
                          <option value="">Select semester</option>
                          <option value="1">Semester 1</option>
                          <option value="2">Semester 2</option>
                          <option value="3">Semester 3</option>
                          <option value="4">Semester 4</option>
                        </select>
                      </div>

                      <div className="teacher-form-field full-width">
                        <div className="label-with-counter">
                          <label className="field-label">Description</label>
                          <span className="char-counter">
                            {newCourseData.description.length}/500
                          </span>
                        </div>
                        <textarea
                          rows="4"
                          maxLength={500}
                          placeholder="Enter course description (optional)"
                          value={newCourseData.description}
                          onChange={(e) =>
                            setNewCourseData({ ...newCourseData, description: e.target.value })
                          }
                          className="teacher-field-textarea"
                        />
                      </div>

                      <div className="teacher-form-field full-width">
                        <label className="field-label">Assign Instructor</label>
                        <select
                          value={newCourseData.instructor}
                          onChange={(e) =>
                            setNewCourseData({ ...newCourseData, instructor: e.target.value })
                          }
                          className="teacher-field-input"
                        >
                          <option value="Dr. Amit Sharma">Dr. Amit Sharma (You)</option>
                          <option value="Prof. Neha Gupta">Prof. Neha Gupta</option>
                          <option value="Dr. Rakesh Verma">Dr. Rakesh Verma</option>
                        </select>
                      </div>
                    </div>

                    <div className="form-actions-footer">
                      <button
                        type="button"
                        className="btn-outline-cancel"
                        onClick={() => goToScreen('courses')}
                      >
                        Cancel
                      </button>
                      <button type="submit" className="btn-primary-blue">
                        <Plus size={16} />
                        <span>Add Course</span>
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 8: REMOVE COURSE
               ======================================================== */}
            {activeScreen === 'remove-course' && (
              <div className="screen-view screen-remove-course">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-page-title">Remove Course</h1>
                    <p className="screen-page-subtitle">
                      Select a course to unassign or remove it from your classes.
                    </p>
                  </div>
                  <button
                    type="button"
                    className="btn-outline-cancel"
                    onClick={() => goToScreen('courses')}
                  >
                    Cancel
                  </button>
                </div>

                <div className="teacher-table-card">
                  <table className="teacher-data-table select-table">
                    <thead>
                      <tr>
                        <th style={{ width: '40px' }}>
                          <input
                            type="checkbox"
                            checked={
                              courses.length > 0 &&
                              selectedCourseIdsToRemove.length === courses.length
                            }
                            onChange={(e) => {
                              if (e.target.checked) {
                                setSelectedCourseIdsToRemove(courses.map((c) => c.id));
                              } else {
                                setSelectedCourseIdsToRemove([]);
                              }
                            }}
                          />
                        </th>
                        <th>Course Name</th>
                        <th>Code</th>
                        <th>Department</th>
                        <th>Semester</th>
                        <th>Students</th>
                        <th>Status</th>
                        <th style={{ textAlign: 'center' }}>Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {courses.map((course) => {
                        const isSelected = selectedCourseIdsToRemove.includes(course.id);
                        return (
                          <tr
                            key={course.id}
                            className={isSelected ? 'row-selected' : ''}
                            onClick={() => handleToggleCourseSelectionToRemove(course.id)}
                            style={{ cursor: 'pointer' }}
                          >
                            <td onClick={(e) => e.stopPropagation()}>
                              <input
                                type="checkbox"
                                checked={isSelected}
                                onChange={() => handleToggleCourseSelectionToRemove(course.id)}
                              />
                            </td>
                            <td>
                              <span className="table-bold-name">{course.name}</span>
                            </td>
                            <td>
                              <span className="table-code-pill">{course.code}</span>
                            </td>
                            <td>{course.department}</td>
                            <td>{course.semester}</td>
                            <td>{course.students}</td>
                            <td>
                              <span className="status-badge-pill active">{course.status}</span>
                            </td>
                            <td style={{ textAlign: 'center' }}>
                              <button
                                type="button"
                                className="action-btn delete"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  setSelectedCourseIdsToRemove([course.id]);
                                  handleExecuteRemoveCourses();
                                }}
                                title="Remove this course immediately"
                              >
                                <Trash2 size={15} />
                              </button>
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>

                  {/* Floating / Bottom Selection Bar */}
                  <div className="remove-selection-bar">
                    <span className="selection-count-text">
                      {selectedCourseIdsToRemove.length} course
                      {selectedCourseIdsToRemove.length === 1 ? '' : 's'} selected
                    </span>

                    <div className="selection-actions">
                      <button
                        type="button"
                        className="btn-outline-cancel"
                        onClick={() => goToScreen('courses')}
                      >
                        Cancel
                      </button>
                      <button
                        type="button"
                        className="btn-danger-solid"
                        onClick={handleExecuteRemoveCourses}
                        disabled={selectedCourseIdsToRemove.length === 0}
                      >
                        <Trash2 size={16} />
                        <span>Remove Selected</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 9: COURSE DETAILS
               ======================================================== */}
            {activeScreen === 'course-details' && (
              <div className="screen-view screen-course-details">
                {/* Back Link */}
                <div className="back-navigation-bar">
                  <button
                    type="button"
                    className="btn-back-link"
                    onClick={() => goToScreen('courses')}
                  >
                    <ArrowLeft size={16} />
                    <span>Back to Courses</span>
                  </button>
                </div>

                {/* Course Header Banner Card */}
                <div className="course-detail-header-card">
                  <div className="course-header-left">
                    <div className="course-icon-badge blue">
                      <Award size={26} />
                    </div>
                    <div>
                      <div className="name-status-row">
                        <h2 className="course-display-name">{selectedCourse.name}</h2>
                        <span className="status-badge-pill active">{selectedCourse.status}</span>
                      </div>
                      <span className="course-code-subtitle">{selectedCourse.code}</span>
                    </div>
                  </div>

                  <button
                    type="button"
                    className="btn-outline-edit"
                    onClick={() => {
                      showToast('Edit mode enabled for course.');
                    }}
                  >
                    <Edit2 size={15} />
                    <span>Edit</span>
                  </button>
                </div>

                {/* Tabs */}
                <div className="detail-tabs-bar">
                  {['Overview', 'Students', 'Schedule', 'Resources'].map((tab) => (
                    <button
                      key={tab}
                      type="button"
                      className={`detail-tab-btn ${courseDetailTab === tab ? 'active' : ''}`}
                      onClick={() => setCourseDetailTab(tab)}
                    >
                      {tab}
                    </button>
                  ))}
                </div>

                {/* Two Columns Grid */}
                <div className="course-content-two-col">
                  {/* Left Column: Course Metadata */}
                  <div className="course-info-card">
                    <div className="info-meta-item">
                      <span className="info-meta-label">Department</span>
                      <span className="info-meta-val">{selectedCourse.deptFull}</span>
                    </div>

                    <div className="info-meta-item">
                      <span className="info-meta-label">Semester</span>
                      <span className="info-meta-val">{selectedCourse.semester}</span>
                    </div>

                    <div className="info-meta-item">
                      <span className="info-meta-label">Course Code</span>
                      <span className="info-meta-val">{selectedCourse.code}</span>
                    </div>

                    <div className="info-meta-item">
                      <span className="info-meta-label">Credits</span>
                      <span className="info-meta-val">{selectedCourse.credits}</span>
                    </div>

                    <div className="info-meta-item full">
                      <span className="info-meta-label">Description</span>
                      <p className="info-meta-desc">{selectedCourse.description}</p>
                    </div>
                  </div>

                  {/* Right Column: Statistics Donut & Recent Activity */}
                  <div className="course-stats-col">
                    {/* Donut Chart Card */}
                    <div className="course-donut-card">
                      <h3 className="card-subheading">Statistics</h3>
                      <div className="donut-stat-wrapper">
                        <div className="circular-donut-container small">
                          <svg viewBox="0 0 100 100" className="donut-svg">
                            <circle
                              cx="50"
                              cy="50"
                              r="38"
                              fill="none"
                              stroke="#e2e8f0"
                              strokeWidth="10"
                            />
                            <circle
                              cx="50"
                              cy="50"
                              r="38"
                              fill="none"
                              stroke="#0284c7"
                              strokeWidth="10"
                              strokeDasharray="238.76"
                              strokeDashoffset={238.76 * (1 - 32 / 36)}
                              strokeLinecap="round"
                              transform="rotate(-90 50 50)"
                            />
                          </svg>
                          <div className="donut-center-text small">
                            <span className="donut-percent">{selectedCourse.students}</span>
                            <span className="donut-label">Enrolled</span>
                          </div>
                        </div>

                        <div className="course-stat-numbers">
                          <div className="c-stat-row">
                            <span className="stat-indicator-dot blue" />
                            <span className="c-stat-label">Enrolled:</span>
                            <span className="c-stat-val">{selectedCourse.students}</span>
                          </div>
                          <div className="c-stat-row">
                            <span className="stat-indicator-dot amber" />
                            <span className="c-stat-label">Pending:</span>
                            <span className="c-stat-val">4</span>
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Recent Activity Card */}
                    <div className="course-recent-activity-card">
                      <h3 className="card-subheading">Recent Activity</h3>
                      <div className="recent-activity-minimal">
                        <div className="mini-activity-item">
                          <span className="bullet-dot blue" />
                          <div className="mini-activity-content">
                            <span className="mini-act-title">New enrollment</span>
                            <span className="mini-act-date">Apr 25, 2025</span>
                          </div>
                        </div>

                        <div className="mini-activity-item">
                          <span className="bullet-dot teal" />
                          <div className="mini-activity-content">
                            <span className="mini-act-title">Schedule updated</span>
                            <span className="mini-act-date">Apr 23, 2025</span>
                          </div>
                        </div>

                        <div className="mini-activity-item">
                          <span className="bullet-dot cyan" />
                          <div className="mini-activity-content">
                            <span className="mini-act-title">Material uploaded</span>
                            <span className="mini-act-date">Apr 20, 2025</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 10: LECTURE MANAGEMENT
               ======================================================== */}
            {activeScreen === 'lectures' && (
              <div className="screen-view screen-lectures">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-page-title">Lecture Management</h1>
                    <p className="screen-page-subtitle">
                      View and update your assigned lecture schedule.
                    </p>
                  </div>
                  <div className="header-actions-group">
                    {/* Date Selector */}
                    <div className="lecture-date-picker-box">
                      <CalendarDays size={16} className="cal-icon" />
                      <input
                        type="text"
                        value={selectedLectureDate}
                        onChange={(e) => setSelectedLectureDate(e.target.value)}
                        className="lecture-date-input"
                      />
                    </div>

                    <button
                      type="button"
                      className="btn-primary-blue"
                      onClick={() => handleOpenUpdateLecture(lectures[0])}
                    >
                      <Plus size={16} />
                      <span>Add Lecture</span>
                    </button>
                  </div>
                </div>

                {/* Lectures Table */}
                <div className="teacher-table-card">
                  <table className="teacher-data-table">
                    <thead>
                      <tr>
                        <th>Time</th>
                        <th>Course</th>
                        <th>Class</th>
                        <th>Room</th>
                        <th>Status</th>
                        <th style={{ textAlign: 'center' }}>Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {lectures.map((lec) => (
                        <tr key={lec.id}>
                          <td>
                            <span className="time-code-pill">{lec.time}</span>
                          </td>
                          <td>
                            <span className="table-bold-name">{lec.course}</span>
                          </td>
                          <td>{lec.class}</td>
                          <td>{lec.room}</td>
                          <td>
                            <span
                              className={`status-badge-pill ${
                                lec.status === 'Ongoing' ? 'ongoing' : 'upcoming'
                              }`}
                            >
                              {lec.status}
                            </span>
                          </td>
                          <td>
                            <div className="table-actions-group center">
                              <button
                                type="button"
                                className="action-btn edit"
                                onClick={() => handleOpenUpdateLecture(lec)}
                                title="Update Schedule"
                              >
                                <Edit2 size={15} />
                              </button>
                              <button
                                type="button"
                                className="action-btn view"
                                onClick={() => handleOpenUpdateLecture(lec)}
                                title="View Lecture Info"
                              >
                                <Eye size={15} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                {/* Bottom Quote Banner with Illustration */}
                <div className="lecture-quote-banner">
                  <div className="quote-illustration-box">
                    <svg viewBox="0 0 160 120" fill="none" className="teaching-vector-svg">
                      <circle cx="80" cy="60" r="50" fill="#e0f2fe" />
                      {/* Teacher figure */}
                      <circle cx="75" cy="40" r="14" fill="#0284c7" />
                      <path
                        d="M50 85C50 68 62 60 75 60C88 60 100 68 100 85V95H50V85Z"
                        fill="#0369a1"
                      />
                      {/* Laptop */}
                      <rect x="85" y="70" width="40" height="25" rx="3" fill="#0f172a" />
                      <line x1="80" y1="95" x2="130" y2="95" stroke="#475569" strokeWidth="4" />
                      {/* Screen glow */}
                      <rect x="88" y="73" width="34" height="19" rx="1" fill="#38bdf8" />
                    </svg>
                  </div>
                  <div className="quote-text-box">
                    <p className="inspirational-quote">
                      "Great teaching builds greater futures."
                    </p>
                    <span className="quote-attribution">Apex Institute Academic Excellence</span>
                  </div>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 11: UPDATE LECTURE SCHEDULE
               ======================================================== */}
            {activeScreen === 'update-lecture' && (
              <div className="screen-view screen-form-page">
                <div className="form-page-container">
                  <div className="form-page-header">
                    <div className="form-header-icon-box blue">
                      <Calendar size={24} />
                    </div>
                    <div>
                      <h1 className="form-page-title">Update Lecture Schedule</h1>
                      <p className="form-page-subtitle">Modify your assigned lecture details.</p>
                    </div>
                  </div>

                  <form onSubmit={handleSaveLectureSchedule} className="form-page-card">
                    <div className="form-grid-two-col">
                      <div className="teacher-form-field">
                        <label className="field-label">Course</label>
                        <select
                          value={lectureFormData.course}
                          onChange={(e) =>
                            setLectureFormData({ ...lectureFormData, course: e.target.value })
                          }
                          className="teacher-field-input"
                        >
                          {courses.map((c) => (
                            <option key={c.id} value={c.name}>
                              {c.name} ({c.code})
                            </option>
                          ))}
                        </select>
                      </div>

                      <div className="teacher-form-field">
                        <label className="field-label">Date</label>
                        <input
                          type="text"
                          value={lectureFormData.date}
                          onChange={(e) =>
                            setLectureFormData({ ...lectureFormData, date: e.target.value })
                          }
                          className="teacher-field-input"
                        />
                      </div>

                      <div className="teacher-form-field">
                        <label className="field-label">Time</label>
                        <input
                          type="text"
                          placeholder="e.g. 09:00 AM - 10:00 AM"
                          value={lectureFormData.time}
                          onChange={(e) =>
                            setLectureFormData({ ...lectureFormData, time: e.target.value })
                          }
                          className="teacher-field-input"
                        />
                      </div>

                      <div className="teacher-form-field">
                        <label className="field-label">Room</label>
                        <input
                          type="text"
                          placeholder="e.g. Lab 2"
                          value={lectureFormData.room}
                          onChange={(e) =>
                            setLectureFormData({ ...lectureFormData, room: e.target.value })
                          }
                          className="teacher-field-input"
                        />
                      </div>

                      <div className="teacher-form-field">
                        <label className="field-label">Duration</label>
                        <select
                          value={lectureFormData.duration}
                          onChange={(e) =>
                            setLectureFormData({ ...lectureFormData, duration: e.target.value })
                          }
                          className="teacher-field-input"
                        >
                          <option value="1 Hour">1 Hour</option>
                          <option value="1.5 Hours">1.5 Hours</option>
                          <option value="2 Hours">2 Hours</option>
                          <option value="3 Hours">3 Hours</option>
                        </select>
                      </div>

                      <div className="teacher-form-field">
                        <label className="field-label">Status</label>
                        <select
                          value={lectureFormData.status}
                          onChange={(e) =>
                            setLectureFormData({ ...lectureFormData, status: e.target.value })
                          }
                          className="teacher-field-input"
                        >
                          <option value="Ongoing">Ongoing</option>
                          <option value="Upcoming">Upcoming</option>
                          <option value="Completed">Completed</option>
                        </select>
                      </div>

                      <div className="teacher-form-field full-width">
                        <label className="field-label">Notes (Optional)</label>
                        <textarea
                          rows="4"
                          placeholder="Add any additional notes..."
                          value={lectureFormData.notes}
                          onChange={(e) =>
                            setLectureFormData({ ...lectureFormData, notes: e.target.value })
                          }
                          className="teacher-field-textarea"
                        />
                      </div>
                    </div>

                    <div className="form-actions-footer">
                      <button
                        type="button"
                        className="btn-outline-cancel"
                        onClick={() => goToScreen('lectures')}
                      >
                        Cancel
                      </button>
                      <button type="submit" className="btn-primary-blue">
                        <Save size={16} />
                        <span>Update Schedule</span>
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            )}

            {/* ========================================================
                SCREEN 12: INSTRUCTOR PROFILE
               ======================================================== */}
            {activeScreen === 'profile' && (
              <div className="screen-view screen-profile">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-page-title">Instructor Profile</h1>
                    <p className="screen-page-subtitle">
                      Manage your personal and professional information.
                    </p>
                  </div>
                </div>

                {/* Top Profile Card */}
                <div className="profile-hero-card">
                  <div className="profile-hero-left">
                    <div className="instructor-hero-avatar">
                      <span className="avatar-initials-large">AS</span>
                    </div>

                    <div className="instructor-hero-info">
                      <h2 className="instructor-full-name">{instructorProfile.name}</h2>
                      <div className="instructor-hero-meta-row">
                        <span className="inst-meta-item">
                          Instructor ID: <strong>{instructorProfile.instructorId}</strong>
                        </span>
                        <span className="meta-separator">•</span>
                        <span className="inst-meta-item">
                          Department: <strong>{instructorProfile.department}</strong>
                        </span>
                      </div>
                      <div className="instructor-hero-contacts">
                        <span className="contact-item">
                          <Mail size={14} /> {instructorProfile.email}
                        </span>
                        <span className="meta-separator">•</span>
                        <span className="contact-item">
                          <Phone size={14} /> {instructorProfile.phone}
                        </span>
                      </div>
                    </div>
                  </div>

                  <button
                    type="button"
                    className="btn-primary-blue edit-profile-btn"
                    onClick={() => {
                      setProfileFormData({ ...instructorProfile });
                      setIsEditProfileModalOpen(true);
                    }}
                  >
                    <Edit2 size={15} />
                    <span>Edit Profile</span>
                  </button>
                </div>

                {/* Two Columns: Professional Information & About Me */}
                <div className="profile-details-two-col">
                  {/* Left Column: Professional Information */}
                  <div className="profile-card-box">
                    <h3 className="profile-box-title">Professional Information</h3>
                    <div className="pro-info-list">
                      <div className="pro-info-row">
                        <span className="pro-label">Designation</span>
                        <span className="pro-val">{instructorProfile.designation}</span>
                      </div>

                      <div className="pro-info-row">
                        <span className="pro-label">Joining Date</span>
                        <span className="pro-val">{instructorProfile.joiningDate}</span>
                      </div>

                      <div className="pro-info-row">
                        <span className="pro-label">Qualification</span>
                        <span className="pro-val">{instructorProfile.qualification}</span>
                      </div>

                      <div className="pro-info-row">
                        <span className="pro-label">Experience</span>
                        <span className="pro-val">{instructorProfile.experience}</span>
                      </div>
                    </div>
                  </div>

                  {/* Right Column: About Me with Book Illustration */}
                  <div className="profile-card-box about-me-box">
                    <h3 className="profile-box-title">About Me</h3>
                    <p className="about-me-paragraph">{instructorProfile.about}</p>

                    <div className="about-me-illustration-corner">
                      <svg viewBox="0 0 120 100" fill="none" className="books-vector-svg">
                        <rect
                          x="20"
                          y="65"
                          width="80"
                          height="14"
                          rx="3"
                          fill="#0284c7"
                          opacity="0.85"
                        />
                        <rect
                          x="25"
                          y="50"
                          width="70"
                          height="14"
                          rx="3"
                          fill="#38bdf8"
                          opacity="0.85"
                        />
                        <rect
                          x="32"
                          y="35"
                          width="56"
                          height="14"
                          rx="3"
                          fill="#0ea5e9"
                          opacity="0.9"
                        />
                        {/* Graduation Cap */}
                        <polygon points="60,10 30,22 60,34 90,22" fill="#0f172a" />
                        <rect x="58" y="24" width="4" height="15" fill="#f59e0b" />
                        <circle cx="60" cy="40" r="3" fill="#f59e0b" />
                      </svg>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </main>
        </div>
      </div>

      {/* ========================================================
          MODAL: EDIT PROFILE MODAL
         ======================================================== */}
      {isEditProfileModalOpen && (
        <div className="teacher-modal-backdrop" onClick={() => setIsEditProfileModalOpen(false)}>
          <div className="teacher-modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">Edit Instructor Profile</h2>
              <button
                type="button"
                className="btn-modal-close"
                onClick={() => setIsEditProfileModalOpen(false)}
              >
                <X size={18} />
              </button>
            </div>

            <form onSubmit={handleSaveProfile} className="modal-form-body">
              <div className="form-grid-two-col">
                <div className="teacher-form-field">
                  <label className="field-label">Full Name</label>
                  <input
                    type="text"
                    value={profileFormData.name}
                    onChange={(e) =>
                      setProfileFormData({ ...profileFormData, name: e.target.value })
                    }
                    className="teacher-field-input"
                    required
                  />
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Designation</label>
                  <input
                    type="text"
                    value={profileFormData.designation}
                    onChange={(e) =>
                      setProfileFormData({ ...profileFormData, designation: e.target.value })
                    }
                    className="teacher-field-input"
                    required
                  />
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Department</label>
                  <input
                    type="text"
                    value={profileFormData.department}
                    onChange={(e) =>
                      setProfileFormData({ ...profileFormData, department: e.target.value })
                    }
                    className="teacher-field-input"
                    required
                  />
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Phone</label>
                  <input
                    type="text"
                    value={profileFormData.phone}
                    onChange={(e) =>
                      setProfileFormData({ ...profileFormData, phone: e.target.value })
                    }
                    className="teacher-field-input"
                    required
                  />
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Qualification</label>
                  <input
                    type="text"
                    value={profileFormData.qualification}
                    onChange={(e) =>
                      setProfileFormData({ ...profileFormData, qualification: e.target.value })
                    }
                    className="teacher-field-input"
                  />
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Experience</label>
                  <input
                    type="text"
                    value={profileFormData.experience}
                    onChange={(e) =>
                      setProfileFormData({ ...profileFormData, experience: e.target.value })
                    }
                    className="teacher-field-input"
                  />
                </div>

                <div className="teacher-form-field full-width">
                  <label className="field-label">About Me Bio</label>
                  <textarea
                    rows="3"
                    value={profileFormData.about}
                    onChange={(e) =>
                      setProfileFormData({ ...profileFormData, about: e.target.value })
                    }
                    className="teacher-field-textarea"
                  />
                </div>
              </div>

              <div className="modal-actions-footer">
                <button
                  type="button"
                  className="btn-outline-cancel"
                  onClick={() => setIsEditProfileModalOpen(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary-blue">
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================
          MODAL: ADD CLASS MODAL (Screen 2)
         ======================================================== */}
      {showAddClassModal && (
        <div className="teacher-modal-backdrop" onClick={() => setShowAddClassModal(false)}>
          <div className="teacher-modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">Add New Class</h2>
              <button
                type="button"
                className="btn-modal-close"
                onClick={() => setShowAddClassModal(false)}
              >
                <X size={18} />
              </button>
            </div>

            <form onSubmit={handleSaveNewClass} className="modal-form-body">
              <div className="form-grid-two-col">
                <div className="teacher-form-field">
                  <label className="field-label">Class / Course Name</label>
                  <input
                    type="text"
                    placeholder="e.g. Artificial Intelligence"
                    value={newClassData.name}
                    onChange={(e) => setNewClassData({ ...newClassData, name: e.target.value })}
                    className="teacher-field-input"
                    required
                  />
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Code</label>
                  <input
                    type="text"
                    placeholder="e.g. BCA-401"
                    value={newClassData.code}
                    onChange={(e) => setNewClassData({ ...newClassData, code: e.target.value })}
                    className="teacher-field-input"
                    required
                  />
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Semester</label>
                  <select
                    value={newClassData.semester}
                    onChange={(e) => setNewClassData({ ...newClassData, semester: e.target.value })}
                    className="teacher-field-input"
                  >
                    <option value="1">1</option>
                    <option value="2">2</option>
                    <option value="3">3</option>
                    <option value="4">4</option>
                    <option value="5">5</option>
                    <option value="6">6</option>
                  </select>
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Estimated Students</label>
                  <input
                    type="number"
                    value={newClassData.students}
                    onChange={(e) => setNewClassData({ ...newClassData, students: e.target.value })}
                    className="teacher-field-input"
                  />
                </div>
              </div>

              <div className="modal-actions-footer">
                <button
                  type="button"
                  className="btn-outline-cancel"
                  onClick={() => setShowAddClassModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary-blue">
                  Create Class
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================
          MODAL: UPLOAD COURSE MATERIAL MODAL
         ======================================================== */}
      {showUploadModal && (
        <div className="teacher-modal-backdrop" onClick={() => setShowUploadModal(false)}>
          <div className="teacher-modal-card upload-course-modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-header-with-badge">
                <div className="modal-icon-bubble blue">
                  <UploadCloud size={20} />
                </div>
                <div>
                  <h2 className="modal-title">Upload Course Material</h2>
                  <p className="modal-subtitle-text">
                    Publish learning resources, lecture slides, and notes for your students.
                  </p>
                </div>
              </div>
              <button
                type="button"
                className="btn-modal-close"
                onClick={() => setShowUploadModal(false)}
              >
                <X size={18} />
              </button>
            </div>

            <form onSubmit={handleUploadCourseMaterial} className="modal-form-body">
              <div className="form-grid-two-col">
                <div className="teacher-form-field">
                  <label className="field-label">Target Course <span className="req">*</span></label>
                  <select
                    value={uploadFormData.courseId}
                    onChange={(e) =>
                      setUploadFormData({ ...uploadFormData, courseId: e.target.value })
                    }
                    className="teacher-field-input"
                  >
                    {courses.map((c) => (
                      <option key={c.id} value={c.id}>
                        {c.name} ({c.code} - Sem {c.semester})
                      </option>
                    ))}
                  </select>
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Material Category <span className="req">*</span></label>
                  <select
                    value={uploadFormData.category}
                    onChange={(e) =>
                      setUploadFormData({ ...uploadFormData, category: e.target.value })
                    }
                    className="teacher-field-input"
                  >
                    <option value="Lecture Notes">Lecture Notes (PDF)</option>
                    <option value="Assignment">Assignment Sheet</option>
                    <option value="Syllabus">Course Syllabus & Outline</option>
                    <option value="Lab Manual">Lab Manual & Code Starter</option>
                    <option value="Presentation Slides">Presentation Slides</option>
                  </select>
                </div>

                <div className="teacher-form-field full-width">
                  <label className="field-label">Document / Resource Title <span className="req">*</span></label>
                  <input
                    type="text"
                    placeholder="e.g. Unit 3: React Fullstack Architecture & RESTful API Notes"
                    value={uploadFormData.title}
                    onChange={(e) =>
                      setUploadFormData({ ...uploadFormData, title: e.target.value })
                    }
                    className="teacher-field-input"
                    required
                  />
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">Academic Unit / Module</label>
                  <input
                    type="text"
                    placeholder="e.g. Unit 3: Components & State"
                    value={uploadFormData.module}
                    onChange={(e) =>
                      setUploadFormData({ ...uploadFormData, module: e.target.value })
                    }
                    className="teacher-field-input"
                  />
                </div>

                <div className="teacher-form-field">
                  <label className="field-label">External Resource URL (Optional)</label>
                  <input
                    type="url"
                    placeholder="e.g. https://github.com/example/react-lab"
                    value={uploadFormData.externalLink}
                    onChange={(e) =>
                      setUploadFormData({ ...uploadFormData, externalLink: e.target.value })
                    }
                    className="teacher-field-input"
                  />
                </div>

                {/* Interactive Drag & Drop Box */}
                <div className="teacher-form-field full-width">
                  <label className="field-label">Select File to Upload <span className="req">*</span></label>
                  <div className="interactive-upload-dropzone">
                    <div className="dropzone-icon-box">
                      <FileUp size={32} />
                    </div>
                    <div className="dropzone-text-group">
                      <span className="dropzone-main-text">
                        Click to browse or drag & drop lecture file here
                      </span>
                      <span className="dropzone-sub-text">
                        Supports PDF, DOCX, PPTX, ZIP (Up to 50MB)
                      </span>
                    </div>

                    <div className="dropzone-selected-file-pill">
                      <span className="selected-file-name">
                        📄 {uploadFormData.fileName || 'React_FullStack_Architecture.pdf'}
                      </span>
                      <span className="selected-file-size">
                        ({uploadFormData.fileSize || '4.2 MB'})
                      </span>
                    </div>
                  </div>
                </div>

                <div className="teacher-form-field full-width">
                  <label className="field-label">Description / Instructions for Students</label>
                  <textarea
                    rows="3"
                    placeholder="Add instructions, chapter references, or submission expectations..."
                    value={uploadFormData.description}
                    onChange={(e) =>
                      setUploadFormData({ ...uploadFormData, description: e.target.value })
                    }
                    className="teacher-field-textarea"
                  />
                </div>
              </div>

              <div className="modal-actions-footer">
                <button
                  type="button"
                  className="btn-outline-cancel"
                  onClick={() => setShowUploadModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary-blue">
                  <UploadCloud size={16} />
                  <span>Upload & Publish Material</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================
          MODAL: QUICK ATTENDANCE ROLL CALL
         ======================================================== */}
      {showQuickAttendanceModal && (
        <div className="teacher-modal-backdrop" onClick={() => setShowQuickAttendanceModal(false)}>
          <div className="teacher-modal-card quick-attendance-modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-header-with-badge">
                <div className="modal-icon-bubble green">
                  <CheckSquare size={20} />
                </div>
                <div>
                  <h2 className="modal-title">Quick Roll Call & Attendance</h2>
                  <p className="modal-subtitle-text">
                    {quickAttendanceCourse.name} ({quickAttendanceCourse.code}) • Today's Session
                  </p>
                </div>
              </div>
              <button
                type="button"
                className="btn-modal-close"
                onClick={() => setShowQuickAttendanceModal(false)}
              >
                <X size={18} />
              </button>
            </div>

            <form onSubmit={handleSaveQuickAttendance} className="modal-form-body">
              <div className="quick-attendance-toolbar">
                <span className="attendance-roster-count">
                  {quickAttendanceRoster.filter((s) => s.present).length} of{' '}
                  {quickAttendanceRoster.length} Students Present
                </span>

                <div className="quick-roster-toggle-buttons">
                  <button
                    type="button"
                    className="btn-roster-toggle-all"
                    onClick={() =>
                      setQuickAttendanceRoster((prev) =>
                        prev.map((s) => ({ ...s, present: true }))
                      )
                    }
                  >
                    Mark All Present
                  </button>
                  <button
                    type="button"
                    className="btn-roster-toggle-all"
                    onClick={() =>
                      setQuickAttendanceRoster((prev) =>
                        prev.map((s) => ({ ...s, present: false }))
                      )
                    }
                  >
                    Mark All Absent
                  </button>
                </div>
              </div>

              <div className="attendance-roster-list">
                {quickAttendanceRoster.map((student) => (
                  <div
                    key={student.id}
                    className={`roster-student-item ${student.present ? 'present' : 'absent'}`}
                    onClick={() =>
                      setQuickAttendanceRoster((prev) =>
                        prev.map((s) =>
                          s.id === student.id ? { ...s, present: !s.present } : s
                        )
                      )
                    }
                  >
                    <div className="roster-avatar">
                      <span>{student.name.split(' ').map((n) => n[0]).join('')}</span>
                    </div>

                    <div className="roster-info">
                      <span className="roster-name">{student.name}</span>
                      <span className="roster-roll">{student.rollNo}</span>
                    </div>

                    <button
                      type="button"
                      className={`attendance-toggle-pill ${student.present ? 'present' : 'absent'}`}
                    >
                      {student.present ? '✓ Present' : '✕ Absent'}
                    </button>
                  </div>
                ))}
              </div>

              <div className="modal-actions-footer">
                <button
                  type="button"
                  className="btn-outline-cancel"
                  onClick={() => setShowQuickAttendanceModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary-blue">
                  <Check size={16} />
                  <span>Save Attendance</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================
          MODAL: CLASS ANNOUNCEMENT MODAL
         ======================================================== */}
      {showAnnouncementModal && (
        <div className="teacher-modal-backdrop" onClick={() => setShowAnnouncementModal(false)}>
          <div className="teacher-modal-card announcement-modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-header-with-badge">
                <div className="modal-icon-bubble purple">
                  <Megaphone size={20} />
                </div>
                <div>
                  <h2 className="modal-title">Broadcast Class Announcement</h2>
                  <p className="modal-subtitle-text">
                    Send instantaneous alerts and notices to enrolled student dashboards.
                  </p>
                </div>
              </div>
              <button
                type="button"
                className="btn-modal-close"
                onClick={() => setShowAnnouncementModal(false)}
              >
                <X size={18} />
              </button>
            </div>

            <form onSubmit={handleSendAnnouncement} className="modal-form-body">
              <div className="form-grid-two-col">
                <div className="teacher-form-field full-width">
                  <label className="field-label">Target Audience / Section</label>
                  <select
                    value={announcementFormData.course}
                    onChange={(e) =>
                      setAnnouncementFormData({ ...announcementFormData, course: e.target.value })
                    }
                    className="teacher-field-input"
                  >
                    <option value="All Classes">All Enrolled Classes (Broadcast to 186 Students)</option>
                    {courses.map((c) => (
                      <option key={c.id} value={`${c.name} (${c.code})`}>
                        {c.name} ({c.code} - Sem {c.semester})
                      </option>
                    ))}
                  </select>
                </div>

                <div className="teacher-form-field full-width">
                  <label className="field-label">Announcement Title <span className="req">*</span></label>
                  <input
                    type="text"
                    placeholder="e.g. Mid-Term Lab Submissions Deadline Extended"
                    value={announcementFormData.title}
                    onChange={(e) =>
                      setAnnouncementFormData({ ...announcementFormData, title: e.target.value })
                    }
                    className="teacher-field-input"
                    required
                  />
                </div>

                <div className="teacher-form-field full-width">
                  <label className="field-label">Notice Message <span className="req">*</span></label>
                  <textarea
                    rows="4"
                    placeholder="Enter detailed message, instructions, or meeting links for your students..."
                    value={announcementFormData.message}
                    onChange={(e) =>
                      setAnnouncementFormData({ ...announcementFormData, message: e.target.value })
                    }
                    className="teacher-field-textarea"
                    required
                  />
                </div>
              </div>

              <div className="modal-actions-footer">
                <button
                  type="button"
                  className="btn-outline-cancel"
                  onClick={() => setShowAnnouncementModal(false)}
                >
                  Cancel
                </button>
                <button type="submit" className="btn-primary-blue">
                  <Megaphone size={16} />
                  <span>Send Announcement</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
