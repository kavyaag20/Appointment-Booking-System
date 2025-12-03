<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="Header.jsp" %>
<%@ include file="dbconnect.jsp" %>
<%
// Check admin session and extend timeout
session.setMaxInactiveInterval(3600); // 1 hour
%>
<%
    // Check if admin is logged in - try multiple possible session attribute names
    String adminName = (String) session.getAttribute("adminName");
    String adminId = (String) session.getAttribute("admin_id");
    String adminUser = (String) session.getAttribute("adminUser");
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    
    // If none of the common admin session attributes exist, redirect to login
    if (adminName == null && adminId == null && adminUser == null && loggedInUser == null) {
        response.sendRedirect("admLogin.jsp");
        return;
    }
    
    // Set a default display name if adminName is null
    if (adminName == null) {
        if (adminUser != null) adminName = adminUser;
        else if (loggedInUser != null) adminName = loggedInUser;
        else adminName = "Admin User";
    }

    int totalEmployees = 0;
    int completedAppointments = 0;
    int hiringApplications = 0;
    double totalRevenue = 0.0;

    // Fetch Total Employees
    try {
        String empQuery = "SELECT COUNT(*) AS emp_count FROM employee_info";
        PreparedStatement empStmt = conn.prepareStatement(empQuery);
        ResultSet empRs = empStmt.executeQuery();
        if (empRs.next()) {
            totalEmployees = empRs.getInt("emp_count");
        }
        empRs.close();
        empStmt.close();
    } catch (Exception e) { }

    // Fetch Completed Appointments
    try {
        String apptQuery = "SELECT COUNT(*) AS completed_count FROM bookings WHERE status = 'completed'";
        PreparedStatement apptStmt = conn.prepareStatement(apptQuery);
        ResultSet apptRs = apptStmt.executeQuery();
        if (apptRs.next()) {
            completedAppointments = apptRs.getInt("completed_count");
        }
        apptRs.close();
        apptStmt.close();
    } catch (Exception e) { }

    // Fetch Hiring Applications
    try {
        String appQuery = "SELECT COUNT(*) AS apps_count FROM sitter_applications WHERE status = 'pending'";
        PreparedStatement appStmt = conn.prepareStatement(appQuery);
        ResultSet appRs = appStmt.executeQuery();
        if (appRs.next()) {
            hiringApplications = appRs.getInt("apps_count");
        }
        appRs.close();
        appStmt.close();
    } catch (Exception e) { }

    // Fetch Total Revenue (30% of completed bookings)
    try {
        String revenueQuery = "SELECT SUM(amount_payable * 0.30) as total_revenue FROM bookings WHERE status = 'completed'";
        PreparedStatement revenueStmt = conn.prepareStatement(revenueQuery);
        ResultSet revenueRs = revenueStmt.executeQuery();
        if (revenueRs.next()) {
            totalRevenue = revenueRs.getDouble("total_revenue");
            if (revenueRs.wasNull()) totalRevenue = 0.0;
        }
        revenueRs.close();
        revenueStmt.close();
    } catch (Exception e) { }

    // Fetch Top Performer (employee with highest average rating)
    String topPerformer = "No Data";
    double avgRating = 0.0;
    try {
        String topPerformerQuery = "SELECT full_name, AVG(rating) as avg_rating FROM employee_info WHERE rating IS NOT NULL AND rating > 0 GROUP BY employee_id, full_name ORDER BY avg_rating DESC LIMIT 1";
        PreparedStatement topStmt = conn.prepareStatement(topPerformerQuery);
        ResultSet topRs = topStmt.executeQuery();
        if (topRs.next()) {
            topPerformer = topRs.getString("full_name");
            avgRating = topRs.getDouble("avg_rating");
        }
        topRs.close();
        topStmt.close();
    } catch (Exception e) { 
        // Fallback: try to get top performer based on completed appointments count
        try {
            String fallbackQuery = "SELECT ei.full_name, COUNT(ca.employee_id) as appointment_count " +
                                 "FROM employee_info ei " +
                                 "LEFT JOIN completed_appointments ca ON ei.employee_id = ca.employee_id " +
                                 "GROUP BY ei.employee_id, ei.full_name " +
                                 "ORDER BY appointment_count DESC LIMIT 1";
            PreparedStatement fallbackStmt = conn.prepareStatement(fallbackQuery);
            ResultSet fallbackRs = fallbackStmt.executeQuery();
            if (fallbackRs.next()) {
                topPerformer = fallbackRs.getString("full_name");
                avgRating = 0.0; // No rating available in this case
            }
            fallbackRs.close();
            fallbackStmt.close();
        } catch (Exception ex) { }
    }

    // Fetch Most Booked Service
    String mostBookedService = "No Data";
    int mostBookedServiceCount = 0;
    try {
        String serviceQuery = "SELECT service_type, COUNT(*) as service_count " +
                            "FROM completed_appointments " +
                            "WHERE service_type IS NOT NULL " +
                            "GROUP BY service_type " +
                            "ORDER BY service_count DESC LIMIT 1";
        PreparedStatement serviceStmt = conn.prepareStatement(serviceQuery);
        ResultSet serviceRs = serviceStmt.executeQuery();
        if (serviceRs.next()) {
            mostBookedService = serviceRs.getString("service_type");
            mostBookedServiceCount = serviceRs.getInt("service_count");
        }
        serviceRs.close();
        serviceStmt.close();
    } catch (Exception e) { }

    // Calculate Customer Retention (customers who have more than one completed booking)
    int retentionPercent = 0;
    try {
        String totalCustomersQuery = "SELECT COUNT(DISTINCT user_email) as total_customers FROM completed_appointments";
        String repeatCustomersQuery = "SELECT COUNT(*) as repeat_customers FROM (" +
                                    "SELECT user_email FROM completed_appointments " +
                                    "GROUP BY user_email HAVING COUNT(*) > 1" +
                                    ") as repeat_users";
        
        int totalCustomers = 0;
        int repeatCustomers = 0;
        
        // Get total customers
        PreparedStatement totalStmt = conn.prepareStatement(totalCustomersQuery);
        ResultSet totalRs = totalStmt.executeQuery();
        if (totalRs.next()) {
            totalCustomers = totalRs.getInt("total_customers");
        }
        totalRs.close();
        totalStmt.close();
        
        // Get repeat customers
        PreparedStatement repeatStmt = conn.prepareStatement(repeatCustomersQuery);
        ResultSet repeatRs = repeatStmt.executeQuery();
        if (repeatRs.next()) {
            repeatCustomers = repeatRs.getInt("repeat_customers");
        }
        repeatRs.close();
        repeatStmt.close();
        
        // Calculate retention percentage
        if (totalCustomers > 0) {
            retentionPercent = (int) Math.round((double) repeatCustomers / totalCustomers * 100);
        }
    } catch (Exception e) { }
