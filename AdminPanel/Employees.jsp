<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
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

.status-badge {
    padding: 0.3rem 0.6rem;
    border-radius: 4px;
    font-size: 0.8rem;
    font-weight: 600;
}

.status-active {
    background-color: #d4edda;
    color: #155724;
}

.status-inactive {
    background-color: #f8d7da;
    color: #721c24;
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
</style>

<!-- Main Content -->
<div class="main-content">
    <!-- Employees Section -->
    <div id="employees" class="content-section active">
        <h2 class="section-title">Employees</h2>
        
        <!-- Tab Buttons -->
        <div class="table-tabs">
            <button class="tab-button active" onclick="showTab('active')">Active Employees</button>
            <button class="tab-button" onclick="showTab('all')">All Employees</button>
        </div>
        
        <!-- Active Employees Table -->
        <div id="active-content" class="table-content active">
            <div class="data-table-container">
                <div class="table-header">
                    Active Employees
                </div>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Role</th>
                                <th>Rating</th>
                                <th>Hire Date</th>
                                <th>Status</th>
                                <th>View</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            PreparedStatement pstmt = null;
                            ResultSet rs = null;
                            try {
                                String sql = "SELECT * FROM employee_info WHERE employment_status = 'Active' ORDER BY employee_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while(rs.next()) {
                                    int employeeId = rs.getInt("employee_id");
                                    String fullName = rs.getString("full_name");
                                    String role = rs.getString("role");
                                    String rating = rs.getString("rating");
                                    String hireDate = rs.getString("hire_date");
                                    String status = rs.getString("employment_status");
                            %>
                            <tr>
                                <td>#<%= employeeId %></td>
                                <td><%= fullName != null ? fullName : "" %></td>
                                <td><%= role != null ? role.substring(0, 1).toUpperCase() + role.substring(1) : "" %></td>
                                <td><%= rating != null ? rating : "N/A" %></td>
                                <td><%= hireDate != null ? hireDate : "" %></td>
                                <td><span class="status-badge status-<%= status != null ? status.toLowerCase() : "inactive" %>"><%= status != null ? status : "Inactive" %></span></td>
                                <td>
                                    <button class="btn-view" onclick="showEmployeeDetails('<%= employeeId %>')">View</button>
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
        
        <!-- All Employees Table -->
        <div id="all-content" class="table-content">
            <div class="data-table-container">
                <div class="table-header">
                    All Employees
                </div>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Role</th>
                                <th>Rating</th>
                                <th>Hire Date</th>
                                <th>Status</th>
                                <th>View</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try {
                                String sql = "SELECT * FROM employee_info ORDER BY employee_id DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while(rs.next()) {
                                    int employeeId = rs.getInt("employee_id");
                                    String fullName = rs.getString("full_name");
                                    String role = rs.getString("role");
                                    String rating = rs.getString("rating");
                                    String hireDate = rs.getString("hire_date");
                                    String status = rs.getString("employment_status");
                            %>
                            <tr>
                                <td>#<%= employeeId %></td>
                                <td><%= fullName != null ? fullName : "" %></td>
                                <td><%= role != null ? role.substring(0, 1).toUpperCase() + role.substring(1) : "" %></td>
                                <td><%= rating != null ? rating : "N/A" %></td>
                                <td><%= hireDate != null ? hireDate : "" %></td>
                                <td><span class="status-badge status-<%= status != null ? status.toLowerCase() : "inactive" %>"><%= status != null ? status : "Inactive" %></span></td>
                                <td>
                                    <button class="btn-view" onclick="showEmployeeDetails('<%= employeeId %>')">View</button>
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
    </div>
</div>

<!-- Modal for viewing employee details -->
<div id="employeeDetailModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeEmployeeModal()">&times;</span>
        <h2 style="color: var(--primary-pink); margin-bottom: 2rem;">Employee Details</h2>
        <div id="employeeModalContent">
            <%
            String employeeDetailId = request.getParameter("employeeDetailId");
            if (employeeDetailId != null) {
                Connection modalConn = null;
                PreparedStatement modalStmt = null;
                ResultSet modalRs = null;
                try {
                    // Create a new connection for the modal to avoid conflicts
                    modalConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/project","root","");
                    String sql = "SELECT * FROM employee_info WHERE employee_id = ?";
                    modalStmt = modalConn.prepareStatement(sql);
                    modalStmt.setInt(1, Integer.parseInt(employeeDetailId));
                    modalRs = modalStmt.executeQuery();
                    
                    if (modalRs.next()) {
                        int employeeId = modalRs.getInt("employee_id");
                        String fullName = modalRs.getString("full_name");
                        String email = modalRs.getString("emp_email");
                        String phone = modalRs.getString("phone");
                        String role = modalRs.getString("role");
                        String experience = modalRs.getString("experience");
                        String rating = modalRs.getString("rating");
                        String hireDate = modalRs.getString("hire_date");
                        int age = modalRs.getInt("age");
                        String status = modalRs.getString("employment_status");
            %>
            <div class="detail-row">
                <div class="detail-label">Employee ID:</div>
                <div class="detail-value">#<%= employeeId %></div>
            </div>
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
                <div class="detail-label">Role:</div>
                <div class="detail-value">
                    <%= role != null ? 
                        role.substring(0, 1).toUpperCase() + role.substring(1) : 
                        "Not provided" %>
                </div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Experience:</div>
                <div class="detail-value"><%= experience != null ? experience : "Not provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Rating:</div>
                <div class="detail-value"><%= rating != null ? rating : "Not provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Hire Date:</div>
                <div class="detail-value"><%= hireDate != null ? hireDate : "Not provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Age:</div>
                <div class="detail-value"><%= age > 0 ? age : "Not provided" %></div>
            </div>
            <div class="detail-row">
                <div class="detail-label">Employment Status:</div>
                <div class="detail-value">
                    <span class="status-badge status-<%= status != null ? status.toLowerCase() : "inactive" %>"><%= status != null ? status : "Inactive" %></span>
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

function showEmployeeDetails(employeeId) {
    // Add employeeDetailId parameter to URL without reloading
    const url = new URL(window.location.href);
    url.searchParams.set('employeeDetailId', employeeId);
    window.history.pushState({}, '', url);
    
    // Show the modal
    document.getElementById('employeeDetailModal').style.display = 'block';
    
    // Reload just the modal content
    fetch(url)
        .then(response => response.text())
        .then(html => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');
            const newContent = doc.getElementById('employeeModalContent').innerHTML;
            document.getElementById('employeeModalContent').innerHTML = newContent;
        })
        .catch(err => console.error('Error loading modal content:', err));
}

function closeEmployeeModal() {
    // Remove the employeeDetailId parameter from URL
    const url = new URL(window.location.href);
    url.searchParams.delete('employeeDetailId');
    window.history.pushState({}, '', url);
    
    // Hide the modal
    document.getElementById('employeeDetailModal').style.display = 'none';
}

// Close modal when clicking outside of it
window.onclick = function(event) {
    const modal = document.getElementById('employeeDetailModal');
    if (event.target == modal) {
        closeEmployeeModal();
    }
}

// Show modal if employeeDetailId parameter exists on page load
document.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('employeeDetailId')) {
        document.getElementById('employeeDetailModal').style.display = 'block';
    }
});
</script>

</body>
</html>