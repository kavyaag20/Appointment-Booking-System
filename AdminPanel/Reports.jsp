<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*, java.sql.*, java.time.*, java.time.format.*" %>
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

    // Get filter parameters
    String selectedYear = request.getParameter("year");
    String selectedMonth = request.getParameter("month");
    String serviceFilter = request.getParameter("service");
    
    // Set defaults
    if (selectedYear == null || selectedYear.isEmpty()) {
        selectedYear = String.valueOf(LocalDate.now().getYear());
    }
    if (selectedMonth == null || selectedMonth.isEmpty()) {
        selectedMonth = "all";
    }
    if (serviceFilter == null || serviceFilter.isEmpty()) {
        serviceFilter = "all";
    }

    // Initialize variables for reports
    List<Map<String, Object>> dailyReports = new ArrayList<>();
    Map<String, Double> serviceRevenue = new HashMap<>();
    double totalRevenue = 0.0;
    double totalMonthlyRevenue = 0.0;
    double totalYearlyRevenue = 0.0;

    try {
        // Build query based on filters
        StringBuilder queryBuilder = new StringBuilder();
        queryBuilder.append("SELECT DATE(booking_date) as report_date, ");
        queryBuilder.append("service_type, ");
        queryBuilder.append("SUM(amount_payable * 0.30) as daily_revenue, ");
        queryBuilder.append("COUNT(*) as bookings_count ");
        queryBuilder.append("FROM bookings WHERE status = 'completed' ");
        queryBuilder.append("AND YEAR(booking_date) = ? ");
        
        List<Object> params = new ArrayList<>();
        params.add(Integer.parseInt(selectedYear));
        
        if (!"all".equals(selectedMonth)) {
            queryBuilder.append("AND MONTH(booking_date) = ? ");
            params.add(Integer.parseInt(selectedMonth));
        }
        
        if (!"all".equals(serviceFilter)) {
            queryBuilder.append("AND service_type = ? ");
            params.add(serviceFilter);
        }
        
        queryBuilder.append("GROUP BY DATE(booking_date), service_type ");
        queryBuilder.append("ORDER BY report_date DESC, service_type");

        PreparedStatement stmt = conn.prepareStatement(queryBuilder.toString());
        for (int i = 0; i < params.size(); i++) {
            if (params.get(i) instanceof Integer) {
                stmt.setInt(i + 1, (Integer) params.get(i));
            } else {
                stmt.setString(i + 1, (String) params.get(i));
            }
        }
        
        ResultSet rs = stmt.executeQuery();
        
        Map<String, Map<String, Object>> dateGrouped = new HashMap<>();
        
        while (rs.next()) {
            String reportDate = rs.getString("report_date");
            String serviceType = rs.getString("service_type");
            double dailyRev = rs.getDouble("daily_revenue");
            int bookingsCount = rs.getInt("bookings_count");
            
            // Group by date
            if (!dateGrouped.containsKey(reportDate)) {
                Map<String, Object> dateData = new HashMap<>();
                dateData.put("date", reportDate);
                dateData.put("services", new ArrayList<Map<String, Object>>());
                dateData.put("totalDayRevenue", 0.0);
                dateData.put("totalDayBookings", 0);
                dateGrouped.put(reportDate, dateData);
            }
            
            Map<String, Object> serviceData = new HashMap<>();
            serviceData.put("service", serviceType);
            serviceData.put("revenue", dailyRev);
            serviceData.put("bookings", bookingsCount);
            
            Map<String, Object> dateData = dateGrouped.get(reportDate);
            ((List<Map<String, Object>>) dateData.get("services")).add(serviceData);
            dateData.put("totalDayRevenue", (Double) dateData.get("totalDayRevenue") + dailyRev);
            dateData.put("totalDayBookings", (Integer) dateData.get("totalDayBookings") + bookingsCount);
            
            // Accumulate service revenue
            serviceRevenue.put(serviceType, serviceRevenue.getOrDefault(serviceType, 0.0) + dailyRev);
            totalRevenue += dailyRev;
        }
        
        // Convert to list for display
        for (Map<String, Object> dateData : dateGrouped.values()) {
            dailyReports.add(dateData);
        }
        
        // Sort by date descending
        dailyReports.sort((a, b) -> ((String) b.get("date")).compareTo((String) a.get("date")));
        
        rs.close();
        stmt.close();
        
        // Get monthly total
        String monthlyQuery = "SELECT SUM(amount_payable * 0.30) as monthly_revenue FROM bookings WHERE status = 'completed' AND YEAR(booking_date) = ? AND MONTH(booking_date) = ?";
        if (!"all".equals(selectedMonth)) {
            PreparedStatement monthlyStmt = conn.prepareStatement(monthlyQuery);
            monthlyStmt.setInt(1, Integer.parseInt(selectedYear));
            monthlyStmt.setInt(2, Integer.parseInt(selectedMonth));
            ResultSet monthlyRs = monthlyStmt.executeQuery();
            if (monthlyRs.next()) {
                totalMonthlyRevenue = monthlyRs.getDouble("monthly_revenue");
            }
            monthlyRs.close();
            monthlyStmt.close();
        }
        
        // Get yearly total
        String yearlyQuery = "SELECT SUM(amount_payable * 0.30) as yearly_revenue FROM bookings WHERE status = 'completed' AND YEAR(booking_date) = ?";
        PreparedStatement yearlyStmt = conn.prepareStatement(yearlyQuery);
        yearlyStmt.setInt(1, Integer.parseInt(selectedYear));
        ResultSet yearlyRs = yearlyStmt.executeQuery();
        if (yearlyRs.next()) {
            totalYearlyRevenue = yearlyRs.getDouble("yearly_revenue");
        }
        yearlyRs.close();
        yearlyStmt.close();
        
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<style>
.reports-container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 1rem;
}

