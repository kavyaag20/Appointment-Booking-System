<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.time.LocalDate"%>
<%@ include file="dbconnect.jsp" %>
<%@ include file="Header.jsp" %>
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
%>
<%
// Handle Accept/Reject/Hired actions
if ("POST".equals(request.getMethod())) {
    String action = request.getParameter("action");
    String applicationId = request.getParameter("applicationId");
    
    if (action != null && applicationId != null) {
        PreparedStatement pstmt = null;
        PreparedStatement insertStmt = null;
        PreparedStatement deleteStmt = null;
        ResultSet rs = null;
        
        try {
            if ("hired".equals(action)) {
                // First get the application data
                String selectSql = "SELECT * FROM sitter_applications WHERE id = ?";
                pstmt = conn.prepareStatement(selectSql);
                pstmt.setInt(1, Integer.parseInt(applicationId));
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    // FIXED: Corrected INSERT statement to match table structure
                    String insertSql = "INSERT INTO employee_info (full_name, phone, emp_email, role, hire_date, age, employment_status, rating, experience) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    insertStmt = conn.prepareStatement(insertSql);
                    insertStmt.setString(1, rs.getString("full_name"));
                    insertStmt.setString(2, rs.getString("phone"));
                    insertStmt.setString(3, rs.getString("email"));
                    insertStmt.setString(4, rs.getString("service_type"));
                    insertStmt.setDate(5, Date.valueOf(LocalDate.now()));
                    insertStmt.setInt(6, rs.getInt("age"));
                    insertStmt.setString(7, "Active");
                    insertStmt.setString(8, "0"); // rating
                    insertStmt.setString(9, rs.getString("experience"));
                    
                    int rowsInserted = insertStmt.executeUpdate();
                    
                    if (rowsInserted > 0) {
                        // Delete from sitter_applications table only if insert was successful
                        String deleteSql = "DELETE FROM sitter_applications WHERE id = ?";
                        deleteStmt = conn.prepareStatement(deleteSql);
                        deleteStmt.setInt(1, Integer.parseInt(applicationId));
                        deleteStmt.executeUpdate();
                        
                        // Redirect to Employees.jsp to show the new employee
                        response.sendRedirect("Employees.jsp");
                        return;
                    } else {
                        // Log error or handle failure
                        System.out.println("Failed to insert employee record");
                    }
                }
            } else {
                // Regular accept/reject action
                String sql = "UPDATE sitter_applications SET status = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, action);
                pstmt.setInt(2, Integer.parseInt(applicationId));
                pstmt.executeUpdate();
            }
            
            response.sendRedirect("HiringApp.jsp");
            return;
        } catch(Exception e) {
            e.printStackTrace();
            // Add error logging to understand what's failing
            System.out.println("Error in hire process: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (insertStmt != null) insertStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (deleteStmt != null) deleteStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            // FIXED: Don't close the main connection here as other parts of the page need it
        }
    }
}
%>

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

.btn-hired {
    background-color: #007bff;
    color: white;
    border: none;
    padding: 0.4rem 0.8rem;
    border-radius: 4px;
    font-size: 0.8rem;
    cursor: pointer;
    transition: background-color 0.3s;
    width: 70px;
}

