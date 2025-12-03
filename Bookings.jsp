<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.time.*"%>
<%@page import="java.time.format.*"%>
<%@ include file="dbconnect.jsp" %>
<%
    // Check if user is logged in
    String userEmail = (String) session.getAttribute("user_email");
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userEmail == null || userEmail.isEmpty() || userId == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

   

        // Handle rating submission
        if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("action") != null && "rate".equals(request.getParameter("action"))) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("booking_id"));
                int rating = Integer.parseInt(request.getParameter("rating"));
                String review = request.getParameter("review");

                // Start transaction
                conn.setAutoCommit(false);

                // Update booking with rating and review
                String updateBookingQuery = "UPDATE bookings SET rating = ?, review = ?, updated_at = NOW() WHERE booking_id = ? AND user_email = ? AND status = 'completed'";
                PreparedStatement updateBookingStmt = conn.prepareStatement(updateBookingQuery);
                updateBookingStmt.setInt(1, rating);
                updateBookingStmt.setString(2, review != null ? review.trim() : "");
                updateBookingStmt.setInt(3, bookingId);
                updateBookingStmt.setString(4, userEmail);

                int bookingResult = updateBookingStmt.executeUpdate();
                updateBookingStmt.close();

                if (bookingResult > 0) {
                    // Also update the completed_appointments table
                    String updateCompletedQuery = "UPDATE completed_appointments SET rating = ?, review = ? WHERE booking_id = ? AND user_email = ?";
                    PreparedStatement updateCompletedStmt = conn.prepareStatement(updateCompletedQuery);
                    updateCompletedStmt.setInt(1, rating);
                    updateCompletedStmt.setString(2, review != null ? review.trim() : "");
                    updateCompletedStmt.setInt(3, bookingId);
                    updateCompletedStmt.setString(4, userEmail);

                    int completedResult = updateCompletedStmt.executeUpdate();
                    updateCompletedStmt.close();

                    if (completedResult > 0) {
                        // Commit both updates
                        conn.commit();
                        response.sendRedirect("Bookings.jsp?rating=success");
                        return;
                    } else {
                        // Rollback if completed_appointments update failed
                        conn.rollback();
                    }
                } else {
                    // Rollback if bookings update failed
                    conn.rollback();
                }

                // Reset auto-commit
                conn.setAutoCommit(true);

            } catch (Exception e) {
                try {
                    conn.rollback();
                    conn.setAutoCommit(true);
                } catch (SQLException se) {
                    se.printStackTrace();
                }
                // Handle error silently or log it
            }
        }

    // Handle appointment cancellation
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("action") != null && "cancel".equals(request.getParameter("action"))) {
        try {
            int bookingId = Integer.parseInt(request.getParameter("booking_id"));
            String cancelReason = request.getParameter("cancel_reason");
            
            // First, get the booking details
            String getBookingQuery = "SELECT * FROM bookings WHERE booking_id = ? AND user_email = ? AND status IN ('pending', 'in_progress')";
            PreparedStatement getBookingStmt = conn.prepareStatement(getBookingQuery);
            getBookingStmt.setInt(1, bookingId);
            getBookingStmt.setString(2, userEmail);
            ResultSet bookingRs = getBookingStmt.executeQuery();
            
            if (bookingRs.next()) {
                // Insert into cancelled_appointments table
                String insertCancelQuery = "INSERT INTO cancelled_appointments (booking_id, user_email, employee_id, owner_name, pet_name, service_type, booking_date, time_slot, amount_payable, cancel_reason, cancelled_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'user')";
                PreparedStatement insertCancelStmt = conn.prepareStatement(insertCancelQuery);
                insertCancelStmt.setInt(1, bookingId);
                insertCancelStmt.setString(2, bookingRs.getString("user_email"));
                insertCancelStmt.setInt(3, bookingRs.getInt("employee_id"));
                insertCancelStmt.setString(4, bookingRs.getString("owner_name"));
                insertCancelStmt.setString(5, bookingRs.getString("pet_name"));
                insertCancelStmt.setString(6, bookingRs.getString("service_type"));
                insertCancelStmt.setDate(7, bookingRs.getDate("booking_date"));
                insertCancelStmt.setString(8, bookingRs.getString("time_slot"));
                insertCancelStmt.setInt(9, bookingRs.getInt("amount_payable"));
                insertCancelStmt.setString(10, cancelReason != null ? cancelReason.trim() : "");
                insertCancelStmt.executeUpdate();
                insertCancelStmt.close();
                
                // Update booking status to cancelled
                String updateStatusQuery = "UPDATE bookings SET status = 'cancelled', updated_at = NOW() WHERE booking_id = ?";
                PreparedStatement updateStatusStmt = conn.prepareStatement(updateStatusQuery);
                updateStatusStmt.setInt(1, bookingId);
                updateStatusStmt.executeUpdate();
                updateStatusStmt.close();
                
                response.sendRedirect("Bookings.jsp?cancel=success");
                return;
            }
            
            bookingRs.close();
            getBookingStmt.close();
        } catch (Exception e) {
            response.sendRedirect("Bookings.jsp?cancel=error");
            return;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings - Pet Care</title>
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
            --pink-color: #e83e8c;
            --warning-color: #d97706;
            --danger-color: #dc3545;
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
        
        .container {
            max-width: 1000px;
        }
        
        .booking-card {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 1.25rem;
            margin-bottom: 1rem;
            box-shadow: var(--card-shadow);
            transition: all 0.2s;
        }
        
        .booking-card:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
        }
        
        .booking-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        
        .service-badge {
            background: var(--primary-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 500;
            display: inline-block;
        }
        
        .status-badge {
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 500;
        }
        
        .status-pending {
            background: #fef3c7;
            color: #92400e;
        }
        
        .status-in_progress {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .status-completed {
            background: #dcfce7;
            color: #166534;
        }
        
        .status-cancelled {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .booking-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 0.75rem;
            margin-bottom: 1rem;
        }
        
        .detail-item {
            background: var(--bg-light);
            padding: 0.75rem;
            border-radius: 6px;
            border: 1px solid var(--border-color);
        }
        
        .detail-item strong {
            color: var(--text-primary);
            font-weight: 500;
            font-size: 0.8rem;
            display: block;
            margin-bottom: 0.25rem;
        }
        
        .detail-item div {
            color: var(--text-secondary);
            font-size: 0.875rem;
        }
        
        .pet-info {
            background: var(--bg-light);
            padding: 1rem;
            border-radius: 6px;
            border: 1px solid var(--border-color);
            margin-top: 0.75rem;
        }
        
        .pet-info h5 {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .pet-info > div {
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
        }
        
        .pet-info > div:last-child {
            margin-bottom: 0;
        }
        
        .amount-display {
            font-size: 1.125rem;
            font-weight: 600;
            color: var(--accent-color);
        }
        
        .no-bookings {
            text-align: center;
            padding: 2rem;
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            box-shadow: var(--card-shadow);
        }
        
        .no-bookings i {
            font-size: 2.5rem;
            color: var(--secondary-color);
            margin-bottom: 1rem;
        }
        
        .btn-pink {
            background: var(--pink-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 500;
            font-size: 0.875rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.375rem;
            transition: all 0.2s;
        }
        
        .btn-pink:hover {
            background: #d62d7b;
            color: white;
            text-decoration: none;
            transform: translateY(-1px);
        }
        
        .btn-danger {
            background: var(--danger-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 500;
            font-size: 0.875rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.375rem;
            transition: all 0.2s;
        }
        
        .btn-danger:hover {
            background: #c82333;
            color: white;
            text-decoration: none;
            transform: translateY(-1px);
        }
        
        .provider-info {
            background: var(--bg-light);
            padding: 1rem;
            border-radius: 6px;
            border: 1px solid var(--border-color);
            margin-top: 0.75rem;
        }
        
        .provider-info h5 {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .provider-name {
            font-weight: 500;
            color: var(--primary-color);
            font-size: 0.875rem;
        }
        
        .rating-section {
            background: #fefce8;
            border: 1px solid #facc15;
            border-radius: 6px;
            padding: 1rem;
            margin-top: 0.75rem;
        }
        
        .rating-section h5 {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .rating-stars {
            display: flex;
            gap: 0.375rem;
            margin: 0.75rem 0;
        }
        
        .rating-star {
            font-size: 1.5rem;
            color: #d1d5db;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .rating-star:hover,
        .rating-star.active {
            color: #facc15;
            transform: scale(1.05);
        }
        
        .rating-display {
            display: flex;
            align-items: center;
            gap: 0.375rem;
            font-size: 0.875rem;
        }
        
        .rating-display .star {
            color: #facc15;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }

        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 1.5rem;
            border-radius: 8px;
            width: 90%;
            max-width: 450px;
            position: relative;
            border: 1px solid var(--border-color);
        }

        .close-modal {
            color: var(--text-secondary);
            float: right;
            font-size: 1.5rem;
            font-weight: bold;
            cursor: pointer;
            position: absolute;
            right: 1rem;
            top: 0.5rem;
        }

        .close-modal:hover {
            color: var(--pink-color);
        }
        
        .form-control {
            border: 1px solid var(--border-color);
            border-radius: 6px;
            padding: 0.625rem 0.75rem;
            font-size: 0.875rem;
            transition: all 0.2s;
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.125rem rgba(37, 99, 235, 0.25);
            outline: none;
        }
        
        .form-label {
            font-weight: 500;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
        }
        
        .alert {
            padding: 0.75rem;
            border-radius: 6px;
            font-size: 0.875rem;
            border: 1px solid;
            margin-bottom: 1rem;
        }
        
        .alert-success {
            background: #dcfce7;
            border-color: #bbf7d0;
            color: #166534;
        }
        
        .alert-danger {
            background: #fee2e2;
            border-color: #fecaca;
            color: #991b1b;
        }
        
        .alert-warning {
            background: #fef3c7;
            border-color: #fde68a;
            color: #92400e;
        }
        
        .btn-secondary {
            background: var(--secondary-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 500;
            font-size: 0.875rem;
        }
        
        .btn-secondary:hover {
            background: #475569;
        }
        
        .cancel-section {
            background: #fef2f2;
            border: 1px solid #fecaca;
            border-radius: 6px;
            padding: 1rem;
            margin-top: 0.75rem;
        }
        
        .cancel-section h5 {
            font-size: 1rem;
            font-weight: 600;
            color: var(--danger-color);
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .action-buttons {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
            margin-top: 0.75rem;
        }
    </style>
</head>
<body>
    <jsp:include page="Header.jsp" />
    
    <div class="page-header">
        <div class="container">
            <h1 class="page-title">My Bookings</h1>
            <p class="page-subtitle">Track your pet care service appointments</p>
        </div>
    </div>
    
    <div class="container">
        <%
        try {
            // Get all bookings for the logged-in user
            String bookingQuery = "SELECT b.*, ei.full_name as provider_name, ei.phone as provider_phone " +
                                 "FROM bookings b " +
                                 "LEFT JOIN employee_info ei ON b.employee_id = ei.employee_id " +
                                 "WHERE b.user_email = ? " +
                                 "ORDER BY b.booking_date DESC, b.booking_id DESC";
            
            PreparedStatement bookingStmt = conn.prepareStatement(bookingQuery);
            bookingStmt.setString(1, userEmail);
            ResultSet bookings = bookingStmt.executeQuery();
            
            boolean hasBookings = false;
            
            while (bookings.next()) {
                hasBookings = true;
                
                // Format booking date
                Date bookingDate = bookings.getDate("booking_date");
                LocalDate localDate = bookingDate.toLocalDate();
                String formattedDate = localDate.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
                
                // Get status from database
                String status = bookings.getString("status");
                String statusClass = "status-" + status;
                String statusText = "";
                
                switch(status) {
                    case "pending":
                        statusText = "Confirmed";
                        break;
                    case "in_progress":
                        statusText = "In Progress";
                        break;
                    case "completed":
                        statusText = "Completed";
                        break;
                    case "cancelled":
                        statusText = "Cancelled";
                        break;
                    default:
                        statusText = "Confirmed";
                        statusClass = "status-pending";
                }
                
                int bookingId = bookings.getInt("booking_id");
                Integer rating = bookings.getInt("rating");
                if (bookings.wasNull()) rating = null;
                String review = bookings.getString("review");
                
                // Check if booking can be cancelled (only pending and in_progress can be cancelled)
                boolean canCancel = "pending".equals(status) || "in_progress".equals(status);
        %>
        <div class="booking-card">
            <div class="booking-header">
                <div class="d-flex align-items-center flex-wrap gap-2">
                    <div class="service-badge">
                        <%= bookings.getString("service_type") %>
                    </div>
                    <div class="status-badge <%= statusClass %>">
                        <%= statusText %>
                    </div>
                </div>
                <div class="amount-display">
                    ₹<%= bookings.getInt("amount_payable") %>
                </div>
            </div>
            
            <div class="booking-details">
                <div class="detail-item">
                    <strong>Date</strong>
                    <div><%= formattedDate %></div>
                </div>
                <div class="detail-item">
                    <strong>Time</strong>
                    <div><%= bookings.getString("time_slot").substring(0,1).toUpperCase() + bookings.getString("time_slot").substring(1) %></div>
                </div>
                <div class="detail-item">
                    <strong>Address</strong>
                    <div><%= bookings.getString("address") %></div>
                </div>
                <div class="detail-item">
                    <strong>Phone</strong>
                    <div><%= bookings.getString("phone_number") %></div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-6">
                    <div class="pet-info">
                        <h5><i class="bi bi-heart"></i>Pet Information</h5>
                        <div><strong>Name:</strong> <%= bookings.getString("pet_name") %></div>
                        <div><strong>Age:</strong> <%= bookings.getInt("pet_age") %> years old</div>
                        <div><strong>Breed:</strong> <%= bookings.getString("pet_breed") %></div>
                        <% if (bookings.getString("special_instructions") != null && !bookings.getString("special_instructions").isEmpty()) { %>
                        <div class="mt-2">
                            <strong>Special Instructions:</strong><br>
                            <em><%= bookings.getString("special_instructions") %></em>
                        </div>
                        <% } %>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="provider-info">
                        <h5><i class="bi bi-person-badge"></i>Service Provider</h5>
                        <div class="provider-name">
                            <%= bookings.getString("provider_name") != null ? bookings.getString("provider_name") : "TBA" %>
                        </div>
                        <% if (bookings.getString("provider_phone") != null) { %>
                        <div class="mt-1">
                            <i class="bi bi-telephone me-1"></i>
                            <%= bookings.getString("provider_phone") %>
                        </div>
                        <% } %>
                        <% if ("pending".equals(status)) { %>
                        <div class="mt-2">
                            <small class="text-success">
                                <i class="bi bi-check-circle me-1"></i>
                                Appointment confirmed, the service provider will come on time
                            </small>
                        </div>
                        <% } else if ("in_progress".equals(status)) { %>
                        <div class="mt-2">
                            <small class="text-primary">
                                <i class="bi bi-play-circle me-1"></i>
                                Service in progress
                            </small>
                        </div>
                        <% } else if ("completed".equals(status)) { %>
                        <div class="mt-2">
                            <small class="text-success">
                                <i class="bi bi-check-all me-1"></i>
                                Service completed successfully
                            </small>
                        </div>
                        <% } else if ("cancelled".equals(status)) { %>
                        <div class="mt-2">
                            <small class="text-danger">
                                <i class="bi bi-x-circle me-1"></i>
                                Appointment cancelled
                            </small>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Rating Section for Completed Services -->
            <% if ("completed".equals(status)) { %>
                <div class="rating-section">
                    <h5><i class="bi bi-star"></i>Service Rating</h5>
                    <% if (rating != null) { %>
                        <!-- Show existing rating -->
                        <div class="rating-display">
                            <span>Your Rating:</span>
                            <% for (int i = 1; i <= 5; i++) { %>
                                <i class="bi bi-star<%= i <= rating ? "-fill star" : "" %>" style="color: #facc15;"></i>
                            <% } %>
                            <span>(<%= rating %>/5)</span>
                        </div>
                        <% if (review != null && !review.trim().isEmpty()) { %>
                        <div class="mt-2">
                            <strong>Your Review:</strong><br>
                            <em>"<%= review %>"</em>
                        </div>
                        <% } %>
                    <% } else { %>
                        <!-- Show rating form -->
                        <p class="mb-2">How was your experience with this service?</p>
                        <button class="btn-pink" onclick="openRatingModal(<%= bookingId %>)">
                            <i class="bi bi-star"></i>Rate This Service
                        </button>
                    <% } %>
                </div>
            <% } %>

            <!-- Cancel Section for Pending/In Progress Services -->
            <% if (canCancel) { %>
                <div class="cancel-section">
                    <h5><i class="bi bi-exclamation-triangle"></i>Cancel Appointment</h5>
                    <p class="mb-2">Need to cancel this appointment? You can cancel up to 2 hours before the scheduled time.</p>
                    <button class="btn-danger" onclick="openCancelModal(<%= bookingId %>)">
                        <i class="bi bi-x-circle"></i>Cancel Appointment
                    </button>
                </div>
            <% } %>
        </div>
        <%
            }
            
            if (!hasBookings) {
        %>
        <div class="no-bookings">
            <i class="bi bi-calendar-x"></i>
            <h3>No Bookings Yet</h3>
            <p>You haven't made any pet care bookings yet.</p>
            <p>Start by finding the perfect care provider for your furry friend!</p>
            <a href="BookYourCare.jsp" class="btn-pink mt-2">
                <i class="bi bi-plus-circle"></i>Book Your First Service
            </a>
        </div>
        <%
            }
            
            bookings.close();
            bookingStmt.close();
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error loading bookings: " + e.getMessage() + "</div>");
        }
        %>
        
        <!-- Success Messages -->
        <% if (request.getParameter("booking") != null && "success".equals(request.getParameter("booking"))) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i>
            <strong>Booking Confirmed Successfully!</strong> Your pet care service has been booked and confirmed. 
            The service provider will contact you shortly to confirm the appointment details.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (request.getParameter("rating") != null && "success".equals(request.getParameter("rating"))) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-star-fill me-2"></i>
            <strong>Rating Submitted!</strong> Thank you for rating your service experience. Your feedback helps us improve our services.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (request.getParameter("cancel") != null && "success".equals(request.getParameter("cancel"))) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-x-circle-fill me-2"></i>
            <strong>Appointment Cancelled!</strong> Your appointment has been cancelled successfully. Any applicable refunds will be processed within 3-5 business days.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (request.getParameter("cancel") != null && "error".equals(request.getParameter("cancel"))) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Cancellation Failed!</strong> Unable to cancel the appointment. Please contact support for assistance.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <div class="text-center mt-3">
            <a href="BookYourCare.jsp" class="btn-pink">
                <i class="bi bi-plus-circle"></i>Book Another Service
            </a>
        </div>
    </div>

    <!-- Rating Modal -->
    <div id="ratingModal" class="modal">
        <div class="modal-content">
            <span class="close-modal" onclick="closeRatingModal()">&times;</span>
            <h3 style="color: var(--pink-color); margin-bottom: 1rem; font-size: 1.25rem;">
                <i class="bi bi-star me-2"></i>Rate Your Service Experience
            </h3>
            <form method="POST" id="ratingForm">
                <input type="hidden" name="action" value="rate">
                <input type="hidden" name="booking_id" id="modal_booking_id">
                
                <div class="mb-3">
                    <label class="form-label">Overall Rating:</label>
                    <div class="rating-stars" id="ratingStars">
                        <i class="bi bi-star rating-star" data-rating="1"></i>
                        <i class="bi bi-star rating-star" data-rating="2"></i>
                        <i class="bi bi-star rating-star" data-rating="3"></i>
                        <i class="bi bi-star rating-star" data-rating="4"></i>
                        <i class="bi bi-star rating-star" data-rating="5"></i>
                    </div>
                    <input type="hidden" name="rating" id="selectedRating" required>
                </div>
                
                <div class="mb-3">
                    <label for="review" class="form-label">Your Review (Optional):</label>
                    <textarea class="form-control" name="review" id="review" rows="3" 
                              placeholder="Share your experience with this service provider..."></textarea>
                </div>
                
                <div class="text-center">
                    <button type="submit" class="btn-pink me-2">
                        <i class="bi bi-check-circle"></i>Submit Rating
                    </button>
                    <button type="button" class="btn-secondary" onclick="closeRatingModal()">
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Cancel Modal -->
    <div id="cancelModal" class="modal">
        <div class="modal-content">
            <span class="close-modal" onclick="closeCancelModal()">&times;</span>
            <h3 style="color: var(--danger-color); margin-bottom: 1rem; font-size: 1.25rem;">
                <i class="bi bi-exclamation-triangle me-2"></i>Cancel Appointment
            </h3>
            <form method="POST" id="cancelForm">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" name="booking_id" id="cancel_booking_id">
                
                <div class="mb-3">
                    <p>Are you sure you want to cancel this appointment?</p>
                    <div class="alert alert-warning">
                        <i class="bi bi-info-circle me-2"></i>
                        <strong>Cancellation Policy:</strong> Appointments cancelled more than 2 hours before the scheduled time are eligible for a full refund.
                    </div>
                </div>
                
                <div class="mb-3">
                    <label for="cancel_reason" class="form-label">Reason for Cancellation (Optional):</label>
                    <textarea class="form-control" name="cancel_reason" id="cancel_reason" rows="3" 
                              placeholder="Please let us know why you're cancelling (optional)..."></textarea>
                </div>
                
                <div class="text-center">
                    <button type="submit" class="btn-danger me-2">
                        <i class="bi bi-x-circle"></i>Confirm Cancellation
                    </button>
                    <button type="button" class="btn-secondary" onclick="closeCancelModal()">
                        Keep Appointment
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <jsp:include page="Footer.jsp" />
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let selectedRating = 0;

        function openRatingModal(bookingId) {
            document.getElementById('modal_booking_id').value = bookingId;
            document.getElementById('ratingModal').style.display = 'block';
            resetRating();
        }

        function closeRatingModal() {
            document.getElementById('ratingModal').style.display = 'none';
            resetRating();
        }

        function resetRating() {
            selectedRating = 0;
            document.getElementById('selectedRating').value = '';
            document.getElementById('review').value = '';
            const stars = document.querySelectorAll('.rating-star');
            stars.forEach(star => {
                star.classList.remove('active');
                star.className = 'bi bi-star rating-star';
            });
        }

        function openCancelModal(bookingId) {
            document.getElementById('cancel_booking_id').value = bookingId;
            document.getElementById('cancelModal').style.display = 'block';
        }

        function closeCancelModal() {
            document.getElementById('cancelModal').style.display = 'none';
            document.getElementById('cancel_reason').value = '';
        }

        // Rating star interaction
        document.addEventListener('DOMContentLoaded', function() {
            const stars = document.querySelectorAll('.rating-star');
            
            stars.forEach(star => {
                star.addEventListener('click', function() {
                    selectedRating = parseInt(this.dataset.rating);
                    document.getElementById('selectedRating').value = selectedRating;
                    
                    // Update star display
                    stars.forEach((s, index) => {
                        if (index < selectedRating) {
                            s.className = 'bi bi-star-fill rating-star active';
                        } else {
                            s.className = 'bi bi-star rating-star';
                        }
                    });
                });
                
                star.addEventListener('mouseenter', function() {
                    const hoverRating = parseInt(this.dataset.rating);
                    stars.forEach((s, index) => {
                        if (index < hoverRating) {
                            s.className = 'bi bi-star-fill rating-star active';
                        } else {
                            s.className = 'bi bi-star rating-star';
                        }
                    });
                });
                
                star.addEventListener('mouseleave', function() {
                    stars.forEach((s, index) => {
                        if (index < selectedRating) {
                            s.className = 'bi bi-star-fill rating-star active';
                        } else {
                            s.className = 'bi bi-star rating-star';
                        }
                    });
                });
            });
        });

        // Close modals when clicking outside
        window.onclick = function(event) {
            const ratingModal = document.getElementById('ratingModal');
            const cancelModal = document.getElementById('cancelModal');
            if (event.target === ratingModal) {
                closeRatingModal();
            }
            if (event.target === cancelModal) {
                closeCancelModal();
            }
        }

        // Form validation
        document.getElementById('ratingForm').addEventListener('submit', function(e) {
            if (selectedRating === 0) {
                e.preventDefault();
                alert('Please select a rating before submitting.');
                return false;
            }
        });

        document.getElementById('cancelForm').addEventListener('submit', function(e) {
            if (!confirm('Are you sure you want to cancel this appointment? This action cannot be undone.')) {
                e.preventDefault();
                return false;
            }
        });
    </script>
</body>
</html>