%>
<style>
.stats-grid {
    display: flex;
    gap: 2rem;
    margin-bottom: 2rem;
    justify-content: center;
    max-width: 1200px;
    margin-left: auto;
    margin-right: auto;
}

.stat-card {
    background: #fff;
    border-radius: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    padding: 2.5rem 2rem;
    min-width: 300px;
    max-width: 350px;
    text-align: center;
    flex: 1 1 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    border: 2px solid #f0f0f0;
}

.stat-icon {
    font-size: 3rem;
    color: var(--primary-pink, #e91e63);
    margin-bottom: 1rem;
}

.stat-number {
    font-size: 2.8rem;
    font-weight: bold;
    margin-bottom: 0.5rem;
    color: var(--dark-text, #212121);
}

.stat-label {
    font-size: 1.2rem;
    color: #666;
    margin-bottom: 0.2rem;
    font-weight: 500;
}

.stat-card-link {
    text-decoration: none;
    color: inherit;
    display: block;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    flex: 1;
}

.stat-card-link:hover {
    text-decoration: none;
    color: inherit;
    transform: translateY(-2px);
}

.stat-card-link:hover .stat-card {
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
    border-color: var(--primary-pink, #e91e63);
}

.stat-card-link:active .stat-card {
    transform: scale(0.98);
}

.stat-card {
    cursor: pointer;
    transition: all 0.2s ease;
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
    color: var(--primary-pink, #e91e63);
    font-weight: bold;
    opacity: 0.7;
    font-size: 1.2rem;
}

.data-table-container {
    margin-top: 2.5rem;
    background: #fff;
    border-radius: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    padding: 2rem;
}

.table-header {
    font-size: 1.3rem;
    font-weight: 600;
    margin-bottom: 1rem;
    color: white;
}

.metrics-row {
    display: flex;
    gap: 2rem;
    justify-content: center;
}

.metric-card {
    flex: 1 1 0;
    background: #f8f9fa;
    border-radius: 10px;
    padding: 1.2rem 1rem;
    margin-bottom: 1rem;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    text-align: center;
}

.metric-title {
    color: var(--primary-pink, #e91e63);
    font-weight: 600;
    font-size: 1.1rem;
}

.metric-value {
    font-size: 1.1rem;
    margin-top: 0.4rem;
    margin-bottom: 0.3rem;
}

/* Updated Revenue Section - Made Clickable */
.revenue-section-link {
    text-decoration: none;
    color: inherit;
    display: block;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.revenue-section-link:hover {
    text-decoration: none;
    color: inherit;
    transform: translateY(-2px);
}

.revenue-section-link:hover .revenue-section {
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
    border-color: var(--primary-pink, #e91e63);
}

.revenue-section-link:active .revenue-section {
    transform: scale(0.98);
}

.revenue-section {
    margin-top: 3rem;
    background: #fff;
    border-radius: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    padding: 2rem;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s ease;
    position: relative;
    border: 2px solid #f0f0f0;
}

.revenue-section:hover {
    background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
}

.revenue-section:hover::after {
    content: "→";
    position: absolute;
    top: 20px;
    right: 25px;
    color: var(--primary-pink, #e91e63);
    font-weight: bold;
    opacity: 0.7;
    font-size: 1.2rem;
}

.revenue-label {
    font-size: 1.3rem;
    color: var(--primary-pink, #e91e63);
    margin-bottom: 0.8rem;
    font-weight: 600;
}

.revenue-value {
    font-size: 2.2rem;
    color: #212121;
    font-weight: bold;
}

@media (max-width: 1024px) {
    .stats-grid {
        gap: 1.5rem;
    }
    
    .stat-card {
        min-width: 250px;
        padding: 2rem 1.5rem;
    }
    
    .stat-number {
        font-size: 2.5rem;
    }
    
    .stat-icon {
        font-size: 2.8rem;
    }
}

@media (max-width: 900px) {
    .stats-grid, .metrics-row {
        flex-direction: column;
        gap: 1.5rem;
        align-items: stretch;
    }
    .stat-card, .metric-card {
        min-width: auto;
        max-width: none;
    }
}
</style>

<!-- Main Content -->
<div class="main-content">
    <!-- Dashboard Section -->
    <div id="dashboard" class="content-section active">
        <h2 class="section-title">Dashboard</h2>
        
        <div class="stats-grid">
            <a href="Employees.jsp" class="stat-card-link">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="bi bi-people-fill"></i>
                    </div>
                    <div class="stat-number"><%= totalEmployees %></div>
                    <div class="stat-label">Total Employees</div>
                </div>
            </a>

            <a href="Appointments.jsp" class="stat-card-link">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="bi bi-calendar-check"></i>
                    </div>
                    <div class="stat-number"><%= completedAppointments %></div>
                    <div class="stat-label">Completed Appointments</div>
                </div>
            </a>

            <a href="HiringApp.jsp" class="stat-card-link">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="bi bi-file-earmark-person"></i>
                    </div>
                    <div class="stat-number"><%= hiringApplications %></div>
                    <div class="stat-label">Hiring Applications</div>
                </div>
            </a>
        </div>
        
        <div class="data-table-container">
            <div class="table-header">
                Performance Metrics
            </div>
            <div class="metrics-row">
                <div class="metric-card">
                    <div class="metric-title">Top Performer</div>
                    <div class="metric-value"><%= topPerformer %></div>
                    <div>
                        <% if (avgRating > 0) { %>
                            <i class="bi bi-star-fill text-warning"></i> <%= String.format("%.1f", avgRating) %> avg rating
                        <% } else { %>
                            <i class="bi bi-person-check-fill text-success"></i> Most appointments
                        <% } %>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-title">Most Booked Service</div>
                    <div class="metric-value"><%= mostBookedService %></div>
                    <div>
                        <%= mostBookedServiceCount %> appointments total
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-title">Customer Retention</div>
                    <div class="metric-value"><%= retentionPercent %>%</div>
                    <div>Repeat customers</div>
                </div>
            </div>
        </div>

        <!-- Total Revenue Earned Section - Now Clickable -->
        <a href="Reports.jsp" class="revenue-section-link">
            <div class="revenue-section">
                <div class="revenue-label">Total Revenue Earned (30%)</div>
                <div class="revenue-value">₹<%= String.format("%.0f", totalRevenue) %></div>
            </div>
        </a>
    </div>
</div>

</body>
</html>