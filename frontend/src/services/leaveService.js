/**
 * EduChain Leave Management Service
 * Provides real-time leave request submission, approval/rejection,
 * and synchronized state between Student and Teacher dashboards.
 */

const STORAGE_KEY = 'educhain_leave_requests';
const EVENT_KEY = 'educhain_leave_updated';

const INITIAL_LEAVES = [
  {
    id: 'LEV-2026-101',
    studentName: 'Rahul Sharma',
    studentId: 'STU-1023',
    category: 'Medical Leave',
    startDate: '2026-11-16',
    endDate: '2026-11-18',
    days: '3 Days',
    reason: 'Diagnosed with viral fever. Physician recommended medical rest and medication.',
    status: 'Pending',
    submittedOn: 'Today, 08:30 AM',
  },
  {
    id: 'LEV-2026-102',
    studentName: 'Priya Sundaram',
    studentId: 'STU-1088',
    category: 'Academic Conference',
    startDate: '2026-11-20',
    endDate: '2026-11-22',
    days: '3 Days',
    reason: 'Invited to present student research paper on ML Algorithms at Tech Conclave.',
    status: 'Pending',
    submittedOn: 'Today, 09:15 AM',
  },
  {
    id: 'LEV-2025-081',
    studentName: 'Rahul Sharma',
    studentId: 'STU-1023',
    category: 'Medical Leave',
    startDate: '2025-04-12',
    endDate: '2025-04-14',
    days: '3 Days',
    reason: 'Severe food poisoning and treatment under campus medical officer.',
    status: 'Approved',
    submittedOn: '11 Apr 2025',
    reviewedBy: 'Dr. Neha Verma',
    reviewedOn: '11 Apr 2025',
  },
  {
    id: 'LEV-2025-064',
    studentName: 'Rahul Sharma',
    studentId: 'STU-1023',
    category: 'Official Sports / Cultural',
    startDate: '2025-03-20',
    endDate: '2025-03-21',
    days: '2 Days',
    reason: 'Representing institute football team at Inter-University State Championship.',
    status: 'Approved',
    submittedOn: '18 Mar 2025',
    reviewedBy: 'Dr. Neha Verma',
    reviewedOn: '19 Mar 2025',
  },
  {
    id: 'LEV-2025-055',
    studentName: 'Aarav Patel',
    studentId: 'STU-1045',
    category: 'Personal Leave',
    startDate: '2025-02-05',
    endDate: '2025-02-08',
    days: '4 Days',
    reason: 'Attending cousin wedding ceremony in hometown without prior department permission.',
    status: 'Rejected',
    submittedOn: '04 Feb 2025',
    reviewedBy: 'Dr. Neha Verma',
    reviewedOn: '05 Feb 2025',
  },
];

class LeaveService {
  constructor() {
    this._initStorage();
  }

  _initStorage() {
    if (typeof window === 'undefined') return;
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (!stored) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(INITIAL_LEAVES));
      }
    } catch (e) {
      console.warn('[LeaveService] LocalStorage init failed:', e);
    }
  }

  getLeaves() {
    if (typeof window === 'undefined') return INITIAL_LEAVES;
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      return stored ? JSON.parse(stored) : INITIAL_LEAVES;
    } catch (e) {
      console.warn('[LeaveService] getLeaves parse error:', e);
      return INITIAL_LEAVES;
    }
  }

  getStudentLeaves(studentIdOrName) {
    const list = this.getLeaves();
    if (!studentIdOrName) return list;
    const q = String(studentIdOrName).trim().toLowerCase();
    const filtered = list.filter(
      (l) =>
        (l.studentId && l.studentId.toLowerCase() === q) ||
        (l.studentName && l.studentName.toLowerCase().includes(q))
    );
    return filtered.length > 0 ? filtered : list;
  }

  applyLeave(formData) {
    const list = this.getLeaves();
    const now = new Date();
    const newId = `LEV-${now.getFullYear()}-${100 + list.length + 1}`;

    const newLeave = {
      id: newId,
      studentName: formData.studentName || 'Student',
      studentId: formData.studentId || 'STU-1023',
      category: formData.category || 'Medical Leave',
      startDate: formData.startDate,
      endDate: formData.endDate,
      days: formData.days || '1 Day',
      reason: formData.reason || '',
      status: 'Pending',
      submittedOn: 'Just now',
    };

    const updated = [newLeave, ...list];
    this._saveAndNotify(updated);
    return newLeave;
  }

  updateStatus(leaveId, newStatus, reviewer = 'Dr. Neha Verma') {
    const list = this.getLeaves();
    const updated = list.map((item) => {
      if (item.id === leaveId) {
        return {
          ...item,
          status: newStatus,
          reviewedBy: reviewer,
          reviewedOn: 'Just now',
        };
      }
      return item;
    });

    this._saveAndNotify(updated);
    return updated.find((l) => l.id === leaveId);
  }

  _saveAndNotify(leaves) {
    if (typeof window === 'undefined') return;
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(leaves));
      window.dispatchEvent(new CustomEvent(EVENT_KEY, { detail: leaves }));
    } catch (e) {
      console.warn('[LeaveService] save error:', e);
    }
  }

  subscribe(callback) {
    if (typeof window === 'undefined') return () => {};

    const handleCustom = (e) => {
      callback(e.detail || this.getLeaves());
    };

    const handleStorage = (e) => {
      if (e.key === STORAGE_KEY) {
        callback(this.getLeaves());
      }
    };

    window.addEventListener(EVENT_KEY, handleCustom);
    window.addEventListener('storage', handleStorage);

    // Initial emit
    callback(this.getLeaves());

    return () => {
      window.removeEventListener(EVENT_KEY, handleCustom);
      window.removeEventListener('storage', handleStorage);
    };
  }
}

export const leaveService = new LeaveService();
export default leaveService;
