<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Book Your Care</title>
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
            background-color: #f8f9fa;
            color: var(--dark-text);
            line-height: 1.6;
            margin: 0;
            padding: 0;
        }
        
        /* Top Header */
        .top-header {
            position: fixed;
            top: 0;
            left: 280px;
            right: 0;
            height: 70px;
            background-color: white;
            border-bottom: 2px solid var(--primary-yellow);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 2rem;
            z-index: 999;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .welcome-section {
            display: flex;
            align-items: center;
            color: var(--primary-pink);
        }
        
        .welcome-text {
            font-weight: 600;
            font-size: 1.1rem;
        }
        
        .employee-name {
            font-weight: 700;
            margin-left: 8px;
        }
        
        .logout-btn {
            background-color: var(--primary-pink);
            color: white;
            border: none;
            padding: 0.6rem 1.2rem;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            text-decoration: none;
            cursor: pointer;
        }
        
        .logout-btn:hover {
            background-color: #d62d7b;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            color: white;
        }
        
        .logout-btn i {
            margin-right: 8px;
            font-size: 1.1rem;
        }

        /* Sidebar Navigation */
        .sidebar {
            background-color: white;
            width: 280px;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            border-right: 3px solid var(--primary-yellow);
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
            z-index: 1000;
        }
        
        .sidebar-header {
            padding: 2rem 1.5rem;
            border-bottom: 2px solid var(--light-yellow);
            text-align: center;
        }
        
        .sidebar-brand {
            font-weight: 700;
            color: var(--primary-pink);
            font-size: 1.5rem;
            margin: 0;
        }
        
        .sidebar-subtitle {
            font-size: 0.9rem;
            color: #666;
            margin-top: 0.5rem;
        }
        
        .sidebar-nav {
            padding: 1rem 0;
        }
        
        .nav-item {
            margin: 0.5rem 1rem;
        }
        
        .nav-link {
            color: var(--dark-text);
            padding: 1rem 1.5rem;
            border-radius: 8px;
            transition: all 0.3s ease;
            font-weight: 500;
            display: flex;
            align-items: center;
            text-decoration: none;
        }
        
        .nav-link i {
            margin-right: 12px;
            font-size: 1.2rem;
            color: var(--primary-yellow);
            width: 20px;
        }
        
        .nav-link:hover {
            background-color: var(--light-yellow);
            color: var(--primary-pink);
            transform: translateX(5px);
        }
        
        .nav-link.active {
            background-color: var(--primary-pink);
            color: white;
        }
        
        .nav-link.active i {
            color: white;
        }
        
        
        /* Main Content */
        .main-content {
            margin-left: 280px;
            margin-top: 70px;
            padding: 2rem;
            min-height: calc(100vh - 70px);
        }
        
        .content-section {
            display: none;
            background-color: white;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border: 2px solid var(--light-yellow);
        }
        
        .content-section.active {
            display: block;
        }
        
        .section-title {
            color: var(--primary-pink);
            font-weight: 700;
            margin-bottom: 2rem;
            font-size: 2rem;
            border-bottom: 3px solid var(--primary-yellow);
            padding-bottom: 0.5rem;
        }
        
        /* Dashboard Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background-color: var(--light-yellow);
            padding: 2rem;
            border-radius: 12px;
            text-align: center;
            border: 2px solid var(--primary-yellow);
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-icon {
            font-size: 3rem;
            color: var(--primary-pink);
            margin-bottom: 1rem;
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--primary-pink);
            margin: 0;
        }
        
        .stat-label {
            color: var(--dark-text);
            font-weight: 500;
            margin-top: 0.5rem;
        }
        
        /* Tables */
        .data-table-container {
            background-color: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
            border: 2px solid var(--light-yellow);
        }
        
        .table-header {
            background-color: var(--primary-pink);
            color: white;
            padding: 1rem;
            font-weight: 600;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th, td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #f0f0f0;
        }
        
        th {
            background-color: var(--light-yellow);
            color: var(--primary-pink);
            font-weight: 600;
        }
        
        tr:hover {
            background-color: #f9f9f9;
        }
        
        .status-badge {
            padding: 0.35rem 0.75rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .status-completed {
            background-color: #d1ecf1;
            color: #0c5460;
        }
        
        .btn-outline-primary {
            border-color: var(--primary-pink);
            color: var(--primary-pink);
        }
        
        .btn-outline-primary:hover {
            background-color: var(--primary-pink);
            color: white;
        }
        
        /* Mobile Responsive */
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
                transition: transform 0.3s ease;
            }
            
            .sidebar.show {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
                padding: 1rem;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
        
        .mobile-header {
            display: none;
        }
        
        @media (max-width: 768px) {
            .mobile-header {
                display: flex;
                justify-content: flex-start;
                align-items: center;
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                background-color: white;
                padding: 1rem;
                border-bottom: 2px solid var(--primary-yellow);
                z-index: 1001;
                height: 70px;
            }
            
            .top-header {
                display: none;
            }
        }
        
        .menu-toggle {
            background: none;
            border: none;
            font-size: 1.5rem;
            color: var(--primary-pink);
            cursor: pointer;
        }
    </style>
</head>
<body>
    <!-- Top Header with Welcome and Logout -->
    <div class="top-header">
        <div class="welcome-section">
            <span class="welcome-text">Welcome,</span>
            <span class="employee-name">Admin User</span>
        </div>
        <a href="admLogin.jsp" class="logout-btn">
            <i class="bi bi-box-arrow-right"></i>
            Logout
        </a>
    </div>

    <!-- Mobile Header -->
    <div class="mobile-header">
        <button class="menu-toggle" onclick="toggleSidebar()">
            <i class="bi bi-list"></i>
        </button>
        <div class="welcome-section">
            <span class="employee-name">Admin User</span>
        </div>
        <a href="admLogin.jsp" class="logout-btn" style="font-size: 0.9rem; padding: 0.4rem 0.8rem;">
            <i class="bi bi-box-arrow-right"></i>
            Logout
        </a>
    </div>

    <!-- Sidebar Navigation -->
   
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h1 class="sidebar-brand">Book Your Care</h1>
            <p class="sidebar-subtitle">Admin Panel</p>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-item">
                <a href="Dashboard.jsp" class="nav-link ">
                    <i class="bi bi-speedometer2"></i>
                    Dashboard
                </a>
            </div>
            <div class="nav-item">
                <a href="Employees.jsp" class="nav-link">
                    <i class="bi bi-people-fill"></i>
                    Employees
                </a>
            </div>
            <div class="nav-item">
                <a href="HiringApp.jsp" class="nav-link">
                    <i class="bi bi-file-earmark-person"></i>
                    Hiring Applications
                </a>
            </div>
            <div class="nav-item">
                <a href="Appointments.jsp" class="nav-link">
                    <i class="bi bi-calendar-check"></i>
                    Completed Appointments
                </a>
            </div>
             <div class="nav-item">
                <a href="Reports.jsp" class="nav-link">
                    <i class="bi bi-clipboard-data"></i>
                  Reports
                </a>
            </div>
        </nav>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
<script>
    // Set active nav link based on current page
    document.addEventListener('DOMContentLoaded', function() {
        const currentPage = window.location.pathname.split('/').pop();
        const navLinks = document.querySelectorAll('.nav-link');
        
        navLinks.forEach(link => {
            // Extract just the filename from href
            const linkPage = link.getAttribute('href').split('/').pop();
            
            // Remove 'active' class from all links first
            link.classList.remove('active');
            
            // Add 'active' class to matching link
            if (currentPage === linkPage) {
                link.classList.add('active');
            }
        });
    });
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('show');
        }
        
        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function(event) {
            const sidebar = document.getElementById('sidebar');
            const menuToggle = document.querySelector('.menu-toggle');
            
            if (window.innerWidth <= 768) {
                if (!sidebar.contains(event.target) && !menuToggle.contains(event.target)) {
                    sidebar.classList.remove('show');
                }
            }
        });
    </script>