<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*, java.sql.*, java.sql.Date" %>
<%@include file="dbconnect.jsp"%>

<%
    session.setMaxInactiveInterval(3600);
    // Check if user is logged in
    String employeeName = (String) session.getAttribute("employeeName");
    String employeeId = (String) session.getAttribute("employee_id");
    if (employeeName == null || employeeId == null) {
        response.sendRedirect("empLogin.jsp");
        return;
    }
    // Initialize variables for statistics
    int totalAppointments = 0;
    int completedAppointments = 0;
    int pendingAppointments = 0;
    double overallRating = 0.0;
    double totalIncome = 0.0;
    
    // Fetch employee data and calculate statistics
    try {
        // Get booking statistics
        String statsQuery = "SELECT COUNT(*) as total, " +
                           "SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed, " +
                           "SUM(CASE WHEN status = 'pending' OR status = 'confirmed' THEN 1 ELSE 0 END) as pending, " +
                           "SUM(CASE WHEN status = 'completed' THEN amount_payable * 0.7 ELSE 0 END) as income " +
                           "FROM bookings WHERE employee_id = ?";
        PreparedStatement statsStmt = conn.prepareStatement(statsQuery);
        statsStmt.setString(1, employeeId);
        ResultSet statsRs = statsStmt.executeQuery();
        
        if (statsRs.next()) {
            totalAppointments = statsRs.getInt("total");
            completedAppointments = statsRs.getInt("completed");
            pendingAppointments = statsRs.getInt("pending");
            totalIncome = statsRs.getDouble("income");
        }
        statsRs.close();
        statsStmt.close();
        
        // Get average rating from completed bookings
        String ratingQuery = "SELECT AVG(rating) as avg_rating FROM bookings WHERE employee_id = ? AND status = 'completed' AND rating IS NOT NULL";
        PreparedStatement ratingStmt = conn.prepareStatement(ratingQuery);
        ratingStmt.setString(1, employeeId);
        ResultSet ratingRs = ratingStmt.executeQuery();
        
        if (ratingRs.next()) {
            double avgRating = ratingRs.getDouble("avg_rating");
            if (!ratingRs.wasNull()) {
                overallRating = avgRating;
            }
        }
        ratingRs.close();
        ratingStmt.close();
        
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading dashboard data: " + e.getMessage() + "</div>");
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Pet Care</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
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
            background-color: #f8f9fa;
            color: var(--dark-text);
            line-height: 1.6;
        }
        
        .main-content {
            padding: 1.5rem;
        }
        
        .content-section {
            background-color: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            border: 2px solid var(--light-yellow);
        }
        
        .section-title {
            color: var(--primary-pink);
            font-weight: 700;
            margin-bottom: 1.5rem;
            font-size: 1.8rem;
            border-bottom: 3px solid var(--primary-yellow);
            padding-bottom: 0.4rem;
        }
        
        /* Dashboard Stats Grid */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }
        
        .stat-card-link {
            text-decoration: none;
            color: inherit;
            display: block;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .stat-card-link:hover {
            text-decoration: none;
            color: inherit;
            transform: translateY(-2px);
        }

        .stat-card-link:hover .stat-card {
            box-shadow: 0 6px 20px rgba(0,0,0,0.15);
            border-color: var(--primary-pink);
        }

        .stat-card-link:active .stat-card {
            transform: scale(0.98);
        }
        
        .stat-card {
            background-color: white;
            padding: 1.2rem;
            border-radius: 10px;
            text-align: center;
            border: 2px solid var(--light-yellow);
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            cursor: pointer;
            position: relative;
        }
        
        .stat-card:hover {
            background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
        }

        .stat-card:hover::after {
            content: "→";
            position: absolute;
            top: 15px;
            right: 20px;
            color: var(--primary-pink);
            font-weight: bold;
            opacity: 0.7;
            font-size: 1.2rem;
        }
        
        .stat-icon {
            font-size: 2rem;
            color: var(--primary-pink);
            margin-bottom: 0.8rem;
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-pink);
            margin-bottom: 0.4rem;
            display: block;
        }
        
        .stat-label {
            font-size: 0.9rem;
            color: var(--dark-text);
            font-weight: 500;
        }
        
        /* Second Row Grid */
        .second-row-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 1.5rem;
        }
        
        /* Income Section - Make it clickable */
        .income-section-link {
            text-decoration: none;
            color: inherit;
            display: block;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .income-section-link:hover {
            text-decoration: none;
            color: inherit;
            transform: translateY(-2px);
        }

        .income-section-link:hover .income-section {
            box-shadow: 0 6px 20px rgba(0,0,0,0.15);
            border-color: var(--primary-pink);
        }

        .income-section-link:active .income-section {
            transform: scale(0.98);
        }
        
        .income-section {
            background-color: white;
            padding: 1.2rem;
            border-radius: 10px;
            border: 2px solid var(--light-yellow);
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            cursor: pointer;
            position: relative;
            transition: all 0.3s ease;
        }

        .income-section:hover {
            background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
        }

        .income-section:hover::after {
            content: "→";
            position: absolute;
            top: 15px;
            right: 20px;
            color: var(--primary-pink);
            font-weight: bold;
            opacity: 0.7;
            font-size: 1.2rem;
        }
        
        .income-title {
            color: var(--primary-pink);
            font-weight: 600;
            font-size: 1.1rem;
            margin-bottom: 0.8rem;
            display: flex;
            align-items: center;
        }
        
        .income-title i {
            margin-right: 0.4rem;
            color: var(--primary-yellow);
        }
        
        .income-amount {
            font-size: 2.2rem;
            font-weight: 700;
            color: var(--primary-pink);
            margin-bottom: 0.4rem;
        }
        
        .income-subtitle {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 0.3rem;
        }
        
        .income-detail {
            color: #888;
            font-size: 0.8rem;
        }
        
        /* Rating Section */
        .rating-section {
            background-color: white;
            padding: 1.2rem;
            border-radius: 10px;
            text-align: center;
            border: 2px solid var(--light-yellow);
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }
        
        .rating-title {
            color: var(--primary-pink);
            font-weight: 600;
            font-size: 1rem;
            margin-bottom: 0.8rem;
        }
        
        .rating-number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-pink);
            margin-bottom: 0.4rem;
        }
        
        .rating-stars {
            margin-bottom: 0.3rem;
            font-size: 1.1rem;
        }
        
        /* Responsive Design */
        @media (max-width: 992px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
            
            .second-row-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
        }
        
        @media (max-width: 768px) {
            .main-content {
                padding: 1rem;
            }
            
            .content-section {
                padding: 1rem;
            }
            
            .section-title {
                font-size: 1.6rem;
                margin-bottom: 1rem;
            }
            
            .stat-card {
                padding: 1rem;
            }
            
            .income-section {
                padding: 1rem;
            }
            
            .rating-section {
                padding: 1rem;
            }
            
            .income-amount {
                font-size: 1.8rem;
            }
            
            .rating-number {
                font-size: 1.6rem;
            }
        }
        
        @media (max-width: 576px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
                gap: 0.8rem;
            }
            
            .stat-number {
                font-size: 1.6rem;
            }
            
            .stat-icon {
                font-size: 1.6rem;
            }
            
            .income-amount {
                font-size: 1.6rem;
            }
        }
    </style>
