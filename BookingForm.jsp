<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
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

    // Get parameters from URL
    String employeeId = request.getParameter("employeeId");
    String employeeName = request.getParameter("employeeName");
    String serviceType = request.getParameter("serviceType");
    String petType = request.getParameter("petType");
    String timeSlot = request.getParameter("timeSlot");
    String address = request.getParameter("address");
    String phoneNumber = request.getParameter("phone");

    // Today's date formatted yyyy-MM-dd
    String todayStr = LocalDate.now().toString();

    // Get user info from database
    String userName = "";
    String userPhone = "";
    try {
        String userQuery = "SELECT full_name, phone FROM user_info WHERE user_email = ?";
        PreparedStatement userStmt = conn.prepareStatement(userQuery);
        userStmt.setString(1, userEmail);
        ResultSet userRs = userStmt.executeQuery();
        if (userRs.next()) {
            userName = userRs.getString("full_name") != null ? userRs.getString("full_name") : "";
            userPhone = userRs.getString("phone") != null ? userRs.getString("phone") : "";
        }
        userRs.close();
        userStmt.close();
    } catch (Exception e) {
        // If user details don't exist, userName and userPhone will remain empty
    }

    // Payment calculation logic
    String paymentInstructions = "";
    int amountPayable = 0;
    if ("Vet".equalsIgnoreCase(serviceType)) {
        if ("morning".equalsIgnoreCase(timeSlot) || "afternoon".equalsIgnoreCase(timeSlot)) amountPayable = 1200;
        else if ("evening".equalsIgnoreCase(timeSlot)) amountPayable = 1500;
        paymentInstructions = "Veterinarian (Vet): Morning/Afternoon ₹1200, Evening ₹1500";
    } else if ("Daycare".equalsIgnoreCase(serviceType) || "Care Taker".equalsIgnoreCase(serviceType) || "Pet Sitter".equalsIgnoreCase(serviceType) || "Boarding".equalsIgnoreCase(serviceType)) {
        if ("morning".equalsIgnoreCase(timeSlot) || "afternoon".equalsIgnoreCase(timeSlot)) amountPayable = 300;
        else if ("evening".equalsIgnoreCase(timeSlot)) amountPayable = 500;
        paymentInstructions = "Care Taker (Pet Sitter/Boarding): Morning/Afternoon ₹300, Evening ₹500";
    } else if ("Walker".equalsIgnoreCase(serviceType)) {
        if ("morning".equalsIgnoreCase(timeSlot)) amountPayable = 250;
        else if ("afternoon".equalsIgnoreCase(timeSlot)) amountPayable = 400;
        else if ("evening".equalsIgnoreCase(timeSlot) || "night".equalsIgnoreCase(timeSlot)) amountPayable = 250;
        paymentInstructions = "Walker: Morning ₹250, Afternoon ₹400, Night/Evening ₹250";
    } else if ("Groomer".equalsIgnoreCase(serviceType)) {
        amountPayable = 800; // Minimum
        paymentInstructions = "Groomer: Basic grooming (bath, brush, nails): ₹800–₹1,200 | Full grooming (haircut, styling, bath): ₹1,500–₹2,500 | Large breed special: ₹2,000–₹3,500";
    }

    // Handle form submission
    String bookingStatus = "";
    String errorDetails = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            String ownerName = request.getParameter("owner_name");
            String petName = request.getParameter("pet_name");
            String petAgeStr = request.getParameter("pet_age");
            String petBreed = request.getParameter("pet_breed");
            String selectedService = request.getParameter("service_type");
            String selectedTimeSlot = request.getParameter("time_slot");
            String bookingAddress = request.getParameter("address");
            String phone = request.getParameter("phone_number");
            String bookingDate = todayStr;
            String specialInstructions = request.getParameter("special_instructions");
            
            // Validation checks
            if (ownerName == null || ownerName.trim().isEmpty()) {
                throw new Exception("Owner name is required");
            }
            if (petName == null || petName.trim().isEmpty()) {
                throw new Exception("Pet name is required");
            }
            if (petAgeStr == null || petAgeStr.trim().isEmpty()) {
                throw new Exception("Pet age is required");
            }
            if (petBreed == null || petBreed.trim().isEmpty()) {
                throw new Exception("Pet breed is required");
            }
            if (selectedService == null || selectedService.trim().isEmpty()) {
                throw new Exception("Service type is required");
            }
            if (selectedTimeSlot == null || selectedTimeSlot.trim().isEmpty()) {
                throw new Exception("Time slot is required");
            }
            if (bookingAddress == null || bookingAddress.trim().isEmpty()) {
                throw new Exception("Address is required");
            }
            if (phone == null || phone.trim().isEmpty()) {
                throw new Exception("Phone number is required");
            }
            if (employeeId == null || employeeId.trim().isEmpty()) {
                throw new Exception("Employee ID is missing");
            }
            
            // Parse pet age
            int petAge = Integer.parseInt(petAgeStr);
            
            java.sql.Date sqlBookingDate = java.sql.Date.valueOf(bookingDate);

            // Check if employee exists and is active
            String checkEmployeeQuery = "SELECT employment_status FROM employee_info WHERE employee_id = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkEmployeeQuery);
            checkStmt.setString(1, employeeId);
            ResultSet checkRs = checkStmt.executeQuery();
            
            if (!checkRs.next()) {
                checkRs.close();
                checkStmt.close();
                throw new Exception("Selected service provider not found");
            }
            
            String empStatus = checkRs.getString("employment_status");
            if (!"Active".equalsIgnoreCase(empStatus)) {
                checkRs.close();
                checkStmt.close();
                throw new Exception("Selected service provider is not available");
            }
            checkRs.close();
            checkStmt.close();

            // Check if employee is already booked for today
            String checkBookingQuery = "SELECT booking_id FROM bookings WHERE employee_id = ? AND booking_date = ? AND status != 'cancelled'";
            PreparedStatement bookingCheckStmt = conn.prepareStatement(checkBookingQuery);
            bookingCheckStmt.setString(1, employeeId);
            bookingCheckStmt.setDate(2, sqlBookingDate);
            ResultSet bookingCheckRs = bookingCheckStmt.executeQuery();
            
            if (bookingCheckRs.next()) {
                bookingCheckRs.close();
                bookingCheckStmt.close();
                throw new Exception("This service provider is already booked for today. Please select another provider.");
            }
            bookingCheckRs.close();
            bookingCheckStmt.close();

            // Insert the booking with status = 'pending'
            String insertQuery = "INSERT INTO bookings (employee_id, owner_name, pet_name, pet_age, pet_breed, service_type, time_slot, address, phone_number, booking_date, special_instructions, amount_payable, user_email, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', NOW(), NOW())";
            PreparedStatement insertStmt = conn.prepareStatement(insertQuery);
            insertStmt.setString(1, employeeId);
            insertStmt.setString(2, ownerName.trim());
            insertStmt.setString(3, petName.trim());
            insertStmt.setInt(4, petAge);
            insertStmt.setString(5, petBreed.trim());
            insertStmt.setString(6, selectedService.trim());
            insertStmt.setString(7, selectedTimeSlot.trim());
            insertStmt.setString(8, bookingAddress.trim());
            insertStmt.setString(9, phone.trim());
            insertStmt.setDate(10, sqlBookingDate);
            insertStmt.setString(11, specialInstructions != null ? specialInstructions.trim() : "");
            insertStmt.setInt(12, amountPayable);
            insertStmt.setString(13, userEmail);

            int result = insertStmt.executeUpdate();
            insertStmt.close();

            if (result > 0) {
                // Success - redirect to Bookings page with success message
                response.sendRedirect("Bookings.jsp?booking=success");
                return;
            } else {
                bookingStatus = "error";
                errorDetails = "Database insert failed - no rows affected";
            }
        } catch (NumberFormatException e) {
            bookingStatus = "error";
            errorDetails = "Invalid pet age format: " + e.getMessage();
        } catch (SQLException e) {
            bookingStatus = "error";
            errorDetails = "Database error: " + e.getMessage();
        } catch (Exception e) {
            bookingStatus = "error";
            errorDetails = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Service - Pet Care</title>
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
        
        .container {
            max-width: 800px;
        }
        
        .provider-info {
            background: var(--bg-light);
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border: 1px solid var(--border-color);
            font-size: 0.875rem;
        }
        
        .provider-name {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            font-size: 1.125rem;
        }
        
        .provider-service {
            background: var(--primary-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 500;
            display: inline-block;
            margin-bottom: 0.75rem;
        }
        
        .booking-form {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: var(--card-shadow);
            margin-bottom: 1.5rem;
        }
        
        .form-section {
            margin-bottom: 1.5rem;
        }
        
        .form-section:last-child {
            margin-bottom: 0;
        }
        
        .section-title {
            color: var(--text-primary);
            font-weight: 600;
            font-size: 1rem;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .form-label {
            font-weight: 500;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
        }
        
        .form-control, .form-select {
            border: 1px solid var(--border-color);
            border-radius: 6px;
            padding: 0.625rem 0.75rem;
            font-size: 0.875rem;
            transition: all 0.2s;
            background: white;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.125rem rgba(37, 99, 235, 0.25);
            outline: none;
        }
        
        .readonly-field {
            background-color: var(--bg-light);
            color: var(--text-secondary);
            border-color: var(--border-color);
        }
        
        .btn-book {
            background: var(--pink-color);
            color: white;
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 6px;
            font-weight: 500;
            font-size: 0.875rem;
            width: 100%;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.375rem;
        }
        
        .btn-book:hover {
            background: #d62d7b;
            transform: translateY(-1px);
        }
        
        .service-summary {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 1.25rem;
            box-shadow: var(--card-shadow);
            margin-bottom: 1.5rem;
        }
        
        .summary-title {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 1rem;
            font-size: 1.125rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem 0;
            border-bottom: 1px solid var(--border-color);
            font-size: 0.875rem;
        }
        
        .summary-row:last-child {
            border-bottom: none;
            font-weight: 600;
            font-size: 1rem;
            margin-top: 0.5rem;
            padding-top: 1rem;
            border-top: 2px solid var(--border-color);
        }
        
        .amount-highlight {
            color: var(--accent-color);
            font-weight: 600;
            font-size: 1.125rem;
        }
        
        .payment-info {
            background: #fef3c7;
            border: 1px solid #f59e0b;
            border-radius: 6px;
            padding: 0.75rem;
            margin: 1rem 0;
            font-size: 0.8rem;
            color: #92400e;
        }
        
        .alert {
            padding: 0.75rem;
            border-radius: 6px;
            font-size: 0.875rem;
            border: 1px solid;
        }
        
        .alert-info {
            background: #eff6ff;
            border-color: #bfdbfe;
            color: #1e40af;
        }
        
        .alert-warning {
            background: #fef3c7;
            border-color: #f59e0b;
            color: #92400e;
        }
        
        .badge {
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
        }
        
        .form-check-input:checked {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .error-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            z-index: 1000;
        }
        
        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 1.5rem;
            border-radius: 8px;
            max-width: 500px;
            position: relative;
            text-align: center;
        }
        
        .close-modal {
            position: absolute;
            top: 0.5rem;
            right: 1rem;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--text-secondary);
        }
        
        .error-icon {
            font-size: 3rem;
            color: var(--danger-color);
            margin-bottom: 1rem;
        }
        
        .error-details {
            background: var(--bg-light);
            border: 1px solid var(--border-color);
            border-radius: 6px;
            padding: 0.75rem;
            margin: 0.75rem 0;
            font-family: monospace;
            font-size: 0.8rem;
            color: var(--danger-color);
            text-align: left;
        }
        
        .mb-3 {
            margin-bottom: 0.75rem;
        }
    </style>
</head>
<body>
    <jsp:include page="Header.jsp" />

    <div class="page-header">
        <div class="container">
            <h1 class="page-title">Complete Booking</h1>
            <p class="page-subtitle">Fill in your details to confirm the service</p>
        </div>
    </div>

    <div class="container">
        <a href="SearchResults.jsp?serviceType=<%= serviceType %>&petType=<%= petType %>&time=<%= timeSlot %>&address=<%= address %>&phone=<%= phoneNumber %>" class="back-btn">
            <i class="bi bi-arrow-left"></i>Back to Results
        </a>
        
        <!-- Service Provider Information -->
        <div class="provider-info">
            <div class="provider-name">
                <i class="bi bi-person-circle me-2"></i>
                <%= employeeName != null ? employeeName : "Service Provider" %>
            </div>
            <span class="provider-service">
                <%= serviceType != null ? serviceType : "Pet Care Service" %>
            </span>
            <div class="mt-2">
                <span class="badge bg-primary me-2">Service: <%= serviceType %></span>
                <span class="badge bg-success me-2">Pet: <%= petType %></span>
                <span class="badge bg-warning me-2">Time: <%= timeSlot %></span>
            </div>
            <div class="mt-2">
                <i class="bi bi-geo-alt me-1"></i><strong>Location:</strong> <%= address %>
            </div>
        </div>

        <!-- Booking Form -->
        <div class="booking-form">
            <form method="POST" id="bookingForm">
                <!-- Owner Information Section -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="bi bi-person"></i>Owner Information
                    </h3>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="owner_name" class="form-label">Full Name</label>
                            <input type="text" class="form-control" id="owner_name" name="owner_name" 
                                   value="<%= userName %>" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="phone_number" class="form-label">Phone Number</label>
                            <input type="tel" class="form-control" id="phone_number" name="phone_number" 
                                   value="<%= userPhone != null && !userPhone.isEmpty() ? userPhone : (phoneNumber != null ? phoneNumber : "") %>" 
                                   pattern="[0-9]{10}" required>
                        </div>
                    </div>
                </div>

                <!-- Pet Information Section -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="bi bi-heart"></i>Pet Information
                    </h3>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="pet_name" class="form-label">Pet Name</label>
                            <input type="text" class="form-control" id="pet_name" name="pet_name" 
                                   placeholder="Enter your pet's name" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="pet_age" class="form-label">Pet Age (years)</label>
                            <select class="form-select" id="pet_age" name="pet_age" required>
                                <option value="" disabled selected>Select age</option>
                                <% for(int i = 1; i <= 20; i++) { %>
                                    <option value="<%= i %>"><%= i %> year<%= i > 1 ? "s" : "" %> old</option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="pet_breed" class="form-label">Pet Breed</label>
                        <input type="text" class="form-control" id="pet_breed" name="pet_breed" 
                               placeholder="e.g., Golden Retriever, Labrador, Mixed Breed" required>
                    </div>
                </div>

                <!-- Service Details Section -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="bi bi-calendar-check"></i>Service Details
                    </h3>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="service_type" class="form-label">Service Type</label>
                            <input type="text" class="form-control readonly-field" id="service_type" name="service_type" 
                                   value="<%= serviceType %>" readonly>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="time_slot" class="form-label">Time Slot</label>
                            <select class="form-select" id="time_slot" name="time_slot" required>
                                <option value="" disabled>Select preferred time</option>
                                <option value="morning" <%= "morning".equals(timeSlot) ? "selected" : "" %>>Morning (8AM - 12PM)</option>
                                <option value="afternoon" <%= "afternoon".equals(timeSlot) ? "selected" : "" %>>Afternoon (12PM - 4PM)</option>
                                <option value="evening" <%= "evening".equals(timeSlot) ? "selected" : "" %>>Evening (4PM - 8PM)</option>
                                <option value="night" <%= "night".equals(timeSlot) ? "selected" : "" %>>Night (8PM - 11PM)</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="booking_date" class="form-label">Date</label>
                            <input type="date" class="form-control readonly-field" id="booking_date" name="booking_date"
                                   value="<%= todayStr %>" readonly>
                            <small class="text-muted">Booking for today only</small>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="address" class="form-label">Service Address</label>
                            <textarea class="form-control readonly-field" id="address" name="address" rows="2" 
                                      readonly><%= address %></textarea>
                        </div>
                    </div>
                </div>

                <!-- Additional Instructions -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="bi bi-chat-text"></i>Additional Information
                    </h3>
                    <div class="mb-3">
                        <label for="special_instructions" class="form-label">Special Instructions (Optional)</label>
                        <textarea class="form-control" id="special_instructions" name="special_instructions" 
                                  rows="3" placeholder="Any special care instructions, allergies, or specific requirements..."></textarea>
                    </div>
                </div>

                <!-- Terms and Conditions -->
                <div class="mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="terms" required>
                        <label class="form-check-label" for="terms">
                            I agree to the <a href="AboutUs.jsp#terms-policies" style="color: var(--primary-color);">Terms and Conditions</a> 
                            and understand that the service provider will contact me to confirm this booking.
                        </label>
                    </div>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn-book">
                    <i class="bi bi-check-circle"></i>Confirm Booking
                </button>
            </form>
        </div>

        <!-- Service Summary -->
        <div class="service-summary">
            <h3 class="summary-title">
                <i class="bi bi-receipt"></i>Booking Summary
            </h3>
            
            <div class="summary-row">
                <span>Service Provider:</span>
                <span><%= employeeName != null ? employeeName : "Service Provider" %></span>
            </div>
            
            <div class="summary-row">
                <span>Service Type:</span>
                <span><%= serviceType %></span>
            </div>
            
            <div class="summary-row">
                <span>Pet Type:</span>
                <span><%= petType %></span>
            </div>
            
            <div class="summary-row">
                <span>Time Slot:</span>
                <span><%= timeSlot %></span>
            </div>
            
            <div class="summary-row">
                <span>Date:</span>
                <span>Today (<%= todayStr %>)</span>
            </div>
            
            <div class="summary-row">
                <span><strong>Amount Payable:</strong></span>
                <span class="amount-highlight">₹<%= amountPayable %></span>
            </div>
            
            <div class="payment-info">
                <i class="bi bi-info-circle me-2"></i>
                <%= paymentInstructions %>
            </div>
            
            <div class="alert alert-warning">
                <i class="bi bi-exclamation-triangle me-2"></i>
                <strong>Important:</strong> Payment will be handled directly with the service provider in person. Do NOT pay online.
            </div>
        </div>

                <!-- Important Notes -->
                <div class="alert alert-info mb-3">
                    <i class="bi bi-info-circle me-2"></i>
                    <strong>Please Note:</strong>
                    <ul class="mb-0 mt-2">
                        <li>This booking is for today's service only</li>
                        <li>Payment will be handled directly with the service provider</li>
                        <li>The service provider will contact you to confirm Accurate timing</li>
                        <li>All our providers are verified and experienced</li>
                    </ul>
                </div>
            </form>
        </div>
    </div>

    <!-- Error Modal -->
    <div id="errorModal" class="error-modal">
        <div class="modal-content">
            <span class="close-modal" onclick="closeErrorModal()">&times;</span>
            <div class="error-icon">
                <i class="bi bi-x-circle-fill"></i>
            </div>
            <h3 style="color: #dc3545; margin-bottom: 1rem;">Booking Failed</h3>
            <p>We're sorry, but there was an error processing your booking request.</p>
            
            <% if (!errorDetails.isEmpty()) { %>
            <div class="error-details">
                <strong>Error Details:</strong><br>
                <%= errorDetails %>
            </div>
            <% } %>
            
            <p>Please try again or contact support if the problem persists.</p>
            <div class="mt-3">
                <button onclick="closeErrorModal()" class="btn btn-primary">Try Again</button>
            </div>
        </div>
    </div>

    <jsp:include page="Footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Phone number validation
        document.getElementById('phone_number').addEventListener('input', function() {
            const phone = this.value;
            if (!/^\d{10}$/.test(phone)) {
                this.setCustomValidity('Please enter a valid 10-digit phone number');
            } else {
                this.setCustomValidity('');
            }
        });

        // Form validation
        document.getElementById('bookingForm').addEventListener('submit', function(e) {
            const phone = document.getElementById('phone_number').value;
            const terms = document.getElementById('terms').checked;
            
            if (!/^\d{10}$/.test(phone)) {
                e.preventDefault();
                alert('Please enter a valid 10-digit phone number');
                return false;
            }
            if (!terms) {
                e.preventDefault();
                alert('Please accept the terms and conditions to continue');
                return false;
            }
        });

        // Modal functions
        function closeErrorModal() {
            document.getElementById('errorModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        
        // Show error modal if booking failed
        <% if ("error".equals(bookingStatus)) { %>
            document.getElementById('errorModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        <% } %>
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            const errorModal = document.getElementById('errorModal');
            if (event.target === errorModal) {
                closeErrorModal();
            }
        }
    </script>
</body>
</html>