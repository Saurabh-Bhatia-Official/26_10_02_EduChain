/**
 * API client for Institute Portal
 * Handles authentication, registration, and role-based workflows
 */

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api';

class ApiService {
  constructor() {
    this.baseUrl = BASE_URL;
  }

  getHeaders(customHeaders = {}) {
    const token = localStorage.getItem('portal_token') || localStorage.getItem('lms_token');
    const headers = {
      'Content-Type': 'application/json',
      ...customHeaders,
    };
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    return headers;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint.startsWith('/') ? endpoint : `/${endpoint}`}`;
    const customHeaders = options.headers || {};
    const config = {
      ...options,
      headers: this.getHeaders(customHeaders),
    };

    try {
      const response = await fetch(url, config);
      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        throw new Error(data.message || `Request failed with status ${response.status}`);
      }

      if (data && data.success === false) {
        throw new Error(data.message || 'Authentication failed. Please check your credentials.');
      }

      return data;
    } catch (error) {
      console.warn(`[API] Backend request failed for ${endpoint}:`, error.message);
      // For real-time database persistence, do not mask POST mutations, register, or auth operations with mock data
      if (options.method === 'POST' || options.method === 'PUT' || options.method === 'DELETE' || endpoint.includes('/auth/')) {
        throw error;
      }
      // For read operations when offline, gracefully use mock demo response
      return this.handleOfflineFallback(endpoint, options, error);
    }
  }

  async handleOfflineFallback(endpoint, options, originalError) {
    const body = JSON.parse(options.body || '{}');

    // Simulate network delay for realistic experience
    await new Promise((r) => setTimeout(r, 600));

    // 1. Institute Login
    if (endpoint.includes('/auth/institute/login') || (endpoint.includes('/auth/login') && body.role === 'institute')) {
      const code = (body.instituteCode || 'INST-2025').toUpperCase();
      return {
        success: true,
        token: 'mock-jwt-institute-' + Date.now(),
        user: {
          id: 'inst_' + code,
          name: 'Institute Administrator',
          email: body.email,
          role: 'institute',
          instituteCode: code,
          instituteName: body.instituteName || (code === 'INST-2025' ? 'Apex Institute of Technology' : `Institute of Advanced Technology (${code})`),
          isVerified: true,
          verificationStatus: 'Officially Verified',
          verificationId: `VRF-${code.replace(/[^A-Z0-9]/g, '')}-2025`,
          verificationDate: 'Academic Session 2025–2026',
          accreditation: 'AICTE & UGC Recognized • Grade A+ NAAC Accredited',
          establishedYear: '2008',
          campusLocation: 'Central Academic Campus',
          studentCount: 1420,
          facultyCount: 86,
          departmentCount: 8,
          activeSemester: 'Academic Year 2025–2026',
        },
        message: 'Institute authenticated successfully.',
      };
    }

    // 2. Role-based Login (Admin, Teacher, Student)
    if (endpoint.includes('/auth/login')) {
      const role = body.role || 'student';
      const roleName = role.charAt(0).toUpperCase() + role.slice(1);
      
      const isStudent = role === 'student';
      const isTeacher = role === 'teacher';
      const userObj = isStudent
        ? {
            id: 'std_1023',
            email: body.email || 'rahul@institute.com',
            role: 'student',
            name: 'Rahul Sharma',
            rollNumber: '1023',
            className: 'BCA - Sem 3',
            course: 'Bachelor of Computer Applications',
            semester: 'Semester 3',
            instituteCode: body.instituteCode || 'INST-2025',
            instituteName: 'Apex Institute of Technology',
            gender: 'Male',
            dob: '12-05-2005',
            fatherName: 'Rakesh Sharma',
            fatherPhone: '+91 98765 43210',
            fatherEmail: 'rakesh@example.com',
            motherName: 'Pooja Sharma',
            motherPhone: '+91 98765 43211',
            motherEmail: 'pooja@example.com',
            address: '123, Green Park, Delhi - 110016',
          }
        : isTeacher
        ? {
            id: 'ins_001',
            email: body.email || 'amit.sharma@institute.com',
            role: 'teacher',
            name: 'Dr. Amit Sharma',
            instructorId: 'INS-001',
            designation: 'Assistant Professor',
            department: 'Computer Science',
            phone: '+91 98765 43210',
            joiningDate: 'Jan 14, 2020',
            qualification: 'Ph.D - Computer Science',
            experience: '5 Years',
            about:
              'Passionate educator with 5+ years of experience in teaching and research. Focused on building strong technical foundations and real-world skills in students.',
            instituteCode: body.instituteCode || 'INST-2025',
            instituteName: 'Apex Institute of Technology',
          }
        : role === 'admin'
        ? {
            id: 'adm_001',
            email: body.email || 'amit.kumar@institute.com',
            role: 'admin',
            name: 'Amit Kumar',
            title: 'System Administrator',
            designation: 'System Administrator',
            phone: '+91 98765 43210',
            instituteCode: body.instituteCode || 'INST-2025',
            instituteName: 'Apex Institute of Technology',
          }
        : {
            id: `usr_${role}_${Date.now().toString().slice(-4)}`,
            email: body.email,
            role: role,
            name: `${roleName} User`,
            instituteCode: body.instituteCode || 'INST-2025',
          };

      return {
        success: true,
        token: `mock-jwt-${role}-${Date.now()}`,
        user: userObj,
        message: `${roleName} signed in successfully.`,
      };
    }

    // 3. Institute Registration
    if (endpoint.includes('/auth/register/institute')) {
      const generatedCode = 'INST-' + Math.floor(1000 + Math.random() * 9000);
      return {
        success: true,
        token: 'mock-jwt-institute-' + Date.now(),
        user: {
          id: 'inst_' + Date.now(),
          instituteName: body.instituteName || 'Apex Institute of Technology',
          instituteType: body.instituteType || 'College',
          name: body.adminName || 'Institute Administrator',
          email: body.adminEmail || body.instituteEmail,
          role: 'institute',
          instituteCode: generatedCode,
          isVerified: true,
          verificationStatus: 'Officially Verified',
          verificationId: `VRF-${generatedCode.replace(/[^A-Z0-9]/g, '')}-2025`,
          verificationDate: 'Academic Session 2025–2026',
          accreditation: 'AICTE & UGC Recognized • Grade A+ NAAC Accredited',
          campusLocation: body.address || 'Academic Campus',
          studentCount: 0,
          facultyCount: 0,
          departmentCount: 1,
        },
        message: 'Institute account registered successfully!',
      };
    }

    // 4. Student Registration
    if (endpoint.includes('/auth/register/student')) {
      return {
        success: true,
        token: 'mock-jwt-student-' + Date.now(),
        user: {
          id: 'std_' + Date.now(),
          name: body.fullName,
          email: body.email,
          role: 'student',
          rollNumber: body.rollNumber,
          course: body.course,
          instituteCode: body.instituteCode,
        },
        message: 'Student registered successfully! Verification pending.',
      };
    }

    // 5. Teacher Registration
    if (endpoint.includes('/auth/register/teacher')) {
      return {
        success: true,
        token: 'mock-jwt-teacher-' + Date.now(),
        user: {
          id: 'tch_' + Date.now(),
          name: body.fullName,
          email: body.email,
          role: 'teacher',
          employeeId: body.employeeId,
          department: body.department,
          instituteCode: body.instituteCode,
        },
        message: 'Teacher registered successfully! Verification pending.',
      };
    }

    // 6. Forgot Password
    if (endpoint.includes('/auth/forgot-password')) {
      return {
        success: true,
        message: `Password reset instructions sent to ${body.email}.`,
      };
    }

    // 7. Students Fallback
    if (endpoint.includes('/students')) {
      if (options.method === 'POST') {
        return { id: Date.now(), ...body, role: 'student', status: 'Active' };
      }
      if (options.method === 'PUT') {
        return { id: endpoint.split('/').pop(), ...body };
      }
      if (options.method === 'DELETE') {
        return { success: true, message: 'Deleted student' };
      }
      return [
        { id: 1, name: 'Rahul Sharma', email: 'rahul.sharma@example.com', rollNumber: 'BCA-301', className: 'BCA - Sem 3', course: 'BCA', department: 'Computer Science', semester: '3', phone: '+91 98765 43210', address: '123 Green Park, Delhi', fatherName: 'Rajesh Sharma', fatherPhone: '+91 98765 43210', status: 'Active' },
        { id: 2, name: 'Priya Singh', email: 'priya.singh@example.com', rollNumber: 'BCA-302', className: 'BCA - Sem 3', course: 'BCA', department: 'Computer Science', semester: '3', phone: '+91 98765 43212', address: '45 Lake View, Delhi', fatherName: 'Manoj Singh', fatherPhone: '+91 98765 43212', status: 'Active' },
        { id: 3, name: 'Amit Kumar', email: 'amit.kumar@example.com', rollNumber: 'BCA-303', className: 'BCA - Sem 3', course: 'BCA', department: 'Computer Science', semester: '3', phone: '+91 98765 43214', address: '78 Sector 15, Delhi', fatherName: 'Suresh Kumar', fatherPhone: '+91 98765 43214', status: 'Active' }
      ];
    }

    // 8. Instructors Fallback
    if (endpoint.includes('/instructors')) {
      if (options.method === 'POST') {
        return { id: Date.now(), ...body, role: 'teacher', status: 'Active' };
      }
      if (options.method === 'PUT') {
        return { id: endpoint.split('/').pop(), ...body };
      }
      if (options.method === 'DELETE') {
        return { success: true, message: 'Deleted instructor' };
      }
      return [
        { id: 1, name: 'Dr. Amit Sharma', email: 'amit.sharma@institute.com', instructorId: 'INS-001', department: 'Computer Science', designation: 'Assistant Professor', phone: '+91 98765 43210', qualification: 'Ph.D - Computer Science', experience: '5 Years', status: 'Active' },
        { id: 2, name: 'Prof. Sunita Rao', email: 'sunita.rao@institute.com', instructorId: 'INS-002', department: 'Mathematics', designation: 'Associate Professor', phone: '+91 98765 43218', qualification: 'M.Sc, M.Phil - Applied Maths', experience: '8 Years', status: 'Active' }
      ];
    }

    // 9. Dashboard Fallback
    if (endpoint.includes('/dashboard/admin')) {
      return {
        totalStudents: 3,
        totalInstructors: 2,
        totalInstitutes: 1,
        activeClasses: 18,
        attendanceRate: 92.4,
        systemStatus: 'Healthy & Connected',
        recentStudents: [],
        recentInstructors: []
      };
    }

    throw originalError;
  }

  get(endpoint, headers = {}) {
    return this.request(endpoint, {
      method: 'GET',
      headers,
    });
  }

  post(endpoint, body = {}, headers = {}) {
    return this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(body),
      headers,
    });
  }

  put(endpoint, body = {}, headers = {}) {
    return this.request(endpoint, {
      method: 'PUT',
      body: JSON.stringify(body),
      headers,
    });
  }

  delete(endpoint, headers = {}) {
    return this.request(endpoint, {
      method: 'DELETE',
      headers,
    });
  }

  // --- Auth Endpoints ---

  async loginInstitute({ instituteCode, email, password }) {
    const res = await this.post('/auth/institute/login', { instituteCode, email, password, role: 'institute' });
    if (res?.token) {
      localStorage.setItem('portal_token', res.token);
      localStorage.setItem('portal_user', JSON.stringify(res.user));
    }
    return res;
  }

  async loginAdmin({ email, password, instituteCode }) {
    const res = await this.post('/auth/admin/login', { email, password, role: 'admin', instituteCode });
    if (res?.token) {
      localStorage.setItem('portal_token', res.token);
      localStorage.setItem('portal_user', JSON.stringify(res.user));
    }
    return res;
  }

  async loginRole({ email, password, role, instituteCode }) {
    if (role === 'admin') {
      return this.loginAdmin({ email, password, instituteCode });
    }
    if (role === 'institute') {
      return this.loginInstitute({ email, password, instituteCode });
    }
    const res = await this.post('/auth/login', { email, password, role, instituteCode });
    if (res?.token) {
      localStorage.setItem('portal_token', res.token);
      localStorage.setItem('portal_user', JSON.stringify(res.user));
    }
    return res;
  }

  async registerInstitute(data) {
    const res = await this.post('/auth/register/institute', data);
    if (res?.token) {
      localStorage.setItem('portal_token', res.token);
      localStorage.setItem('portal_user', JSON.stringify(res.user));
    }
    return res;
  }

  async registerStudent(data) {
    const res = await this.post('/auth/register/student', data);
    if (res?.token) {
      localStorage.setItem('portal_token', res.token);
      localStorage.setItem('portal_user', JSON.stringify(res.user));
    }
    return res;
  }

  async registerTeacher(data) {
    const res = await this.post('/auth/register/teacher', data);
    if (res?.token) {
      localStorage.setItem('portal_token', res.token);
      localStorage.setItem('portal_user', JSON.stringify(res.user));
    }
    return res;
  }

  async forgotPassword({ email, role }) {
    return this.post('/auth/forgot-password', { email, role });
  }

  logout() {
    localStorage.removeItem('portal_token');
    localStorage.removeItem('portal_user');
    localStorage.removeItem('lms_token');
    localStorage.removeItem('lms_user');
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_role');
    try { sessionStorage.clear(); } catch (e) {}
  }

  getCurrentUser() {
    const userStr = localStorage.getItem('portal_user') || localStorage.getItem('lms_user');
    try {
      return userStr ? JSON.parse(userStr) : null;
    } catch {
      return null;
    }
  }
}

export const api = new ApiService();

export const studentService = {
  getAll: (search = '') => api.get(`/students${search ? `?search=${encodeURIComponent(search)}` : ''}`),
  getById: (id) => api.get(`/students/${id}`),
  create: (data) => api.post('/students', data),
  update: (id, data) => api.put(`/students/${id}`, data),
  delete: (id) => api.delete(`/students/${id}`),
};

export const instructorService = {
  getAll: (search = '') => api.get(`/instructors${search ? `?search=${encodeURIComponent(search)}` : ''}`),
  getById: (id) => api.get(`/instructors/${id}`),
  create: (data) => api.post('/instructors', data),
  update: (id, data) => api.put(`/instructors/${id}`, data),
  delete: (id) => api.delete(`/instructors/${id}`),
};

export const dashboardService = {
  getAdminStats: () => api.get('/dashboard/admin'),
  getInstructorStats: (id) => api.get(`/dashboard/instructor/${id}`),
};

export const instituteService = {
  getAll: () => api.get('/db/institutes'),
  getHealth: () => api.get('/db/health'),
  getConsole: () => api.get('/db/console'),
};

export default api;
