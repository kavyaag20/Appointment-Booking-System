<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@ include file="dbconnect.jsp" %>

<%!
// Method declaration - updated to handle role mapping
public String getPricingInfo(String service, String timeSlotParam) {
    // Map search terms to match pricing logic
    if ("Vet".equalsIgnoreCase(service)) {
        if ("morning".equalsIgnoreCase(timeSlotParam) || "afternoon".equalsIgnoreCase(timeSlotParam)) {
            return "₹1200";
        } else if ("evening".equalsIgnoreCase(timeSlotParam)) {
            return "₹1500";
        }
        return "₹1200 - ₹1500";
    } else if ("Daycare".equalsIgnoreCase(service) || "Care Taker".equalsIgnoreCase(service) || 
               "Pet Sitter".equalsIgnoreCase(service) || "Boarding".equalsIgnoreCase(service)) {
        if ("morning".equalsIgnoreCase(timeSlotParam) || "afternoon".equalsIgnoreCase(timeSlotParam)) {
            return "₹300";
        } else if ("evening".equalsIgnoreCase(timeSlotParam)) {
            return "₹500";
        }
        return "₹300 - ₹500";
    } else if ("Walker".equalsIgnoreCase(service)) {
        if ("morning".equalsIgnoreCase(timeSlotParam)) {
            return "₹250";
        } else if ("afternoon".equalsIgnoreCase(timeSlotParam)) {
            return "₹400";
        } else if ("evening".equalsIgnoreCase(timeSlotParam) || "night".equalsIgnoreCase(timeSlotParam)) {
            return "₹250";
        }
        return "₹250 - ₹400";
    } else if ("Groomer".equalsIgnoreCase(service)) {
        return "₹800 - ₹3500";
    }
    return "Contact for pricing";
}
%>

<%
// Get search parameters from the previous form
String serviceType = request.getParameter("serviceType");
String petType = request.getParameter("petType");
String address = request.getParameter("address");
String timeSlot = request.getParameter("time");
String phoneNumber = request.getParameter("phone");

// Check if user is logged in (matching your login.jsp session attributes)
String userEmail = (String) session.getAttribute("user_email");
Integer userId = (Integer) session.getAttribute("user_id");
boolean isLoggedIn = userEmail != null && !userEmail.isEmpty() && userId != null;

// If not logged in, redirect to login
if (!isLoggedIn) {
    response.sendRedirect("Login.jsp");
    return;
}

// Insert search data into database FIRST (before showing results)
boolean insertSuccess = false;
String insertError = "";

