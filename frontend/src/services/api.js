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
      throw error;
    }
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
