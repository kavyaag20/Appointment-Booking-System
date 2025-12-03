<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.time.*"%>
<%@page import="java.time.format.*"%>
<%@include file="dbconnect.jsp"%>
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

    // Handle status update requests
    String action = request.getParameter("action");
    String bookingIdParam = request.getParameter("bookingId");
    String newStatus = request.getParameter("status");
    
    if ("updateStatus".equals(action) && bookingIdParam != null && newStatus != null) {
        try {
            int bookingId = Integer.parseInt(bookingIdParam);
            String updateQuery = "UPDATE bookings SET status = ? WHERE booking_id = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
            updateStmt.setString(1, newStatus);
            updateStmt.setInt(2, bookingId);
            int rowsUpdated = updateStmt.executeUpdate();
            updateStmt.close();
            
            if (rowsUpdated > 0) {
                response.sendRedirect("Appointments.jsp?success=1");
                return;
            } else {
                response.sendRedirect("Appointments.jsp?error=1");
                return;
            }
        } catch (Exception e) {
            response.sendRedirect("Appointments.jsp?error=2");
            return;
        }
    }
%>
<%@ include file="Header.jsp" %>

<style>
.table-tabs {
    display: flex;
    margin-bottom: 1rem;
    gap: 1rem;
}

.tab-button {
    padding: 0.8rem 1.5rem;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    background-color: #f8f9fa;
    color: var(--dark-text);
}

.tab-button.active {
    background-color: var(--primary-pink);
    color: white;
}

.tab-button:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
}

.table-content {
    display: none;
}

.table-content.active {
    display: block;
}

.action-buttons {
    display: flex;
    flex-direction: column;
    gap: 0.3rem;
}

.btn-accept {
    background-color: #28a745;
    color: white;
    border: none;
    padding: 0.4rem 0.8rem;
    border-radius: 4px;
    font-size: 0.8rem;
    cursor: pointer;
    transition: background-color 0.3s;
    width: 70px;
}

.btn-accept:hover {
    background-color: #218838;
}

.btn-reject {
    background-color: #dc3545;
    color: white;
    border: none;
    padding: 0.4rem 0.8rem;
    border-radius: 4px;
    font-size: 0.8rem;
    cursor: pointer;
    transition: background-color 0.3s;
    width: 70px;
}

.btn-reject:hover {
    background-color: #c82333;
}

.btn-view {
    background-color: var(--primary-yellow);
    color: var(--dark-text);
    border: none;
    padding: 0.4rem 0.8rem;
    border-radius: 4px;
    font-size: 0.8rem;
    cursor: pointer;
    transition: background-color 0.3s;
}

.btn-view:hover {
    background-color: #e0a800;
}

.status-completed {
    background-color: #d4edda;
    color: #155724;
    padding: 0.3rem 0.6rem;
    border-radius: 4px;
    font-size: 0.8rem;
}

.status-pending {
    background-color: #fff3cd;
    color: #856404;
    padding: 0.3rem 0.6rem;
    border-radius: 4px;
    font-size: 0.8rem;
}

.status-cancelled {
    background-color: #f8d7da;
    color: #721c24;
    padding: 0.3rem 0.6rem;
    border-radius: 4px;
    font-size: 0.8rem;
}

.status-active {
    background-color: #d1ecf1;
    color: #0c5460;
    padding: 0.3rem 0.6rem;
    border-radius: 4px;
    font-size: 0.8rem;
}

/* Modal Styles */
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
    margin: 3% auto;
    padding: 2rem;
    border-radius: 15px;
    width: 95%;
    max-width: 800px;
    position: relative;
    box-shadow: 0 8px 32px rgba(0,0,0,0.3);
}

.close {
    color: #aaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
    position: absolute;
    right: 1rem;
    top: 1rem;
}

.close:hover {
    color: var(--primary-pink);
}

.detail-row {
    display: flex;
    margin-bottom: 1rem;
    padding: 0.5rem 0;
    border-bottom: 1px solid #eee;
}

