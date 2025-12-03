<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.time.*"%>
<%@page import="java.time.format.*"%>
<%@include file="dbconnect.jsp"%>
<%
    // Check if employee is logged in
    String employeeName = (String) session.getAttribute("employeeName");
    String employeeId = (String) session.getAttribute("employee_id");
    if (employeeName == null || employeeId == null) {
        response.sendRedirect("empLogin.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Appointments - Book Your Care</title>
    <!-- Bootstrap CSS & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-pink: #e83e8c;
            --primary-yellow: #ffc107;
            --light-yellow: #fff9e6;
            --dark-text: #333333;
            --danger-color: #dc3545;
        }
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
            color: var(--dark-text);
        }
        .main-content {
            margin-left: 280px;
            margin-top: 70px;
            padding: 1rem;
        }
        .section-title {
            color: var(--primary-pink);
            font-weight: 600;
            margin-bottom: 1rem;
            font-size: 1.5rem;
            border-bottom: 2px solid var(--primary-yellow);
            padding-bottom: 0.3rem;
        }
        
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
        
        .table-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            border: 1px solid var(--light-yellow);
            padding: 0;
            margin-bottom: 1.5rem;
            overflow: hidden;
        }
        .table-header {
            background: var(--primary-pink);
            color: white;
            padding: 0.8rem 1rem;
            font-size: 1rem;
            font-weight: 600;
        }
        .appointments-table {
            width: 100%;
            border-collapse: collapse;
            border-radius: 0 0 12px 12px;
        }
        .appointments-table thead {
            background: var(--light-yellow);
        }
        .appointments-table thead th {
            font-weight: 600;
            color: var(--dark-text);
            padding: 0.7rem;
            border: none;
            font-size: 0.9rem;
        }
        .appointments-table tbody td {
            padding: 0.7rem;
            vertical-align: middle;
            background: white;
            font-size: 0.9rem;
            border-bottom: 1px solid #f3e9e9;
        }
        .appointments-table tbody tr:last-child td {
            border-bottom: none;
        }
        .view-btn {
            background: var(--primary-yellow);
            color: var(--dark-text);
            border: none;
            padding: 0.3rem 0.8rem;
            border-radius: 6px;
            font-weight: 500;
            font-size: 0.85rem;
            transition: background 0.2s;
            cursor: pointer;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .view-btn:hover {
            background: #ffd633;
        }
        .earnings-highlight {
            color: #28a745;
            font-weight: 600;
            font-size: 0.95rem;
        }
        .earnings-lost {
            color: var(--danger-color);
            font-weight: 600;
            font-size: 0.95rem;
        }
        .status-badge {
            background: #d4edda;
            color: #155724;
            padding: 0.2rem 0.6rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
        }
        .status-cancelled {
            background: #f8d7da;
            color: #721c24;
            padding: 0.2rem 0.6rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
        }
        .no-appointments {
            text-align: center;
            padding: 2rem 1rem;
            background: white;
            border-radius: 12px;
            border: 1px solid var(--light-yellow);
            margin-top: 1rem;
        }
        .no-appointments i {
            font-size: 2rem;
            color: var(--primary-yellow);
            margin-bottom: 0.8rem;
        }
        /* Modal Styles */
        .modal-content {
            border-radius: 8px;
            border: 1px solid var(--light-yellow);
            font-family: 'Poppins', sans-serif;
        }
        .modal-header {
            background: var(--primary-pink);
            color: white;
            border-radius: 8px 8px 0 0;
            border-bottom: none;
        }
        .modal-title {
            font-weight: 600;
            font-size: 1.1rem;
        }
        .modal-body {
            padding: 1.5rem;
        }
        .details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem 1.5rem;
        }
        .modal-body-label {
            font-weight: 500;
            color: var(--primary-pink);
            margin-bottom: 0.1rem;
            font-size: 0.9rem;
        }
        .modal-body-data {
            color: var(--dark-text);
            font-size: 0.9rem;
            margin-bottom: 0.6rem;
            word-break: break-word;
        }
        .cancellation-info {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 1rem;
        }
        .cancellation-info h6 {
            color: var(--danger-color);
            margin-bottom: 0.5rem;
            font-weight: 600;
        }
        .alert {
            padding: 0.75rem;
            border-radius: 6px;
            font-size: 0.875rem;
            border: 1px solid;
            margin-bottom: 1rem;
        }
        .alert-danger {
            background: #fee2e2;
            border-color: #fecaca;
            color: #991b1b;
        }
        @media (max-width: 900px) {
            .main-content {
                margin-left: 0;
                padding: 0.8rem;
            }
            .table-card {
                padding: 0;
            }
            .appointments-table th, .appointments-table td {
                padding: 0.5rem;
                font-size: 0.85rem;
            }
            .details-grid {
                grid-template-columns: 1fr;
            }
            .table-tabs {
                flex-wrap: wrap;
            }
            .tab-button {
                flex: 1;
                min-width: 120px;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="Header.jsp" />

    <div class="main-content">
        <h2 class="section-title">My Appointments</h2>
        
        <!-- Tab Buttons -->
        <div class="table-tabs">
            <button class="tab-button active" onclick="showTab('completed')">Completed</button>
            <button class="tab-button" onclick="showTab('cancelled')">Cancelled</button>
        </div>

        <!-- Completed Appointments Table -->
        <div id="completed-content" class="table-content active">
            <div class="table-card">
                <div class="table-header">Completed Appointments</div>
                <table class="appointments-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Client</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Earnings</th>
                            <th>View</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            String completedQuery = "SELECT b.booking_id, b.owner_name, b.pet_name, b.pet_age, b.pet_breed, " +
                                                   "b.service_type, b.time_slot, b.address, b.phone_number, " +
                                                   "b.booking_date, b.special_instructions, b.amount_payable, " +
                                                   "b.user_email, b.rating, b.review, b.updated_at " +
                                                   "FROM bookings b " +
                                                   "WHERE b.employee_id = ? " +
                                                   "AND b.status = 'completed' " +
                                                   "ORDER BY b.updated_at DESC";
                            PreparedStatement completedStmt = conn.prepareStatement(completedQuery);
                            completedStmt.setString(1, employeeId);
                            ResultSet completedRs = completedStmt.executeQuery();
                            boolean hasCompleted = false;
                            
                            while (completedRs.next()) {
                                hasCompleted = true;
                                Date bookingDate = completedRs.getDate("booking_date");
                                LocalDate localDate = bookingDate.toLocalDate();
                                String formattedDate = localDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
                                String bookingId = "#" + completedRs.getInt("booking_id");
                                int totalAmount = completedRs.getInt("amount_payable");
                                int employeeEarnings = (int)(totalAmount * 0.7);
                                String timeSlot = completedRs.getString("time_slot");
                        %>
                        <tr>
                            <td><%= bookingId %></td>
                            <td><%= completedRs.getString("owner_name") %></td>
                            <td><%= formattedDate %></td>
                            <td><%= timeSlot.substring(0,1).toUpperCase() + timeSlot.substring(1) %></td>
                            <td>
                                <div class="earnings-highlight">₹<%= employeeEarnings %></div>
                            </td>
                            <td>
                                <button class="view-btn" data-bs-toggle="modal" data-bs-target="#viewModal<%= completedRs.getInt("booking_id") %>">View</button>
                                <!-- Modal -->
                                <div class="modal fade" id="viewModal<%= completedRs.getInt("booking_id") %>" tabindex="-1" aria-labelledby="viewModalLabel<%= completedRs.getInt("booking_id") %>" aria-hidden="true">
                                    <div class="modal-dialog modal-dialog-centered modal-lg">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title" id="viewModalLabel<%= completedRs.getInt("booking_id") %>">Appointment Details <%= bookingId %></h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <div class="details-grid">
                                                    <div>
                                                        <div class="modal-body-label">Client Name</div>
                                                        <div class="modal-body-data"><%= completedRs.getString("owner_name") %></div>

                                                        <div class="modal-body-label">Phone Number</div>
                                                        <div class="modal-body-data"><%= completedRs.getString("phone_number") %></div>

                                                        <div class="modal-body-label">Email</div>
                                                        <div class="modal-body-data"><%= completedRs.getString("user_email") %></div>
                                                        
                                                        <div class="modal-body-label">Pet Name</div>
                                                        <div class="modal-body-data"><%= completedRs.getString("pet_name") %></div>
                                                        
                                                        <div class="modal-body-label">Pet Breed</div>
                                                        <div class="modal-body-data"><%= completedRs.getString("pet_breed") %></div>
                                                        
                                                        <div class="modal-body-label">Pet Age</div>
                                                        <div class="modal-body-data"><%= completedRs.getInt("pet_age") %> years</div>
                                                    </div>
                                                    <div>
                                                        <div class="modal-body-label">Service</div>
                                                        <div class="modal-body-data"><%= completedRs.getString("service_type") %></div>
                                                        
                                                        <div class="modal-body-label">Address</div>
                                                        <div class="modal-body-data"><%= completedRs.getString("address") %></div>
                                                        
                                                        <div class="modal-body-label">Special Instructions</div>
                                                        <div class="modal-body-data">
                                                            <%
                                                            String specialInst = completedRs.getString("special_instructions");
                                                            if (specialInst != null && !specialInst.trim().isEmpty()) {
                                                                out.print(specialInst);
                                                            } else {
                                                                out.print("None");
                                                            }
                                                            %>
                                                        </div>
                                                        
                                                        <div class="modal-body-label">Total Amount</div>
                                                        <div class="modal-body-data">₹<%= totalAmount %></div>
                                                        
                                                        <div class="modal-body-label">Employee Earnings</div>
                                                        <div class="modal-body-data">₹<%= employeeEarnings %></div>
                                                        
                                                        <div class="modal-body-label">Date</div>
                                                        <div class="modal-body-data"><%= formattedDate %></div>
                                                        
                                                        <div class="modal-body-label">Time</div>
                                                        <div class="modal-body-data"><%= timeSlot.substring(0,1).toUpperCase() + timeSlot.substring(1) %></div>
                                                    </div>
                                                </div>
                                                <hr>
                                                <div class="details-grid">
                                                    <div>
                                                        <div class="modal-body-label">Rating</div>
                                                        <div class="modal-body-data">
                                                            <% 
                                                            Integer rating = completedRs.getInt("rating"); 
                                                            if (completedRs.wasNull()) rating = null;
                                                            if (rating != null && rating > 0) { 
                                                            %>
                                                                <span>
                                                                    <% for (int i = 1; i <= 5; i++) { %>
                                                                        <i class="bi bi-star<%= i <= rating ? "-fill" : "" %>" style="color: var(--primary-yellow);"></i>
                                                                    <% } %>
                                                                    (<%= rating %>/5)
                                                                </span>
                                                            <% } else { %>
                                                                <span style="color: #6c757d;">No rating</span>
                                                            <% } %>
                                                        </div>
                                                    </div>
                                                    <div>
                                                        <div class="modal-body-label">Review</div>
                                                        <div class="modal-body-data">
                                                            <%
                                                            String review = completedRs.getString("review");
                                                            if (review != null && !review.trim().isEmpty()) {
                                                                out.print(review);
                                                            } else {
                                                                out.print("No review provided");
                                                            }
                                                            %>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div style="margin-top:1rem;">
                                                    <span class="modal-body-label">Status</span>
                                                    <span class="status-badge"><i class="bi bi-check-circle"></i> Completed</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!-- End Modal -->
                            </td>
                        </tr>
                        <%
                            }
                            
                            if (!hasCompleted) {
                        %>
                        <tr>
                            <td colspan="6">
                                <div class="no-appointments">
                                    <i class="bi bi-calendar-check"></i>
                                    <h4 style="color: var(--primary-pink);">No Completed Appointments</h4>
                                    <p>You haven't completed any appointments yet.</p>
                                    <p>Completed appointments will appear here after you mark them as finished.</p>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                            
                            completedRs.close();
                            completedStmt.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6'><div class='alert alert-danger'>Error loading completed appointments: " + e.getMessage() + "</div></td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Cancelled Appointments Table -->
        <div id="cancelled-content" class="table-content">
            <div class="table-card">
                <div class="table-header">Cancelled Appointments</div>
                <table class="appointments-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Client</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Lost Earnings</th>
                            <th>View</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            String cancelledQuery = "SELECT ca.*, b.special_instructions " +
                                                   "FROM cancelled_appointments ca " +
                                                   "LEFT JOIN bookings b ON ca.booking_id = b.booking_id " +
                                                   "WHERE ca.employee_id = ? " +
                                                   "ORDER BY ca.cancelled_at DESC";
                            PreparedStatement cancelledStmt = conn.prepareStatement(cancelledQuery);
                            cancelledStmt.setString(1, employeeId);
                            ResultSet cancelledRs = cancelledStmt.executeQuery();
                            boolean hasCancelled = false;
                            
                            while (cancelledRs.next()) {
                                hasCancelled = true;
                                Date bookingDate = cancelledRs.getDate("booking_date");
                                LocalDate localDate = bookingDate.toLocalDate();
                                String formattedDate = localDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
                                String bookingId = "#" + cancelledRs.getInt("booking_id");
                                int totalAmount = cancelledRs.getInt("amount_payable");
                                int lostEarnings = (int)(totalAmount * 0.7);
                                String timeSlot = cancelledRs.getString("time_slot");
                                
                                String cancelReason = cancelledRs.getString("cancel_reason");
                                if (cancelReason == null || cancelReason.trim().isEmpty()) cancelReason = "No reason provided";
                                
                                Timestamp cancelledAt = cancelledRs.getTimestamp("cancelled_at");
                                String cancelledBy = cancelledRs.getString("cancelled_by");
                                String cancelledByText = "";
                                switch(cancelledBy) {
                                    case "user": cancelledByText = "Customer"; break;
                                    case "admin": cancelledByText = "Admin"; break;
                                    case "employee": cancelledByText = "Service Provider"; break;
                                    default: cancelledByText = "System"; break;
                                }
                        %>
                        <tr>
                            <td><%= bookingId %></td>
                            <td><%= cancelledRs.getString("owner_name") %></td>
                            <td><%= formattedDate %></td>
                            <td><%= timeSlot.substring(0,1).toUpperCase() + timeSlot.substring(1) %></td>
                            <td>
                                <div class="earnings-lost">-₹<%= lostEarnings %></div>
                            </td>
                            <td>
                                <button class="view-btn" data-bs-toggle="modal" data-bs-target="#cancelledModal<%= cancelledRs.getInt("booking_id") %>">View</button>
                                <!-- Modal -->
                                <div class="modal fade" id="cancelledModal<%= cancelledRs.getInt("booking_id") %>" tabindex="-1" aria-labelledby="cancelledModalLabel<%= cancelledRs.getInt("booking_id") %>" aria-hidden="true">
                                    <div class="modal-dialog modal-dialog-centered modal-lg">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title" id="cancelledModalLabel<%= cancelledRs.getInt("booking_id") %>">Cancelled Appointment Details <%= bookingId %></h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <div class="details-grid">
                                                    <div>
                                                        <div class="modal-body-label">Client Name</div>
                                                        <div class="modal-body-data"><%= cancelledRs.getString("owner_name") %></div>

                                                        <div class="modal-body-label">Pet Name</div>
                                                        <div class="modal-body-data"><%= cancelledRs.getString("pet_name") %></div>
                                                        
                                                        <div class="modal-body-label">Service</div>
                                                        <div class="modal-body-data"><%= cancelledRs.getString("service_type") %></div>
                                                        
                                                        <div class="modal-body-label">Date</div>
                                                        <div class="modal-body-data"><%= formattedDate %></div>
                                                        
                                                        <div class="modal-body-label">Time</div>
                                                        <div class="modal-body-data"><%= timeSlot.substring(0,1).toUpperCase() + timeSlot.substring(1) %></div>
                                                    </div>
                                                    <div>
                                                        <div class="modal-body-label">Total Amount</div>
                                                        <div class="modal-body-data">₹<%= totalAmount %></div>
                                                        
                                                        <div class="modal-body-label">Lost Earnings</div>
                                                        <div class="modal-body-data" style="color: var(--danger-color);">-₹<%= lostEarnings %></div>
                                                        
                                                        <div class="modal-body-label">Email</div>
                                                        <div class="modal-body-data"><%= cancelledRs.getString("user_email") %></div>
                                                        
                                                        <div class="modal-body-label">Cancelled At</div>
                                                        <div class="modal-body-data"><%= cancelledAt.toString() %></div>
                                                        
                                                        <div class="modal-body-label">Cancelled By</div>
                                                        <div class="modal-body-data"><%= cancelledByText %></div>
                                                    </div>
                                                </div>
                                                
                                                <div class="cancellation-info">
                                                    <h6><i class="bi bi-x-circle me-2"></i>Cancellation Information</h6>
                                                    <div style="margin-bottom: 0.5rem;">
                                                        <strong>Reason:</strong> <%= cancelReason %>
                                                    </div>
                                                    <%
                                                    String specialInstructions = cancelledRs.getString("special_instructions");
                                                    if (specialInstructions != null && !specialInstructions.trim().isEmpty()) {
                                                    %>
                                                    <div>
                                                        <strong>Original Special Instructions:</strong> <%= specialInstructions %>
                                                    </div>
                                                    <% } %>
                                                </div>
                                                
                                                <div style="margin-top:1rem;">
                                                    <span class="modal-body-label">Status</span>
                                                    <span class="status-cancelled"><i class="bi bi-x-circle"></i> Cancelled</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!-- End Modal -->
                            </td>
                        </tr>
                        <%
                            }
                            
                            if (!hasCancelled) {
                        %>
                        <tr>
                            <td colspan="6">
                                <div class="no-appointments">
                                    <i class="bi bi-calendar-x"></i>
                                    <h4 style="color: var(--danger-color);">No Cancelled Appointments</h4>
                                    <p>You don't have any cancelled appointments.</p>
                                    <p>Cancelled appointments will appear here if clients cancel their bookings.</p>
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
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
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

        // Initialize page - show completed tab by default
        document.addEventListener('DOMContentLoaded', function() {
            showTab('completed');
        });
    </script>
</body>
</html>