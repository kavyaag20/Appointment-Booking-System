<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Employee Login</title>
    <style>
        :root {
            --primary-pink: #e83e8c;
            --primary-yellow: #ffc107;
            --light-yellow: #fff9e6;
            --dark-text: #333333;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Arial', sans-serif;
        }
        
        body {
            background-color: var(--light-yellow);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            color: var(--dark-text);
        }
        
        .login-container {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
        }
        
        .login-header {
            text-align: center;
            margin-bottom: 1.5rem;
        }
        
        .login-header h1 {
            color: var(--primary-pink);
            margin-bottom: 0.5rem;
        }
        
        .form-group {
            margin-bottom: 1rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: bold;
        }
        
        .form-group input {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 1rem;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: var(--primary-yellow);
            box-shadow: 0 0 0 2px rgba(255, 193, 7, 0.2);
        }
        
        .error {
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 0.25rem;
            display: none;
        }
        
        .btn-login {
            width: 100%;
            padding: 0.75rem;
            background-color: var(--primary-pink);
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 1rem;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .btn-login:hover {
            background-color: #d62a7b;
        }
        
        .error-message {
            color: #dc3545;
            text-align: center;
            margin-top: 1rem;
            display: none;
        }
        
        .admin-login-link {
            text-align: center;
            margin-top: 1.5rem;
            padding-top: 1rem;
            border-top: 1px solid #eee;
        }
        
        .admin-login-link a {
            color: var(--primary-pink);
            text-decoration: none;
            font-weight: 500;
        }
        
        .admin-login-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>Employee Login</h1>
            <p>Please enter your credentials</p>
        </div>
        
        <form id="loginForm" method="POST">
            <div class="form-group">
                <label for="emp_email">Employee Email</label>
                <input type="email" id="emp_email" name="emp_email" placeholder="Enter your email">
                <div id="emailError" class="error">Email is required</div>
            </div>
            
            <div class="form-group">
                <label for="phone">Phone Number</label>
                <input type="text" id="phone" name="phone" placeholder="Enter your phone number">
                <div id="phoneError" class="error">Phone number is required</div>
            </div>
            
            <div id="loginError" class="error-message">Invalid email or phone number</div>
            
            <button type="submit" class="btn-login">Login</button>
        </form>
        
        <div class="admin-login-link">
            <a href="admLogin.jsp">Admin Login</a>
        </div>
    </div>

    <script>
        function validateForm() {
            let isValid = true;
            const email = document.getElementById('emp_email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            
            // Reset errors
            document.getElementById('emailError').style.display = 'none';
            document.getElementById('phoneError').style.display = 'none';
            document.getElementById('loginError').style.display = 'none';
            
            // Validate email
            if (email === '') {
                document.getElementById('emailError').style.display = 'block';
                isValid = false;
            } else if (!validateEmail(email)) {
                document.getElementById('emailError').textContent = 'Please enter a valid email';
                document.getElementById('emailError').style.display = 'block';
                isValid = false;
            }
            
            // Validate phone
            if (phone === '') {
                document.getElementById('phoneError').style.display = 'block';
                isValid = false;
            }
            
            return isValid;
        }
        
        function validateEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }
        
        // Add real-time validation
        document.getElementById('emp_email').addEventListener('input', function() {
            const email = this.value.trim();
            const errorDiv = document.getElementById('emailError');
            
            if (email !== '') {
                if (validateEmail(email)) {
                    errorDiv.style.display = 'none';
                } else {
                    errorDiv.textContent = 'Please enter a valid email';
                    errorDiv.style.display = 'block';
                }
            } else {
                errorDiv.textContent = 'Email is required';
                errorDiv.style.display = 'none';
            }
        });
        
        document.getElementById('phone').addEventListener('input', function() {
            if (this.value.trim() !== '') {
                document.getElementById('phoneError').style.display = 'none';
            }
        });
        
        // Handle form submission
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            if (validateForm()) {
                this.submit();
            }
        });
    </script>

    <%
    // Database validation when form is submitted
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String empEmail = request.getParameter("emp_email");
        String phone = request.getParameter("phone");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Load JDBC driver
            Class.forName("com.mysql.jdbc.Driver");
            
            // Database connection parameters
            String url = "jdbc:mysql://127.0.0.1:3306/project";
            String dbUser = "root"; // replace with your MySQL username
            String dbPassword = ""; // replace with your MySQL password
            
            // Establish connection
            conn = DriverManager.getConnection(url, dbUser, dbPassword);
            
            // Prepare SQL query - using emp_email and phone for authentication
            String sql = "SELECT * FROM employee_info WHERE emp_email = ? AND phone = ? ";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, empEmail);
            pstmt.setString(2, phone);
            
            // Execute query
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // Login successful - store employee info in session and redirect
                String employeeId = rs.getString("employee_id");
                String fullName = rs.getString("full_name");
                String role = rs.getString("role");
                
                // Store in session
                session.setAttribute("employee_id", employeeId);
                session.setAttribute("employeeName", fullName);
                session.setAttribute("employeeRole", role);
                session.setAttribute("employeeEmail", empEmail);
                session.setAttribute("employeePhone", phone);
                
                // Set session timeout to 1 hour (3600 seconds)
                session.setMaxInactiveInterval(3600);
                
                // Redirect to employee dashboard
                response.sendRedirect("Dashboard.jsp");
            } else {
                // Login failed - show error message
                out.println("<script>document.getElementById('loginError').style.display = 'block';</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>document.getElementById('loginError').style.display = 'block';</script>");
        } finally {
            // Close resources
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    %>
</body>
</html>