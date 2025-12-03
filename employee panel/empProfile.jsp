<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*, java.sql.*, java.sql.Date" %>
<%@include file="dbconnect.jsp"%>

<%
    // Check if user is logged in
    String employeeName = (String) session.getAttribute("employeeName");
    String employeeId = (String) session.getAttribute("employee_id");
    if (employeeName == null || employeeId == null) {
        response.sendRedirect("empLogin.jsp");
        return;
    }
    
    // Handle form submissions
    String updateType = request.getParameter("updateType");
    String message = "";
    String messageType = "success";
    
    if ("POST".equalsIgnoreCase(request.getMethod()) && updateType != null) {
        try {
            if ("availability".equals(updateType)) {
                // Update availability status
                String isAvailable = request.getParameter("isAvailable");
                String status = "1".equals(isAvailable) ? "Active" : "Inactive";
                
                String updateQuery = "UPDATE employee_info SET employment_status = ? WHERE employee_id = ?";
                PreparedStatement pstmt = conn.prepareStatement(updateQuery);
                pstmt.setString(1, status);
                pstmt.setString(2, employeeId);
                
                int rowsUpdated = pstmt.executeUpdate();
                if (rowsUpdated > 0) {
                    message = "Availability status updated successfully!";
                } else {
                    message = "Failed to update availability status.";
                    messageType = "error";
                }
                pstmt.close();
                
            } else if ("profile".equals(updateType)) {
                // Update personal information
                String fullName = request.getParameter("empName");
                String age = request.getParameter("empAge");
                String phone = request.getParameter("empPhone");
                String email = request.getParameter("empEmail");
                
                String updateQuery = "UPDATE employee_info SET full_name = ?, age = ?, phone = ?, emp_email = ? WHERE employee_id = ?";
                PreparedStatement pstmt = conn.prepareStatement(updateQuery);
                pstmt.setString(1, fullName);
                pstmt.setInt(2, Integer.parseInt(age));
                pstmt.setString(3, phone);
                pstmt.setString(4, email);
                pstmt.setString(5, employeeId);
                
                int rowsUpdated = pstmt.executeUpdate();
                if (rowsUpdated > 0) {
                    session.setAttribute("employeeName", fullName);
                    session.setAttribute("employeeEmail", email);
                    message = "Personal information updated successfully!";
                } else {
                    message = "Failed to update personal information.";
                    messageType = "error";
                }
                pstmt.close();
                
            } else if ("service".equals(updateType)) {
                // Update service information
                String experience = request.getParameter("empExperience");
                
                String updateQuery = "UPDATE employee_info SET experience = ? WHERE employee_id = ?";
                PreparedStatement pstmt = conn.prepareStatement(updateQuery);
                pstmt.setString(1, experience);
                pstmt.setString(2, employeeId);
                
                int rowsUpdated = pstmt.executeUpdate();
                if (rowsUpdated > 0) {
                    message = "Service information updated successfully!";
                } else {
                    message = "Failed to update service information.";
                    messageType = "error";
                }
                pstmt.close();
            }
            
        } catch (Exception e) {
            message = "Error updating information: " + e.getMessage();
            messageType = "error";
            e.printStackTrace();
        }
    }
    
    // Fetch current employee data
    String empName = "";
    String empAge = "";
    String empPhone = "";
    String empEmail = "";
    String empRole = "";
    String empExperience = "";
    String empStatus = "";
    java.sql.Date hireDate = null;
    boolean isAvailable = false;
    
    try {
        // Get employee details
        String empQuery = "SELECT * FROM employee_info WHERE employee_id = ?";
        PreparedStatement empStmt = conn.prepareStatement(empQuery);
        empStmt.setString(1, employeeId);
        ResultSet empRs = empStmt.executeQuery();
        
        if (empRs.next()) {
            empName = empRs.getString("full_name") != null ? empRs.getString("full_name") : "";
            empAge = empRs.getInt("age") != 0 ? String.valueOf(empRs.getInt("age")) : "";
            empPhone = empRs.getString("phone") != null ? empRs.getString("phone") : "";
            empEmail = empRs.getString("emp_email") != null ? empRs.getString("emp_email") : "";
            empRole = empRs.getString("role") != null ? empRs.getString("role") : "";
            empExperience = empRs.getString("experience") != null ? empRs.getString("experience") : "";
            empStatus = empRs.getString("employment_status") != null ? empRs.getString("employment_status") : "Inactive";
            hireDate = empRs.getDate("hire_date");
            isAvailable = "Active".equals(empStatus);
        }
        empRs.close();
        empStmt.close();
        
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading profile data: " + e.getMessage() + "</div>");
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Profile - Pet Care</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary-pink: #e83e8c;
            --primary-yellow: #ffc107;
            --light-yellow: #fff9e6;
            --light-pink: #fdf2f8;
            --dark-text: #2d3748;
            --medium-text: #4a5568;
            --light-text: #718096;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            color: var(--dark-text);
            line-height: 1.6;
            min-height: 100vh;
        }
        
        .main-content {
            padding: 3rem 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .content-section {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .section-title {
            background: linear-gradient(135deg, var(--primary-pink), var(--primary-yellow));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-weight: 700;
            margin-bottom: 3rem;
            font-size: 2.5rem;
            text-align: left;
        }
        
        .profile-section {
            background: linear-gradient(135deg, var(--light-yellow) 0%, var(--light-pink) 100%);
            padding: 2.5rem;
            border-radius: 16px;
            border: 2px solid rgba(232, 62, 140, 0.2);
            margin-bottom: 2.5rem;
            position: relative;
        }
        
        .profile-section h3 {
            color: var(--primary-pink);
            font-weight: 600;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            font-size: 1.5rem;
        }
        
        .profile-section h3 i {
            margin-right: 0.75rem;
            font-size: 1.75rem;
        }
        
        .availability-toggle {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 12px;
            margin-top: 1.5rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        
        .toggle-switch {
            position: relative;
            width: 70px;
            height: 35px;
            background: #cbd5e0;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.4s ease;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .toggle-switch.active {
            background: var(--primary-pink);
        }
        
        .toggle-slider {
            position: absolute;
            top: 3px;
            left: 3px;
            width: 29px;
            height: 29px;
            background: white;
            border-radius: 50%;
            transition: all 0.4s ease;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }
        
        .toggle-switch.active .toggle-slider {
            transform: translateX(35px);
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 1.5rem;
        }
        
        .form-group {
            padding: 1.5rem;
            background: rgba(255, 255, 255, 0.8);
            border-radius: 12px;
            border: 2px solid transparent;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.75rem;
            font-weight: 500;
            color: var(--medium-text);
            font-size: 0.95rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .form-control, .form-select {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 1rem;
            font-size: 1rem;
            background: rgba(255, 255, 255, 0.9);
            width: 100%;
            transition: border-color 0.3s ease;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: var(--primary-pink);
            box-shadow: 0 0 0 4px rgba(232, 62, 140, 0.1);
            outline: none;
        }
        
        .form-control[readonly] {
            background: #f8fafc;
            border-color: #cbd5e0;
            cursor: not-allowed;
        }
        
        .btn {
            border-radius: 12px;
            padding: 1rem 2rem;
            font-weight: 600;
            font-size: 1rem;
            border: none;
            cursor: pointer;
        }
        
        .btn-primary {
            background: var(--primary-pink);
            color: white;
        }
        
        .btn-primary:hover {
            background: #d63384;
        }
        
        .toast-container {
            position: fixed;
            top: 30px;
            right: 30px;
            z-index: 9999;
        }
        
        .toast {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 12px;
            border: none;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }
        
        .availability-status {
            font-weight: 600;
            margin: 0;
            font-size: 1.25rem;
            color: var(--dark-text);
        }
        
        .availability-description {
            margin: 0.5rem 0 0 0;
            color: var(--light-text);
            font-size: 0.95rem;
        }
        
        .text-muted {
            color: var(--light-text) !important;
            font-size: 0.85rem;
            font-style: italic;
        }
        
        @media (max-width: 768px) {
            .main-content {
                padding: 2rem 1rem;
            }
            
            .content-section {
                padding: 2rem;
            }
            
            .section-title {
                font-size: 2rem;
            }
            
            .form-grid {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
            
            .availability-toggle {
                flex-direction: column;
                gap: 1.5rem;
                text-align: center;
            }
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .profile-section {
            animation: fadeInUp 0.6s ease-out;
        }
        
        .profile-section:nth-child(2) { animation-delay: 0.1s; }
        .profile-section:nth-child(3) { animation-delay: 0.2s; }
        .profile-section:nth-child(4) { animation-delay: 0.3s; }
    </style>
</head>
<body>
    <!-- Include header and sidebar -->
    <jsp:include page="Header.jsp" />

    <!-- Toast Container -->
    <div class="toast-container">
        <% if (!message.isEmpty()) { %>
        <div class="toast show" role="alert">
            <div class="toast-header">
                <i class="bi bi-<%= "success".equals(messageType) ? "check-circle-fill text-success" : "exclamation-triangle-fill text-danger" %> me-2"></i>
                <strong class="me-auto"><%= "success".equals(messageType) ? "Success" : "Error" %></strong>
                <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
            </div>
            <div class="toast-body">
                <%= message %>
            </div>
        </div>
        <% } %>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="content-section">
            <h1 class="section-title">Manage Profile</h1>
            
            <!-- Availability Settings -->
            <div class="profile-section">
                <h3>
                    <i class="bi bi-clock-history"></i>
                    Availability Settings
                </h3>
                
                <form method="POST" id="availabilityForm">
                    <input type="hidden" name="updateType" value="availability">
                    <input type="hidden" name="isAvailable" id="availabilityValue" value="<%= isAvailable ? "1" : "0" %>">
                    
                    <div class="availability-toggle">
                        <div>
                            <h5 class="availability-status">Available for New Appointments</h5>
                            <p class="availability-description">Toggle to control whether you receive new appointment requests</p>
                        </div>
                        <div class="toggle-switch <%= isAvailable ? "active" : "" %>" onclick="toggleAvailability(this)">
                            <div class="toggle-slider"></div>
                        </div>
                    </div>
                </form>
            </div>
            
            <!-- Personal Information -->
            <div class="profile-section">
                <h3>
                    <i class="bi bi-person-circle"></i>
                    Personal Information
                </h3>
                
                <form id="profileForm" method="POST">
                    <input type="hidden" name="updateType" value="profile">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="empName">Full Name</label>
                            <input type="text" class="form-control" name="empName" value="<%= empName %>" id="empName" required>
                        </div>
                        <div class="form-group">
                            <label for="empAge">Age</label>
                            <input type="number" class="form-control" name="empAge" value="<%= empAge %>" id="empAge" min="18" max="65" required>
                        </div>
                        <div class="form-group">
                            <label for="empPhone">Phone Number</label>
                            <input type="tel" class="form-control" name="empPhone" value="<%= empPhone %>" id="empPhone" required>
                        </div>
                        <div class="form-group">
                            <label for="empEmail">Email Address</label>
                            <input type="email" class="form-control" name="empEmail" value="<%= empEmail %>" id="empEmail" required>
                        </div>
                    </div>
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-person-check me-2"></i>Update Personal Information
                        </button>
                    </div>
                </form>
            </div>
            
            <!-- Service Information -->
            <div class="profile-section">
                <h3>
                    <i class="bi bi-tools"></i>
                    Service Information
                </h3>
                
                <form id="serviceForm" method="POST">
                    <input type="hidden" name="updateType" value="service">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="empRole">Role/Service Type</label>
                            <input type="text" class="form-control" value="<%= empRole %>" id="empRole" readonly>
                            <small class="text-muted">Role is assigned by admin and cannot be changed</small>
                        </div>
                        <div class="form-group">
                            <label for="empExperience">Years of Experience</label>
                            <select class="form-select" name="empExperience" id="empExperience">
                                <option value="Less than 1 Year" <%= "Less than 1 Year".equals(empExperience) ? "selected" : "" %>>Less than 1 Year</option>
                                <option value="1-2 Years" <%= "1-2 Years".equals(empExperience) ? "selected" : "" %>>1-2 Years</option>
                                <option value="3-5 Years" <%= "3-5 Years".equals(empExperience) ? "selected" : "" %>>3-5 Years</option>
                                <option value="5+ Years" <%= "5+ Years".equals(empExperience) ? "selected" : "" %>>5+ Years</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="hireDate">Hire Date</label>
                            <input type="text" class="form-control" value="<%= hireDate != null ? hireDate.toString() : "Not Set" %>" id="hireDate" readonly>
                            <small class="text-muted">Hire date is set by admin and cannot be changed</small>
                        </div>
                    </div>
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-tools me-2"></i>Update Service Information
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleAvailability(element) {
            element.classList.toggle('active');
            const isActive = element.classList.contains('active');
            document.getElementById('availabilityValue').value = isActive ? '1' : '0';
            
            // Submit the form automatically
            document.getElementById('availabilityForm').submit();
        }
        
        // Auto-hide toast after 5 seconds
        setTimeout(function() {
            const toasts = document.querySelectorAll('.toast');
            toasts.forEach(toast => {
                const bsToast = new bootstrap.Toast(toast);
                bsToast.hide();
            });
        }, 5000);
        
        // Form validation
        document.getElementById('profileForm').addEventListener('submit', function(e) {
            const name = document.getElementById('empName').value.trim();
            const age = document.getElementById('empAge').value;
            const phone = document.getElementById('empPhone').value.trim();
            const email = document.getElementById('empEmail').value.trim();
            
            if (!name || !age || !phone || !email) {
                e.preventDefault();
                alert('Please fill in all required fields.');
                return false;
            }
            
            if (age < 18 || age > 65) {
                e.preventDefault();
                alert('Age must be between 18 and 65.');
                return false;
            }
            
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                e.preventDefault();
                alert('Please enter a valid email address.');
                return false;
            }
            
            const phoneRegex = /^[\+]?[0-9\s\-\(\)]{10,15}$/;
            if (!phoneRegex.test(phone)) {
                e.preventDefault();
                alert('Please enter a valid phone number.');
                return false;
            }
        });
        
        // Add smooth scrolling for better UX
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                document.querySelector(this.getAttribute('href')).scrollIntoView({
                    behavior: 'smooth'
                });
            });
        });
    </script>
</body>
</html>