if (serviceType != null && !serviceType.isEmpty()) {
    PreparedStatement stmt = null;
    try {
        // First, let's make sure the connection is working
        if (conn == null || conn.isClosed()) {
            insertError = "Database connection is not available";
        } else {
            String sql = "INSERT INTO search_bookings(service_type, pet_type, address, time_slot, phone_number, booking_date) " +
                         "VALUES (?, ?, ?, ?, ?, NOW())";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, serviceType);
            stmt.setString(2, petType != null ? petType : "dog");
            stmt.setString(3, address != null ? address : "");
            stmt.setString(4, timeSlot != null ? timeSlot : "");
            stmt.setString(5, phoneNumber != null ? phoneNumber : "");
            
            // EXECUTE the statement - this was missing!
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                insertSuccess = true;
            } else {
                insertError = "No rows were inserted";
            }
        }
    } catch (SQLException e) {
        insertError = "SQL Error: " + e.getMessage();
    } catch (Exception e) {
        insertError = "General Error: " + e.getMessage();
    } finally {
        // Always close the statement in finally block
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                System.err.println("Error closing statement: " + e.getMessage());
            }
        }
    }
}

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Providers - Pet Care</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2563eb;
            --secondary-color: #64748b;
            --accent-color: #059669;
            --warning-color: #d97706;
            --border-color: #e2e8f0;
            --text-primary: #0f172a;
            --text-secondary: #475569;
            --bg-light: #f8fafc;
            --card-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: #ffffff;
            color: var(--text-primary);
            line-height: 1.5;
            font-size: 14px;
        }
        
        .page-header {
            padding: 1rem 0 0.5rem;
            border-bottom: 1px solid var(--border-color);
            margin-bottom: 1.5rem;
            background: white;
        }
        
        .page-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--text-primary);
            margin: 0;
        }
        
        .page-subtitle {
            font-size: 0.875rem;
            color: var(--text-secondary);
            margin: 0.25rem 0 0;
        }
        
        .search-info {
            background: var(--bg-light);
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border: 1px solid var(--border-color);
            font-size: 0.875rem;
        }
        
        .search-info .row > div {
            margin-bottom: 0.5rem;
        }
        
        .search-info .row > div:last-child {
            margin-bottom: 0;
        }
        
        .employee-card {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 1.25rem;
            margin-bottom: 1rem;
            box-shadow: var(--card-shadow);
            transition: all 0.2s ease;
        }
        
        .employee-card:hover {
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
            border-color: var(--primary-color);
        }
        
        .employee-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 0.75rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid var(--border-color);
        }
        
        .employee-name {
            color: var(--text-primary);
            font-weight: 600;
            font-size: 1.125rem;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .employee-role {
            background: var(--primary-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 500;
        }
        
        .pricing-badge {
            background: var(--accent-color);
            color: white;
            padding: 0.375rem 0.75rem;
            border-radius: 6px;
            font-size: 0.875rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            margin-bottom: 0.75rem;
        }
        
        .employee-details {
            margin-bottom: 1rem;
        }
        
        .detail-item {
            display: flex;
            align-items: center;
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
            padding: 0.375rem;
            border-radius: 4px;
            transition: background-color 0.2s;
        }
        
        .detail-item:hover {
            background: var(--bg-light);
        }
        
        .detail-item i {
            color: var(--secondary-color);
            margin-right: 0.75rem;
            width: 16px;
            text-align: center;
            font-size: 0.875rem;
        }
        
        .age-badge, .experience-badge {
            background: var(--bg-light);
            color: var(--text-primary);
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 500;
            border: 1px solid var(--border-color);
        }
        
        .rating-container {
            display: flex;
            align-items: center;
            gap: 0.375rem;
        }
        
        .rating-stars {
            display: flex;
            gap: 0.125rem;
        }
        
        .rating-text {
            font-size: 0.75rem;
            color: var(--text-secondary);
        }
        
        .book-btn {
            background: #e83e8c;
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.375rem;
            transition: all 0.2s;
            font-size: 0.875rem;
        }
        
        .book-btn:hover {
            background: #d62d7b;
            color: white;
            text-decoration: none;
            transform: translateY(-1px);
        }
        
        .back-btn {
            background: transparent;
            color: var(--text-secondary);
            border: 1px solid var(--border-color);
            padding: 0.5rem 0.875rem;
            border-radius: 6px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.375rem;
            margin-bottom: 1rem;
            transition: all 0.2s;
            font-size: 0.875rem;
        }
        
        .back-btn:hover {
            background: var(--bg-light);
            color: var(--text-primary);
            text-decoration: none;
            border-color: var(--secondary-color);
        }
        
        .no-results {
            text-align: center;
            padding: 2rem;
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 8px;
        }
        
        .no-results i {
            font-size: 2.5rem;
            color: var(--warning-color);
            margin-bottom: 1rem;
        }
        
        .no-results h3 {
            color: var(--text-primary);
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        
        .no-results p {
            color: var(--text-secondary);
            font-size: 0.875rem;
            margin-bottom: 1rem;
        }
        
        .no-results ul {
            text-align: left;
            max-width: 300px;
            margin: 0 auto 1.5rem;
        }
        
        .no-results li {
            color: var(--text-secondary);
            font-size: 0.875rem;
            margin-bottom: 0.25rem;
        }
        
        .alert {
            padding: 0.75rem 1rem;
            border-radius: 6px;
            font-size: 0.875rem;
            border: 1px solid;
        }
        
        .alert-info {
            background: #eff6ff;
            border-color: #bfdbfe;
            color: #1e40af;
        }
        
        .container {
            max-width: 1000px;
        }
        
        .availability-badge {
            background: #dcfce7;
            color: #166534;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 500;
            border: 1px solid #bbf7d0;
        }
    </style>
</head>
<body>
    <jsp:include page="Header.jsp" />
    
    <div class="page-header">
        <div class="container">
            <h1 class="page-title">Service Providers</h1>
            <p class="page-subtitle">Available providers for your pet care needs</p>
        </div>
    </div>
    
    <div class="container">
        <a href="BookYourCare.jsp" class="back-btn">
            <i class="bi bi-arrow-left"></i>Back to Search
        </a>
        
        <!-- Search Information -->
        <div class="search-info">
            <div class="row">
                <div class="col-md-6">
                    <div><strong><i class="bi bi-gear-fill text-primary me-2"></i>Service:</strong> <%= serviceType != null ? serviceType : "Not specified" %></div>
                    <div><strong><i class="bi bi-heart-fill text-danger me-2"></i>Pet Type:</strong> <%= petType != null ? petType : "Not specified" %></div>
                </div>
                <div class="col-md-6">
                    <div><strong><i class="bi bi-clock-fill text-warning me-2"></i>Time:</strong> <%= timeSlot != null ? timeSlot : "Not specified" %></div>
                    <div><strong><i class="bi bi-geo-alt-fill text-success me-2"></i>Location:</strong> <%= address != null ? address : "Not specified" %></div>
                </div>
            </div>
        </div>
        
        <!-- Employee Results -->
        <div class="row">
            <div class="col-12">
<%
        try {
            // Query to get active employees based on the service type
            // Exclude employees who are already booked for today
            String employeeQuery = "SELECT * FROM employee_info WHERE employment_status = 'Active' " +
                                  "AND employee_id NOT IN (" +
                                  "    SELECT DISTINCT employee_id FROM bookings " +
                                  "    WHERE booking_date = CURDATE() AND employee_id IS NOT NULL" +
                                  ")";

            // Map search terms to actual database roles
            String actualRole = null;
            if (serviceType != null && !serviceType.isEmpty()) {
                if ("Vet".equalsIgnoreCase(serviceType)) {
                    actualRole = "Vet Assistant";
                } else if ("Daycare".equalsIgnoreCase(serviceType)) {
                    actualRole = "Care Taker";
                } else if ("Groomer".equalsIgnoreCase(serviceType) || "Walker".equalsIgnoreCase(serviceType)) {
                    actualRole = serviceType;
                }

                if (actualRole != null) {
                    employeeQuery += " AND role = ?";
                }
    }
    
    employeeQuery += " ORDER BY rating DESC, full_name";
    
    PreparedStatement empStmt = conn.prepareStatement(employeeQuery);
    if (actualRole != null) {
        empStmt.setString(1, actualRole);
    }
    
    ResultSet employees = empStmt.executeQuery();
    boolean hasResults = false;
    
    while (employees.next()) {
        hasResults = true;
        String currentPricing = getPricingInfo(serviceType, timeSlot);
%> 
                <div class="employee-card">
                    <div class="employee-header">
                        <h3 class="employee-name">
                            <i class="bi bi-person-circle"></i>
                            <%= employees.getString("full_name") %>
                        </h3>
                        <span class="employee-role">
                            <%= employees.getString("role") %>
                        </span>
                    </div>
                    
                    <div class="pricing-badge">
                        <%= currentPricing %>
                    </div>
                    
                    <div class="row">
                        <div class="col-lg-8">
                            <div class="employee-details">
                                <div class="detail-item">
                                    <i class="bi bi-telephone"></i>
                                    <span><strong>Phone:</strong> <%= employees.getString("phone") %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="bi bi-envelope"></i>
                                    <span><strong>Email:</strong> <%= employees.getString("emp_email") %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="bi bi-calendar3"></i>
                                    <span><strong>Age:</strong> <span class="age-badge"><%= employees.getString("age") %> years</span></span>
                                </div>
                                <div class="detail-item">
                                    <i class="bi bi-briefcase"></i>
                                    <span><strong>Experience:</strong> 
                                    <span class="experience-badge">
                                        <%= employees.getString("experience") != null ? employees.getString("experience") : "Professional" %>
                                    </span></span>
                                </div>
                                <div class="detail-item">
                                    <i class="bi bi-star"></i>
                                    <span><strong>Rating:</strong></span>
                                    <div class="rating-container">
                                        <div class="rating-stars">
                                            <%
                                            String ratingStr = employees.getString("rating");
                                            if (ratingStr != null && !ratingStr.isEmpty()) {
                                                try {
                                                    double rating = Double.parseDouble(ratingStr);
                                                    int fullStars = (int) rating;
                                                    boolean hasHalfStar = (rating - fullStars) >= 0.5;
                                                    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
                                                    
                                                    for (int i = 0; i < fullStars; i++) {
                                                        out.print("<i class='bi bi-star-fill' style='color: #eab308;'></i>");
                                                    }
                                                    if (hasHalfStar) {
                                                        out.print("<i class='bi bi-star-half' style='color: #eab308;'></i>");
                                                    }
                                                    for (int i = 0; i < emptyStars; i++) {
                                                        out.print("<i class='bi bi-star' style='color: #cbd5e1;'></i>");
                                                    }
                                                } catch (NumberFormatException e) {
                                                    out.print("<span style='color: #9ca3af;'>⭐⭐⭐⭐⭐</span>");
                                                }
                                            } else {
                                                out.print("<span style='color: #9ca3af;'>⭐⭐⭐⭐⭐</span>");
                                            }
                                            %>
                                        </div>
                                        <span class="rating-text">
                                            (<%= ratingStr != null && !ratingStr.isEmpty() ? ratingStr : "New" %>/5)
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4 text-end">
                            <div class="d-flex flex-column align-items-end gap-2">
                                <a href="BookingForm.jsp?employeeId=<%= employees.getString("employee_id") %>&employeeName=<%= employees.getString("full_name") %>&serviceType=<%= serviceType %>&petType=<%= petType %>&timeSlot=<%= timeSlot %>&address=<%= address %>&phone=<%= phoneNumber %>" 
                                   class="book-btn">
                                    <i class="bi bi-calendar-plus"></i>Book Now
                                </a>
                                <span class="availability-badge">Available today</span>
                            </div>
                        </div>
                    </div>
                </div>
                <%
                    }
                    
                    if (!hasResults) {
                %>
                <div class="no-results">
                    <i class="bi bi-calendar-x"></i>
                    <h3>No Available Providers</h3>
                    <p>All <%= serviceType != null ? serviceType.toLowerCase() : "service" %> providers are currently booked for today.</p>
                    <div class="mt-3">
                        <p><strong>Try these options:</strong></p>
                        <ul class="list-unstyled">
                            <li>• Select a different service type</li>
                            <li>• Try booking for tomorrow</li>
                            <li>• Contact us for urgent needs</li>
                        </ul>
                    </div>
                    <a href="BookYourCare.jsp" class="book-btn">
                        <i class="bi bi-arrow-left"></i>Try Different Search
                    </a>
                </div>
                <%
                    }
                    
                    employees.close();
                    empStmt.close();
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Error loading service providers: " + e.getMessage() + "</div>");
                }
                %>
            </div>
        </div>
        
        <!-- Additional Information -->
        <div class="row mt-3 mb-4">
            <div class="col-12">
                <div class="alert alert-info">
                    <i class="bi bi-info-circle me-2"></i>
                    <strong>Next Steps:</strong> 
                    Click "Book Now" to proceed with your selected provider. 
                    All providers are verified and experienced.
                </div>
            </div>
        </div>
    </div>
    
    <jsp:include page="Footer.jsp" />
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>