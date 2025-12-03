<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@ include file="dbconnect.jsp" %>
<%

// Process form submission
if ("POST".equals(request.getMethod())) {
    
    PreparedStatement pstmt = null;
    
    try {
        // Get form data with null checks
        String fullName = request.getParameter("fullName") != null ? request.getParameter("fullName").trim() : "";
        String email = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
        String phone = request.getParameter("phone") != null ? request.getParameter("phone").trim() : "";
        String serviceType = request.getParameter("serviceType") != null ? request.getParameter("serviceType").trim() : "";
        String experience = request.getParameter("experience") != null ? request.getParameter("experience").trim() : "";
        String ageStr = request.getParameter("age") != null ? request.getParameter("age").trim() : "";
        String message = request.getParameter("message") != null ? request.getParameter("message").trim() : "";

        // Age validation
        int age = 0;
        try {
            age = Integer.parseInt(ageStr);
        } catch (NumberFormatException e) {
            throw new Exception("Please enter a valid age");
        }
        
        // Check age range (18 to 50)
        if (age < 18 || age > 50) {
            throw new Exception("Age must be between 18 and 50 years to apply for this position");
        }

        // Debug output - check your server logs for these
        System.out.println("Attempting to insert:");
        System.out.println("Name: " + fullName);
        System.out.println("Email: " + email);
        System.out.println("Phone: " + phone);
        System.out.println("Service: " + serviceType);
        System.out.println("Experience: " + experience);
        System.out.println("Age: " + age);
        System.out.println("Message: " + message);

        // Prepare SQL statement - modified to match your table structure
        String sql = "INSERT INTO sitter_applications (full_name, email, phone, service_type, experience, age, message, status) VALUES (?, ?, ?, ?, ?, ?, ?,?)";
        pstmt = conn.prepareStatement(sql);
        
        // Set parameters
        pstmt.setString(1, fullName);
        pstmt.setString(2, email);
        pstmt.setString(3, phone);
        pstmt.setString(4, serviceType);
        pstmt.setString(5, experience);
        pstmt.setInt(6, age);  // Using setInt for age
        pstmt.setString(7, message);
        pstmt.setString(8, "pending");
        
        // Execute query
        int rowsAffected = pstmt.executeUpdate();
        System.out.println("Rows affected: " + rowsAffected);
        
        // Redirect on success
        if (rowsAffected > 0) {
            response.sendRedirect("BookYourCare.jsp");
            return;
        } else {
            throw new SQLException("No rows were inserted");
        }
    } catch(Exception e) {
        // Detailed error logging
        e.printStackTrace(); // Check your server logs for this
        String errorMsg = "Error submitting application: " + e.getMessage();
        System.out.println(errorMsg);
        out.println("<script>alert('" + errorMsg.replace("'", "\\'") + "');</script>");
    } finally {
        // Close connections
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Become a Sitter - Book Your Care</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-pink: #e83e8c;
            --primary-yellow: #ffc107;
            --light-yellow: #fff9e6;
            --dark-text: #333333;
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            background-color: white;
            color: var(--dark-text);
            line-height: 1.6;
            margin: 0;
            padding: 0;
        }
        
        /* Hero Section */
        .sitter-hero {
            background-color: var(--light-yellow);
            padding: 4rem 0;
            text-align: center;
        }
        
        .sitter-hero h1 {
            color: var(--primary-pink);
            font-size: 2.8rem;
            margin-bottom: 1rem;
        }
        
        .sitter-hero p {
            font-size: 1.2rem;
            max-width: 800px;
            margin: 0 auto;
        }
        
        /* Main Content */
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 3rem 2rem;
        }
        
        /* Info Cards Row */
        .info-cards-row {
            display: flex;
            gap: 2rem;
            margin-bottom: 3rem;
        }
        
        .info-card {
            background-color: white;
            border-radius: 10px;
            padding: 2rem;
            flex: 1;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            border-top: 4px solid var(--primary-pink);
        }
        
        .info-card h2 {
            color: var(--primary-pink);
            margin-top: 0;
            display: flex;
            align-items: center;
        }
        
        .info-card h2 i {
            margin-right: 10px;
            color: var(--primary-yellow);
        }
        
        /* Positions Section */
        .positions-section {
            margin-bottom: 3rem;
        }
        
        .section-title {
            color: var(--primary-pink);
            font-size: 2rem;
            margin-bottom: 1.5rem;
            text-align: center;
        }
        
        .service-options {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
        }
        
        .service-option {
            flex: 1;
            min-width: 150px;
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem 1rem;
            text-align: center;
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
            border: 1px solid #eee;
            transition: all 0.3s;
        }
        
        .service-option:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .service-option i {
            font-size: 2rem;
            color: var(--primary-pink);
            margin-bottom: 0.5rem;
        }
        
        .service-option h3 {
            margin: 0.5rem 0;
            color: var(--primary-pink);
        }
        
        /* Application Form Section */
        .form-section {
            background-color: white;
            border-radius: 10px;
            padding: 3rem;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            border-top: 4px solid var(--primary-yellow);
            max-width: 800px;
            margin: 0 auto;
        }
        
        .form-title {
            color: var(--primary-pink);
            text-align: center;
            margin-top: 0;
            margin-bottom: 2rem;
            font-size: 2rem;
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
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--primary-pink);
        }
        
        select.form-control {
            appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23e83e8c' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 1em;
        }
        
        .btn-submit {
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
        
        .btn-submit:hover {
            background-color: #d62d7b;
            transform: translateY(-2px);
        }
        
        /* Interview Section */
        .interview-notice {
            background-color: var(--light-yellow);
            padding: 2rem;
            border-radius: 10px;
            margin-top: 2rem;
            text-align: center;
            border: 2px dashed var(--primary-pink);
        }
        
        .interview-notice h3 {
            color: var(--primary-pink);
            margin-top: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .interview-notice i {
            margin-right: 10px;
        }
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .info-cards-row {
                flex-direction: column;
            }
            
            .service-option {
                min-width: calc(50% - 0.5rem);
            }
            
            .form-section {
                padding: 2rem 1.5rem;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="Header.jsp" />
   <!-- Hero Section -->
    <section class="sitter-hero">
        <h1>Join Our Team of Pet Care Professionals</h1>
        <p>Turn your love for animals into a rewarding career with Book Your Care</p>
    </section>

    <!-- Main Content -->
    <div class="main-container">
        <!-- Requirements and Salary Structure -->
        <div class="info-cards-row">
            <div class="info-card">
                <h2><i class="bi bi-patch-question"></i> Requirements</h2>
                <p>To become a sitter with Book Your Care, you must meet these basic requirements:</p>
                <ul>
                    <li>Age between 18 and 50 years</li>
                    <li>Genuine love and patience for animals</li>
                    <li>Basic knowledge of animal behavior</li>
                    <li>Clean background check</li>
                    <li>Ability to commit to regular schedules</li>
                    <li>For specialized roles (vet/groomer), relevant certifications</li>
                </ul>
            </div>
            
            <div class="info-card">
                <h2><i class="bi bi-cash-stack"></i> Salary Structure</h2>
                <p>Our transparent model ensures you're fairly paid for your time and expertise:</p>
                <ul>
                    <li><strong>Our transparent 70/30 commission model:</strong></li>
                    <li>30% of your service payment will go to the organization</li>
                    <li>Salaries are given monthly according to your appointment rates</li>
                    <li>Service rates are highly confidential, the Structure will be provided(in-person) only if you apply to become a employee by filling the form</li>
                    <li>Tips are totally depended on opet owners.Organization shares no rights within.</li>
                </ul>
                <p>Example: For a ₹10,000 monthly appointment, you receive ₹7,000 and ₹3,000 goes to the organization.</p>
            </div>
        </div>
        
        <!-- Positions Available -->
        <div class="positions-section">
            <h2 class="section-title">Positions Available</h2>
            <div class="service-options">
                <div class="service-option">
                    <i class="bi bi-heart-pulse"></i>
                    <h3>Vet Assistant</h3>
                    <p>Help care for pets under veterinary supervision</p>
                </div>
                <div class="service-option">
                    <i class="bi bi-scissors"></i>
                    <h3>Groomer</h3>
                    <p>Keep pets looking and feeling their best</p>
                </div>
                <div class="service-option">
                    <i class="bi bi-bicycle"></i>
                    <h3>Walker</h3>
                    <p>Provide exercise and outdoor time</p>
                </div>
                <div class="service-option">
                    <i class="bi bi-house-heart"></i>
                    <h3>Caretaker</h3>
                    <p>Overnight stays and day care</p>
                </div>
            </div>
        </div>
        
        <!-- Application Form -->
        <div class="form-section">
            <h2 class="form-title">Application Form</h2>
            <form id="sitterApplication" method="post" action="">
                <div class="form-group">
                    <label for="fullName">Full Name</label>
                    <input type="text" id="fullName" name="fullName" class="form-control" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" required>
                </div>
                
                <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <input type="tel" id="phone" name="phone" class="form-control" required>
                </div>
                
                <div class="form-group">
                    <label for="serviceType">Service You're Applying For</label>
                    <select id="serviceType" name="serviceType" class="form-control" required>
                        <option value="">Select a service</option>
                        <option value="vet assistant">Vet Assistant</option>
                        <option value="groomer">Groomer</option>
                        <option value="walker">Walker</option>
                        <option value="care taker">Care taker</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="experience">Years of Experience with Animals</label>
                    <select id="experience" name="experience" class="form-control" required>
                        <option value="">Select experience</option>
                        <option value="0-1">0-1 years</option>
                        <option value="1-3">1-3 years</option>
                        <option value="3-5">3-5 years</option>
                        <option value="5+">5+ years</option>
                    </select>
                </div>
                
                 <div class="form-group">
                    <label for="age">Age (18-50 years)</label>
                    <input type="number" id="age" name="age" class="form-control" min="18" max="50" required>
                </div>
                
                
                <div class="form-group">
                    <label for="message">Why do you want to work with animals? (Brief statement)</label>
                    <textarea id="message" name="message" class="form-control" rows="3" required></textarea>
                </div>
                
                <button type="submit" class="btn-submit">Submit Application</button>
            </form>
            
            <div class="interview-notice">
                <h3><i class="bi bi-person-check"></i> Hiring Process</h3>
                <p>We only hire employees through in-person interviews at our Palanpur office. After reviewing your application, we'll contact you to schedule an interview.</p>
                <p><strong>Interview Address:</strong><br>
                123 Pet Care Lane, Near Gandhi Park<br>
                Palanpur, Gujarat 385001</p>
                <p><strong>Phone:</strong> +91 98765 43210</p>
            </div>
        </div>
    </div>

    <jsp:include page="Footer.jsp" />
    <script>
        document.getElementById('sitterApplication').addEventListener('submit', function(e) {
            // Additional client-side age validation
            const ageInput = document.getElementById('age');
            const age = parseInt(ageInput.value);
            
            if (age < 18 || age > 50) {
                e.preventDefault();
                alert('Age must be between 18 and 50 years to apply for this position.');
                return false;
            }
        });
    </script>
</body>
</html>