</head>
<body>

<!-- Include header and sidebar -->
<jsp:include page="Header.jsp" />

<!-- Main Content -->
<div class="main-content">
    <div class="content-section">
        <h2 class="section-title">Dashboard</h2>
        
        <!-- First Row: Three Stats Cards - Now Clickable -->
        <div class="dashboard-grid">
                 <div class="stat-card">
                    <div class="stat-icon">
                        <i class="bi bi-calendar-check"></i>
                    </div>
                    <div class="stat-number"><%= totalAppointments %></div>
                    <div class="stat-label">Total Appointments</div>
                </div>
            
            <a href="completedApp.jsp" class="stat-card-link">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="bi bi-check-circle"></i>
                    </div>
                    <div class="stat-number"><%= completedAppointments %></div>
                    <div class="stat-label">Completed</div>
                </div>
            </a>
            
            <a href="pendingApp.jsp" class="stat-card-link">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="bi bi-clock"></i>
                    </div>
                    <div class="stat-number"><%= pendingAppointments %></div>
                    <div class="stat-label">Pending</div>
                </div>
            </a>
        </div>
        
        <!-- Second Row: Income and Rating -->
        <div class="second-row-grid">
            <a href="Reports.jsp" class="income-section-link">
                <div class="income-section">
                    <div class="income-title">
                        <i class="bi bi-currency-rupee"></i>
                        Total Income Earned
                    </div>
                    <div class="income-amount">₹<%= String.format("%.0f", totalIncome) %></div>
                    <div class="income-subtitle">70% of completed appointments</div>
                    <div class="income-detail">From <%= completedAppointments %> completed appointments</div>
                </div>
            </a>
            
            <div class="rating-section">
                <div class="rating-title">Overall Rating</div>
                <div class="rating-number"><%= String.format("%.1f", overallRating) %></div>
                <div class="rating-stars">
                    <%
                        int fullStars = (int) overallRating;
                        for (int i = 0; i < fullStars; i++) {
                    %>
                        <i class="bi bi-star-fill text-warning"></i>
                    <%
                        }
                        if (overallRating % 1 >= 0.5) {
                    %>
                        <i class="bi bi-star-half text-warning"></i>
                    <%
                        }
                        // Fill remaining stars as empty
                        int remainingStars = 5 - fullStars - (overallRating % 1 >= 0.5 ? 1 : 0);
                        for (int i = 0; i < remainingStars; i++) {
                    %>
                        <i class="bi bi-star text-warning"></i>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>