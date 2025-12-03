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

    String updateStatus = "";
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("action") != null) {
       // Replace the completion logic in pendingApp.jsp with this corrected version

        if ("complete".equals(request.getParameter("action"))) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("booking_id"));

                // Start transaction
                conn.setAutoCommit(false);

                // First, get the booking data to transfer
                String selectQuery = "SELECT * FROM bookings WHERE booking_id = ? AND employee_id = ? AND status = 'pending'";
                PreparedStatement selectStmt = conn.prepareStatement(selectQuery);
                selectStmt.setInt(1, bookingId);
                selectStmt.setString(2, employeeId);
                ResultSet rs = selectStmt.executeQuery();

                if (rs.next()) {
                    // Insert into completed_appointments table
                    String insertQuery = "INSERT INTO completed_appointments " +
                                       "(booking_id, user_email, employee_id, owner_name, pet_name, service_type, " +
                                       "booking_date, time_slot, amount_payable, special_instructions, rating, " +
                                       "review, pet_breed, pet_age, phone_number, address, completed_at, completed_by) " +
                                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), 'employee')";

                    PreparedStatement insertStmt = conn.prepareStatement(insertQuery);
                    insertStmt.setInt(1, rs.getInt("booking_id"));
                    insertStmt.setString(2, rs.getString("user_email"));
                    insertStmt.setString(3, rs.getString("employee_id"));
                    insertStmt.setString(4, rs.getString("owner_name"));
                    insertStmt.setString(5, rs.getString("pet_name"));
                    insertStmt.setString(6, rs.getString("service_type"));
                    insertStmt.setDate(7, rs.getDate("booking_date"));
                    insertStmt.setString(8, rs.getString("time_slot"));
                    insertStmt.setInt(9, rs.getInt("amount_payable"));
                    insertStmt.setString(10, rs.getString("special_instructions"));

                    // Set rating and review as NULL initially - they will be updated when user rates
                    insertStmt.setObject(11, null); // rating - NULL initially
                    insertStmt.setString(12, null);  // review - NULL initially

                    insertStmt.setString(13, rs.getString("pet_breed"));
                    insertStmt.setInt(14, rs.getInt("pet_age"));
                    insertStmt.setString(15, rs.getString("phone_number"));
                    insertStmt.setString(16, rs.getString("address"));

                    int insertResult = insertStmt.executeUpdate();
                    insertStmt.close();

                    if (insertResult > 0) {
                        // Update the status in bookings table to completed
                        String updateQuery = "UPDATE bookings SET status = 'completed', updated_at = NOW() WHERE booking_id = ? AND employee_id = ?";
                        PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
                        updateStmt.setInt(1, bookingId);
                        updateStmt.setString(2, employeeId);
                        int updateResult = updateStmt.executeUpdate();
                        updateStmt.close();

                        if (updateResult > 0) {
                            // Commit transaction
                            conn.commit();
                            updateStatus = "success";
                        } else {
                            // Rollback transaction
                            conn.rollback();
                            updateStatus = "error";
                        }
                    } else {
                        // Rollback transaction
                        conn.rollback();
                        updateStatus = "error";
                    }
                } else {
                    // No booking found or already processed
                    conn.rollback();
                    updateStatus = "notfound";
                }

                rs.close();
                selectStmt.close();

                // Reset auto-commit
                conn.setAutoCommit(true);

            } catch (Exception e) {
                try {
                    conn.rollback();
                    conn.setAutoCommit(true);
                } catch (SQLException se) {
                    se.printStackTrace();
                }
                updateStatus = "error";
                e.printStackTrace();
            }
        }
      }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pending Appointments - Book Your Care</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-pink: #e83e8c;
            --primary-yellow: #ffc107;
            --light-yellow: #fff9e6;
            --dark-text: #333333;
            --success-green: #28a745;
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
            min-height: calc(100vh - 70px);
        }
        .section-title {
            color: var(--primary-pink);
            font-weight: 600;
            margin-bottom: 1rem;
            font-size: 1.5rem;
            border-bottom: 2px solid var(--primary-yellow);
            padding-bottom: 0.3rem;
        }
        .table-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            border: 1px solid var(--light-yellow);
            padding: 0;
            margin-bottom: 1.5rem;
        }
        .table-header {
            background: var(--primary-pink);
            color: white;
            padding: 0.8rem 1rem;
            border-radius: 12px 12px 0 0;
            font-size: 1rem;
            font-weight: 600;
        }
        .pending-table {
            width: 100%;
            border-collapse: collapse;
        }
        .pending-table thead {
            background: var(--light-yellow);
        }
        .pending-table thead th {
            font-weight: 600;
            color: var(--dark-text);
            padding: 0.7rem;
            border: none;
            font-size: 0.9rem;
        }
        .pending-table tbody td {
            padding: 0.7rem;
            vertical-align: middle;
            background: white;
            font-size: 0.9rem;
            border-bottom: 1px solid #f3e9e9;
        }
        .pending-table tbody tr:last-child td {
            border-bottom: none;
        }
        .mark-btn {
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
            min-width: 100px;
        }
        .mark-btn:hover {
            background: #ffd633;
        }
        .status-badge {
            background: var(--primary-yellow);
            color: var(--dark-text);
            padding: 0.2rem 0.6rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
        }
        .completed-badge {
            background: var(--success-green);
            color: white;
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
            margin: 2rem auto;
            max-width: 400px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        .no-appointments i {
            font-size: 2rem;
            color: var(--primary-yellow);
            margin-bottom: 0.8rem;
        }
        .summary {
            margin-top: 1rem;
            max-width: 400px;
            margin-left: auto;
            margin-right: auto;
            background: var(--light-yellow);
            border-radius: 8px;
            padding: 0.7rem;
            font-weight: 600;
            color: var(--dark-text);
            font-size: 0.9rem;
        }
        .view-btn {
            background: #fff;
            border: 1px solid var(--primary-pink);
            color: var(--primary-pink);
            border-radius: 6px;
            padding: 0.25rem 0.7rem;
            font-weight: 500;
            transition: background 0.15s;
            cursor: pointer;
            font-size: 0.85rem;
        }
        .view-btn:hover {
            background: var(--primary-pink);
            color: #fff;
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
        .modal-dialog {
            max-width: 650px;
            width: 95vw;
            margin: 1.5rem auto;
        }
        .modal-body {
            padding: 1.5rem;
            overflow-x: auto;
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
        @media (max-width: 900px) {
            .main-content {
                margin-left: 0;
                padding: 0.8rem;
            }
            .table-card {
                padding: 0;
            }
            .pending-table th, .pending-table td {
                padding: 0.5rem;
                font-size: 0.85rem;
            }
            .no-appointments {
                padding: 1.5rem 0.5rem;
            }
            .details-grid {
                grid-template-columns: 1fr;
            }
            .modal-dialog {
                max-width: 98vw;
                margin: 0.5rem auto;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="Header.jsp" />

    <div class="main-content">
        <h2 class="section-title">Pending Appointments</h2>
        <% if ("success".equals(updateStatus)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i>
            Appointment marked as completed successfully and transferred to completed appointments!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("error".equals(updateStatus)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-x-circle-fill me-2"></i>
            Error updating appointment status. Please try again.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if ("notfound".equals(updateStatus)) { %>
        <div class="alert alert-warning alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            Appointment not found or already processed.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        <div class="table-card">
            <div class="table-header">Pending Appointments</div>
            <%
            try {
                String pendingQuery = "SELECT b.booking_id, b.owner_name, b.pet_name, b.pet_age, b.pet_breed, " +
                                     "b.service_type, b.time_slot, b.address, b.phone_number, " +
                                     "b.booking_date, b.special_instructions, b.amount_payable, " +
                                     "b.user_email, b.created_at " +
                                     "FROM bookings b " +
                                     "WHERE b.employee_id = ? " +
                                     "AND b.status = 'pending' " +
                                     "ORDER BY b.booking_date DESC, b.created_at DESC";
                PreparedStatement pendingStmt = conn.prepareStatement(pendingQuery);
                pendingStmt.setString(1, employeeId);
                ResultSet pendingRs = pendingStmt.executeQuery();
                boolean hasPending = false;
                int appointmentCount = 0, totalAmount = 0;
            %>
            <table class="pending-table">
                <thead>
                    <tr>
                        <th>Client</th>
                        <th>Pet</th>
                        <th>Breed</th>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Amount</th>
                        <th>Mark Completed</th>
                        <th>View</th>
                    </tr>
                </thead>
                <tbody>
                <%
                while (pendingRs.next()) {
                    hasPending = true;
                    appointmentCount++;
                    totalAmount += pendingRs.getInt("amount_payable");
                    Date bookingDate = pendingRs.getDate("booking_date");
                    LocalDate localDate = bookingDate.toLocalDate();
                    String formattedDate = localDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
                    int bookingId = pendingRs.getInt("booking_id");
                %>
                    <tr>
                        <td><%= pendingRs.getString("owner_name") %></td>
                        <td><%= pendingRs.getString("pet_name") %> (<%= pendingRs.getInt("pet_age") %>)</td>
                        <td><%= pendingRs.getString("pet_breed") %></td>
                        <td><%= formattedDate %></td>
                        <td><%= pendingRs.getString("time_slot").substring(0,1).toUpperCase() + pendingRs.getString("time_slot").substring(1) %></td>
                        <td>₹<%= pendingRs.getInt("amount_payable") %></td>
                        <td>
                            <form method="POST" style="margin:0;" onsubmit="return confirmComplete()">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="booking_id" value="<%= bookingId %>">
                                <button type="submit" class="mark-btn">Completed</button>
                            </form>
                        </td>
                        <td>
                            <button class="view-btn" data-bs-toggle="modal" data-bs-target="#viewModal<%= bookingId %>">View</button>
                            <!-- Modal -->
                            <div class="modal fade" id="viewModal<%= bookingId %>" tabindex="-1" aria-labelledby="viewModalLabel<%= bookingId %>" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="viewModalLabel<%= bookingId %>">Appointment Details</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="details-grid">
                                                <div>
                                                    <div class="modal-body-label">Client Name</div>
                                                    <div class="modal-body-data"><%= pendingRs.getString("owner_name") %></div>
                                                    <div class="modal-body-label">Phone Number</div>
                                                    <div class="modal-body-data"><%= pendingRs.getString("phone_number") %></div>
                                                    <div class="modal-body-label">Email</div>
                                                    <div class="modal-body-data"><%= pendingRs.getString("user_email") %></div>
                                                    <div class="modal-body-label">Pet Name</div>
                                                    <div class="modal-body-data"><%= pendingRs.getString("pet_name") %></div>
                                                    <div class="modal-body-label">Pet Breed</div>
                                                    <div class="modal-body-data"><%= pendingRs.getString("pet_breed") %></div>
                                                    <div class="modal-body-label">Pet Age</div>
                                                    <div class="modal-body-data"><%= pendingRs.getInt("pet_age") %></div>
                                                </div>
                                                <div>
                                                    <div class="modal-body-label">Service</div>
                                                    <div class="modal-body-data"><%= pendingRs.getString("service_type") %></div>
                                                    <div class="modal-body-label">Address</div>
                                                    <div class="modal-body-data"><%= pendingRs.getString("address") %></div>
                                                    <div class="modal-body-label">Special Instructions</div>
                                                    <div class="modal-body-data"><%= pendingRs.getString("special_instructions") != null && !pendingRs.getString("special_instructions").trim().isEmpty() ? pendingRs.getString("special_instructions") : "-" %></div>
                                                    <div class="modal-body-label">Total Amount</div>
                                                    <div class="modal-body-data">₹<%= pendingRs.getInt("amount_payable") %></div>
                                                    <div class="modal-body-label">Employee Earnings</div>
                                                    <div class="modal-body-data">₹<%= (int)(pendingRs.getInt("amount_payable")*0.7) %></div>
                                                    <div class="modal-body-label">Date</div>
                                                    <div class="modal-body-data"><%= formattedDate %></div>
                                                    <div class="modal-body-label">Time</div>
                                                    <div class="modal-body-data"><%= pendingRs.getString("time_slot").substring(0,1).toUpperCase() + pendingRs.getString("time_slot").substring(1) %></div>
                                                </div>
                                            </div>
                                            <div style="margin-top:1rem;">
                                                <span class="modal-body-label">Status</span>
                                                <span class="status-badge">Pending</span>
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
                %>
                </tbody>
            </table>
            <%
            if (!hasPending) {
            %>
            <div class="no-appointments">
                <i class="bi bi-calendar-check"></i>
                <h4 style="color: var(--primary-pink); margin-bottom: 0.6rem;">No Pending Appointments</h4>
                <p style="font-size:0.9rem;">You don't have any pending appointments.<br>New bookings will appear here when clients book your services.</p>
            </div>
            <%
            } else {
                int expectedEarnings = (int)(totalAmount * 0.7);
            %>
            <div class="summary text-center">
                <span>Total Pending: <%= appointmentCount %></span> &nbsp; | &nbsp;
                <span>Expected Earnings: ₹<%= expectedEarnings %></span>
            </div>
            <%
            }
            pendingRs.close();
            pendingStmt.close();
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error loading pending appointments: " + e.getMessage() + "</div>");
            }
            %>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmComplete() {
            return confirm('Are you sure you want to mark this appointment as completed? This will transfer the data to completed appointments.');
        }
    </script>
</body>
</html>