.filter-section {
    background: #fff;
    border-radius: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    padding: 2rem;
    margin-bottom: 2rem;
    border: 2px solid #f0f0f0;
}

.filter-row {
    display: flex;
    gap: 1.5rem;
    align-items: end;
    flex-wrap: wrap;
}

.filter-group {
    flex: 1;
    min-width: 200px;
}

.filter-label {
    font-weight: 600;
    color: var(--primary-pink, #e91e63);
    margin-bottom: 0.5rem;
    display: block;
}

.filter-select {
    width: 100%;
    padding: 0.75rem;
    border: 2px solid #f0f0f0;
    border-radius: 8px;
    font-size: 1rem;
    transition: border-color 0.2s;
}

.filter-select:focus {
    border-color: var(--primary-pink, #e91e63);
    outline: none;
}

.filter-btn {
    background: var(--primary-pink, #e91e63);
    color: white;
    border: none;
    padding: 0.75rem 2rem;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
}

.filter-btn:hover {
    background: #d62d7b;
    transform: translateY(-2px);
}

.summary-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
    margin-bottom: 2rem;
}

.summary-card {
    background: #fff;
    border-radius: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    padding: 1.5rem;
    text-align: center;
    border: 2px solid #f0f0f0;
    transition: all 0.2s;
}

.summary-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
}

.summary-title {
    font-size: 1rem;
    color: #666;
    margin-bottom: 0.5rem;
    font-weight: 500;
}

.summary-amount {
    font-size: 1.8rem;
    font-weight: 700;
    color: var(--primary-pink, #e91e63);
    margin-bottom: 0.5rem;
}

.service-buttons {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
}

.service-btn {
    background: #fff;
    border: 2px solid var(--primary-pink, #e91e63);
    color: var(--primary-pink, #e91e63);
    padding: 1rem;
    border-radius: 10px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    text-decoration: none;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
}

.service-btn:hover {
    background: var(--primary-pink, #e91e63);
    color: white;
    transform: translateY(-2px);
    text-decoration: none;
}

.service-btn.active {
    background: var(--primary-pink, #e91e63);
    color: white;
}

.reports-table-container {
    background: #fff;
    border-radius: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    overflow: hidden;
    border: 2px solid #f0f0f0;
}

.table-header {
    background: var(--primary-pink, #e91e63);
    color: white;
    padding: 1.5rem;
    font-size: 1.3rem;
    font-weight: 600;
}

.reports-table {
    width: 100%;
    border-collapse: collapse;
}

.reports-table th {
    background: #f8f9fa;
    color: var(--primary-pink, #e91e63);
    padding: 1rem;
    font-weight: 600;
    text-align: left;
    border-bottom: 2px solid #f0f0f0;
}

.reports-table td {
    padding: 1rem;
    border-bottom: 1px solid #f0f0f0;
    vertical-align: top;
}

.reports-table tbody tr:hover {
    background: #f8f9fa;
}

.date-cell {
    font-weight: 600;
    color: var(--primary-pink, #e91e63);
    min-width: 120px;
}

.service-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.service-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.5rem;
    background: #f8f9fa;
    border-radius: 5px;
    border-left: 3px solid var(--primary-pink, #e91e63);
}

.service-name {
    font-weight: 500;
    color: #333;
}

.service-revenue {
    font-weight: 600;
    color: var(--primary-pink, #e91e63);
}

.service-bookings {
    font-size: 0.9rem;
    color: #666;
}

.total-row {
    background: var(--light-yellow, #fff9e6);
    font-weight: 700;
    font-size: 1.1rem;
}

.total-amount {
    color: var(--primary-pink, #e91e63);
    font-size: 1.2rem;
}

.no-data {
    text-align: center;
    padding: 3rem;
    color: #666;
    font-style: italic;
}

@media (max-width: 768px) {
    .filter-row {
        flex-direction: column;
        gap: 1rem;
    }
    
    .filter-group {
        min-width: 100%;
    }
    
    .summary-cards {
        grid-template-columns: 1fr;
    }
    
    .service-buttons {
        grid-template-columns: 1fr;
    }
    
    .reports-table {
        font-size: 0.9rem;
    }
    
    .reports-table th,
    .reports-table td {
        padding: 0.75rem 0.5rem;
    }
}
</style>

<!-- Main Content -->
<div class="main-content">
    <div class="reports-container">
        <h2 class="section-title">Revenue Reports</h2>
        
        <!-- Filter Section -->
        <div class="filter-section">
            <form method="GET" action="Reports.jsp">
                <div class="filter-row">
                    <div class="filter-group">
                        <label class="filter-label">Year</label>
                        <select name="year" class="filter-select">
                            <% 
                                int currentYear = LocalDate.now().getYear();
                                for (int year = currentYear; year >= currentYear - 5; year--) {
                            %>
                                <option value="<%= year %>" <%= year == Integer.parseInt(selectedYear) ? "selected" : "" %>><%= year %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label class="filter-label">Month</label>
                        <select name="month" class="filter-select">
                            <option value="all" <%= "all".equals(selectedMonth) ? "selected" : "" %>>All Months</option>
                            <option value="1" <%= "1".equals(selectedMonth) ? "selected" : "" %>>January</option>
                            <option value="2" <%= "2".equals(selectedMonth) ? "selected" : "" %>>February</option>
                            <option value="3" <%= "3".equals(selectedMonth) ? "selected" : "" %>>March</option>
                            <option value="4" <%= "4".equals(selectedMonth) ? "selected" : "" %>>April</option>
                            <option value="5" <%= "5".equals(selectedMonth) ? "selected" : "" %>>May</option>
                            <option value="6" <%= "6".equals(selectedMonth) ? "selected" : "" %>>June</option>
                            <option value="7" <%= "7".equals(selectedMonth) ? "selected" : "" %>>July</option>
                            <option value="8" <%= "8".equals(selectedMonth) ? "selected" : "" %>>August</option>
                            <option value="9" <%= "9".equals(selectedMonth) ? "selected" : "" %>>September</option>
                            <option value="10" <%= "10".equals(selectedMonth) ? "selected" : "" %>>October</option>
                            <option value="11" <%= "11".equals(selectedMonth) ? "selected" : "" %>>November</option>
                            <option value="12" <%= "12".equals(selectedMonth) ? "selected" : "" %>>December</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label class="filter-label">Service</label>
                        <select name="service" class="filter-select">
                            <option value="all" <%= "all".equals(serviceFilter) ? "selected" : "" %>>All Services</option>
                            <option value="Groomer" <%= "Groomer".equals(serviceFilter) ? "selected" : "" %>>Groomer</option>
                            <option value="Vet" <%= "Vet".equals(serviceFilter) ? "selected" : "" %>>Vet</option>
                            <option value="Daycare" <%= "Daycare".equals(serviceFilter) ? "selected" : "" %>>Day Care</option>
                            <option value="Walker" <%= "Walker".equals(serviceFilter) ? "selected" : "" %>>Walker</option>
                        </select>
                    </div>
                    <button type="submit" class="filter-btn">
                        <i class="bi bi-funnel"></i> Apply Filter
                    </button>
                </div>
            </form>
        </div>

        <!-- Summary Cards -->
        <div class="summary-cards">
            <div class="summary-card">
                <div class="summary-title">Total Filtered Revenue</div>
                <div class="summary-amount">₹<%= String.format("%.0f", totalRevenue) %></div>
            </div>
            <% if (!"all".equals(selectedMonth)) { %>
            <div class="summary-card">
                <div class="summary-title">Monthly Revenue</div>
                <div class="summary-amount">₹<%= String.format("%.0f", totalMonthlyRevenue) %></div>
            </div>
            <% } %>
            <div class="summary-card">
                <div class="summary-title">Yearly Revenue (<%= selectedYear %>)</div>
                <div class="summary-amount">₹<%= String.format("%.0f", totalYearlyRevenue) %></div>
            </div>
        </div>

        <!-- Service Filter Buttons -->
        <div class="service-buttons">
            <a href="Reports.jsp?year=<%= selectedYear %>&month=<%= selectedMonth %>&service=all" 
               class="service-btn <%= "all".equals(serviceFilter) ? "active" : "" %>">
                <i class="bi bi-grid"></i> All Services
            </a>
            <a href="Reports.jsp?year=<%= selectedYear %>&month=<%= selectedMonth %>&service=Groomer" 
               class="service-btn <%= "Groomer".equals(serviceFilter) ? "active" : "" %>">
                <i class="bi bi-scissors"></i> Groomer
            </a>
            <a href="Reports.jsp?year=<%= selectedYear %>&month=<%= selectedMonth %>&service=Vet" 
               class="service-btn <%= "Vet".equals(serviceFilter) ? "active" : "" %>">
                <i class="bi bi-heart-pulse"></i> Vet
            </a>
            <a href="Reports.jsp?year=<%= selectedYear %>&month=<%= selectedMonth %>&service=Daycare" 
               class="service-btn <%= "Daycare".equals(serviceFilter) ? "active" : "" %>">
                <i class="bi bi-house-heart"></i> Day Care
            </a>
            <a href="Reports.jsp?year=<%= selectedYear %>&month=<%= selectedMonth %>&service=Walker" 
               class="service-btn <%= "Walker".equals(serviceFilter) ? "active" : "" %>">
                <i class="bi bi-person-walking"></i> Walker
            </a>
        </div>

        <!-- Reports Table -->
        <div class="reports-table-container">
            <div class="table-header">
                Daily Revenue Report 
                <% if (!"all".equals(serviceFilter)) { %>
                    - <%= serviceFilter %> Service
                <% } %>
                <% if (!"all".equals(selectedMonth)) { %>
                    - <%= new DateFormatSymbols().getMonths()[Integer.parseInt(selectedMonth)-1] %> <%= selectedYear %>
                <% } else { %>
                    - <%= selectedYear %>
                <% } %>
            </div>
            
            <% if (dailyReports.isEmpty()) { %>
                <div class="no-data">
                    <i class="bi bi-inbox" style="font-size: 3rem; color: #ccc; margin-bottom: 1rem; display: block;"></i>
                    No revenue data found for the selected filters.
                </div>
            <% } else { %>
                <table class="reports-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Services & Revenue</th>
                            <th>Total Bookings</th>
                            <th>Day Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> dailyReport : dailyReports) { %>
                            <tr>
                                <td class="date-cell"><%= dailyReport.get("date") %></td>
                                <td>
                                    <div class="service-list">
                                        <% 
                                            List<Map<String, Object>> services = (List<Map<String, Object>>) dailyReport.get("services");
                                            for (Map<String, Object> service : services) {
                                        %>
                                            <div class="service-item">
                                                <span class="service-name"><%= service.get("service") %></span>
                                                <div>
                                                    <span class="service-revenue">₹<%= String.format("%.0f", (Double) service.get("revenue")) %></span>
                                                    <span class="service-bookings">(<%= service.get("bookings") %> bookings)</span>
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>
                                </td>
                                <td><%= dailyReport.get("totalDayBookings") %></td>
                                <td class="total-amount">₹<%= String.format("%.0f", (Double) dailyReport.get("totalDayRevenue")) %></td>
                            </tr>
                        <% } %>
                        <tr class="total-row">
                            <td colspan="3"><strong>Total Revenue</strong></td>
                            <td class="total-amount"><strong>₹<%= String.format("%.0f", totalRevenue) %></strong></td>
                        </tr>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>
</div>

</body>
</html>