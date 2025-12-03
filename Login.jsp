<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="dbconnect.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Random" %>

<%!
    // Method to generate random password (keeping this for forgot password feature)
    public String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random random = new Random();
        StringBuilder password = new StringBuilder();
        for (int i = 0; i < 8; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        return password.toString();
    }
%>

<%
    String message = "";
    String messageType = "";
    boolean showForgotForm = false;
    boolean showSuccessMessage = false;
    
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        String action = request.getParameter("action");
        
        if (action != null) {
            if (action.equals("login")) {
                String email = request.getParameter("login-email");
                String password = request.getParameter("login-password");
                
                if (email != null && password != null && !email.trim().isEmpty() && !password.trim().isEmpty()) {
                    // REMOVED HASHING - Direct password comparison
                    pstmt = conn.prepareStatement("SELECT user_id, user_email FROM user_info WHERE user_email = ? AND user_password = ?");
                    pstmt.setString(1, email);
                    pstmt.setString(2, password); // Plain text password
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        session.setAttribute("user_id", rs.getInt("user_id"));
                        session.setAttribute("user_email", rs.getString("user_email"));
                        session.setMaxInactiveInterval(3600);
                        response.sendRedirect("BookYourCare.jsp");
                        return;
                    } else {
                        message = "Invalid email or password!";
                        messageType = "error";
                    }
                } else {
                    message = "Please fill in all fields!";
                    messageType = "error";
                }
            }
            
            else if (action.equals("signup")) {
                String email = request.getParameter("signup-email");
                String password = request.getParameter("signup-password");
                String confirmPassword = request.getParameter("signup-confirm");
                
                if (email != null && password != null && confirmPassword != null && 
                    !email.trim().isEmpty() && !password.trim().isEmpty() && !confirmPassword.trim().isEmpty()) {
                    
                    if (!password.equals(confirmPassword)) {
                        message = "Passwords do not match!";
                        messageType = "error";
                    } else if (password.length() < 6) {
                        message = "Password must be at least 6 characters long!";
                        messageType = "error";
                    } else {
                        pstmt = conn.prepareStatement("SELECT user_email FROM user_info WHERE user_email = ?");
                        pstmt.setString(1, email);
                        rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                            message = "Email already exists! Please use a different email.";
                            messageType = "error";
                        } else {
                            // REMOVED HASHING - Store plain text password
                            pstmt = conn.prepareStatement("INSERT INTO user_info (user_email, user_password) VALUES (?, ?)", Statement.RETURN_GENERATED_KEYS);
                            pstmt.setString(1, email);
                            pstmt.setString(2, password); // Plain text password
                            
                            int rowsAffected = pstmt.executeUpdate();
                            if (rowsAffected > 0) {
                                ResultSet generatedKeys = pstmt.getGeneratedKeys();
                                if (generatedKeys.next()) {
                                    int userId = generatedKeys.getInt(1);
                                    session.setAttribute("user_id", userId);
                                    session.setAttribute("user_email", email);
                                    response.sendRedirect("BookYourCare.jsp");
                                    return;
                                }
                            } else {
                                message = "Registration failed! Please try again.";
                                messageType = "error";
                            }
                        }
                    }
                } else {
                    message = "Please fill in all fields!";
                    messageType = "error";
                }
            }
            
            else if (action.equals("forgot")) {
                String email = request.getParameter("forgot-email");
                
                if (email != null && !email.trim().isEmpty()) {
                    pstmt = conn.prepareStatement("SELECT user_id FROM user_info WHERE user_email = ?");
                    pstmt.setString(1, email);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        String newPassword = generateRandomPassword();
                        // REMOVED HASHING - Store plain text password
                        pstmt = conn.prepareStatement("UPDATE user_info SET user_password = ? WHERE user_email = ?");
                        pstmt.setString(1, newPassword); // Plain text password
                        pstmt.setString(2, email);
                        
                        int rowsUpdated = pstmt.executeUpdate();
                        if (rowsUpdated > 0) {
                            message = "Password reset successful! Your new password is: <strong>" + newPassword + "</strong> (Please note it down and login with this password)";
                            messageType = "success";
                            showSuccessMessage = true;
                        } else {
                            message = "Password reset failed! Please try again.";
                            messageType = "error";
                        }
                    } else {
                        message = "Email not found in our records!";
                        messageType = "error";
                    }
                } else {
                    message = "Please enter your email address!";
                    messageType = "error";
                }
                showForgotForm = true;
            }
        }
        
        String showForgot = request.getParameter("show-forgot");
        if ("true".equals(showForgot)) {
            showForgotForm = true;
        }
        
    } catch (Exception e) {
        message = "Database error: " + e.getMessage();
        messageType = "error";
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Your Care - Login</title>
    <style>
        :root {
            --primary-pink: #e83e8c;
            --primary-yellow: #ffc107;
            --light-yellow: #fff9e6;
            --dark-text: #333333;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background-color: white;
            color: var(--dark-text);
            line-height: 1.6;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background-color: var(--light-yellow);
        }
        
        .login-container {
            width: 100%;
            max-width: 400px;
            padding: 2rem;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            position: relative;
        }
        
        .logo {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .logo h1 {
            color: var(--primary-pink);
            font-size: 2rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .form-toggle {
            display: flex;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid #eee;
        }
        
        .toggle-btn {
            flex: 1;
            padding: 0.8rem;
            text-align: center;
            background: none;
            border: none;
            font-weight: 600;
            font-size: 1.1rem;
            color: var(--dark-text);
            cursor: pointer;
            transition: all 0.3s;
            position: relative;
        }
        
        .toggle-btn.active {
            color: var(--primary-pink);
        }
        
        .toggle-btn.active::after {
            content: '';
            position: absolute;
            bottom: -1px;
            left: 0;
            width: 100%;
            height: 3px;
            background-color: var(--primary-pink);
        }
        
        .form-container {
            display: none;
            animation: fadeIn 0.3s ease-out;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .form-container.active {
            display: block;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 1rem;
            transition: border 0.3s;
            box-sizing: border-box;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--primary-pink);
        }
        
        .forgot-password {
            text-align: right;
            margin-bottom: 1.5rem;
        }
        
        .forgot-password a {
            color: var(--primary-pink);
            text-decoration: none;
            font-size: 0.9rem;
            cursor: pointer;
        }
        
        .forgot-password a:hover {
            text-decoration: underline;
        }
        
        .btn-login {
            width: 100%;
            padding: 0.8rem;
            background-color: var(--primary-pink);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-login:hover {
            background-color: #d62d7b;
            transform: translateY(-2px);
        }
        
        .back-to-login {
            text-align: center;
            margin-top: 1rem;
        }
        
        .back-to-login a {
            color: var(--primary-pink);
            text-decoration: none;
            font-size: 0.9rem;
            cursor: pointer;
        }
        
        .back-to-login a:hover {
            text-decoration: underline;
        }
        
        .message {
            padding: 1rem;
            border-radius: 5px;
            margin-bottom: 1rem;
            text-align: center;
            font-weight: 500;
        }
        
        .message.error {
            background-color: #ffebee;
            color: #c62828;
            border: 1px solid #ef5350;
        }
        
        .message.success {
            background-color: #e8f5e8;
            color: #2e7d32;
            border: 1px solid #4caf50;
        }
        
        .success-message {
            display: none;
            text-align: center;
            padding: 1rem;
            background-color: #f0fff0;
            border-radius: 5px;
            margin-bottom: 1rem;
            color: #2e7d32;
        }
        
        .password-display {
            background-color: #f5f5f5;
            padding: 1rem;
            border-radius: 5px;
            margin-top: 1rem;
            text-align: center;
            border: 2px solid var(--primary-yellow);
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">
            <h1>Book Your Care</h1>
        </div>
        
        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <% if (showForgotForm) { %>
        <!-- Forgot Password Form -->
        <div id="forgot-form" class="form-container active">
            <% if (showSuccessMessage) { %>
                <div class="success-message" style="display: block;">
                    Password has been reset successfully!
                </div>
            <% } %>
            <form method="post">
                <input type="hidden" name="action" value="forgot">
                <div class="form-group">
                    <label for="forgot-email">Email Address</label>
                    <input type="email" id="forgot-email" name="forgot-email" class="form-control" placeholder="Enter your registered email" required>
                </div>
                <button type="submit" class="btn-login">Reset Password</button>
                <div class="back-to-login">
                    <a href="?">← Back to Login</a>
                </div>
            </form>
        </div>
        <% } else { %>
        <!-- Main Login/Signup Forms -->
        <div id="main-forms">
            <div class="form-toggle">
                <button class="toggle-btn active" onclick="showForm('login')">Login</button>
                <button class="toggle-btn" onclick="showForm('signup')">Sign Up</button>
            </div>
            
            <!-- Login Form -->
            <div id="login-form" class="form-container active">
                <form method="post">
                    <input type="hidden" name="action" value="login">
                    <div class="form-group">
                        <label for="login-email">Email</label>
                        <input type="email" id="login-email" name="login-email" class="form-control" placeholder="Enter your email" required>
                    </div>
                    <div class="form-group">
                        <label for="login-password">Password</label>
                        <input type="password" id="login-password" name="login-password" class="form-control" placeholder="Enter your password" required>
                    </div>
                    <div class="forgot-password">
                        <a href="?show-forgot=true">Forgot Password?</a>
                    </div>
                    <button type="submit" class="btn-login">Login</button>
                </form>
            </div>
            
            <!-- Signup Form -->
            <div id="signup-form" class="form-container">
                <form method="post">
                    <input type="hidden" name="action" value="signup">
                    <div class="form-group">
                        <label for="signup-email">Email</label>
                        <input type="email" id="signup-email" name="signup-email" class="form-control" placeholder="Enter your email" required>
                    </div>
                    <div class="form-group">
                        <label for="signup-password">Password</label>
                        <input type="password" id="signup-password" name="signup-password" class="form-control" placeholder="Create a password (min 6 characters)" required>
                    </div>
                    <div class="form-group">
                        <label for="signup-confirm">Confirm Password</label>
                        <input type="password" id="signup-confirm" name="signup-confirm" class="form-control" placeholder="Confirm your password" required>
                    </div>
                    <button type="submit" class="btn-login">Sign Up</button>
                </form>
            </div>
        </div>
        <% } %>
    </div>

    <script>
        // Toggle between login and signup forms
        function showForm(formType) {
            document.querySelectorAll('.toggle-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            document.querySelectorAll('.form-container').forEach(form => {
                form.classList.remove('active');
            });
            
            document.querySelector('.toggle-btn[onclick="showForm(\'' + formType + '\')"]').classList.add('active');
            document.getElementById(formType + '-form').classList.add('active');
        }
    </script>
</body>
</html>