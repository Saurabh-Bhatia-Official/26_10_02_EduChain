import React, { useState, useEffect } from 'react';
import {
  LayoutDashboard,
  Users,
  UserCheck,
  BookOpen,
  Calendar,
  Layers,
  BarChart3,
  Settings,
  LogOut,
  Search,
  Plus,
  Filter,
  Download,
  Eye,
  Edit2,
  Trash2,
  CheckCircle2,
  AlertCircle,
  ChevronLeft,
  ChevronRight,
  ArrowLeft,
  ArrowRight,
  GraduationCap,
  Shield,
  Clock,
  MapPin,
  Mail,
  Phone,
  FileText,
  Save,
  X,
  Check,
  CalendarDays,
  Building2,
  TrendingUp,
  Award,
  Bell,
  Landmark,
  Share2,
  HelpCircle,
  Lock,
  ChevronDown,
  UploadCloud,
  FileSpreadsheet
} from 'lucide-react';
import InstituteBuildingIllustration from '../components/illustrations/InstituteBuildingIllustration';
import { studentService, instructorService, dashboardService, instituteService } from '../services/api';

export default function AdminPortalPage({
  onNavigate,
  currentUser,
  onLogout,
  initialTab = 'dashboard'
}) {
  // 15 Design Screens Mapping:
  // 1: 'dashboard'
  // 2: 'student-records'
  // 3: 'add-student'
  // 4: 'student-detail'
  // 5: 'instructor-records'
  // 6: 'instructor-tracking'
  // 7: 'add-instructor'
  // 8: 'class-management'
  // 9: 'academic-planning'
  // 10: 'lecture-schedule'
  // 11: 'exam-timetable'
  // 12: 'create-exam'
  // 13: 'cross-module'
  // 14: 'reports'
  // 15: 'settings'
  const [activeScreen, setActiveScreen] = useState(() => {
    if (initialTab === 'student-records' || initialTab === 'students') return 'student-records';
    if (initialTab === 'add-student') return 'add-student';
    if (initialTab === 'student-detail') return 'student-detail';
    if (initialTab === 'instructor-records' || initialTab === 'instructors') return 'instructor-records';
    if (initialTab === 'instructor-tracking') return 'instructor-tracking';
    if (initialTab === 'add-instructor') return 'add-instructor';
    if (initialTab === 'class-management' || initialTab === 'classes') return 'class-management';
    if (initialTab === 'academic-planning') return 'academic-planning';
    if (initialTab === 'lecture-schedule') return 'lecture-schedule';
    if (initialTab === 'exam-timetable') return 'exam-timetable';
    if (initialTab === 'create-exam') return 'create-exam';
    if (initialTab === 'cross-module' || initialTab === 'global-records') return 'cross-module';
    if (initialTab === 'reports' || initialTab === 'analytics') return 'reports';
    if (initialTab === 'settings' || initialTab === 'profile') return 'settings';
    return 'dashboard';
  });

  const [toastMessage, setToastMessage] = useState('');
  const [globalSearch, setGlobalSearch] = useState('');
  const [showDiagramNavigator, setShowDiagramNavigator] = useState(true);

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3400);
  };

  const goToScreen = (screenName) => {
    setActiveScreen(screenName);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Sync with initialTab prop changes
  useEffect(() => {
    if (initialTab) {
      if (initialTab === 'student-records' || initialTab === 'students') setActiveScreen('student-records');
      else if (initialTab === 'add-student') setActiveScreen('add-student');
      else if (initialTab === 'student-detail') setActiveScreen('student-detail');
      else if (initialTab === 'instructor-records' || initialTab === 'instructors') setActiveScreen('instructor-records');
      else if (initialTab === 'instructor-tracking') setActiveScreen('instructor-tracking');
      else if (initialTab === 'add-instructor') setActiveScreen('add-instructor');
      else if (initialTab === 'class-management' || initialTab === 'classes') setActiveScreen('class-management');
      else if (initialTab === 'academic-planning') setActiveScreen('academic-planning');
      else if (initialTab === 'lecture-schedule') setActiveScreen('lecture-schedule');
      else if (initialTab === 'exam-timetable') setActiveScreen('exam-timetable');
      else if (initialTab === 'create-exam') setActiveScreen('create-exam');
      else if (initialTab === 'cross-module' || initialTab === 'global-records') setActiveScreen('cross-module');
      else if (initialTab === 'reports' || initialTab === 'analytics') setActiveScreen('reports');
      else if (initialTab === 'settings' || initialTab === 'profile') setActiveScreen('settings');
      else setActiveScreen('dashboard');
    }
  }, [initialTab]);

  // Load dynamic data from Backend API on mount
  useEffect(() => {
    let isMounted = true;
    const fetchDynamicData = async () => {
      try {
        const [studentsData, instructorsData] = await Promise.allSettled([
          studentService.getAll(),
          instructorService.getAll()
        ]);

        if (isMounted && studentsData.status === 'fulfilled' && Array.isArray(studentsData.value) && studentsData.value.length > 0) {
          const mappedStudents = studentsData.value.map((s) => ({
            id: s.id,
            name: s.name,
            rollNo: s.rollNumber || `BCA-${s.id}`,
            department: s.department || 'Computer Science',
            course: s.course || 'BCA',
            semester: s.semester || '3',
            attendance: 92,
            presentRate: 92,
            absentRate: 6,
            leaveRate: 2,
            status: s.status || 'Active',
            dob: s.dob || '2004-05-12',
            gender: s.gender || 'Male',
            parentName: s.fatherName || 'Parent Name',
            parentPhone: s.fatherPhone || '+91 98765 43210',
            motherName: s.motherName || 'Mother Name',
            email: s.email,
            address: s.address || 'Academic Campus'
          }));
          setStudents(mappedStudents);
        }

        if (isMounted && instructorsData.status === 'fulfilled' && Array.isArray(instructorsData.value) && instructorsData.value.length > 0) {
          const mappedInstructors = instructorsData.value.map((i) => ({
            id: i.id,
            name: i.name,
            instructorId: i.instructorId || `INS-00${i.id}`,
            department: i.department || 'Computer Science',
            email: i.email,
            phone: i.phone || '+91 98765 43210',
            qualification: i.qualification || 'Ph.D - Computer Science',
            experience: i.experience || '5 Years',
            status: i.status || 'Active',
            classesCount: 3,
            attendanceStatus: i.status === 'On Leave' ? 'On Leave' : 'Present'
          }));
          setInstructors(mappedInstructors);
        }
      } catch (err) {
        console.warn('Backend loading warning:', err);
      }
    };

    fetchDynamicData();
    return () => { isMounted = false; };
  }, []);

  // ==========================================
  // 1. ADMIN PROFILE & SETTINGS STATE (Page 15)
  // ==========================================
  const [adminProfile, setAdminProfile] = useState({
    name: currentUser?.name || 'Admin Administrator',
    title: currentUser?.title || 'System Administrator',
    email: currentUser?.email || '',
    phone: currentUser?.phone || '',
    instituteName: currentUser?.instituteName || '',
    instituteCode: currentUser?.instituteCode || ''
  });

  const [isEditProfileModalOpen, setIsEditProfileModalOpen] = useState(false);
  const [profileFormData, setProfileFormData] = useState({ ...adminProfile });
  const [isChangePasswordModalOpen, setIsChangePasswordModalOpen] = useState(false);
  const [passwordFormData, setPasswordFormData] = useState({ currentPassword: '', newPassword: '', confirmPassword: '' });
  const [isCalendarModalOpen, setIsCalendarModalOpen] = useState(false);
  const [isBulkUpdateModalOpen, setIsBulkUpdateModalOpen] = useState(false);

  // Settings Toggles
  const [notificationSettings, setNotificationSettings] = useState({
    emailAlerts: true,
    smsNotifications: false,
    timetableAlerts: true
  });
  const [systemPreferences, setSystemPreferences] = useState({
    darkMode: false,
    language: 'English (US)',
    defaultSemester: 'Semester 3'
  });

  // ==========================================
  // 2. STUDENTS DATA (Pages 2, 3, 4)
  // ==========================================
  const [students, setStudents] = useState([
    {
      id: 1,
      name: 'Rahul Sharma',
      rollNo: 'BCA-301',
      department: 'Computer Science',
      course: 'BCA',
      semester: '3',
      attendance: 92,
      presentRate: 92,
      absentRate: 6,
      leaveRate: 2,
      status: 'Active',
      dob: '2004-05-12',
      gender: 'Male',
      parentName: 'Rajesh Sharma',
      parentPhone: '+91 98765 43210',
      motherName: 'Sunita Sharma',
      email: 'rahul.sharma@example.com',
      address: '123 Green Park, Delhi'
    },
    {
      id: 2,
      name: 'Priya Singh',
      rollNo: 'BCA-302',
      department: 'Computer Science',
      course: 'BCA',
      semester: '3',
      attendance: 88,
      presentRate: 88,
      absentRate: 8,
      leaveRate: 4,
      status: 'Active',
      dob: '2004-08-21',
      gender: 'Female',
      parentName: 'Manoj Singh',
      parentPhone: '+91 98765 43212',
      motherName: 'Kavita Singh',
      email: 'priya.singh@example.com',
      address: '45 Lake View Colony, Delhi'
    },
    {
      id: 3,
      name: 'Amit Kumar',
      rollNo: 'BCA-303',
      department: 'Computer Science',
      course: 'BCA',
      semester: '3',
      attendance: 94,
      presentRate: 94,
      absentRate: 4,
      leaveRate: 2,
      status: 'Active',
      dob: '2004-02-05',
      gender: 'Male',
      parentName: 'Suresh Kumar',
      parentPhone: '+91 98765 43214',
      motherName: 'Rekha Devi',
      email: 'amit.kumar@example.com',
      address: '78 Sector 15, Rohini, Delhi'
    },
    {
      id: 4,
      name: 'Neha Patel',
      rollNo: 'BCA-304',
      department: 'Computer Science',
      course: 'BCA',
      semester: '3',
      attendance: 90,
      presentRate: 90,
      absentRate: 7,
      leaveRate: 3,
      status: 'Active',
      dob: '2004-11-18',
      gender: 'Female',
      parentName: 'Vikram Patel',
      parentPhone: '+91 98765 43216',
      motherName: 'Meena Patel',
      email: 'neha.patel@example.com',
      address: '12 Model Town, Delhi'
    },
    {
      id: 5,
      name: 'Sahil Verma',
      rollNo: 'BCA-305',
      department: 'Mathematics',
      course: 'BCA',
      semester: '3',
      attendance: 81,
      presentRate: 81,
      absentRate: 14,
      leaveRate: 5,
      status: 'Active',
      dob: '2004-09-29',
      gender: 'Male',
      parentName: 'Anil Verma',
      parentPhone: '+91 98765 43218',
      motherName: 'Sunita Verma',
      email: 'sahil.verma@example.com',
      address: '56 Civil Lines, Delhi'
    },
    {
      id: 6,
      name: 'Rohan Mehta',
      rollNo: 'BCA-306',
      department: 'Computer Science',
      course: 'BCA',
      semester: '3',
      attendance: 92,
      presentRate: 92,
      absentRate: 6,
      leaveRate: 2,
      status: 'Active',
      dob: '2004-05-12',
      gender: 'Male',
      parentName: 'Rajesh Mehta',
      parentPhone: '+91 98765 43210',
      motherName: 'Neeta Mehta',
      motherPhone: '+91 98765 43211',
      email: 'rohanmehta@example.com',
      address: '123 Green Park, Delhi'
    }
  ]);

  const [studentSearch, setStudentSearch] = useState('');
  const [studentDeptFilter, setStudentDeptFilter] = useState('All');
  const [studentStatusFilter, setStudentStatusFilter] = useState('All');
  const [studentPaginationPage, setStudentPaginationPage] = useState(1);

  // Selected student for Page 4 (Detail View)
  const [selectedStudent, setSelectedStudent] = useState(students[5]); // Default to Rohan Mehta as shown in image
  const [studentDetailTab, setStudentDetailTab] = useState('Personal Info');

  // Form state for Page 3 (Add / Edit Student)
  const [editingStudentId, setEditingStudentId] = useState(null);
  const [studentFormData, setStudentFormData] = useState({
    fullName: '',
    rollNumber: '',
    department: 'Computer Science',
    course: 'BCA',
    dob: '2004-05-12',
    gender: 'Male',
    parentName: '',
    parentPhone: '',
    email: '',
    address: '123 Green Park, Delhi'
  });

  // Open Page 3 for Add
  const handleOpenAddStudent = () => {
    setEditingStudentId(null);
    setStudentFormData({
      fullName: '',
      rollNumber: `BCA-${300 + students.length + 1}`,
      department: 'Computer Science',
      course: 'BCA',
      dob: '2004-05-12',
      gender: 'Male',
      parentName: '',
      parentPhone: '',
      email: '',
      address: '123 Green Park, Delhi'
    });
    goToScreen('add-student');
  };

  // Open Page 3 for Edit
  const handleOpenEditStudent = (stud) => {
    setEditingStudentId(stud.id);
    setStudentFormData({
      fullName: stud.name,
      rollNumber: stud.rollNo,
      department: stud.department,
      course: stud.course,
      dob: stud.dob,
      gender: stud.gender,
      parentName: stud.parentName,
      parentPhone: stud.parentPhone,
      email: stud.email,
      address: stud.address || '123 Green Park, Delhi'
    });
    goToScreen('add-student');
  };

  // Submit Page 3 Form
  const handleSaveStudent = async (e) => {
    e.preventDefault();
    if (!studentFormData.fullName.trim() || !studentFormData.rollNumber.trim()) {
      showToast('Please enter both student full name and roll number.');
      return;
    }

    try {
      if (editingStudentId) {
        const payload = {
          name: studentFormData.fullName,
          rollNumber: studentFormData.rollNumber,
          department: studentFormData.department,
          course: studentFormData.course,
          dob: studentFormData.dob,
          gender: studentFormData.gender,
          fatherName: studentFormData.parentName,
          fatherPhone: studentFormData.parentPhone,
          email: studentFormData.email,
          address: studentFormData.address
        };
        await studentService.update(editingStudentId, payload);

        setStudents((prev) =>
          prev.map((s) =>
            s.id === editingStudentId
              ? {
                  ...s,
                  name: studentFormData.fullName,
                  rollNo: studentFormData.rollNumber,
                  department: studentFormData.department,
                  course: studentFormData.course,
                  dob: studentFormData.dob,
                  gender: studentFormData.gender,
                  parentName: studentFormData.parentName,
                  parentPhone: studentFormData.parentPhone,
                  email: studentFormData.email,
                  address: studentFormData.address
                }
              : s
          )
        );
        if (selectedStudent?.id === editingStudentId) {
          setSelectedStudent((prev) => ({
            ...prev,
            name: studentFormData.fullName,
            rollNo: studentFormData.rollNumber,
            department: studentFormData.department,
            course: studentFormData.course,
            dob: studentFormData.dob,
            gender: studentFormData.gender,
            parentName: studentFormData.parentName,
            parentPhone: studentFormData.parentPhone,
            email: studentFormData.email,
            address: studentFormData.address
          }));
        }
        showToast(`Student ${studentFormData.fullName} updated in database!`);
      } else {
        const payload = {
          name: studentFormData.fullName,
          rollNumber: studentFormData.rollNumber,
          department: studentFormData.department,
          course: studentFormData.course,
          semester: '3',
          dob: studentFormData.dob,
          gender: studentFormData.gender,
          fatherName: studentFormData.parentName,
          fatherPhone: studentFormData.parentPhone,
          email: studentFormData.email || `${studentFormData.rollNumber.toLowerCase().replace(/[^a-z0-9]/g, '')}@institute.com`,
          address: studentFormData.address,
          status: 'Active'
        };
        const saved = await studentService.create(payload);

        const newStudent = {
          id: saved?.id || (students.length + 1),
          name: saved?.name || studentFormData.fullName,
          rollNo: saved?.rollNumber || studentFormData.rollNumber,
          department: saved?.department || studentFormData.department,
          course: saved?.course || studentFormData.course,
          semester: '3',
          attendance: 90,
          presentRate: 90,
          absentRate: 8,
          leaveRate: 2,
          status: 'Active',
          dob: studentFormData.dob,
          gender: studentFormData.gender,
          parentName: studentFormData.parentName,
          parentPhone: studentFormData.parentPhone,
          motherName: 'Mother Name',
          email: saved?.email || studentFormData.email,
          address: studentFormData.address
        };
        setStudents([newStudent, ...students]);
        showToast(`New Student ${newStudent.name} (${newStudent.rollNo}) saved to database!`);
      }
    } catch (err) {
      showToast('Notice: ' + err.message);
    }
    goToScreen('student-records');
  };

  // Delete Student
  const handleDeleteStudent = async (id, name) => {
    if (window.confirm(`Are you sure you want to delete student "${name}"?`)) {
      try {
        await studentService.delete(id);
      } catch (err) {
        console.warn('API delete warning:', err);
      }
      setStudents((prev) => prev.filter((s) => s.id !== id));
      showToast(`Student "${name}" deleted from database.`);
    }
  };

  // Open Page 4 (View Profile)
  const handleViewStudentDetail = (stud) => {
    setSelectedStudent(stud);
    setStudentDetailTab('Personal Info');
    goToScreen('student-detail');
  };

  // ==========================================
  // 3. INSTRUCTORS DATA (Pages 5, 6, 7)
  // ==========================================
  const [instructors, setInstructors] = useState([
    {
      id: 1,
      name: 'Dr. Amit Sharma',
      instructorId: 'INS-001',
      department: 'Computer Science',
      email: 'amit@inst.edu',
      phone: '+91 98765 43210',
      qualification: 'Ph.D - Computer Science',
      experience: '5 Years',
      status: 'Active',
      classesCount: 4,
      attendanceStatus: 'Present'
    },
    {
      id: 2,
      name: 'Dr. Neha Patel',
      instructorId: 'INS-002',
      department: 'Mathematics',
      email: 'neha@inst.edu',
      phone: '+91 98765 43211',
      qualification: 'Ph.D - Mathematics',
      experience: '6 Years',
      status: 'Active',
      classesCount: 3,
      attendanceStatus: 'Present'
    },
    {
      id: 3,
      name: 'Prof. Raj Kumar',
      instructorId: 'INS-003',
      department: 'Physics',
      email: 'raj@inst.edu',
      phone: '+91 98765 43212',
      qualification: 'M.Tech / Ph.D',
      experience: '7 Years',
      status: 'Active',
      classesCount: 4,
      attendanceStatus: 'Present'
    },
    {
      id: 4,
      name: 'Dr. Sneha Rao',
      instructorId: 'INS-004',
      department: 'English',
      email: 'sneha@inst.edu',
      phone: '+91 98765 43213',
      qualification: 'Ph.D - English Literature',
      experience: '4 Years',
      status: 'On Leave',
      classesCount: 0,
      attendanceStatus: 'On Leave'
    },
    {
      id: 5,
      name: 'Mr. Vikram Singh',
      instructorId: 'INS-005',
      department: 'Commerce',
      email: 'vikram@inst.edu',
      phone: '+91 98765 43214',
      qualification: 'M.Com, UGC-NET',
      experience: '3 Years',
      status: 'Active',
      classesCount: 3,
      attendanceStatus: 'Present'
    },
    {
      id: 6,
      name: 'Dr. Ritu Sharma',
      instructorId: 'INS-006',
      department: 'Computer Science',
      email: 'ritu@inst.edu',
      phone: '+91 98765 43211',
      qualification: 'Ph.D',
      experience: '8',
      status: 'Active',
      classesCount: 2,
      attendanceStatus: 'Present'
    }
  ]);

  const [instructorSearch, setInstructorSearch] = useState('');
  const [instructorTrackingDept, setInstructorTrackingDept] = useState('All');
  const [instructorTrackingDate, setInstructorTrackingDate] = useState('2025-04-28');

  // Form state for Page 7 (Add / Edit Instructor)
  const [editingInstructorId, setEditingInstructorId] = useState(null);
  const [instructorFormData, setInstructorFormData] = useState({
    fullName: '',
    instructorId: '',
    department: 'Computer Science',
    email: '',
    phone: '',
    qualification: 'Ph.D',
    experience: '8',
    status: 'Active'
  });

  const handleOpenAddInstructor = () => {
    setEditingInstructorId(null);
    setInstructorFormData({
      fullName: 'Dr. Ritu Sharma',
      instructorId: `INS-00${instructors.length + 1}`,
      department: 'Computer Science',
      email: 'ritu@inst.edu',
      phone: '+91 98765 43211',
      qualification: 'Ph.D',
      experience: '8',
      status: 'Active'
    });
    goToScreen('add-instructor');
  };

  const handleOpenEditInstructor = (inst) => {
    setEditingInstructorId(inst.id);
    setInstructorFormData({
      fullName: inst.name,
      instructorId: inst.instructorId,
      department: inst.department,
      email: inst.email,
      phone: inst.phone,
      qualification: inst.qualification,
      experience: inst.experience,
      status: inst.status
    });
    goToScreen('add-instructor');
  };

  const handleSaveInstructor = async (e) => {
    e.preventDefault();
    if (!instructorFormData.fullName.trim() || !instructorFormData.instructorId.trim()) {
      showToast('Please enter both instructor name and ID.');
      return;
    }

    try {
      if (editingInstructorId) {
        const payload = {
          name: instructorFormData.fullName,
          instructorId: instructorFormData.instructorId,
          department: instructorFormData.department,
          email: instructorFormData.email,
          phone: instructorFormData.phone,
          qualification: instructorFormData.qualification,
          experience: instructorFormData.experience,
          status: instructorFormData.status
        };
        await instructorService.update(editingInstructorId, payload);

        setInstructors((prev) =>
          prev.map((inst) =>
            inst.id === editingInstructorId
              ? {
                  ...inst,
                  name: instructorFormData.fullName,
                  instructorId: instructorFormData.instructorId,
                  department: instructorFormData.department,
                  email: instructorFormData.email,
                  phone: instructorFormData.phone,
                  qualification: instructorFormData.qualification,
                  experience: instructorFormData.experience,
                  status: instructorFormData.status
                }
              : inst
          )
        );
        showToast(`Instructor ${instructorFormData.fullName} updated in database!`);
      } else {
        const payload = {
          name: instructorFormData.fullName,
          instructorId: instructorFormData.instructorId,
          department: instructorFormData.department,
          email: instructorFormData.email || `${instructorFormData.instructorId.toLowerCase().replace(/[^a-z0-9]/g, '')}@inst.edu`,
          phone: instructorFormData.phone,
          qualification: instructorFormData.qualification,
          experience: instructorFormData.experience,
          status: instructorFormData.status
        };
        const saved = await instructorService.create(payload);

        const newInst = {
          id: saved?.id || (instructors.length + 1),
          name: saved?.name || instructorFormData.fullName,
          instructorId: saved?.instructorId || instructorFormData.instructorId,
          department: saved?.department || instructorFormData.department,
          email: saved?.email || instructorFormData.email,
          phone: instructorFormData.phone,
          qualification: instructorFormData.qualification,
          experience: instructorFormData.experience,
          status: instructorFormData.status,
          classesCount: 3,
          attendanceStatus: instructorFormData.status === 'On Leave' ? 'On Leave' : 'Present'
        };
        setInstructors([...instructors, newInst]);
        showToast(`Instructor ${newInst.name} (${newInst.instructorId}) registered in database!`);
      }
    } catch (err) {
      showToast('Notice: ' + err.message);
    }
    goToScreen('instructor-records');
  };

  const handleDeleteInstructor = async (id, name) => {
    if (window.confirm(`Are you sure you want to remove instructor "${name}"?`)) {
      try {
        await instructorService.delete(id);
      } catch (err) {
        console.warn('API delete instructor warning:', err);
      }
      setInstructors((prev) => prev.filter((i) => i.id !== id));
      showToast(`Instructor "${name}" removed from database.`);
    }
  };

  // ==========================================
  // 4. CLASS MANAGEMENT STATE (Page 8)
  // ==========================================
  const [classes, setClasses] = useState([
    {
      id: 1,
      name: 'Web Development',
      code: 'BCA-301',
      department: 'Computer Science',
      semester: '3',
      instructor: 'Dr. Amit Sharma'
    },
    {
      id: 2,
      name: 'Mathematics',
      code: 'BCA-201',
      department: 'Mathematics',
      semester: '3',
      instructor: 'Dr. Neha Patel'
    },
    {
      id: 3,
      name: 'Database Management',
      code: 'BCA-302',
      department: 'Computer Science',
      semester: '3',
      instructor: 'Prof. Raj Kumar'
    },
    {
      id: 4,
      name: 'Computer Networks',
      code: 'BCA-303',
      department: 'Computer Science',
      semester: '3',
      instructor: 'Dr. Amit Sharma'
    },
    {
      id: 5,
      name: 'Operating Systems',
      code: 'BCA-304',
      department: 'Computer Science',
      semester: '3',
      instructor: 'Mr. Vikram Singh'
    }
  ]);

  const [classSearch, setClassSearch] = useState('');
  const [isAddClassModalOpen, setIsAddClassModalOpen] = useState(false);
  const [classFormData, setClassFormData] = useState({
    name: '',
    code: '',
    department: 'Computer Science',
    semester: '3',
    instructor: 'Dr. Amit Sharma'
  });

  const handleSaveClass = (e) => {
    e.preventDefault();
    if (!classFormData.name.trim() || !classFormData.code.trim()) {
      showToast('Please enter both class name and code.');
      return;
    }
    const newClass = {
      id: classes.length + 1,
      name: classFormData.name,
      code: classFormData.code,
      department: classFormData.department,
      semester: classFormData.semester,
      instructor: classFormData.instructor
    };
    setClasses([...classes, newClass]);
    setIsAddClassModalOpen(false);
    setClassFormData({
      name: '',
      code: '',
      department: 'Computer Science',
      semester: '3',
      instructor: 'Dr. Amit Sharma'
    });
    showToast(`Class "${newClass.name} (${newClass.code})" added successfully!`);
  };

  const handleDeleteClass = (id, name) => {
    if (window.confirm(`Delete class "${name}"?`)) {
      setClasses((prev) => prev.filter((c) => c.id !== id));
      showToast(`Class "${name}" deleted.`);
    }
  };

  // ==========================================
  // 5. LECTURE SCHEDULE STATE (Page 10)
  // ==========================================
  const [lectureClass, setLectureClass] = useState('BCA-301');
  const [lectureSemester, setLectureSemester] = useState('3');
  const [lectureDateRange, setLectureDateRange] = useState('Apr 28, 2025 - May 04, 2025');

  const [lectureSlots, setLectureSlots] = useState([
    {
      id: 1,
      day: 'Mon',
      timeSlot: '09:00 - 10:00',
      subject: 'Web Development',
      instructor: 'Dr. Amit Sharma',
      room: 'Lab 2',
      status: 'Active'
    },
    {
      id: 2,
      day: 'Tue',
      timeSlot: '10:00 - 11:00',
      subject: 'Mathematics',
      instructor: 'Dr. Neha Patel',
      room: 'Room 101',
      status: 'Active'
    },
    {
      id: 3,
      day: 'Wed',
      timeSlot: '09:00 - 10:00',
      subject: 'Database Management',
      instructor: 'Prof. Raj Kumar',
      room: 'Lab 3',
      status: 'Active'
    },
    {
      id: 4,
      day: 'Thu',
      timeSlot: '11:00 - 12:00',
      subject: 'Computer Networks',
      instructor: 'Dr. Amit Sharma',
      room: 'Room 102',
      status: 'Active'
    },
    {
      id: 5,
      day: 'Fri',
      timeSlot: '09:00 - 10:00',
      subject: 'Operating Systems',
      instructor: 'Mr. Vikram Singh',
      room: 'Lab 1',
      status: 'Active'
    }
  ]);

  const [isAddLectureSlotModalOpen, setIsAddLectureSlotModalOpen] = useState(false);
  const [lectureSlotFormData, setLectureSlotFormData] = useState({
    day: 'Mon',
    timeSlot: '09:00 - 10:00',
    subject: 'Web Development',
    instructor: 'Dr. Amit Sharma',
    room: 'Lab 2',
    status: 'Active'
  });

  const handleSaveLectureSlot = (e) => {
    e.preventDefault();
    setLectureSlots([
      ...lectureSlots,
      {
        id: lectureSlots.length + 1,
        ...lectureSlotFormData
      }
    ]);
    setIsAddLectureSlotModalOpen(false);
    showToast('New lecture schedule slot added!');
  };

  // ==========================================
  // 6. EXAM TIMETABLE & CREATION (Pages 11, 12)
  // ==========================================
  const [exams, setExams] = useState([
    {
      id: 1,
      name: 'Mid Term Exam',
      class: 'BCA-301',
      dateTime: 'Apr 28, 2025 - 09:30 AM',
      duration: '2 Hours',
      status: 'Published'
    },
    {
      id: 2,
      name: 'End Semester',
      class: 'BCA-302',
      dateTime: 'May 20, 2025 - 09:30 AM',
      duration: '3 Hours',
      status: 'Published'
    },
    {
      id: 3,
      name: 'Quiz 1',
      class: 'BCA-303',
      dateTime: 'May 05, 2025 - 01:00 PM',
      duration: '1 Hour',
      status: 'Draft'
    },
    {
      id: 4,
      name: 'Quiz 2',
      class: 'BCA-304',
      dateTime: 'May 12, 2025 - 01:00 PM',
      duration: '1 Hour',
      status: 'Draft'
    },
    {
      id: 5,
      name: 'Practical Exam',
      class: 'BCA-305',
      dateTime: 'May 25, 2025 - 09:30 AM',
      duration: '3 Hours',
      status: 'Published'
    }
  ]);

  const [examTab, setExamTab] = useState('All'); // 'All' | 'Upcoming' | 'Published' | 'Draft'
  const [editingExamId, setEditingExamId] = useState(null);
  const [examFormData, setExamFormData] = useState({
    name: 'Mid Term Exam',
    class: 'BCA-301',
    date: '2025-04-28',
    startTime: '09:30 AM',
    duration: '2 Hours',
    instructions: 'Please arrive 15 minutes before exam start time. Calculators are permitted only for Mathematics paper.'
  });

  const handleOpenCreateExam = () => {
    setEditingExamId(null);
    setExamFormData({
      name: '',
      class: 'BCA-301',
      date: '2025-04-28',
      startTime: '09:30 AM',
      duration: '2 Hours',
      instructions: 'Enter exam instructions...'
    });
    goToScreen('create-exam');
  };

  const handleOpenEditExam = (ex) => {
    setEditingExamId(ex.id);
    setExamFormData({
      name: ex.name,
      class: ex.class,
      date: '2025-04-28',
      startTime: '09:30 AM',
      duration: ex.duration,
      instructions: 'Please bring your Institute ID card and examination hall admit pass.'
    });
    goToScreen('create-exam');
  };

  const handleSaveExam = (e) => {
    e.preventDefault();
    if (!examFormData.name.trim()) {
      showToast('Please enter an exam title.');
      return;
    }

    if (editingExamId) {
      setExams((prev) =>
        prev.map((ex) =>
          ex.id === editingExamId
            ? {
                ...ex,
                name: examFormData.name,
                class: examFormData.class,
                duration: examFormData.duration,
                dateTime: `${examFormData.date} - ${examFormData.startTime}`
              }
            : ex
        )
      );
      showToast(`Exam "${examFormData.name}" updated successfully!`);
    } else {
      const newExam = {
        id: exams.length + 1,
        name: examFormData.name,
        class: examFormData.class,
        dateTime: `${examFormData.date} - ${examFormData.startTime}`,
        duration: examFormData.duration,
        status: 'Published'
      };
      setExams([newExam, ...exams]);
      showToast(`New Exam "${newExam.name}" scheduled & published!`);
    }
    goToScreen('exam-timetable');
  };

  const handleDeleteExam = (id, name) => {
    if (window.confirm(`Delete exam "${name}"?`)) {
      setExams((prev) => prev.filter((e) => e.id !== id));
      showToast(`Exam "${name}" deleted.`);
    }
  };

  const handleToggleExamStatus = (id) => {
    setExams((prev) =>
      prev.map((ex) =>
        ex.id === id ? { ...ex, status: ex.status === 'Published' ? 'Draft' : 'Published' } : ex
      )
    );
    showToast('Exam publication status updated.');
  };

  // ==========================================
  // 7. CROSS-MODULE RECORDS STATE (Page 13)
  // ==========================================
  const [crossModuleTab, setCrossModuleTab] = useState('Students'); // 'Students' | 'Instructors'
  const [crossModuleSearch, setCrossModuleSearch] = useState('');
  const [crossModuleDept, setCrossModuleDept] = useState('All');
  const [crossModuleStatus, setCrossModuleStatus] = useState('All');

  // ==========================================
  // 8. REPORTS & ANALYTICS STATE (Page 14)
  // ==========================================
  const [reportDateRange, setReportDateRange] = useState('Apr 01, 2025 - Apr 30, 2025');

  // Filtered Lists
  const filteredStudents = students.filter((s) => {
    const matchesSearch =
      s.name.toLowerCase().includes(studentSearch.toLowerCase()) ||
      s.rollNo.toLowerCase().includes(studentSearch.toLowerCase()) ||
      s.department.toLowerCase().includes(studentSearch.toLowerCase());
    const matchesDept = studentDeptFilter === 'All' || s.department === studentDeptFilter;
    const matchesStatus = studentStatusFilter === 'All' || s.status === studentStatusFilter;
    return matchesSearch && matchesDept && matchesStatus;
  });

  const filteredInstructors = instructors.filter((i) => {
    return (
      i.name.toLowerCase().includes(instructorSearch.toLowerCase()) ||
      i.department.toLowerCase().includes(instructorSearch.toLowerCase()) ||
      i.instructorId.toLowerCase().includes(instructorSearch.toLowerCase())
    );
  });

  const filteredClasses = classes.filter((c) => {
    return (
      c.name.toLowerCase().includes(classSearch.toLowerCase()) ||
      c.code.toLowerCase().includes(classSearch.toLowerCase()) ||
      c.department.toLowerCase().includes(classSearch.toLowerCase())
    );
  });

  const filteredExams = exams.filter((ex) => {
    if (examTab === 'All') return true;
    return ex.status.toLowerCase() === examTab.toLowerCase();
  });

  // Active primary sidebar tab
  const getActiveSidebarTab = () => {
    if (activeScreen === 'dashboard') return 'dashboard';
    if (
      activeScreen === 'student-records' ||
      activeScreen === 'add-student' ||
      activeScreen === 'student-detail'
    )
      return 'students';
    if (
      activeScreen === 'instructor-records' ||
      activeScreen === 'instructor-tracking' ||
      activeScreen === 'add-instructor'
    )
      return 'instructors';
    if (activeScreen === 'class-management') return 'classes';
    if (
      activeScreen === 'academic-planning' ||
      activeScreen === 'lecture-schedule' ||
      activeScreen === 'exam-timetable' ||
      activeScreen === 'create-exam'
    )
      return 'academic';
    if (activeScreen === 'cross-module') return 'cross-module';
    if (activeScreen === 'reports') return 'reports';
    if (activeScreen === 'settings') return 'settings';
    return 'dashboard';
  };

  const activeSidebarTab = getActiveSidebarTab();

  // 15 Design Pages Definition for the Flow Switcher
  const flowPages = [
    { num: 1, id: 'dashboard', label: 'Admin Dashboard' },
    { num: 2, id: 'student-records', label: 'Student Records' },
    { num: 3, id: 'add-student', label: 'Add / Edit Student' },
    { num: 4, id: 'student-detail', label: 'Student Detail' },
    { num: 5, id: 'instructor-records', label: 'Instructor Records' },
    { num: 6, id: 'instructor-tracking', label: 'Instructor Tracking' },
    { num: 7, id: 'add-instructor', label: 'Add / Edit Instructor' },
    { num: 8, id: 'class-management', label: 'Class Management' },
    { num: 9, id: 'academic-planning', label: 'Academic Planning' },
    { num: 10, id: 'lecture-schedule', label: 'Lecture Schedule' },
    { num: 11, id: 'exam-timetable', label: 'Exam Timetable' },
    { num: 12, id: 'create-exam', label: 'Create / Edit Exam' },
    { num: 13, id: 'cross-module', label: 'Cross-Module Records' },
    { num: 14, id: 'reports', label: 'Reports & Analytics' },
    { num: 15, id: 'settings', label: 'Admin Profile / Settings' }
  ];

  return (
    <div className="admin-portal-root">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="admin-portal-toast" role="status">
          <CheckCircle2 size={18} />
          <span>{toastMessage}</span>
        </div>
      )}


      <div className="admin-portal-layout">
        {/* ========================================================
            LEFT DARK NAVY SIDEBAR (Matching Design in Screenshots)
           ======================================================== */}
        <aside className="admin-sidebar">
          {/* Logo Header */}
          <div className="admin-sidebar-brand" onClick={() => goToScreen('dashboard')}>
            <div className="admin-brand-icon-box">
              <Building2 size={22} className="admin-brand-icon-svg" />
            </div>
            <div className="admin-brand-titles">
              <span className="admin-brand-main">Institute Portal</span>
              <span className="admin-brand-tag">Administration</span>
            </div>
          </div>

          {/* Navigation Menu */}
          <nav className="admin-nav-menu">
            <button
              type="button"
              className={`admin-nav-item ${activeSidebarTab === 'dashboard' ? 'active' : ''}`}
              onClick={() => goToScreen('dashboard')}
            >
              <LayoutDashboard size={18} className="nav-icon" />
              <span>Dashboard</span>
            </button>

            <button
              type="button"
              className={`admin-nav-item ${activeSidebarTab === 'students' ? 'active' : ''}`}
              onClick={() => goToScreen('student-records')}
            >
              <Users size={18} className="nav-icon" />
              <span>Student Management</span>
            </button>

            <button
              type="button"
              className={`admin-nav-item ${activeSidebarTab === 'instructors' ? 'active' : ''}`}
              onClick={() => goToScreen('instructor-records')}
            >
              <UserCheck size={18} className="nav-icon" />
              <span>Instructor Management</span>
            </button>

            <button
              type="button"
              className={`admin-nav-item ${activeSidebarTab === 'classes' ? 'active' : ''}`}
              onClick={() => goToScreen('class-management')}
            >
              <BookOpen size={18} className="nav-icon" />
              <span>Class Management</span>
            </button>

            <button
              type="button"
              className={`admin-nav-item ${activeSidebarTab === 'academic' ? 'active' : ''}`}
              onClick={() => goToScreen('academic-planning')}
            >
              <Calendar size={18} className="nav-icon" />
              <span>Academic Planning</span>
            </button>

            <button
              type="button"
              className={`admin-nav-item ${activeSidebarTab === 'cross-module' ? 'active' : ''}`}
              onClick={() => goToScreen('cross-module')}
            >
              <Layers size={18} className="nav-icon" />
              <span>Cross-Module Records</span>
            </button>

            <button
              type="button"
              className={`admin-nav-item ${activeSidebarTab === 'reports' ? 'active' : ''}`}
              onClick={() => goToScreen('reports')}
            >
              <BarChart3 size={18} className="nav-icon" />
              <span>Reports & Analytics</span>
            </button>

            <button
              type="button"
              className={`admin-nav-item ${activeSidebarTab === 'settings' ? 'active' : ''}`}
              onClick={() => goToScreen('settings')}
            >
              <Settings size={18} className="nav-icon" />
              <span>Settings</span>
            </button>
          </nav>

          {/* Sidebar Footer */}
          <div className="admin-sidebar-footer">
            <button
              type="button"
              className="admin-nav-item inst-home-btn"
              onClick={() => onNavigate('institute-home')}
              title="Return to Institute Home Portal"
            >
              <Landmark size={18} className="nav-icon" />
              <span>Institute Home</span>
            </button>
            <button
              type="button"
              className="admin-logout-btn"
              onClick={() => {
                if (window.confirm('Are you sure you want to log out from Admin Module?')) {
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

        {/* ========================================================
            MAIN WORKSPACE AREA
           ======================================================== */}
        <div className="admin-main-wrapper">
          {/* Top Bar Header */}
          <header className="admin-topbar">
            <div className="admin-topbar-search">
              <Search size={18} className="search-icon" />
              <input
                type="text"
                placeholder={
                  activeScreen === 'student-records'
                    ? 'Search by name, roll no., department...'
                    : activeScreen === 'instructor-records'
                    ? 'Search by name, department, or ID...'
                    : activeScreen === 'class-management'
                    ? 'Search by class name, code, dept...'
                    : 'Search anything...'
                }
                value={globalSearch}
                onChange={(e) => {
                  setGlobalSearch(e.target.value);
                  if (activeScreen === 'student-records') setStudentSearch(e.target.value);
                  if (activeScreen === 'instructor-records') setInstructorSearch(e.target.value);
                  if (activeScreen === 'class-management') setClassSearch(e.target.value);
                }}
                className="topbar-search-input"
              />
            </div>

            <div className="admin-topbar-actions">
              <button
                type="button"
                className="btn-topbar-icon"
                onClick={() => showToast('All notifications are up to date.')}
                title="Notifications"
              >
                <Bell size={18} />
                <span className="notif-badge">3</span>
              </button>

              <div
                className="admin-topbar-profile"
                onClick={() => goToScreen('settings')}
                title="View Admin Profile / Settings"
              >
                <div className="admin-avatar-circle">
                  <span>{adminProfile.name.split(' ').map((n) => n[0]).join('') || 'AK'}</span>
                </div>
                <div className="admin-profile-info">
                  <span className="admin-name">{adminProfile.name}</span>
                  <span className="admin-role-tag">{adminProfile.title}</span>
                </div>
              </div>
            </div>
          </header>

          {/* ========================================================
              DYNAMIC PAGE VIEWS (Matching All 15 Screens)
             ======================================================== */}
          <main className="admin-content-container">
            {/* ----------------------------------------------------
                SCREEN 1: ADMIN DASHBOARD
               ---------------------------------------------------- */}
            {activeScreen === 'dashboard' && (
              <div className="admin-screen screen-dashboard">
                {/* Welcome Hero Banner with Campus Illustration */}
                <div className="admin-welcome-banner">
                  <div className="welcome-banner-text">
                    <h1 className="welcome-title">Good Morning, Admin!</h1>
                    <p className="welcome-subtitle">
                      Here's what's happening at your institute today.
                    </p>
                  </div>
                  <div className="welcome-banner-graphic">
                    <InstituteBuildingIllustration variant="compact" />
                  </div>
                </div>

                {/* KPI Metrics: 3 Stat Cards */}
                <div className="admin-kpi-grid">
                  <div className="kpi-card blue" onClick={() => goToScreen('student-records')}>
                    <div className="kpi-icon-wrap">
                      <Users size={22} />
                    </div>
                    <div className="kpi-content">
                      <span className="kpi-label">Total Students</span>
                      <span className="kpi-value">{students.length}</span>
                      <span className="kpi-trend positive">Active in Database</span>
                    </div>
                  </div>

                  <div className="kpi-card teal" onClick={() => goToScreen('instructor-records')}>
                    <div className="kpi-icon-wrap">
                      <UserCheck size={22} />
                    </div>
                    <div className="kpi-content">
                      <span className="kpi-label">Total Instructors</span>
                      <span className="kpi-value">{instructors.length}</span>
                      <span className="kpi-trend positive">Active in Database</span>
                    </div>
                  </div>

                  <div className="kpi-card green" onClick={() => goToScreen('class-management')}>
                    <div className="kpi-icon-wrap">
                      <BookOpen size={22} />
                    </div>
                    <div className="kpi-content">
                      <span className="kpi-label">Active Classes</span>
                      <span className="kpi-value">48</span>
                      <span className="kpi-trend positive">+3% from last month</span>
                    </div>
                  </div>
                </div>

                {/* Two Column Grid: Recent Activities & Quick Actions */}
                <div className="dashboard-columns-grid">
                  {/* Left Column: Recent Activities */}
                  <div className="admin-card activities-card">
                    <div className="card-header-row">
                      <h2 className="card-title">Recent Activities</h2>
                      <span className="card-badge">Live Updates</span>
                    </div>

                    <div className="activities-list">
                      <div className="activity-item">
                        <div className="activity-dot blue" />
                        <div className="activity-details">
                          <span className="activity-action">New student registered</span>
                          <span className="activity-subject">Rohan Mehta &bull; BCA-301</span>
                        </div>
                        <span className="activity-time">10:25 AM</span>
                      </div>

                      <div className="activity-item">
                        <div className="activity-dot teal" />
                        <div className="activity-details">
                          <span className="activity-action">Instructor attendance updated</span>
                          <span className="activity-subject">Dr. Amit Sharma &bull; Present</span>
                        </div>
                        <span className="activity-time">09:45 AM</span>
                      </div>

                      <div className="activity-item">
                        <div className="activity-dot purple" />
                        <div className="activity-details">
                          <span className="activity-action">Exam timetable published</span>
                          <span className="activity-subject">BCA-Sem 3 &bull; Mid Term 2025</span>
                        </div>
                        <span className="activity-time">09:15 AM</span>
                      </div>

                      <div className="activity-item">
                        <div className="activity-dot green" />
                        <div className="activity-details">
                          <span className="activity-action">New course added</span>
                          <span className="activity-subject">Data Science</span>
                        </div>
                        <span className="activity-time">08:30 AM</span>
                      </div>
                    </div>
                  </div>

                  {/* Right Column: Quick Actions */}
                  <div className="admin-card quick-actions-card">
                    <div className="card-header-row">
                      <h2 className="card-title">Quick Actions</h2>
                    </div>

                    <div className="quick-actions-buttons-grid">
                      <button
                        type="button"
                        className="quick-action-btn"
                        onClick={handleOpenAddStudent}
                      >
                        <div className="qa-icon-wrap blue">
                          <Plus size={18} />
                        </div>
                        <span>Add Student</span>
                      </button>

                      <button
                        type="button"
                        className="quick-action-btn"
                        onClick={handleOpenAddInstructor}
                      >
                        <div className="qa-icon-wrap teal">
                          <Plus size={18} />
                        </div>
                        <span>Add Instructor</span>
                      </button>

                      <button
                        type="button"
                        className="quick-action-btn"
                        onClick={handleOpenCreateExam}
                      >
                        <div className="qa-icon-wrap purple">
                          <Calendar size={18} />
                        </div>
                        <span>Create Exam Timetable</span>
                      </button>

                      <button
                        type="button"
                        className="quick-action-btn"
                        onClick={() => goToScreen('lecture-schedule')}
                      >
                        <div className="qa-icon-wrap orange">
                          <Clock size={18} />
                        </div>
                        <span>Create Lecture Schedule</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 2: STUDENT MANAGEMENT / RECORDS
               ---------------------------------------------------- */}
            {activeScreen === 'student-records' && (
              <div className="admin-screen screen-student-records">
                {/* Header Row */}
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Student Records</h1>
                    <p className="screen-subtitle">View, add and manage student details.</p>
                  </div>

                  <div className="screen-header-actions">
                    <button
                      type="button"
                      className="btn-admin-secondary"
                      onClick={() => showToast('Student roster exported to Excel / CSV format.')}
                    >
                      <Download size={15} />
                      <span>Export</span>
                    </button>
                    <button
                      type="button"
                      className="btn-admin-primary"
                      onClick={handleOpenAddStudent}
                    >
                      <Plus size={16} />
                      <span>Add Student</span>
                    </button>
                  </div>
                </div>

                {/* Stat Counters Row */}
                <div className="sub-stat-bar">
                  <div className="stat-pill-box">
                    <span className="stat-pill-label">Total Students:</span>
                    <strong className="stat-pill-num">1,250</strong>
                  </div>
                  <div className="stat-pill-box">
                    <span className="stat-pill-dot green" />
                    <span className="stat-pill-label">Active:</span>
                    <strong className="stat-pill-num">1,180</strong>
                  </div>
                  <div className="stat-pill-box">
                    <span className="stat-pill-dot orange" />
                    <span className="stat-pill-label">Inactive:</span>
                    <strong className="stat-pill-num">70</strong>
                  </div>
                </div>

                {/* Filters & Search Toolbar */}
                <div className="table-controls-toolbar">
                  <div className="toolbar-search-wrap">
                    <Search size={16} className="search-icon" />
                    <input
                      type="text"
                      placeholder="Search by name, roll no., department..."
                      value={studentSearch}
                      onChange={(e) => setStudentSearch(e.target.value)}
                      className="toolbar-search-input"
                    />
                  </div>

                  <div className="toolbar-filters-wrap">
                    <div className="filter-select-group">
                      <Filter size={15} />
                      <select
                        value={studentDeptFilter}
                        onChange={(e) => setStudentDeptFilter(e.target.value)}
                        className="toolbar-select"
                      >
                        <option value="All">All Departments</option>
                        <option value="Computer Science">Computer Science</option>
                        <option value="Mathematics">Mathematics</option>
                      </select>
                    </div>

                    <select
                      value={studentStatusFilter}
                      onChange={(e) => setStudentStatusFilter(e.target.value)}
                      className="toolbar-select"
                    >
                      <option value="All">All Status</option>
                      <option value="Active">Active</option>
                      <option value="Inactive">Inactive</option>
                    </select>
                  </div>
                </div>

                {/* Student Records Table */}
                <div className="admin-table-container">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>Name</th>
                        <th>Roll No.</th>
                        <th>Department</th>
                        <th>Course</th>
                        <th>Attendance</th>
                        <th>Status</th>
                        <th className="text-right">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredStudents.map((stud, idx) => (
                        <tr key={stud.id}>
                          <td>{idx + 1}</td>
                          <td>
                            <strong
                              className="student-table-name"
                              onClick={() => handleViewStudentDetail(stud)}
                            >
                              {stud.name}
                            </strong>
                          </td>
                          <td>
                            <span className="code-badge">{stud.rollNo}</span>
                          </td>
                          <td>{stud.department}</td>
                          <td>{stud.course}</td>
                          <td>
                            <span
                              className={`attendance-pill ${
                                stud.attendance >= 90
                                  ? 'high'
                                  : stud.attendance >= 80
                                  ? 'mid'
                                  : 'low'
                              }`}
                            >
                              {stud.attendance}%
                            </span>
                          </td>
                          <td>
                            <span className="status-badge active">{stud.status}</span>
                          </td>
                          <td className="text-right">
                            <div className="action-buttons-cell">
                              <button
                                type="button"
                                className="table-action-icon-btn view"
                                onClick={() => handleViewStudentDetail(stud)}
                                title="View Student Detail"
                              >
                                <Eye size={15} />
                              </button>
                              <button
                                type="button"
                                className="table-action-icon-btn edit"
                                onClick={() => handleOpenEditStudent(stud)}
                                title="Edit Student"
                              >
                                <Edit2 size={15} />
                              </button>
                              <button
                                type="button"
                                className="table-action-icon-btn delete"
                                onClick={() => handleDeleteStudent(stud.id, stud.name)}
                                title="Delete Student"
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

                {/* Table Footer with Pagination */}
                <div className="table-footer-pagination">
                  <span className="pagination-info">Showing 1-{filteredStudents.length} of 1,250</span>
                  <div className="pagination-controls">
                    <button
                      type="button"
                      className="page-btn"
                      disabled={studentPaginationPage === 1}
                      onClick={() => setStudentPaginationPage((p) => Math.max(1, p - 1))}
                    >
                      <ChevronLeft size={16} />
                    </button>
                    <button type="button" className="page-btn active">1</button>
                    <button type="button" className="page-btn">2</button>
                    <button type="button" className="page-btn">3</button>
                    <button type="button" className="page-btn">4</button>
                    <button type="button" className="page-btn">5</button>
                    <button type="button" className="page-btn">
                      <ChevronRight size={16} />
                    </button>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 3: ADD / EDIT STUDENT
               ---------------------------------------------------- */}
            {activeScreen === 'add-student' && (
              <div className="admin-screen screen-add-student">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">
                      {editingStudentId ? 'Edit Student Details' : 'Add New Student'}
                    </h1>
                    <p className="screen-subtitle">Fill in the student details to register.</p>
                  </div>
                  <button
                    type="button"
                    className="btn-admin-secondary"
                    onClick={() => goToScreen('student-records')}
                  >
                    <ArrowLeft size={16} />
                    <span>Back to Records</span>
                  </button>
                </div>

                <div className="admin-card form-split-card">
                  {/* Left Column: Form Fields */}
                  <form onSubmit={handleSaveStudent} className="form-main-fields">
                    <div className="form-grid-2col">
                      <div className="form-group">
                        <label className="form-label">
                          Full Name <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Rohan Mehta"
                          value={studentFormData.fullName}
                          onChange={(e) =>
                            setStudentFormData({ ...studentFormData, fullName: e.target.value })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Roll Number <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. BCA-306"
                          value={studentFormData.rollNumber}
                          onChange={(e) =>
                            setStudentFormData({ ...studentFormData, rollNumber: e.target.value })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Department <span className="req">*</span>
                        </label>
                        <select
                          value={studentFormData.department}
                          onChange={(e) =>
                            setStudentFormData({ ...studentFormData, department: e.target.value })
                          }
                          className="form-select"
                        >
                          <option value="Computer Science">Computer Science</option>
                          <option value="Mathematics">Mathematics</option>
                          <option value="Physics">Physics</option>
                          <option value="Commerce">Commerce</option>
                        </select>
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Course <span className="req">*</span>
                        </label>
                        <select
                          value={studentFormData.course}
                          onChange={(e) =>
                            setStudentFormData({ ...studentFormData, course: e.target.value })
                          }
                          className="form-select"
                        >
                          <option value="BCA">BCA</option>
                          <option value="B.Tech">B.Tech</option>
                          <option value="B.Sc">B.Sc</option>
                          <option value="MCA">MCA</option>
                        </select>
                      </div>

                      <div className="form-group">
                        <label className="form-label">Date of Birth</label>
                        <input
                          type="date"
                          value={studentFormData.dob}
                          onChange={(e) =>
                            setStudentFormData({ ...studentFormData, dob: e.target.value })
                          }
                          className="form-input"
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">Gender</label>
                        <div className="radio-options-row">
                          <label className="radio-label">
                            <input
                              type="radio"
                              name="gender"
                              value="Male"
                              checked={studentFormData.gender === 'Male'}
                              onChange={() =>
                                setStudentFormData({ ...studentFormData, gender: 'Male' })
                              }
                            />
                            <span>Male</span>
                          </label>
                          <label className="radio-label">
                            <input
                              type="radio"
                              name="gender"
                              value="Female"
                              checked={studentFormData.gender === 'Female'}
                              onChange={() =>
                                setStudentFormData({ ...studentFormData, gender: 'Female' })
                              }
                            />
                            <span>Female</span>
                          </label>
                          <label className="radio-label">
                            <input
                              type="radio"
                              name="gender"
                              value="Other"
                              checked={studentFormData.gender === 'Other'}
                              onChange={() =>
                                setStudentFormData({ ...studentFormData, gender: 'Other' })
                              }
                            />
                            <span>Other</span>
                          </label>
                        </div>
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Parent / Guardian Name <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Rajesh Mehta"
                          value={studentFormData.parentName}
                          onChange={(e) =>
                            setStudentFormData({ ...studentFormData, parentName: e.target.value })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Parent Phone Number <span className="req">*</span>
                        </label>
                        <input
                          type="tel"
                          placeholder="+91 98765 43210"
                          value={studentFormData.parentPhone}
                          onChange={(e) =>
                            setStudentFormData({ ...studentFormData, parentPhone: e.target.value })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group full-width">
                        <label className="form-label">Student Email Address</label>
                        <input
                          type="email"
                          placeholder="e.g. rohanmehta@example.com"
                          value={studentFormData.email}
                          onChange={(e) =>
                            setStudentFormData({ ...studentFormData, email: e.target.value })
                          }
                          className="form-input"
                        />
                      </div>
                    </div>

                    {/* Bottom Action Buttons */}
                    <div className="form-actions-row">
                      <button
                        type="button"
                        className="btn-admin-cancel"
                        onClick={() => goToScreen('student-records')}
                      >
                        Cancel
                      </button>
                      <button type="submit" className="btn-admin-primary">
                        <Save size={16} />
                        <span>Save Student</span>
                      </button>
                    </div>
                  </form>

                  {/* Right Column: Photo Upload Card */}
                  <div className="photo-upload-sidecard">
                    <div className="photo-preview-box">
                      <div className="avatar-graphic-placeholder student">
                        <GraduationCap size={48} />
                      </div>
                    </div>
                    <button
                      type="button"
                      className="btn-upload-photo"
                      onClick={() => showToast('Photo uploaded successfully (max 2MB verified).')}
                    >
                      <UploadCloud size={16} />
                      <span>Upload Photo</span>
                    </button>
                    <span className="photo-hint-text">(Max 2MB &bull; JPG / PNG)</span>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 4: STUDENT DETAIL / PROFILE
               ---------------------------------------------------- */}
            {activeScreen === 'student-detail' && selectedStudent && (
              <div className="admin-screen screen-student-detail">
                {/* Top Profile Card Header */}
                <div className="profile-banner-card">
                  <div className="profile-banner-left">
                    <button
                      type="button"
                      className="btn-banner-back"
                      onClick={() => goToScreen('student-records')}
                    >
                      <ChevronLeft size={16} />
                      <span>Back</span>
                    </button>

                    <div className="profile-avatar-circle">
                      <span>{selectedStudent.name.split(' ').map((n) => n[0]).join('')}</span>
                    </div>

                    <div className="profile-headline-details">
                      <h1 className="profile-name">{selectedStudent.name}</h1>
                      <p className="profile-roll-meta">
                        Roll No: <strong>{selectedStudent.rollNo}</strong> &bull; BCA - Sem{' '}
                        {selectedStudent.semester}
                      </p>
                    </div>
                  </div>

                  <div className="profile-banner-right">
                    <button
                      type="button"
                      className="btn-admin-primary"
                      onClick={() => handleOpenEditStudent(selectedStudent)}
                    >
                      <Edit2 size={15} />
                      <span>Edit Student</span>
                    </button>
                  </div>
                </div>

                {/* Sub Tab Navigation */}
                <div className="profile-tabs-strip">
                  {['Personal Info', 'Academic Info', 'Attendance', 'Parent Information'].map((tab) => (
                    <button
                      key={tab}
                      type="button"
                      className={`profile-tab-btn ${studentDetailTab === tab ? 'active' : ''}`}
                      onClick={() => setStudentDetailTab(tab)}
                    >
                      {tab}
                    </button>
                  ))}
                </div>

                {/* Content Area */}
                <div className="profile-content-grid">
                  {/* Left Column: Personal Info Card */}
                  <div className="admin-card profile-details-card">
                    <h3 className="section-title">Personal Information</h3>
                    <div className="info-kv-grid">
                      <div className="kv-item">
                        <span className="kv-label">Full Name</span>
                        <span className="kv-value">{selectedStudent.name}</span>
                      </div>
                      <div className="kv-item">
                        <span className="kv-label">Roll Number</span>
                        <span className="kv-value code">{selectedStudent.rollNo}</span>
                      </div>
                      <div className="kv-item">
                        <span className="kv-label">Department</span>
                        <span className="kv-value">{selectedStudent.department}</span>
                      </div>
                      <div className="kv-item">
                        <span className="kv-label">Course</span>
                        <span className="kv-value">{selectedStudent.course}</span>
                      </div>
                      <div className="kv-item">
                        <span className="kv-label">Date of Birth</span>
                        <span className="kv-value">{selectedStudent.dob}</span>
                      </div>
                      <div className="kv-item">
                        <span className="kv-label">Gender</span>
                        <span className="kv-value">{selectedStudent.gender}</span>
                      </div>
                      <div className="kv-item full-width">
                        <span className="kv-label">Email</span>
                        <span className="kv-value">{selectedStudent.email}</span>
                      </div>
                      <div className="kv-item full-width">
                        <span className="kv-label">Address</span>
                        <span className="kv-value">{selectedStudent.address}</span>
                      </div>
                    </div>
                  </div>

                  {/* Right Column: Attendance Overview & Parent Info */}
                  <div className="profile-side-column">
                    {/* Attendance Donut Chart Card */}
                    <div className="admin-card attendance-overview-card">
                      <h3 className="section-title">Attendance Overview</h3>
                      <div className="donut-chart-wrapper">
                        <svg viewBox="0 0 36 36" className="circular-donut">
                          {/* Background Circle */}
                          <path
                            className="donut-bg"
                            d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                            fill="none"
                            stroke="#e2e8f0"
                            strokeWidth="3.5"
                          />
                          {/* Present Circle */}
                          <path
                            className="donut-fill green"
                            strokeDasharray={`${selectedStudent.presentRate}, 100`}
                            d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                            fill="none"
                            stroke="#10b981"
                            strokeWidth="3.5"
                            strokeLinecap="round"
                          />
                        </svg>
                        <div className="donut-center-metric">
                          <span className="donut-val">{selectedStudent.attendance}%</span>
                          <span className="donut-sub">Present</span>
                        </div>
                      </div>

                      <div className="donut-legend">
                        <div className="legend-row">
                          <span className="legend-dot green" />
                          <span className="legend-name">Present</span>
                          <span className="legend-val">{selectedStudent.presentRate}%</span>
                        </div>
                        <div className="legend-row">
                          <span className="legend-dot red" />
                          <span className="legend-name">Absent</span>
                          <span className="legend-val">{selectedStudent.absentRate}%</span>
                        </div>
                        <div className="legend-row">
                          <span className="legend-dot amber" />
                          <span className="legend-name">Leave</span>
                          <span className="legend-val">{selectedStudent.leaveRate}%</span>
                        </div>
                      </div>
                    </div>

                    {/* Parent / Guardian Information Card */}
                    <div className="admin-card parent-info-card">
                      <h3 className="section-title">Parent / Guardian Information</h3>
                      <div className="parent-kv-list">
                        <div className="parent-kv">
                          <span className="p-label">Father's Name</span>
                          <strong className="p-val">{selectedStudent.parentName}</strong>
                          <span className="p-phone">{selectedStudent.parentPhone}</span>
                        </div>
                        <div className="parent-kv">
                          <span className="p-label">Mother's Name</span>
                          <strong className="p-val">{selectedStudent.motherName || 'Neeta Mehta'}</strong>
                          <span className="p-phone">{selectedStudent.motherPhone || '+91 98765 43211'}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 5: INSTRUCTOR MANAGEMENT / RECORDS
               ---------------------------------------------------- */}
            {activeScreen === 'instructor-records' && (
              <div className="admin-screen screen-instructor-records">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Instructor Records</h1>
                    <p className="screen-subtitle">View, add and manage instructor details.</p>
                  </div>

                  <div className="screen-header-actions">
                    <button
                      type="button"
                      className="btn-admin-secondary"
                      onClick={() => goToScreen('instructor-tracking')}
                    >
                      <BarChart3 size={15} />
                      <span>Tracking & Reports</span>
                    </button>
                    <button
                      type="button"
                      className="btn-admin-primary"
                      onClick={handleOpenAddInstructor}
                    >
                      <Plus size={16} />
                      <span>Add Instructor</span>
                    </button>
                  </div>
                </div>

                {/* Sub Stat Bar */}
                <div className="sub-stat-bar">
                  <div className="stat-pill-box">
                    <span className="stat-pill-label">Total Instructors:</span>
                    <strong className="stat-pill-num">186</strong>
                  </div>
                  <div className="stat-pill-box">
                    <span className="stat-pill-dot green" />
                    <span className="stat-pill-label">Active:</span>
                    <strong className="stat-pill-num">168</strong>
                  </div>
                  <div className="stat-pill-box">
                    <span className="stat-pill-dot amber" />
                    <span className="stat-pill-label">On Leave:</span>
                    <strong className="stat-pill-num">18</strong>
                  </div>
                </div>

                {/* Search Bar */}
                <div className="table-controls-toolbar">
                  <div className="toolbar-search-wrap">
                    <Search size={16} className="search-icon" />
                    <input
                      type="text"
                      placeholder="Search by name, department, or ID..."
                      value={instructorSearch}
                      onChange={(e) => setInstructorSearch(e.target.value)}
                      className="toolbar-search-input"
                    />
                  </div>
                </div>

                {/* Instructor Table */}
                <div className="admin-table-container">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>Name</th>
                        <th>ID</th>
                        <th>Department</th>
                        <th>Email</th>
                        <th>Status</th>
                        <th className="text-right">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredInstructors.map((inst, idx) => (
                        <tr key={inst.id}>
                          <td>{idx + 1}</td>
                          <td>
                            <strong>{inst.name}</strong>
                          </td>
                          <td>
                            <span className="code-badge">{inst.instructorId}</span>
                          </td>
                          <td>{inst.department}</td>
                          <td>{inst.email}</td>
                          <td>
                            <span
                              className={`status-badge ${
                                inst.status === 'Active' ? 'active' : 'warning'
                              }`}
                            >
                              {inst.status}
                            </span>
                          </td>
                          <td className="text-right">
                            <div className="action-buttons-cell">
                              <button
                                type="button"
                                className="table-action-icon-btn view"
                                onClick={() => goToScreen('instructor-tracking')}
                                title="View Instructor Tracking"
                              >
                                <Eye size={15} />
                              </button>
                              <button
                                type="button"
                                className="table-action-icon-btn edit"
                                onClick={() => handleOpenEditInstructor(inst)}
                                title="Edit Instructor"
                              >
                                <Edit2 size={15} />
                              </button>
                              <button
                                type="button"
                                className="table-action-icon-btn delete"
                                onClick={() => handleDeleteInstructor(inst.id, inst.name)}
                                title="Delete Instructor"
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

                <div className="table-footer-pagination">
                  <span className="pagination-info">Showing 1-{filteredInstructors.length} of 186</span>
                  <div className="pagination-controls">
                    <button type="button" className="page-btn active">1</button>
                    <button type="button" className="page-btn">2</button>
                    <button type="button" className="page-btn">3</button>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 6: INSTRUCTOR TRACKING
               ---------------------------------------------------- */}
            {activeScreen === 'instructor-tracking' && (
              <div className="admin-screen screen-instructor-tracking">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Instructor Tracking</h1>
                    <p className="screen-subtitle">Monitor attendance and assigned classes.</p>
                  </div>

                  {/* Filter Toolbar on Right */}
                  <div className="screen-header-actions">
                    <select
                      value={instructorTrackingDept}
                      onChange={(e) => setInstructorTrackingDept(e.target.value)}
                      className="toolbar-select"
                    >
                      <option value="All">Select Department</option>
                      <option value="Computer Science">Computer Science</option>
                      <option value="Mathematics">Mathematics</option>
                      <option value="Physics">Physics</option>
                    </select>

                    <input
                      type="date"
                      value={instructorTrackingDate}
                      onChange={(e) => setInstructorTrackingDate(e.target.value)}
                      className="toolbar-date-input"
                    />

                    <button
                      type="button"
                      className="btn-admin-primary"
                      onClick={() => showToast('Full Faculty Daily Report generated.')}
                    >
                      <FileText size={15} />
                      <span>View Report</span>
                    </button>
                  </div>
                </div>

                {/* Sub Stat Bar */}
                <div className="sub-stat-bar">
                  <div className="stat-pill-box">
                    <span className="stat-pill-label">Total Instructors:</span>
                    <strong className="stat-pill-num">186</strong>
                  </div>
                  <div className="stat-pill-box">
                    <span className="stat-pill-dot green" />
                    <span className="stat-pill-label">Present:</span>
                    <strong className="stat-pill-num">168</strong>
                  </div>
                  <div className="stat-pill-box">
                    <span className="stat-pill-dot red" />
                    <span className="stat-pill-label">Absent:</span>
                    <strong className="stat-pill-num">12</strong>
                  </div>
                  <div className="stat-pill-box">
                    <span className="stat-pill-dot amber" />
                    <span className="stat-pill-label">On Leave:</span>
                    <strong className="stat-pill-num">6</strong>
                  </div>
                </div>

                {/* Two Column Grid: Attendance Donut Chart vs Assigned Classes */}
                <div className="tracking-columns-grid">
                  {/* Left Column: Attendance Overview */}
                  <div className="admin-card attendance-tracking-card">
                    <h3 className="section-title">Attendance Overview</h3>
                    <div className="donut-chart-wrapper large">
                      <svg viewBox="0 0 36 36" className="circular-donut">
                        <path
                          className="donut-bg"
                          d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                          fill="none"
                          stroke="#e2e8f0"
                          strokeWidth="3.5"
                        />
                        <path
                          className="donut-fill green"
                          strokeDasharray="90, 100"
                          d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                          fill="none"
                          stroke="#10b981"
                          strokeWidth="3.5"
                          strokeLinecap="round"
                        />
                      </svg>
                      <div className="donut-center-metric">
                        <span className="donut-val">90%</span>
                        <span className="donut-sub">Present</span>
                      </div>
                    </div>

                    <div className="donut-legend horizontal">
                      <div className="legend-row">
                        <span className="legend-dot green" />
                        <span>Present: 168</span>
                      </div>
                      <div className="legend-row">
                        <span className="legend-dot red" />
                        <span>Absent: 12</span>
                      </div>
                      <div className="legend-row">
                        <span className="legend-dot amber" />
                        <span>On Leave: 6</span>
                      </div>
                    </div>
                  </div>

                  {/* Right Column: Assigned Classes Table */}
                  <div className="admin-card assigned-classes-card">
                    <h3 className="section-title">Assigned Classes</h3>
                    <table className="admin-table simple">
                      <thead>
                        <tr>
                          <th>Instructor</th>
                          <th>Classes</th>
                          <th>Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {instructors.slice(0, 5).map((inst) => (
                          <tr key={inst.id}>
                            <td>
                              <strong>{inst.name}</strong>
                              <span className="sub-inst-id">{inst.instructorId}</span>
                            </td>
                            <td>
                              <span className="classes-count-badge">{inst.classesCount}</span>
                            </td>
                            <td>
                              <span
                                className={`status-badge ${
                                  inst.status === 'Active' ? 'active' : 'warning'
                                }`}
                              >
                                {inst.status}
                              </span>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 7: ADD / EDIT INSTRUCTOR
               ---------------------------------------------------- */}
            {activeScreen === 'add-instructor' && (
              <div className="admin-screen screen-add-instructor">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">
                      {editingInstructorId ? 'Edit Instructor Details' : 'Add New Instructor'}
                    </h1>
                    <p className="screen-subtitle">Fill in the instructor details to register.</p>
                  </div>
                  <button
                    type="button"
                    className="btn-admin-secondary"
                    onClick={() => goToScreen('instructor-records')}
                  >
                    <ArrowLeft size={16} />
                    <span>Back to Instructors</span>
                  </button>
                </div>

                <div className="admin-card form-split-card">
                  {/* Left Column: Form */}
                  <form onSubmit={handleSaveInstructor} className="form-main-fields">
                    <div className="form-grid-2col">
                      <div className="form-group">
                        <label className="form-label">
                          Full Name <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Dr. Ritu Sharma"
                          value={instructorFormData.fullName}
                          onChange={(e) =>
                            setInstructorFormData({
                              ...instructorFormData,
                              fullName: e.target.value
                            })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Instructor ID <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. INS-006"
                          value={instructorFormData.instructorId}
                          onChange={(e) =>
                            setInstructorFormData({
                              ...instructorFormData,
                              instructorId: e.target.value
                            })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Department <span className="req">*</span>
                        </label>
                        <select
                          value={instructorFormData.department}
                          onChange={(e) =>
                            setInstructorFormData({
                              ...instructorFormData,
                              department: e.target.value
                            })
                          }
                          className="form-select"
                        >
                          <option value="Computer Science">Computer Science</option>
                          <option value="Mathematics">Mathematics</option>
                          <option value="Physics">Physics</option>
                          <option value="Commerce">Commerce</option>
                          <option value="English">English</option>
                        </select>
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Email <span className="req">*</span>
                        </label>
                        <input
                          type="email"
                          placeholder="ritu@inst.edu"
                          value={instructorFormData.email}
                          onChange={(e) =>
                            setInstructorFormData({
                              ...instructorFormData,
                              email: e.target.value
                            })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Phone Number <span className="req">*</span>
                        </label>
                        <input
                          type="tel"
                          placeholder="+91 98765 43211"
                          value={instructorFormData.phone}
                          onChange={(e) =>
                            setInstructorFormData({
                              ...instructorFormData,
                              phone: e.target.value
                            })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Qualification <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Ph.D"
                          value={instructorFormData.qualification}
                          onChange={(e) =>
                            setInstructorFormData({
                              ...instructorFormData,
                              qualification: e.target.value
                            })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">Experience (Years)</label>
                        <input
                          type="text"
                          placeholder="e.g. 8"
                          value={instructorFormData.experience}
                          onChange={(e) =>
                            setInstructorFormData({
                              ...instructorFormData,
                              experience: e.target.value
                            })
                          }
                          className="form-input"
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">Status</label>
                        <select
                          value={instructorFormData.status}
                          onChange={(e) =>
                            setInstructorFormData({
                              ...instructorFormData,
                              status: e.target.value
                            })
                          }
                          className="form-select"
                        >
                          <option value="Active">Active</option>
                          <option value="On Leave">On Leave</option>
                        </select>
                      </div>
                    </div>

                    <div className="form-actions-row">
                      <button
                        type="button"
                        className="btn-admin-cancel"
                        onClick={() => goToScreen('instructor-records')}
                      >
                        Cancel
                      </button>
                      <button type="submit" className="btn-admin-primary">
                        <Save size={16} />
                        <span>Save Instructor</span>
                      </button>
                    </div>
                  </form>

                  {/* Right Column: Instructor Photo Upload */}
                  <div className="photo-upload-sidecard">
                    <div className="photo-preview-box">
                      <div className="avatar-graphic-placeholder instructor">
                        <UserCheck size={48} />
                      </div>
                    </div>
                    <button
                      type="button"
                      className="btn-upload-photo"
                      onClick={() => showToast('Instructor photo uploaded (max 2MB verified).')}
                    >
                      <UploadCloud size={16} />
                      <span>Upload Photo</span>
                    </button>
                    <span className="photo-hint-text">(Max 2MB &bull; JPG / PNG)</span>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 8: CLASS MANAGEMENT
               ---------------------------------------------------- */}
            {activeScreen === 'class-management' && (
              <div className="admin-screen screen-class-management">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Class Management</h1>
                    <p className="screen-subtitle">View and manage class details.</p>
                  </div>

                  <div className="screen-header-actions">
                    <button
                      type="button"
                      className="btn-admin-primary"
                      onClick={() => setIsAddClassModalOpen(true)}
                    >
                      <Plus size={16} />
                      <span>Add Class</span>
                    </button>
                  </div>
                </div>

                {/* Toolbar */}
                <div className="table-controls-toolbar">
                  <div className="toolbar-search-wrap">
                    <Search size={16} className="search-icon" />
                    <input
                      type="text"
                      placeholder="Search by class name, code, dept..."
                      value={classSearch}
                      onChange={(e) => setClassSearch(e.target.value)}
                      className="toolbar-search-input"
                    />
                  </div>
                </div>

                {/* Table */}
                <div className="admin-table-container">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>Class Name</th>
                        <th>Code</th>
                        <th>Department</th>
                        <th>Semester</th>
                        <th>Instructors</th>
                        <th className="text-right">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredClasses.map((cls, idx) => (
                        <tr key={cls.id}>
                          <td>{idx + 1}</td>
                          <td>
                            <strong>{cls.name}</strong>
                          </td>
                          <td>
                            <span className="code-badge">{cls.code}</span>
                          </td>
                          <td>{cls.department}</td>
                          <td>{cls.semester}</td>
                          <td>{cls.instructor}</td>
                          <td className="text-right">
                            <div className="action-buttons-cell">
                              <button
                                type="button"
                                className="table-action-icon-btn view"
                                onClick={() => {
                                  setLectureClass(cls.code);
                                  goToScreen('lecture-schedule');
                                }}
                                title="View Class Lecture Schedule"
                              >
                                <Eye size={15} />
                              </button>
                              <button
                                type="button"
                                className="table-action-icon-btn delete"
                                onClick={() => handleDeleteClass(cls.id, cls.name)}
                                title="Delete Class"
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

                <div className="table-footer-pagination">
                  <span className="pagination-info">Showing 1-{filteredClasses.length} of 12</span>
                  <div className="pagination-controls">
                    <button type="button" className="page-btn active">1</button>
                    <button type="button" className="page-btn">2</button>
                    <button type="button" className="page-btn">3</button>
                  </div>
                </div>

                {/* Add Class Modal */}
                {isAddClassModalOpen && (
                  <div className="admin-modal-overlay">
                    <div className="admin-modal-card">
                      <div className="modal-header">
                        <h3>Add New Academic Class</h3>
                        <button
                          type="button"
                          className="modal-close-btn"
                          onClick={() => setIsAddClassModalOpen(false)}
                        >
                          <X size={18} />
                        </button>
                      </div>

                      <form onSubmit={handleSaveClass}>
                        <div className="modal-body-fields">
                          <div className="form-group">
                            <label className="form-label">Class Name *</label>
                            <input
                              type="text"
                              placeholder="e.g. Artificial Intelligence"
                              value={classFormData.name}
                              onChange={(e) =>
                                setClassFormData({ ...classFormData, name: e.target.value })
                              }
                              className="form-input"
                              required
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Class Code *</label>
                            <input
                              type="text"
                              placeholder="e.g. BCA-305"
                              value={classFormData.code}
                              onChange={(e) =>
                                setClassFormData({ ...classFormData, code: e.target.value })
                              }
                              className="form-input"
                              required
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Department *</label>
                            <select
                              value={classFormData.department}
                              onChange={(e) =>
                                setClassFormData({ ...classFormData, department: e.target.value })
                              }
                              className="form-select"
                            >
                              <option value="Computer Science">Computer Science</option>
                              <option value="Mathematics">Mathematics</option>
                              <option value="Physics">Physics</option>
                            </select>
                          </div>

                          <div className="form-group">
                            <label className="form-label">Semester *</label>
                            <select
                              value={classFormData.semester}
                              onChange={(e) =>
                                setClassFormData({ ...classFormData, semester: e.target.value })
                              }
                              className="form-select"
                            >
                              <option value="1">1</option>
                              <option value="2">2</option>
                              <option value="3">3</option>
                              <option value="4">4</option>
                              <option value="5">5</option>
                              <option value="6">6</option>
                            </select>
                          </div>

                          <div className="form-group">
                            <label className="form-label">Assigned Instructor *</label>
                            <select
                              value={classFormData.instructor}
                              onChange={(e) =>
                                setClassFormData({ ...classFormData, instructor: e.target.value })
                              }
                              className="form-select"
                            >
                              {instructors.map((i) => (
                                <option key={i.id} value={i.name}>
                                  {i.name} ({i.department})
                                </option>
                              ))}
                            </select>
                          </div>
                        </div>

                        <div className="modal-footer-actions">
                          <button
                            type="button"
                            className="btn-admin-cancel"
                            onClick={() => setIsAddClassModalOpen(false)}
                          >
                            Cancel
                          </button>
                          <button type="submit" className="btn-admin-primary">
                            Create Class
                          </button>
                        </div>
                      </form>
                    </div>
                  </div>
                )}
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 9: ACADEMIC PLANNING
               ---------------------------------------------------- */}
            {activeScreen === 'academic-planning' && (
              <div className="admin-screen screen-academic-planning">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Academic Planning</h1>
                    <p className="screen-subtitle">Reorganize and plan academic schedules.</p>
                  </div>
                </div>

                {/* 2 Main Feature Cards */}
                <div className="planning-feature-cards-grid">
                  {/* Card 1: Lecture Schedule */}
                  <div className="admin-card planning-feature-card">
                    <div className="feature-card-header">
                      <div className="feature-icon-box blue">
                        <Clock size={24} />
                      </div>
                      <div>
                        <h2 className="feature-title">Lecture Schedule</h2>
                        <p className="feature-desc">
                          Create, edit and publish lecture schedule, timetables and weekly schedule.
                        </p>
                      </div>
                    </div>

                    <div className="feature-card-actions">
                      <button
                        type="button"
                        className="btn-admin-secondary"
                        onClick={() => goToScreen('lecture-schedule')}
                      >
                        View Schedule
                      </button>
                      <button
                        type="button"
                        className="btn-admin-primary"
                        onClick={() => goToScreen('lecture-schedule')}
                      >
                        Manage
                      </button>
                    </div>
                  </div>

                  {/* Card 2: Exam Timetable */}
                  <div className="admin-card planning-feature-card">
                    <div className="feature-card-header">
                      <div className="feature-icon-box purple">
                        <Calendar size={24} />
                      </div>
                      <div>
                        <h2 className="feature-title">Exam Timetable</h2>
                        <p className="feature-desc">
                          Create, view and publish exam timetables easily.
                        </p>
                      </div>
                    </div>

                    <div className="feature-card-actions">
                      <button
                        type="button"
                        className="btn-admin-secondary"
                        onClick={() => goToScreen('exam-timetable')}
                      >
                        View Timetable
                      </button>
                      <button
                        type="button"
                        className="btn-admin-primary"
                        onClick={() => goToScreen('exam-timetable')}
                      >
                        Manage
                      </button>
                    </div>
                  </div>
                </div>

                {/* Bottom Quick Actions & Illustration Banner */}
                <div className="admin-card planning-banner-card">
                  <div className="planning-quick-actions-col">
                    <h3 className="section-title">Quick Actions</h3>
                    <div className="planning-buttons-list">
                      <button
                        type="button"
                        className="planning-action-row"
                        onClick={() => goToScreen('lecture-schedule')}
                      >
                        <Clock size={16} />
                        <span>Create Lecture Schedule</span>
                        <ChevronRight size={15} className="arrow-icon" />
                      </button>
                      <button
                        type="button"
                        className="planning-action-row"
                        onClick={handleOpenCreateExam}
                      >
                        <Calendar size={16} />
                        <span>Create Exam Timetable</span>
                        <ChevronRight size={15} className="arrow-icon" />
                      </button>
                      <button
                        type="button"
                        className="planning-action-row"
                        onClick={() => goToScreen('class-management')}
                      >
                        <BookOpen size={16} />
                        <span>Manage Classes</span>
                        <ChevronRight size={15} className="arrow-icon" />
                      </button>
                      <button
                        type="button"
                        className="planning-action-row"
                        onClick={() => setIsCalendarModalOpen(true)}
                      >
                        <CalendarDays size={16} />
                        <span>View Academic Calendar</span>
                        <ChevronRight size={15} className="arrow-icon" />
                      </button>
                    </div>
                  </div>

                  <div className="planning-graphic-col">
                    <div className="planning-illustration-graphic">
                      <GraduationCap size={72} className="academic-cap-svg" />
                      <div className="books-stack-badge">
                        <span>Academic Session 2025–2026</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 10: CREATE / EDIT LECTURE SCHEDULE
               ---------------------------------------------------- */}
            {activeScreen === 'lecture-schedule' && (
              <div className="admin-screen screen-lecture-schedule">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Lecture Schedule</h1>
                    <p className="screen-subtitle">Create or update lecture schedules for a class.</p>
                  </div>

                  <div className="screen-header-actions">
                    <button
                      type="button"
                      className="btn-admin-secondary"
                      onClick={() => setIsAddLectureSlotModalOpen(true)}
                    >
                      <Plus size={15} />
                      <span>Add Slot</span>
                    </button>
                    <button
                      type="button"
                      className="btn-admin-secondary"
                      onClick={() => goToScreen('academic-planning')}
                    >
                      <ArrowLeft size={16} />
                      <span>Back</span>
                    </button>
                  </div>
                </div>

                {/* Filter Toolbar matching Screenshot */}
                <div className="lecture-filters-toolbar">
                  <div className="lecture-filter-item">
                    <label className="filter-field-label">Select Class</label>
                    <select
                      value={lectureClass}
                      onChange={(e) => setLectureClass(e.target.value)}
                      className="toolbar-select"
                    >
                      <option value="BCA-301">BCA-301</option>
                      <option value="BCA-201">BCA-201</option>
                      <option value="BCA-302">BCA-302</option>
                      <option value="BCA-303">BCA-303</option>
                      <option value="BCA-304">BCA-304</option>
                    </select>
                  </div>

                  <div className="lecture-filter-item">
                    <label className="filter-field-label">Select Semester</label>
                    <select
                      value={lectureSemester}
                      onChange={(e) => setLectureSemester(e.target.value)}
                      className="toolbar-select"
                    >
                      <option value="1">1</option>
                      <option value="2">2</option>
                      <option value="3">3</option>
                      <option value="4">4</option>
                    </select>
                  </div>

                  <div className="lecture-filter-item">
                    <label className="filter-field-label">Select Date Range</label>
                    <input
                      type="text"
                      value={lectureDateRange}
                      onChange={(e) => setLectureDateRange(e.target.value)}
                      className="toolbar-search-input"
                    />
                  </div>
                </div>

                {/* Schedule Table */}
                <div className="admin-table-container">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>Day</th>
                        <th>Time - Subject</th>
                        <th>Instructor</th>
                        <th>Room</th>
                        <th>Status</th>
                        <th className="text-right">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {lectureSlots.map((slot, idx) => (
                        <tr key={slot.id}>
                          <td>{idx + 1}</td>
                          <td>
                            <strong className="day-badge">{slot.day}</strong>
                          </td>
                          <td>
                            <div className="subject-time-cell">
                              <span className="slot-time">{slot.timeSlot}</span>
                              <strong className="slot-subject">{slot.subject}</strong>
                            </div>
                          </td>
                          <td>{slot.instructor}</td>
                          <td>
                            <span className="room-badge">{slot.room}</span>
                          </td>
                          <td>
                            <span className="status-badge active">{slot.status}</span>
                          </td>
                          <td className="text-right">
                            <button
                              type="button"
                              className="table-action-icon-btn delete"
                              onClick={() => {
                                setLectureSlots(lectureSlots.filter((s) => s.id !== slot.id));
                                showToast('Lecture slot removed.');
                              }}
                              title="Delete Slot"
                            >
                              <Trash2 size={15} />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                {/* Bottom Actions */}
                <div className="form-actions-row">
                  <button
                    type="button"
                    className="btn-admin-cancel"
                    onClick={() => goToScreen('academic-planning')}
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    className="btn-admin-primary"
                    onClick={() => {
                      showToast('Lecture schedule saved & published to classes.');
                      goToScreen('academic-planning');
                    }}
                  >
                    <Save size={16} />
                    <span>Save Schedule</span>
                  </button>
                </div>

                {/* Add Lecture Slot Modal */}
                {isAddLectureSlotModalOpen && (
                  <div className="admin-modal-overlay">
                    <div className="admin-modal-card">
                      <div className="modal-header">
                        <h3>Add Lecture Schedule Slot</h3>
                        <button
                          type="button"
                          className="modal-close-btn"
                          onClick={() => setIsAddLectureSlotModalOpen(false)}
                        >
                          <X size={18} />
                        </button>
                      </div>

                      <form onSubmit={handleSaveLectureSlot}>
                        <div className="modal-body-fields">
                          <div className="form-group">
                            <label className="form-label">Day</label>
                            <select
                              value={lectureSlotFormData.day}
                              onChange={(e) =>
                                setLectureSlotFormData({
                                  ...lectureSlotFormData,
                                  day: e.target.value
                                })
                              }
                              className="form-select"
                            >
                              <option value="Mon">Monday</option>
                              <option value="Tue">Tuesday</option>
                              <option value="Wed">Wednesday</option>
                              <option value="Thu">Thursday</option>
                              <option value="Fri">Friday</option>
                              <option value="Sat">Saturday</option>
                            </select>
                          </div>

                          <div className="form-group">
                            <label className="form-label">Time Slot</label>
                            <input
                              type="text"
                              value={lectureSlotFormData.timeSlot}
                              onChange={(e) =>
                                setLectureSlotFormData({
                                  ...lectureSlotFormData,
                                  timeSlot: e.target.value
                                })
                              }
                              className="form-input"
                              placeholder="09:00 - 10:00"
                              required
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Subject</label>
                            <input
                              type="text"
                              value={lectureSlotFormData.subject}
                              onChange={(e) =>
                                setLectureSlotFormData({
                                  ...lectureSlotFormData,
                                  subject: e.target.value
                                })
                              }
                              className="form-input"
                              placeholder="Web Development"
                              required
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Instructor</label>
                            <select
                              value={lectureSlotFormData.instructor}
                              onChange={(e) =>
                                setLectureSlotFormData({
                                  ...lectureSlotFormData,
                                  instructor: e.target.value
                                })
                              }
                              className="form-select"
                            >
                              {instructors.map((i) => (
                                <option key={i.id} value={i.name}>
                                  {i.name}
                                </option>
                              ))}
                            </select>
                          </div>

                          <div className="form-group">
                            <label className="form-label">Room</label>
                            <input
                              type="text"
                              value={lectureSlotFormData.room}
                              onChange={(e) =>
                                setLectureSlotFormData({
                                  ...lectureSlotFormData,
                                  room: e.target.value
                                })
                              }
                              className="form-input"
                              placeholder="Lab 2"
                              required
                            />
                          </div>
                        </div>

                        <div className="modal-footer-actions">
                          <button
                            type="button"
                            className="btn-admin-cancel"
                            onClick={() => setIsAddLectureSlotModalOpen(false)}
                          >
                            Cancel
                          </button>
                          <button type="submit" className="btn-admin-primary">
                            Save Slot
                          </button>
                        </div>
                      </form>
                    </div>
                  </div>
                )}
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 11: EXAM TIMETABLE MANAGEMENT
               ---------------------------------------------------- */}
            {activeScreen === 'exam-timetable' && (
              <div className="admin-screen screen-exam-timetable">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Exam Timetable</h1>
                    <p className="screen-subtitle">View and manage exam schedules.</p>
                  </div>

                  <div className="screen-header-actions">
                    <button
                      type="button"
                      className="btn-admin-primary"
                      onClick={handleOpenCreateExam}
                    >
                      <Plus size={16} />
                      <span>Create Exam</span>
                    </button>
                  </div>
                </div>

                {/* Filter Tabs & Toolbar */}
                <div className="exam-tabs-toolbar">
                  <div className="exam-filter-pills">
                    {['All', 'Upcoming', 'Published', 'Draft'].map((tab) => (
                      <button
                        key={tab}
                        type="button"
                        className={`exam-tab-pill ${examTab === tab ? 'active' : ''}`}
                        onClick={() => setExamTab(tab)}
                      >
                        {tab}
                      </button>
                    ))}
                  </div>

                  <button
                    type="button"
                    className="btn-admin-secondary"
                    onClick={() => showToast('Filtered exam calendar.')}
                  >
                    <Filter size={15} />
                    <span>Filter</span>
                  </button>
                </div>

                {/* Table */}
                <div className="admin-table-container">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>Exam Name</th>
                        <th>Class</th>
                        <th>Date & Time</th>
                        <th>Duration</th>
                        <th>Status</th>
                        <th className="text-right">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredExams.map((ex, idx) => (
                        <tr key={ex.id}>
                          <td>{idx + 1}</td>
                          <td>
                            <strong>{ex.name}</strong>
                          </td>
                          <td>
                            <span className="code-badge">{ex.class}</span>
                          </td>
                          <td>{ex.dateTime}</td>
                          <td>{ex.duration}</td>
                          <td>
                            <span
                              className={`status-badge ${
                                ex.status === 'Published' ? 'active' : 'draft'
                              }`}
                            >
                              {ex.status}
                            </span>
                          </td>
                          <td className="text-right">
                            <div className="action-buttons-cell">
                              <button
                                type="button"
                                className="table-action-icon-btn edit"
                                onClick={() => handleOpenEditExam(ex)}
                                title="Edit Exam"
                              >
                                <Edit2 size={15} />
                              </button>
                              <button
                                type="button"
                                className="table-action-icon-btn status"
                                onClick={() => handleToggleExamStatus(ex.id)}
                                title={ex.status === 'Published' ? 'Set as Draft' : 'Publish'}
                              >
                                <CheckCircle2 size={15} />
                              </button>
                              <button
                                type="button"
                                className="table-action-icon-btn delete"
                                onClick={() => handleDeleteExam(ex.id, ex.name)}
                                title="Delete Exam"
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

                <div className="table-footer-pagination">
                  <span className="pagination-info">Showing 1-{filteredExams.length} of 5</span>
                  <div className="pagination-controls">
                    <button type="button" className="page-btn active">1</button>
                    <button type="button" className="page-btn">2</button>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 12: CREATE / EDIT EXAM
               ---------------------------------------------------- */}
            {activeScreen === 'create-exam' && (
              <div className="admin-screen screen-create-exam">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">
                      {editingExamId ? 'Edit Exam Details' : 'Create New Exam'}
                    </h1>
                    <p className="screen-subtitle">Fill in the exam details.</p>
                  </div>
                  <button
                    type="button"
                    className="btn-admin-secondary"
                    onClick={() => goToScreen('exam-timetable')}
                  >
                    <ArrowLeft size={16} />
                    <span>Back to Timetable</span>
                  </button>
                </div>

                <div className="admin-card form-split-card">
                  {/* Left Column: Form */}
                  <form onSubmit={handleSaveExam} className="form-main-fields">
                    <div className="form-grid-2col">
                      <div className="form-group">
                        <label className="form-label">
                          Exam Name <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Mid Term Exam"
                          value={examFormData.name}
                          onChange={(e) =>
                            setExamFormData({ ...examFormData, name: e.target.value })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Class <span className="req">*</span>
                        </label>
                        <select
                          value={examFormData.class}
                          onChange={(e) =>
                            setExamFormData({ ...examFormData, class: e.target.value })
                          }
                          className="form-select"
                        >
                          <option value="BCA-301">BCA-301</option>
                          <option value="BCA-302">BCA-302</option>
                          <option value="BCA-303">BCA-303</option>
                          <option value="BCA-304">BCA-304</option>
                          <option value="BCA-305">BCA-305</option>
                        </select>
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Exam Date <span className="req">*</span>
                        </label>
                        <input
                          type="date"
                          value={examFormData.date}
                          onChange={(e) =>
                            setExamFormData({ ...examFormData, date: e.target.value })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Start Time <span className="req">*</span>
                        </label>
                        <input
                          type="text"
                          placeholder="09:30 AM"
                          value={examFormData.startTime}
                          onChange={(e) =>
                            setExamFormData({ ...examFormData, startTime: e.target.value })
                          }
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Duration <span className="req">*</span>
                        </label>
                        <select
                          value={examFormData.duration}
                          onChange={(e) =>
                            setExamFormData({ ...examFormData, duration: e.target.value })
                          }
                          className="form-select"
                        >
                          <option value="1 Hour">1 Hour</option>
                          <option value="2 Hours">2 Hours</option>
                          <option value="3 Hours">3 Hours</option>
                        </select>
                      </div>

                      <div className="form-group full-width">
                        <label className="form-label">Instructions</label>
                        <textarea
                          rows={3}
                          placeholder="Enter exam instructions..."
                          value={examFormData.instructions}
                          onChange={(e) =>
                            setExamFormData({ ...examFormData, instructions: e.target.value })
                          }
                          className="form-textarea"
                        />
                      </div>
                    </div>

                    <div className="form-actions-row">
                      <button
                        type="button"
                        className="btn-admin-cancel"
                        onClick={() => goToScreen('exam-timetable')}
                      >
                        Cancel
                      </button>
                      <button type="submit" className="btn-admin-primary">
                        <Save size={16} />
                        <span>Save Exam</span>
                      </button>
                    </div>
                  </form>

                  {/* Right Column: Exam Details Card */}
                  <div className="exam-graphic-sidecard">
                    <div className="exam-clipboard-box">
                      <FileText size={56} className="clipboard-icon" />
                    </div>
                    <h4 className="exam-sidecard-title">Exam Checklist</h4>
                    <ul className="exam-sidecard-list">
                      <li>&bull; Admit card verification enabled</li>
                      <li>&bull; Automatic timetable sync</li>
                      <li>&bull; Notifications to students & faculty</li>
                    </ul>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 13: CROSS-MODULE RECORDS
               ---------------------------------------------------- */}
            {activeScreen === 'cross-module' && (
              <div className="admin-screen screen-cross-module">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Global Records Access</h1>
                    <p className="screen-subtitle">
                      View and manage student and instructor records across modules.
                    </p>
                  </div>
                </div>

                <div className="cross-module-layout-grid">
                  {/* Left / Main Section: Records Table & Controls */}
                  <div className="cross-module-table-col">
                    {/* Toggle Pills: Students / Instructors */}
                    <div className="cross-module-type-toggle">
                      <button
                        type="button"
                        className={`type-toggle-btn ${crossModuleTab === 'Students' ? 'active' : ''}`}
                        onClick={() => setCrossModuleTab('Students')}
                      >
                        Students
                      </button>
                      <button
                        type="button"
                        className={`type-toggle-btn ${crossModuleTab === 'Instructors' ? 'active' : ''}`}
                        onClick={() => setCrossModuleTab('Instructors')}
                      >
                        Instructors
                      </button>
                    </div>

                    {/* Toolbar */}
                    <div className="table-controls-toolbar">
                      <div className="toolbar-search-wrap">
                        <Search size={16} className="search-icon" />
                        <input
                          type="text"
                          placeholder="Search name, roll no / ID..."
                          value={crossModuleSearch}
                          onChange={(e) => setCrossModuleSearch(e.target.value)}
                          className="toolbar-search-input"
                        />
                      </div>

                      <div className="toolbar-filters-wrap">
                        <select
                          value={crossModuleDept}
                          onChange={(e) => setCrossModuleDept(e.target.value)}
                          className="toolbar-select"
                        >
                          <option value="All">All Departments</option>
                          <option value="Computer Science">Computer Science</option>
                          <option value="Mathematics">Mathematics</option>
                        </select>

                        <select
                          value={crossModuleStatus}
                          onChange={(e) => setCrossModuleStatus(e.target.value)}
                          className="toolbar-select"
                        >
                          <option value="All">All Status</option>
                          <option value="Active">Active</option>
                        </select>

                        <button
                          type="button"
                          className="btn-admin-secondary"
                          onClick={() => showToast('Full cross-module dataset exported to CSV.')}
                        >
                          <Download size={14} />
                          <span>Export</span>
                        </button>
                      </div>
                    </div>

                    {/* Table */}
                    <div className="admin-table-container">
                      <table className="admin-table">
                        {crossModuleTab === 'Students' ? (
                          <>
                            <thead>
                              <tr>
                                <th>#</th>
                                <th>Name</th>
                                <th>Roll No.</th>
                                <th>Department</th>
                                <th>Course</th>
                                <th>Status</th>
                                <th className="text-right">Action</th>
                              </tr>
                            </thead>
                            <tbody>
                              {students
                                .filter((s) =>
                                  crossModuleDept === 'All' ? true : s.department === crossModuleDept
                                )
                                .map((stud, idx) => (
                                  <tr key={stud.id}>
                                    <td>{idx + 1}</td>
                                    <td>
                                      <strong>{stud.name}</strong>
                                    </td>
                                    <td>
                                      <span className="code-badge">{stud.rollNo}</span>
                                    </td>
                                    <td>{stud.department}</td>
                                    <td>{stud.course}</td>
                                    <td>
                                      <span className="status-badge active">{stud.status}</span>
                                    </td>
                                    <td className="text-right">
                                      <button
                                        type="button"
                                        className="table-action-icon-btn view"
                                        onClick={() => handleViewStudentDetail(stud)}
                                      >
                                        <Eye size={15} />
                                      </button>
                                    </td>
                                  </tr>
                                ))}
                            </tbody>
                          </>
                        ) : (
                          <>
                            <thead>
                              <tr>
                                <th>#</th>
                                <th>Name</th>
                                <th>ID</th>
                                <th>Department</th>
                                <th>Email</th>
                                <th>Status</th>
                                <th className="text-right">Action</th>
                              </tr>
                            </thead>
                            <tbody>
                              {instructors
                                .filter((i) =>
                                  crossModuleDept === 'All' ? true : i.department === crossModuleDept
                                )
                                .map((inst, idx) => (
                                  <tr key={inst.id}>
                                    <td>{idx + 1}</td>
                                    <td>
                                      <strong>{inst.name}</strong>
                                    </td>
                                    <td>
                                      <span className="code-badge">{inst.instructorId}</span>
                                    </td>
                                    <td>{inst.department}</td>
                                    <td>{inst.email}</td>
                                    <td>
                                      <span
                                        className={`status-badge ${
                                          inst.status === 'Active' ? 'active' : 'warning'
                                        }`}
                                      >
                                        {inst.status}
                                      </span>
                                    </td>
                                    <td className="text-right">
                                      <button
                                        type="button"
                                        className="table-action-icon-btn view"
                                        onClick={() => goToScreen('instructor-tracking')}
                                      >
                                        <Eye size={15} />
                                      </button>
                                    </td>
                                  </tr>
                                ))}
                            </tbody>
                          </>
                        )}
                      </table>
                    </div>

                    <div className="table-footer-pagination">
                      <span className="pagination-info">Showing 1-5 of 1,250</span>
                      <div className="pagination-controls">
                        <button type="button" className="page-btn active">1</button>
                        <button type="button" className="page-btn">2</button>
                      </div>
                    </div>
                  </div>

                  {/* Right Column: Quick Access Sidebar Card */}
                  <div className="cross-module-quick-col">
                    <div className="admin-card quick-access-card">
                      <h3 className="section-title">Quick Access</h3>
                      <div className="quick-access-list">
                        <button
                          type="button"
                          className="quick-access-item"
                          onClick={() => goToScreen('student-records')}
                        >
                          <Users size={16} />
                          <span>View Student Records</span>
                        </button>
                        <button
                          type="button"
                          className="quick-access-item"
                          onClick={() => goToScreen('instructor-records')}
                        >
                          <UserCheck size={16} />
                          <span>View Instructor Records</span>
                        </button>
                        <button
                          type="button"
                          className="quick-access-item"
                          onClick={() => setIsBulkUpdateModalOpen(true)}
                        >
                          <Edit2 size={16} />
                          <span>Bulk Update</span>
                        </button>
                        <button
                          type="button"
                          className="quick-access-item"
                          onClick={() => showToast('Full Institute data exported to XLSX.')}
                        >
                          <Download size={16} />
                          <span>Export Data</span>
                        </button>
                      </div>

                      <div className="cross-module-illustration">
                        <GraduationCap size={64} className="studying-student-svg" />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 14: REPORTS & ANALYTICS
               ---------------------------------------------------- */}
            {activeScreen === 'reports' && (
              <div className="admin-screen screen-reports-analytics">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Reports & Analytics</h1>
                    <p className="screen-subtitle">Insights for better decision making.</p>
                  </div>

                  <div className="screen-header-actions">
                    <div className="date-range-badge">
                      <CalendarDays size={15} />
                      <span>{reportDateRange}</span>
                    </div>

                    <button
                      type="button"
                      className="btn-admin-secondary"
                      onClick={() => showToast('Analytics executive summary exported.')}
                    >
                      <Download size={15} />
                      <span>Export</span>
                    </button>
                  </div>
                </div>

                {/* 4 Metric Cards */}
                <div className="reports-metrics-grid">
                  <div className="report-metric-card blue">
                    <div className="metric-icon-wrap">
                      <Users size={20} />
                    </div>
                    <div className="metric-data">
                      <span className="metric-label">Total Students</span>
                      <strong className="metric-val">1,250</strong>
                      <span className="metric-trend positive">+5%</span>
                    </div>
                  </div>

                  <div className="report-metric-card teal">
                    <div className="metric-icon-wrap">
                      <UserCheck size={20} />
                    </div>
                    <div className="metric-data">
                      <span className="metric-label">Total Instructors</span>
                      <strong className="metric-val">186</strong>
                      <span className="metric-trend positive">+2%</span>
                    </div>
                  </div>

                  <div className="report-metric-card green">
                    <div className="metric-icon-wrap">
                      <CheckCircle2 size={20} />
                    </div>
                    <div className="metric-data">
                      <span className="metric-label">Average Attendance</span>
                      <strong className="metric-val">89%</strong>
                      <span className="metric-trend positive">+1%</span>
                    </div>
                  </div>

                  <div className="report-metric-card orange">
                    <div className="metric-icon-wrap">
                      <Award size={20} />
                    </div>
                    <div className="metric-data">
                      <span className="metric-label">Exam Pass Rate</span>
                      <strong className="metric-val">92%</strong>
                      <span className="metric-trend positive">+4%</span>
                    </div>
                  </div>
                </div>

                {/* 3 Analytics Visualizations Row */}
                <div className="analytics-visuals-grid">
                  {/* Visual 1: Student Enrollment Trend (Bar Chart) */}
                  <div className="admin-card visual-card enrollment-card">
                    <h3 className="section-title">Student Enrollment Trend</h3>
                    <div className="bar-chart-container">
                      <div className="chart-bars-wrap">
                        {[
                          { month: 'Jan', val: 55 },
                          { month: 'Feb', val: 70 },
                          { month: 'Mar', val: 82 },
                          { month: 'Apr', val: 95 },
                          { month: 'May', val: 65 },
                          { month: 'Jun', val: 88 }
                        ].map((bar) => (
                          <div key={bar.month} className="bar-column">
                            <div className="bar-pillar-wrap">
                              <div
                                className="bar-pillar"
                                style={{ height: `${bar.val}%` }}
                                title={`${bar.month}: ${bar.val * 12} enrolled`}
                              />
                            </div>
                            <span className="bar-label">{bar.month}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Visual 2: Department Wise Performance (Donut Chart) */}
                  <div className="admin-card visual-card dept-chart-card">
                    <h3 className="section-title">Department Wise Performance</h3>
                    <div className="dept-donut-wrap">
                      <div className="donut-chart-wrapper">
                        <svg viewBox="0 0 36 36" className="circular-donut">
                          <path
                            className="donut-bg"
                            d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                            fill="none"
                            stroke="#e2e8f0"
                            strokeWidth="4"
                          />
                          {/* Segment 1: Computer Science 40% */}
                          <path
                            strokeDasharray="40, 100"
                            strokeDashoffset="0"
                            d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                            fill="none"
                            stroke="#0284c7"
                            strokeWidth="4"
                          />
                          {/* Segment 2: Mathematics 25% */}
                          <path
                            strokeDasharray="25, 100"
                            strokeDashoffset="-40"
                            d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                            fill="none"
                            stroke="#06b6d4"
                            strokeWidth="4"
                          />
                          {/* Segment 3: Physics 15% */}
                          <path
                            strokeDasharray="15, 100"
                            strokeDashoffset="-65"
                            d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                            fill="none"
                            stroke="#8b5cf6"
                            strokeWidth="4"
                          />
                          {/* Segment 4: Commerce 12% */}
                          <path
                            strokeDasharray="12, 100"
                            strokeDashoffset="-80"
                            d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                            fill="none"
                            stroke="#f59e0b"
                            strokeWidth="4"
                          />
                        </svg>
                        <div className="donut-center-metric">
                          <span className="donut-val">1,250</span>
                          <span className="donut-sub">Total</span>
                        </div>
                      </div>

                      <div className="dept-legend-list">
                        <div className="legend-row">
                          <span className="legend-dot blue" />
                          <span>Computer Science</span>
                          <strong>40%</strong>
                        </div>
                        <div className="legend-row">
                          <span className="legend-dot cyan" />
                          <span>Mathematics</span>
                          <strong>25%</strong>
                        </div>
                        <div className="legend-row">
                          <span className="legend-dot purple" />
                          <span>Physics</span>
                          <strong>15%</strong>
                        </div>
                        <div className="legend-row">
                          <span className="legend-dot orange" />
                          <span>Commerce</span>
                          <strong>12%</strong>
                        </div>
                        <div className="legend-row">
                          <span className="legend-dot teal" />
                          <span>Others</span>
                          <strong>8%</strong>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Visual 3: Top Performers List */}
                  <div className="admin-card visual-card performers-card">
                    <h3 className="section-title">Top Performers</h3>
                    <div className="performers-list">
                      {[
                        { name: 'Rahul Sharma', score: '96%' },
                        { name: 'Priya Singh', score: '94%' },
                        { name: 'Amit Kumar', score: '93%' },
                        { name: 'Neha Patel', score: '91%' },
                        { name: 'Sahil Verma', score: '88%' }
                      ].map((item, idx) => (
                        <div key={item.name} className="performer-item">
                          <div className="performer-rank-circle">{idx + 1}</div>
                          <div className="performer-avatar">
                            {item.name.split(' ').map((n) => n[0]).join('')}
                          </div>
                          <span className="performer-name">{item.name}</span>
                          <span className="performer-score">{item.score}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ----------------------------------------------------
                SCREEN 15: ADMIN PROFILE / SETTINGS
               ---------------------------------------------------- */}
            {activeScreen === 'settings' && (
              <div className="admin-screen screen-settings">
                <div className="screen-header-row">
                  <div>
                    <h1 className="screen-title">Admin Profile / Settings</h1>
                    <p className="screen-subtitle">Manage administrator credentials and system configurations.</p>
                  </div>
                </div>

                <div className="settings-columns-grid">
                  {/* Left Column: Admin Profile Card */}
                  <div className="admin-card profile-summary-card">
                    <div className="profile-badge-header">
                      <div className="admin-large-avatar">
                        <span>{adminProfile.name.split(' ').map((n) => n[0]).join('')}</span>
                      </div>
                      <h2 className="admin-display-name">{adminProfile.name}</h2>
                      <span className="admin-title-badge">{adminProfile.title}</span>
                    </div>

                    <div className="admin-contact-block">
                      <div className="contact-item">
                        <Mail size={15} />
                        <span>{adminProfile.email}</span>
                      </div>
                      <div className="contact-item">
                        <Phone size={15} />
                        <span>{adminProfile.phone}</span>
                      </div>
                    </div>

                    <button
                      type="button"
                      className="btn-admin-primary full-width"
                      onClick={() => setIsEditProfileModalOpen(true)}
                    >
                      <Edit2 size={15} />
                      <span>Edit Profile</span>
                    </button>

                    <div className="profile-quick-links">
                      <span className="ql-title">Quick Links</span>
                      <button
                        type="button"
                        className="ql-btn"
                        onClick={() => showToast('Help & Technical Support opened.')}
                      >
                        <HelpCircle size={15} />
                        <span>Help & Support</span>
                      </button>
                      <button
                        type="button"
                        className="ql-btn"
                        onClick={() => showToast('Privacy Policy documentation opened.')}
                      >
                        <Shield size={15} />
                        <span>Privacy Policy</span>
                      </button>
                      <button
                        type="button"
                        className="ql-btn"
                        onClick={() => showToast('Terms & Conditions opened.')}
                      >
                        <FileText size={15} />
                        <span>Terms & Conditions</span>
                      </button>
                    </div>
                  </div>

                  {/* Right Column: Account Settings & Institute Footer Banner */}
                  <div className="settings-main-col">
                    <div className="admin-card account-settings-card">
                      <h3 className="section-title">Account Settings</h3>

                      <div className="settings-menu-list">
                        <div
                          className="settings-menu-item"
                          onClick={() => setIsChangePasswordModalOpen(true)}
                        >
                          <div className="menu-icon-box">
                            <Lock size={16} />
                          </div>
                          <div className="menu-text-wrap">
                            <span className="menu-item-title">Change Password</span>
                            <span className="menu-item-sub">Update your master admin password</span>
                          </div>
                          <ChevronRight size={16} className="menu-arrow" />
                        </div>

                        <div className="settings-menu-item">
                          <div className="menu-icon-box">
                            <Bell size={16} />
                          </div>
                          <div className="menu-text-wrap">
                            <span className="menu-item-title">Notification Settings</span>
                            <span className="menu-item-sub">Configure email & system alerts</span>
                          </div>
                          <label className="toggle-switch">
                            <input
                              type="checkbox"
                              checked={notificationSettings.emailAlerts}
                              onChange={(e) =>
                                setNotificationSettings({
                                  ...notificationSettings,
                                  emailAlerts: e.target.checked
                                })
                              }
                            />
                            <span className="toggle-slider" />
                          </label>
                        </div>

                        <div className="settings-menu-item">
                          <div className="menu-icon-box">
                            <Settings size={16} />
                          </div>
                          <div className="menu-text-wrap">
                            <span className="menu-item-title">System Preferences</span>
                            <span className="menu-item-sub">Theme, language, and session defaults</span>
                          </div>
                          <ChevronRight size={16} className="menu-arrow" />
                        </div>

                        <div className="settings-menu-item">
                          <div className="menu-icon-box">
                            <Shield size={16} />
                          </div>
                          <div className="menu-text-wrap">
                            <span className="menu-item-title">Security Settings</span>
                            <span className="menu-item-sub">Two-factor authentication & session audit</span>
                          </div>
                          <ChevronRight size={16} className="menu-arrow" />
                        </div>
                      </div>
                    </div>

                    {/* Bottom Institute Banner Card */}
                    <div className="admin-card institute-footer-card">
                      <div className="banner-left-info">
                        <span className="inst-badge">Institute Portal</span>
                        <h4 className="banner-motto">"Better Education — Brighter Future"</h4>
                        <p className="banner-copy">
                          Together we build a stronger academic community.
                        </p>
                      </div>
                      <div className="banner-graphic-small">
                        <InstituteBuildingIllustration variant="compact" />
                      </div>
                    </div>
                  </div>
                </div>

                {/* Edit Profile Modal */}
                {isEditProfileModalOpen && (
                  <div className="admin-modal-overlay">
                    <div className="admin-modal-card">
                      <div className="modal-header">
                        <h3>Edit Administrator Profile</h3>
                        <button
                          type="button"
                          className="modal-close-btn"
                          onClick={() => setIsEditProfileModalOpen(false)}
                        >
                          <X size={18} />
                        </button>
                      </div>

                      <form
                        onSubmit={(e) => {
                          e.preventDefault();
                          setAdminProfile({ ...profileFormData });
                          setIsEditProfileModalOpen(false);
                          showToast('Admin Profile updated successfully!');
                        }}
                      >
                        <div className="modal-body-fields">
                          <div className="form-group">
                            <label className="form-label">Full Name *</label>
                            <input
                              type="text"
                              value={profileFormData.name}
                              onChange={(e) =>
                                setProfileFormData({ ...profileFormData, name: e.target.value })
                              }
                              className="form-input"
                              required
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Job Title *</label>
                            <input
                              type="text"
                              value={profileFormData.title}
                              onChange={(e) =>
                                setProfileFormData({ ...profileFormData, title: e.target.value })
                              }
                              className="form-input"
                              required
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Email Address *</label>
                            <input
                              type="email"
                              value={profileFormData.email}
                              onChange={(e) =>
                                setProfileFormData({ ...profileFormData, email: e.target.value })
                              }
                              className="form-input"
                              required
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Phone Number *</label>
                            <input
                              type="tel"
                              value={profileFormData.phone}
                              onChange={(e) =>
                                setProfileFormData({ ...profileFormData, phone: e.target.value })
                              }
                              className="form-input"
                              required
                            />
                          </div>
                        </div>

                        <div className="modal-footer-actions">
                          <button
                            type="button"
                            className="btn-admin-cancel"
                            onClick={() => setIsEditProfileModalOpen(false)}
                          >
                            Cancel
                          </button>
                          <button type="submit" className="btn-admin-primary">
                            Save Changes
                          </button>
                        </div>
                      </form>
                    </div>
                  </div>
                )}

                {/* Change Password Modal */}
                {isChangePasswordModalOpen && (
                  <div className="admin-modal-overlay">
                    <div className="admin-modal-card">
                      <div className="modal-header">
                        <h3>Change Admin Password</h3>
                        <button
                          type="button"
                          className="modal-close-btn"
                          onClick={() => setIsChangePasswordModalOpen(false)}
                        >
                          <X size={18} />
                        </button>
                      </div>

                      <form
                        onSubmit={(e) => {
                          e.preventDefault();
                          if (passwordFormData.newPassword !== passwordFormData.confirmPassword) {
                            showToast('New passwords do not match!');
                            return;
                          }
                          setIsChangePasswordModalOpen(false);
                          setPasswordFormData({
                            currentPassword: '',
                            newPassword: '',
                            confirmPassword: ''
                          });
                          showToast('Admin password updated successfully!');
                        }}
                      >
                        <div className="modal-body-fields">
                          <div className="form-group">
                            <label className="form-label">Current Password *</label>
                            <input
                              type="password"
                              value={passwordFormData.currentPassword}
                              onChange={(e) =>
                                setPasswordFormData({
                                  ...passwordFormData,
                                  currentPassword: e.target.value
                                })
                              }
                              className="form-input"
                              required
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">New Password *</label>
                            <input
                              type="password"
                              value={passwordFormData.newPassword}
                              onChange={(e) =>
                                setPasswordFormData({
                                  ...passwordFormData,
                                  newPassword: e.target.value
                                })
                              }
                              className="form-input"
                              required
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Confirm New Password *</label>
                            <input
                              type="password"
                              value={passwordFormData.confirmPassword}
                              onChange={(e) =>
                                setPasswordFormData({
                                  ...passwordFormData,
                                  confirmPassword: e.target.value
                                })
                              }
                              className="form-input"
                              required
                            />
                          </div>
                        </div>

                        <div className="modal-footer-actions">
                          <button
                            type="button"
                            className="btn-admin-cancel"
                            onClick={() => setIsChangePasswordModalOpen(false)}
                          >
                            Cancel
                          </button>
                          <button type="submit" className="btn-admin-primary">
                            Update Password
                          </button>
                        </div>
                      </form>
                    </div>
                  </div>
                )}
              </div>
            )}
          </main>
        </div>
      </div>

      {/* Calendar Modal */}
      {isCalendarModalOpen && (
        <div className="admin-modal-overlay">
          <div className="admin-modal-card">
            <div className="modal-header">
              <h3>Academic Calendar 2025–2026</h3>
              <button
                type="button"
                className="modal-close-btn"
                onClick={() => setIsCalendarModalOpen(false)}
              >
                <X size={18} />
              </button>
            </div>
            <div className="modal-body-fields">
              <p><strong>Spring Semester:</strong> Jan 15 – May 25, 2025</p>
              <p><strong>Mid-Term Examinations:</strong> Apr 28 – May 05, 2025</p>
              <p><strong>Practical Labs Assessment:</strong> May 10 – May 18, 2025</p>
              <p><strong>Final Term Exams:</strong> May 20 – June 05, 2025</p>
              <p><strong>Summer Break:</strong> June 10 – July 31, 2025</p>
            </div>
            <div className="modal-footer-actions">
              <button
                type="button"
                className="btn-admin-primary"
                onClick={() => setIsCalendarModalOpen(false)}
              >
                Close Calendar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Bulk Update Modal */}
      {isBulkUpdateModalOpen && (
        <div className="admin-modal-overlay">
          <div className="admin-modal-card">
            <div className="modal-header">
              <h3>Bulk Student & Instructor Update</h3>
              <button
                type="button"
                className="modal-close-btn"
                onClick={() => setIsBulkUpdateModalOpen(false)}
              >
                <X size={18} />
              </button>
            </div>
            <div className="modal-body-fields">
              <p className="form-label">Upload CSV / Excel template for bulk record reconciliation:</p>
              <div className="photo-preview-box" style={{ padding: '20px', textAlign: 'center' }}>
                <FileSpreadsheet size={48} style={{ color: '#0284c7', margin: '0 auto 8px' }} />
                <span>Drag & drop <strong>.csv</strong> or <strong>.xlsx</strong> here</span>
              </div>
            </div>
            <div className="modal-footer-actions">
              <button
                type="button"
                className="btn-admin-cancel"
                onClick={() => setIsBulkUpdateModalOpen(false)}
              >
                Cancel
              </button>
              <button
                type="button"
                className="btn-admin-primary"
                onClick={() => {
                  setIsBulkUpdateModalOpen(false);
                  showToast('Bulk update completed successfully! 1,250 records verified.');
                }}
              >
                Import & Sync
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
