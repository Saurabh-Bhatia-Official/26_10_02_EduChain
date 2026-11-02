// frontend/src/pages/Students.jsx

import { useEffect, useState } from "react";
import { studentService } from "../services/api";

export default function Students() {
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [editingId, setEditingId] = useState(null);

  const [form, setForm] = useState({
    name: "",
    email: "",
    rollNumber: "",
    className: "",
    phone: "",
    address: "",
    fatherName: "",
    fatherPhone: "",
  });

  const loadStudents = async () => {
    try {
      setLoading(true);
      setError("");

      const data = await studentService.getAll();
      setStudents(Array.isArray(data) ? data : data.data || []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadStudents();
  }, []);

  const handleChange = (event) => {
    setForm({
      ...form,
      [event.target.name]: event.target.value,
    });
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    try {
      setError("");

      if (editingId) {
        await studentService.update(editingId, form);
      } else {
        await studentService.create(form);
      }

      setForm({
        name: "",
        email: "",
        rollNumber: "",
        className: "",
        phone: "",
        address: "",
        fatherName: "",
        fatherPhone: "",
      });

      setEditingId(null);
      await loadStudents();
    } catch (err) {
      setError(err.message);
    }
  };

  const handleEdit = (student) => {
    setEditingId(student.id);

    setForm({
      name: student.name || "",
      email: student.email || "",
      rollNumber: student.rollNumber || "",
      className: student.className || "",
      phone: student.phone || "",
      address: student.address || "",
      fatherName: student.fatherName || "",
      fatherPhone: student.fatherPhone || "",
    });
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Delete this student record?")) return;

    try {
      setError("");
      await studentService.delete(id);
      await loadStudents();
    } catch (err) {
      setError(err.message);
    }
  };

  const filteredStudents = students.filter((student) =>
    [
      student.name,
      student.email,
      student.rollNumber,
      student.className,
    ].some((value) =>
      String(value || "")
        .toLowerCase()
        .includes(search.toLowerCase())
    )
  );

  if (loading) return <p>Loading student records...</p>;

  return (
    <div className="students-page">
      <h1>Student Management</h1>

      {error && <p role="alert">{error}</p>}

      <form onSubmit={handleSubmit}>
        <input
          name="name"
          placeholder="Student name"
          value={form.name}
          onChange={handleChange}
          required
        />

        <input
          name="email"
          type="email"
          placeholder="Email"
          value={form.email}
          onChange={handleChange}
          required
        />

        <input
          name="rollNumber"
          placeholder="Roll number"
          value={form.rollNumber}
          onChange={handleChange}
          required
        />

        <input
          name="className"
          placeholder="Class"
          value={form.className}
          onChange={handleChange}
          required
        />

        <input
          name="phone"
          placeholder="Phone number"
          value={form.phone}
          onChange={handleChange}
        />

        <input
          name="address"
          placeholder="Address"
          value={form.address}
          onChange={handleChange}
        />

        <input
          name="fatherName"
          placeholder="Parent/guardian name"
          value={form.fatherName}
          onChange={handleChange}
        />

        <input
          name="fatherPhone"
          placeholder="Parent/guardian phone"
          value={form.fatherPhone}
          onChange={handleChange}
        />

        <button type="submit">
          {editingId ? "Update Student" : "Add Student"}
        </button>

        {editingId && (
          <button
            type="button"
            onClick={() => {
              setEditingId(null);
              setForm({
                name: "",
                email: "",
                rollNumber: "",
                className: "",
                phone: "",
                address: "",
                fatherName: "",
                fatherPhone: "",
              });
            }}
          >
            Cancel
          </button>
        )}
      </form>

      <input
        placeholder="Search students..."
        value={search}
        onChange={(event) => setSearch(event.target.value)}
      />

      <p>Total students: {filteredStudents.length}</p>

      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Roll Number</th>
            <th>Class</th>
            <th>Actions</th>
          </tr>
        </thead>

        <tbody>
          {filteredStudents.map((student) => (
            <tr key={student.id}>
              <td>{student.name}</td>
              <td>{student.email}</td>
              <td>{student.rollNumber}</td>
              <td>{student.className}</td>
              <td>
                <button onClick={() => handleEdit(student)}>
                  Edit
                </button>

                <button onClick={() => handleDelete(student.id)}>
                  Delete
                </button>
              </td>
            </tr>
          ))}

          {filteredStudents.length === 0 && (
            <tr>
              <td colSpan="5">No student records found.</td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}