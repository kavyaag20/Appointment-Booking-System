<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Login</title>
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
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>Admin Login</h1>
            <p>Please enter your credentials</p>
        </div>
        
        <form id="loginForm" method="POST">
            <div class="form-group">
                <label for="admin_id">Admin ID</label>
                <input type="text" id="admin_id" name="admin_id" placeholder="Enter admin ID">
                <div id="adminIdError" class="error">Admin ID is required</div>
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Enter password">
                <div id="passwordError" class="error">Password is required</div>
            </div>
            
            <div id="loginError" class="error-message">Invalid admin ID or password</div>
            
            <button type="submit" class="btn-login">Login</button>
        </form>
    </div>

    <script>
        function validateForm() {
            let isValid = true;
            const adminId = document.getElementById('admin_id').value.trim();
            const password = document.getElementById('password').value.trim();
            
            // Reset errors
            document.getElementById('adminIdError').style.display = 'none';
            document.getElementById('passwordError').style.display = 'none';
            document.getElementById('loginError').style.display = 'none';
            
            // Validate admin ID
            if (adminId === '') {
                document.getElementById('adminIdError').style.display = 'block';
                isValid = false;
            }
            
            // Validate password
            if (password === '') {
                document.getElementById('passwordError').style.display = 'block';
                isValid = false;
            }
            
            return isValid;
        }
        
        // Add real-time validation
        document.getElementById('admin_id').addEventListener('input', function() {
            if (this.value.trim() !== '') {
                document.getElementById('adminIdError').style.display = 'none';
            }
        });
        
        document.getElementById('password').addEventListener('input', function() {
            if (this.value.trim() !== '') {
                document.getElementById('passwordError').style.display = 'none';
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
        String adminId = request.getParameter("admin_id");
        String password = request.getParameter("password");
        
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
            
            // Prepare SQL query
            String sql = "SELECT * FROM admin_info WHERE admin_id = ? AND password = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, adminId);
            pstmt.setString(2, password);
            
            // Execute query
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // Login successful - store admin info in session and redirect
                session.setAttribute("admin_id", adminId);
                
                // Set session timeout to 1 hour (3600 seconds)
                session.setMaxInactiveInterval(3600);
                
                // Redirect to admin dashboard
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