.btn-hired:hover {
    background-color: #0056b3;
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
    margin: 5% auto;
    padding: 2rem;
    border-radius: 10px;
    width: 90%;
    max-width: 600px;
    position: relative;
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
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

.status-accepted {
    background-color: #d4edda;
    color: #155724;
    padding: 0.3rem 0.6rem;
    border-radius: 4px;
    font-size: 0.8rem;
}

.status-rejected {
    background-color: #f8d7da;
    color: #721c24;
    padding: 0.3rem 0.6rem;
    border-radius: 4px;
    font-size: 0.8rem;
}

.status-hired {
    background-color: #d1ecf1;
    color: #0c5460;
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
</style>

<!-- Main Content -->
<div class="main-content">
    <!-- Hiring Applications Section -->
    <div id="applications" class="content-section active">
        <h2 class="section-title">Hiring Applications</h2>
        
        <!-- Tab Buttons -->
        <div class="table-tabs">
            <button class="tab-button active" onclick="showTab('pending')">Pending</button>
            <button class="tab-button" onclick="showTab('completed')">Completed</button>
            <button class="tab-button" onclick="showTab('rejected')">Rejected</button>
        </div>
        
        <!-- Pending Applications Table -->
        <div id="pending-content" class="table-content active">
            <div class="data-table-container">
                <div class="table-header">
                    Pending Applications
                </div>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Age</th>
                                <th>Role</th>
                                <th>View</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            PreparedStatement pstmt = null;
                            ResultSet rs = null;
                            try {
                                String sql = "SELECT * FROM sitter_applications WHERE status = 'pending' ORDER BY id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while(rs.next()) {
                                    int id = rs.getInt("id");
                                    String fullName = rs.getString("full_name");
                                    String email = rs.getString("email");
                                    int age = rs.getInt("age");
                                    String serviceType = rs.getString("service_type");
                            %>
                            <tr>
                                <td><%= fullName != null ? fullName : "" %></td>
                                <td><%= email != null ? email : "" %></td>
                                <td><%= age %></td>
                                <td><%= serviceType != null ? serviceType : "" %></td>
                                <td>
                                    <button class="btn-view" onclick="showDetails('<%= id %>')">View</button>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <form method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="accepted">
                                            <input type="hidden" name="applicationId" value="<%= id %>">
                                            <button type="submit" class="btn-accept">Accept</button>
                                        </form>
                                        <form method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="rejected">
                                            <input type="hidden" name="applicationId" value="<%= id %>">
                                            <button type="submit" class="btn-reject">Reject</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            } finally {
                                try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Completed Applications Table -->
        <div id="completed-content" class="table-content">
            <div class="data-table-container">
                <div class="table-header">
                    Completed Applications
                </div>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Age</th>
                                <th>Role</th>
                                <th>View</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try {
                                String sql = "SELECT * FROM sitter_applications WHERE status = 'accepted' ORDER BY id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while(rs.next()) {
                                    int id = rs.getInt("id");
                                    String fullName = rs.getString("full_name");
                                    String email = rs.getString("email");
                                    int age = rs.getInt("age");
                                    String serviceType = rs.getString("service_type");
                            %>
                            <tr>
                                <td><%= fullName != null ? fullName : "" %></td>
                                <td><%= email != null ? email : "" %></td>
                                <td><%= age %></td>
                                <td><%= serviceType != null ? serviceType : "" %></td>
                                <td>
                                    <button class="btn-view" onclick="showDetails('<%= id %>')">View</button>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <form method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="hired">
                                            <input type="hidden" name="applicationId" value="<%= id %>">
                                            <button type="submit" class="btn-hired">Hire</button>
                                        </form>
                                        <form method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="rejected">
                                            <input type="hidden" name="applicationId" value="<%= id %>">
                                            <button type="submit" class="btn-reject">Reject</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            } finally {
                                try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Rejected Applications Table -->
        <div id="rejected-content" class="table-content">
            <div class="data-table-container">
                <div class="table-header">
                    Rejected Applications
                </div>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Age</th>
                                <th>Role</th>
                                <th>View</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try {
                                String sql = "SELECT * FROM sitter_applications WHERE status = 'rejected' ORDER BY id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while(rs.next()) {
                                    int id = rs.getInt("id");
                                    String fullName = rs.getString("full_name");
                                    String email = rs.getString("email");
                                    int age = rs.getInt("age");
                                    String serviceType = rs.getString("service_type");
                                    String status = rs.getString("status");
                            %>
                            <tr>
                                <td><%= fullName != null ? fullName : "" %></td>
                                <td><%= email != null ? email : "" %></td>
                                <td><%= age %></td>
                                <td><%= serviceType != null ? serviceType : "" %></td>
                                <td>
                                    <button class="btn-view" onclick="showDetails('<%= id %>')">View</button>
                                </td>
                                <td>
                                    <span class="status-<%= status %>"><%= status.toUpperCase() %></span>
                                </td>
                            </tr>
                            <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            } finally {
                                try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal for viewing details -->
<div id="detailModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal()">&times;</span>
        <h2 style="color: var(--primary-pink); margin-bottom: 2rem;">Application Details</h2>
        <div id="modalContent">
            <%
            String detailId = request.getParameter("detailId");
            if (detailId != null) {
                Connection modalConn = null;
                PreparedStatement modalStmt = null;
                ResultSet modalRs = null;
                try {
                    // Create a new connection for the modal to avoid conflicts
                    modalConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/project","root","");
                    String sql = "SELECT * FROM sitter_applications WHERE id = ?";
                    modalStmt = modalConn.prepareStatement(sql);
                    modalStmt.setInt(1, Integer.parseInt(detailId));
                    modalRs = modalStmt.executeQuery();
                    
                    if (modalRs.next()) {
                        int id = modalRs.getInt("id");
                        String fullName = modalRs.getString("full_name");
                        String email = modalRs.getString("email");
                        String phone = modalRs.getString("phone");
                        String serviceType = modalRs.getString("service_type");
                        String experience = modalRs.getString("experience");
                        int age = modalRs.getInt("age");
                        String message = modalRs.getString("message");
                        String status = modalRs.getString("status");
            %>
            <div class="detail-row">
                <div class="detail-label">Name:</div>
                <div class="detail-value"><%= fullName != null ? fullName : "Not provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Email:</div>
                <div class="detail-value"><%= email != null ? email : "Not provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Phone:</div>
                <div class="detail-value"><%= phone != null ? phone : "Not provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Service Type:</div>
                <div class="detail-value">
                    <%= serviceType != null ? 
                        serviceType.substring(0, 1).toUpperCase() + serviceType.substring(1) : 
                        "Not provided" %>
                </div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Experience:</div>
                <div class="detail-value"><%= experience != null ? experience : "Not provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Age:</div>
                <div class="detail-value"><%= age > 0 ? age : "Not provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Message:</div>
                <div class="detail-value"><%= message != null ? message : "No message provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Status:</div>
                <div class="detail-value">
                    <span class="status-<%= status %>"><%= status.toUpperCase() %></span>
                </div>
            </div>
            <%
                    }
                } catch(Exception e) {
                    e.printStackTrace();
                } finally {
                    try { if (modalRs != null) modalRs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    try { if (modalStmt != null) modalStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                    try { if (modalConn != null) modalConn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
            %>
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
    event.target.classList.add('active');
}

function showDetails(id) {
    // Add detailId parameter to URL without reloading
    const url = new URL(window.location.href);
    url.searchParams.set('detailId', id);
    window.history.pushState({}, '', url);
    
    // Show the modal
    document.getElementById('detailModal').style.display = 'block';
    
    // Reload just the modal content
    fetch(url)
        .then(response => response.text())
        .then(html => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');
            const newContent = doc.getElementById('modalContent').innerHTML;
            document.getElementById('modalContent').innerHTML = newContent;
        })
        .catch(err => console.error('Error loading modal content:', err));
}

function closeModal() {
    // Remove the detailId parameter from URL
    const url = new URL(window.location.href);
    url.searchParams.delete('detailId');
    window.history.pushState({}, '', url);
    
    // Hide the modal
    document.getElementById('detailModal').style.display = 'none';
}

// Close modal when clicking outside of it
window.onclick = function(event) {
    const modal = document.getElementById('detailModal');
    if (event.target == modal) {
        closeModal();
    }
}

// Show modal if detailId parameter exists on page load
document.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('detailId')) {
        document.getElementById('detailModal').style.display = 'block';
    }
});
</script>