.detail-label {
    font-weight: 600;
    width: 150px;
    color: var(--primary-pink);
}

.detail-value {
    flex: 1;
}

.alert {
    padding: 0.75rem 1.25rem;
    margin-bottom: 1rem;
    border: 1px solid transparent;
    border-radius: 0.375rem;
}

.alert-success {
    color: #155724;
    background-color: #d4edda;
    border-color: #c3e6cb;
}

.alert-danger {
    color: #721c24;
    background-color: #f8d7da;
    border-color: #f5c6cb;
}

.cancelled-info {
    background-color: #f8f9fa;
    border: 1px solid #dee2e6;
    border-radius: 5px;
    padding: 1rem;
    margin-top: 1rem;
}

.cancelled-info h6 {
    color: #dc3545;
    margin-bottom: 0.5rem;
}
</style>

<div class="main-content">
    <!-- Page Title Section -->
    <h2 class="section-title">Appointments</h2>

    <%
    // Show success/error messages
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    
    if ("1".equals(success)) {
    %>
        <div class="alert alert-success">
            Appointment status updated successfully!
        </div>
    <%
    } else if ("1".equals(error)) {
    %>
        <div class="alert alert-danger">
            Failed to update appointment status. Appointment not found.
        </div>
    <%
    } else if ("2".equals(error)) {
    %>
        <div class="alert alert-danger">
            An error occurred while updating the appointment status.
        </div>
    <%
    }
    %>

    <%
    try {
        // Calculate total revenue (30% of each booking amount)
        String revenueQuery = "SELECT SUM(amount_payable * 0.30) as total_revenue FROM bookings WHERE status = 'completed'";
        PreparedStatement revenueStmt = conn.prepareStatement(revenueQuery);
        ResultSet revenueRs = revenueStmt.executeQuery();
        
        double totalRevenue = 0.0;
        if (revenueRs.next()) {
            totalRevenue = revenueRs.getDouble("total_revenue");
            if (revenueRs.wasNull()) totalRevenue = 0.0;
        }
        revenueRs.close();
        revenueStmt.close();
    %>

    <!-- Tab Buttons -->
    <div class="table-tabs">
        <button class="tab-button active" onclick="showTab('completed')">Completed</button>
        <button class="tab-button" onclick="showTab('pending')">Pending</button>
        <button class="tab-button" onclick="showTab('cancelled')">Cancelled</button>
    </div>

    <!-- Completed Appointments Table -->
    <div id="completed-content" class="table-content active">
        <div class="data-table-container">
            <div class="table-header">
                Completed Appointments
            </div>
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Email</th>
                            <th>Employee ID</th>
                            <th>Service</th>
                            <th>Revenue Earned</th>
                            <th>View</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                       <%
                    // Get completed appointments from completed_appointments table
                    String completedQuery = "SELECT ca.complete_id, ca.booking_id, ca.user_email, ca.employee_id, " +
                                            "ca.owner_name, ca.pet_name, ca.service_type, ca.booking_date, " +
                                            "ca.time_slot, ca.amount_payable, ca.rating, ca.review, " +
                                            "ca.pet_breed, ca.pet_age, ca.phone_number, ca.address, " +
                                            "ca.special_instructions, ca.completed_at, ca.completed_by, " +
                                            "e.full_name as employee_name " +
                                            "FROM completed_appointments ca " +
                                            "LEFT JOIN employee_info e ON ca.employee_id = e.employee_id " +
                                            "ORDER BY ca.completed_at DESC";

                    PreparedStatement completedStmt = conn.prepareStatement(completedQuery);
                    ResultSet completedRs = completedStmt.executeQuery();

                    boolean hasCompletedAppointments = false;

                    while (completedRs.next()) {
                        hasCompletedAppointments = true;

                        // Calculate revenue (30% of booking amount)
                        double completedBookingAmount = completedRs.getDouble("amount_payable");
                        double completedRevenue = completedBookingAmount * 0.30;

                        // Format booking date
                        Date completedBookingDate = completedRs.getDate("booking_date");
                        LocalDate completedLocalDate = completedBookingDate.toLocalDate();
                        String completedFormattedDate = completedLocalDate.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));

                        String completedEmployeeName = completedRs.getString("employee_name");
                        if (completedEmployeeName == null) completedEmployeeName = "Not Assigned";

                        // Create data attributes for modal
                        String completedDataAttributes = String.format(
                            "data-booking-id='%s' data-employee='%s' data-employee-id='%s' data-client='%s' data-service='%s' " +
                            "data-date='%s' data-time='%s' data-pet='%s' data-breed='%s' data-age='%d' " +
                            "data-phone='%s' data-address='%s' data-email='%s' data-amount='%.0f' " +
                            "data-revenue='%.0f' data-status='%s' data-user-id='%s'",
                            completedRs.getInt("booking_id"),
                            completedEmployeeName,
                            completedRs.getInt("employee_id"),
                            completedRs.getString("owner_name"),
                            completedRs.getString("service_type"),
                            completedFormattedDate,
                            completedRs.getString("time_slot"),
                            completedRs.getString("pet_name"),
                            completedRs.getString("pet_breed") != null ? completedRs.getString("pet_breed") : "N/A",
                            completedRs.getInt("pet_age"),
                            completedRs.getString("phone_number") != null ? completedRs.getString("phone_number") : "N/A",
                            completedRs.getString("address") != null ? completedRs.getString("address") : "N/A",
                            completedRs.getString("user_email"),
                            completedBookingAmount,
                            completedRevenue,
                            "completed",
                            completedRs.getString("user_email") // Using email as user_id for now
                        );

                        String completedSpecialInstructions = completedRs.getString("special_instructions");
                        if (completedSpecialInstructions == null) completedSpecialInstructions = "None";

                        Integer completedRating = completedRs.getInt("rating");
                        if (completedRs.wasNull()) completedRating = null;

                        String completedReview = completedRs.getString("review");
                        if (completedReview == null) completedReview = "No review provided";
                    %>

                    <tr class="appointment-row" <%= completedDataAttributes %> 
                        data-instructions="<%= completedSpecialInstructions %>"
                        data-rating="<%= completedRating != null ? completedRating : 0 %>"
                        data-review="<%= completedReview %>">
                        <td><%= completedRs.getString("user_email") %></td>
                        <td><%= completedRs.getInt("employee_id") %></td>
                        <td><%= completedRs.getString("service_type") %></td>
                        <td>₹<%= String.format("%.0f", completedRevenue) %></td>
                        <td>
                            <button class="btn-view" onclick="viewAppointmentDetails(this)">View</button>
                        </td>
                        <td>
                            <span class="status-completed">COMPLETED</span>
                        </td>
                    </tr>

                    <%
                    }

                    if (!hasCompletedAppointments) {
                    %>
                    <tr>
                        <td colspan="6" class="text-center py-5">
                            <div class="text-muted">
                                <i class="bi bi-calendar-check" style="font-size: 3rem; margin-bottom: 1rem; display: block;"></i>
                                <h5>No Completed Appointments</h5>
                                <p>No completed appointments found.</p>
                            </div>
                        </td>
                    </tr>
                    <%
                    }

                    completedRs.close();
                    completedStmt.close();
                    %>
                        
                       
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Pending Appointments Table -->
    <div id="pending-content" class="table-content">
        <div class="data-table-container">
            <div class="table-header">
                Pending Appointments
            </div>
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Email</th>
                            <th>Employee ID</th>
                            <th>Service</th>
                            <th>Revenue Earned</th>
                            <th>View</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            // Get pending appointments
                            String pendingQuery = "SELECT b.booking_id, b.owner_name, b.pet_name, b.pet_age, b.pet_breed, " +
                                                 "b.service_type, b.time_slot, b.address, b.phone_number, " +
                                                 "b.booking_date, b.special_instructions, b.amount_payable, " +
                                                 "b.user_email, b.rating, b.review, b.status, b.created_at, " +
                                                 "b.employee_id, e.full_name as employee_name " +
                                                 "FROM bookings b " +
                                                 "LEFT JOIN employee_info e ON b.employee_id = e.employee_id " +
                                                 "WHERE b.status = 'pending' " +
                                                 "ORDER BY b.created_at DESC";
                            
                            PreparedStatement pendingStmt = conn.prepareStatement(pendingQuery);
                            ResultSet pendingRs = pendingStmt.executeQuery();
                            
                            boolean hasPendingAppointments = false;
                            
                            while (pendingRs.next()) {
                                hasPendingAppointments = true;
                                
                                // Calculate revenue (30% of booking amount)
                                double pendingBookingAmount = pendingRs.getDouble("amount_payable");
                                double pendingRevenue = pendingBookingAmount * 0.30;
                                
                                // Format booking date
                                Date pendingBookingDate = pendingRs.getDate("booking_date");
                                LocalDate pendingLocalDate = pendingBookingDate.toLocalDate();
                                String pendingFormattedDate = pendingLocalDate.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
                                
                                String pendingEmployeeName = pendingRs.getString("employee_name");
                                if (pendingEmployeeName == null) pendingEmployeeName = "Not Assigned";
                                
                                // Create data attributes for modal
                                String pendingDataAttributes = String.format(
                                    "data-booking-id='%s' data-employee='%s' data-employee-id='%s' data-client='%s' data-service='%s' " +
                                    "data-date='%s' data-time='%s' data-pet='%s' data-breed='%s' data-age='%d' " +
                                    "data-phone='%s' data-address='%s' data-email='%s' data-amount='%.0f' " +
                                    "data-revenue='%.0f' data-status='%s' data-user-id='%s'",
                                    pendingRs.getInt("booking_id"),
                                    pendingEmployeeName,
                                    pendingRs.getInt("employee_id"),
                                    pendingRs.getString("owner_name"),
                                    pendingRs.getString("service_type"),
                                    pendingFormattedDate,
                                    pendingRs.getString("time_slot"),
                                    pendingRs.getString("pet_name"),
                                    pendingRs.getString("pet_breed"),
                                    pendingRs.getInt("pet_age"),
                                    pendingRs.getString("phone_number"),
                                    pendingRs.getString("address"),
                                    pendingRs.getString("user_email"),
                                    pendingBookingAmount,
                                    pendingRevenue,
                                    "pending",
                                    pendingRs.getString("user_email") // Using email as user_id for now
                                );
                                
                                String pendingSpecialInstructions = pendingRs.getString("special_instructions");
                                if (pendingSpecialInstructions == null) pendingSpecialInstructions = "None";
                        %>
                        
                        <tr class="appointment-row" <%= pendingDataAttributes %> 
                            data-instructions="<%= pendingSpecialInstructions %>">
                            <td><%= pendingRs.getString("user_email") %></td>
                            <td><%= pendingRs.getInt("employee_id") %></td>
                            <td><%= pendingRs.getString("service_type") %></td>
                            <td>₹<%= String.format("%.0f", pendingRevenue) %></td>
                            <td>
                                <button class="btn-view" onclick="viewAppointmentDetails(this)">View</button>
                            </td>
                            <td>
                                <span class="status-pending">PENDING</span>
                            </td>
                        </tr>
                        
                        <%
                            }
                            
                            if (!hasPendingAppointments) {
                        %>
                        <tr>
                            <td colspan="6" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="bi bi-calendar-x" style="font-size: 3rem; margin-bottom: 1rem; display: block;"></i>
                                    <h5>No Pending Appointments</h5>
                                    <p>No pending appointments found.</p>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                            
                            pendingRs.close();
                            pendingStmt.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6'><div class='alert alert-danger'>Error loading pending appointments: " + e.getMessage() + "</div></td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Cancelled Appointments Table -->
    <div id="cancelled-content" class="table-content">
        <div class="data-table-container">
            <div class="table-header">
                Cancelled Appointments
            </div>
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Email</th>
                            <th>Employee ID</th>
                            <th>Service</th>
                            <th>Amount Lost</th>
                            <th>View</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            // Get cancelled appointments from cancelled_appointments table
                            String cancelledQuery = "SELECT ca.*, b.special_instructions, b.rating, b.review, " +
                                                   "b.created_at, e.full_name as employee_name " +
                                                   "FROM cancelled_appointments ca " +
                                                   "LEFT JOIN bookings b ON ca.booking_id = b.booking_id " +
                                                   "LEFT JOIN employee_info e ON ca.employee_id = e.employee_id " +
                                                   "ORDER BY ca.cancelled_at DESC";
                            
                            PreparedStatement cancelledStmt = conn.prepareStatement(cancelledQuery);
                            ResultSet cancelledRs = cancelledStmt.executeQuery();
                            
                            boolean hasCancelledAppointments = false;
                            
                            while (cancelledRs.next()) {
                                hasCancelledAppointments = true;
                                
                                // Calculate lost revenue (30% of booking amount)
                                double cancelledBookingAmount = cancelledRs.getDouble("amount_payable");
                                double cancelledLostRevenue = cancelledBookingAmount * 0.30;
                                
                                // Format booking date
                                Date cancelledBookingDate = cancelledRs.getDate("booking_date");
                                LocalDate cancelledLocalDate = cancelledBookingDate.toLocalDate();
                                String cancelledFormattedDate = cancelledLocalDate.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
                                
                                String cancelledEmployeeName = cancelledRs.getString("employee_name");
                                if (cancelledEmployeeName == null) cancelledEmployeeName = "Not Assigned";
                                
                                // Create data attributes for modal
                                String cancelledDataAttributes = String.format(
                                    "data-booking-id='%s' data-employee='%s' data-employee-id='%s' data-client='%s' data-service='%s' " +
                                    "data-date='%s' data-time='%s' data-pet='%s' data-breed='%s' data-age='0' " +
                                    "data-phone='0' data-address='' data-email='%s' data-amount='%.0f' " +
                                    "data-revenue='%.0f' data-status='%s' data-user-id='%s'",
                                    cancelledRs.getInt("booking_id"),
                                    cancelledEmployeeName,
                                    cancelledRs.getInt("employee_id"),
                                    cancelledRs.getString("owner_name"),
                                    cancelledRs.getString("service_type"),
                                    cancelledFormattedDate,
                                    cancelledRs.getString("time_slot"),
                                    cancelledRs.getString("pet_name"),
                                    "N/A", // pet_breed not available in cancelled_appointments
                                    cancelledRs.getString("user_email"),
                                    cancelledBookingAmount,
                                    cancelledLostRevenue,
                                    "cancelled",
                                    cancelledRs.getString("user_email")
                                );
                                
                                String cancelReason = cancelledRs.getString("cancel_reason");
                                if (cancelReason == null || cancelReason.trim().isEmpty()) cancelReason = "No reason provided";
                                
                                Timestamp cancelledAt = cancelledRs.getTimestamp("cancelled_at");
                                String cancelledBy = cancelledRs.getString("cancelled_by");
                        %>
                        
                        <tr class="appointment-row" <%= cancelledDataAttributes %> 
                            data-instructions="<%= cancelReason %>"
                            data-cancelled-at="<%= cancelledAt.toString() %>"
                            data-cancelled-by="<%= cancelledBy %>">
                            <td><%= cancelledRs.getString("user_email") %></td>
                            <td><%= cancelledRs.getInt("employee_id") %></td>
                            <td><%= cancelledRs.getString("service_type") %></td>
                            <td style="color: #dc3545;">-₹<%= String.format("%.0f", cancelledLostRevenue) %></td>
                            <td>
                                <button class="btn-view" onclick="viewCancelledDetails(this)">View</button>
                            </td>
                            <td>
                                <span class="status-cancelled">CANCELLED</span>
                            </td>
                        </tr>
                        
                        <%
                            }
                            
                            if (!hasCancelledAppointments) {
                        %>
                        <tr>
                            <td colspan="6" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="bi bi-calendar-x" style="font-size: 3rem; margin-bottom: 1rem; display: block;"></i>
                                    <h5>No Cancelled Appointments</h5>
                                    <p>No cancelled appointments found.</p>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                            
                            cancelledRs.close();
                            cancelledStmt.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6'><div class='alert alert-danger'>Error loading cancelled appointments: " + e.getMessage() + "</div></td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <%
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Database error: " + e.getMessage() + "</div>");
    }
    %>

    <!-- Appointment Details Modal -->
    <div id="appointmentDetailsModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2 style="color: var(--primary-pink); margin-bottom: 2rem;">Appointment Details</h2>
            
            <div class="detail-row">
                <div class="detail-label">Booking ID:</div>
                <div class="detail-value" id="modal-booking-id"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">User ID:</div>
                <div class="detail-value" id="modal-user-id"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Employee ID:</div>
                <div class="detail-value" id="modal-employee-id"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Employee:</div>
                <div class="detail-value" id="modal-employee"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Client Name:</div>
                <div class="detail-value" id="modal-client-name"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Service Type:</div>
                <div class="detail-value" id="modal-service"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Date & Time:</div>
                <div class="detail-value" id="modal-date-time"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Pet Details:</div>
                <div class="detail-value" id="modal-pet-details"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Phone:</div>
                <div class="detail-value" id="modal-phone"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Email:</div>
                <div class="detail-value" id="modal-email"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Address:</div>
                <div class="detail-value" id="modal-address"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Total Amount:</div>
                <div class="detail-value" id="modal-total-amount"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Revenue Earned (30%):</div>
                <div class="detail-value" id="modal-revenue-amount" style="color: var(--primary-pink); font-weight: 600;"></div>
            </div>
            <div class="detail-row" id="rating-section" style="display: none;">
                <div class="detail-label">Rating:</div>
                <div class="detail-value" id="modal-rating"></div>
            </div>
            <div class="detail-row" id="review-section" style="display: none;">
                <div class="detail-label">Review:</div>
                <div class="detail-value" id="modal-review" style="font-style: italic; background: #f8f9fa; padding: 0.5rem; border-radius: 5px;"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Special Instructions:</div>
                <div class="detail-value" id="modal-instructions" style="background: #f8f9fa; padding: 0.5rem; border-radius: 5px;"></div>
            </div>
        </div>
    </div>

    <!-- Cancelled Appointment Details Modal -->
    <div id="cancelledDetailsModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeCancelledModal()">&times;</span>
            <h2 style="color: #dc3545; margin-bottom: 2rem;">Cancelled Appointment Details</h2>
            
            <div class="detail-row">
                <div class="detail-label">Booking ID:</div>
                <div class="detail-value" id="cancelled-modal-booking-id"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">User Email:</div>
                <div class="detail-value" id="cancelled-modal-user-id"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Employee ID:</div>
                <div class="detail-value" id="cancelled-modal-employee-id"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Employee:</div>
                <div class="detail-value" id="cancelled-modal-employee"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Client Name:</div>
                <div class="detail-value" id="cancelled-modal-client-name"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Service Type:</div>
                <div class="detail-value" id="cancelled-modal-service"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Date & Time:</div>
                <div class="detail-value" id="cancelled-modal-date-time"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Pet Name:</div>
                <div class="detail-value" id="cancelled-modal-pet-details"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Total Amount:</div>
                <div class="detail-value" id="cancelled-modal-total-amount"></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Revenue Lost (30%):</div>
                <div class="detail-value" id="cancelled-modal-revenue-amount" style="color: #dc3545; font-weight: 600;"></div>
            </div>
            
            <div class="cancelled-info">
                <h6><i class="bi bi-x-circle me-2"></i>Cancellation Information</h6>
                <div class="detail-row" style="border-bottom: none; margin-bottom: 0.5rem;">
                    <div class="detail-label">Cancelled At:</div>
                    <div class="detail-value" id="cancelled-modal-cancelled-at"></div>
                </div>
                <div class="detail-row" style="border-bottom: none; margin-bottom: 0.5rem;">
                    <div class="detail-label">Cancelled By:</div>
                    <div class="detail-value" id="cancelled-modal-cancelled-by"></div>
                </div>
                <div class="detail-row" style="border-bottom: none; margin-bottom: 0;">
                    <div class="detail-label">Reason:</div>
                    <div class="detail-value" id="cancelled-modal-instructions" style="background: #fff; padding: 0.5rem; border-radius: 5px; border: 1px solid #dee2e6;"></div>
                </div>
            </div>
        </div>
    </div>

</div>

<script>
function showTab(tabName) {
    // Hide all tab contents
    document.querySelectorAll('.table-content').forEach(content => {
        content.classList.remove('active');
    });
    
    // Remove active class from all buttons
    document.querySelectorAll('.tab-button').forEach(button => {
        button.classList.remove('active');
    });
    
    // Show selected tab content
    document.getElementById(tabName + '-content').classList.add('active');
    
    // Add active class to clicked button
    document.querySelector('[onclick="showTab(\'' + tabName + '\')"]').classList.add('active');
}

function viewAppointmentDetails(button) {
    const row = button.closest('tr');
    
    // Basic info
    document.getElementById('modal-booking-id').textContent = '#' + row.getAttribute('data-booking-id');
    document.getElementById('modal-user-id').textContent = row.getAttribute('data-user-id');
    document.getElementById('modal-employee-id').textContent = row.getAttribute('data-employee-id');
    document.getElementById('modal-employee').textContent = row.getAttribute('data-employee');
    document.getElementById('modal-service').textContent = row.getAttribute('data-service');
    document.getElementById('modal-date-time').textContent = row.getAttribute('data-date') + ' at ' + row.getAttribute('data-time');
    document.getElementById('modal-client-name').textContent = row.getAttribute('data-client');
    document.getElementById('modal-pet-details').textContent = row.getAttribute('data-pet') + ' (' + row.getAttribute('data-breed') + ', ' + row.getAttribute('data-age') + ' years)';
    document.getElementById('modal-phone').textContent = row.getAttribute('data-phone');
    document.getElementById('modal-email').textContent = row.getAttribute('data-email');
    document.getElementById('modal-address').textContent = row.getAttribute('data-address');
    document.getElementById('modal-total-amount').textContent = '₹' + row.getAttribute('data-amount');
    document.getElementById('modal-revenue-amount').textContent = '₹' + row.getAttribute('data-revenue');
    document.getElementById('modal-instructions').textContent = row.getAttribute('data-instructions');
    
    // Rating and review (only for completed appointments)
    var rating = parseInt(row.getAttribute('data-rating'));
    var review = row.getAttribute('data-review');
    var status = row.getAttribute('data-status');
    
    if (status === 'completed' && rating > 0) {
        document.getElementById('rating-section').style.display = 'flex';
        document.getElementById('review-section').style.display = 'flex';
        
        // Generate star rating
        var stars = '';
        for (var i = 1; i <= 5; i++) {
            if (i <= rating) {
                stars += '<i class="bi bi-star-fill" style="color: var(--primary-yellow); margin-right: 2px;"></i>';
            } else {
                stars += '<i class="bi bi-star" style="color: #ddd; margin-right: 2px;"></i>';
            }
        }
        document.getElementById('modal-rating').innerHTML = stars + ' (' + rating + '/5)';
        
        // Show review if available
        if (review && review !== 'No review provided') {
            document.getElementById('modal-review').textContent = '"' + review + '"';
        } else {
            document.getElementById('modal-review').textContent = 'No review provided';
        }
    } else {
        document.getElementById('rating-section').style.display = 'none';
        document.getElementById('review-section').style.display = 'none';
    }
    
    // Show modal
    document.getElementById('appointmentDetailsModal').style.display = 'block';
}

function viewCancelledDetails(button) {
    const row = button.closest('tr');
    
    // Basic info
    document.getElementById('cancelled-modal-booking-id').textContent = '#' + row.getAttribute('data-booking-id');
    document.getElementById('cancelled-modal-user-id').textContent = row.getAttribute('data-user-id');
    document.getElementById('cancelled-modal-employee-id').textContent = row.getAttribute('data-employee-id');
    document.getElementById('cancelled-modal-employee').textContent = row.getAttribute('data-employee');
    document.getElementById('cancelled-modal-service').textContent = row.getAttribute('data-service');
    document.getElementById('cancelled-modal-date-time').textContent = row.getAttribute('data-date') + ' at ' + row.getAttribute('data-time');
    document.getElementById('cancelled-modal-client-name').textContent = row.getAttribute('data-client');
    document.getElementById('cancelled-modal-pet-details').textContent = row.getAttribute('data-pet');
    document.getElementById('cancelled-modal-total-amount').textContent = '₹' + row.getAttribute('data-amount');
    document.getElementById('cancelled-modal-revenue-amount').textContent = '-₹' + row.getAttribute('data-revenue');
    document.getElementById('cancelled-modal-instructions').textContent = row.getAttribute('data-instructions');
    document.getElementById('cancelled-modal-cancelled-at').textContent = row.getAttribute('data-cancelled-at');
    
    var cancelledBy = row.getAttribute('data-cancelled-by');
    var cancelledByText = '';
    switch(cancelledBy) {
        case 'user': cancelledByText = 'Customer'; break;
        case 'admin': cancelledByText = 'Admin'; break;
        case 'employee': cancelledByText = 'Service Provider'; break;
        default: cancelledByText = 'System'; break;
    }
    document.getElementById('cancelled-modal-cancelled-by').textContent = cancelledByText;
    
    // Show modal
    document.getElementById('cancelledDetailsModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('appointmentDetailsModal').style.display = 'none';
}

function closeCancelledModal() {
    document.getElementById('cancelledDetailsModal').style.display = 'none';
}

// Close modal when clicking outside of it
window.onclick = function(event) {
    const modal = document.getElementById('appointmentDetailsModal');
    const cancelledModal = document.getElementById('cancelledDetailsModal');
    if (event.target == modal) {
        closeModal();
    }
    if (event.target == cancelledModal) {
        closeCancelledModal();
    }
}

function updateStatus(bookingId, newStatus) {
    var actionText = newStatus === 'completed' ? 'accept' : 'reject';
    if (confirm('Are you sure you want to ' + actionText + ' this appointment?')) {
        // Create a form and submit it
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = 'Appointments.jsp';
        
        var actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'updateStatus';
        
        var bookingIdInput = document.createElement('input');
        bookingIdInput.type = 'hidden';
        bookingIdInput.name = 'bookingId';
        bookingIdInput.value = bookingId;
        
        var statusInput = document.createElement('input');
        statusInput.type = 'hidden';
        statusInput.name = 'status';
        statusInput.value = newStatus;
        
        form.appendChild(actionInput);
        form.appendChild(bookingIdInput);
        form.appendChild(statusInput);
        
        document.body.appendChild(form);
        form.submit();
    }
}

// Initialize page - show completed tab by default
document.addEventListener('DOMContentLoaded', function() {
    showTab('completed');
});
</script>