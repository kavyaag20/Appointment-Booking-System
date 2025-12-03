<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <!-- Bootstrap CSS -->
   
        <style>
            :root {
            --primary-pink: #e83e8c;
            --primary-yellow: #ffc107;
            --light-yellow: #fff9e6;
            --dark-text: #333333;
        }
        .navbar {
            padding: 0.8rem 0;
            background-color: white;
            position: sticky;
            top: 0;
            z-index: 1000;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .navbar-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }
        
        .navbar-brand {
            font-weight: 700;
            color: var(--primary-pink) !important;
            font-size: 1.8rem;
            margin-right: auto;
        }
        
        .navbar-nav {
            margin-left: auto;
        }
        
        .nav-link {
            color: var(--primary-pink) !important;
            font-weight: 600;
            font-size: 1.05rem;
            padding: 0.5rem 1rem !important;
            position: relative;
        }
        
        .nav-link i {
            margin-right: 8px;
            font-size: 1.1rem;
        }
        
        .nav-link:hover {
            color: var(--primary-yellow) !important;
        }
        
        /* Dropdown Styles */
        .dropdown-menu {
            background-color: white;
            border: 2px solid var(--primary-yellow);
            border-radius: 8px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            min-width: 600px;
            padding: 0.5rem 0;
            margin-top: 0.5rem;
            display: none;
            flex-direction: row;
        }
        
        .dropdown:hover .dropdown-menu {
            display: flex !important;
            margin-top: 0;
        }
        
        .dropdown-menu li {
            flex: 1;
        }
        
        .dropdown-item {
            color: var(--primary-pink);
            font-weight: 500;
            padding: 0.7rem 1rem;
            transition: all 0.3s ease;
            border: none;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            white-space: nowrap;
            border-right: 1px solid #f0f0f0;
        }
        
        .dropdown-item:last-child {
            border-right: none;
        }
        
        .dropdown-item i {
            margin-right: 0;
            margin-bottom: 5px;
            font-size: 1.2rem;
            color: var(--primary-yellow);
        }
        
        .dropdown-item:hover {
            background-color: var(--light-yellow);
            color: var(--primary-pink);
            transform: translateY(-3px);
        }
        
        .dropdown-item:focus {
            background-color: var(--light-yellow);
            color: var(--primary-pink);
        }
        
        /* Mobile toggler styling */
        @media (max-width: 991.98px) {
            .navbar-brand {
                margin-left: 0;
                order: 2;
            }
            
            .navbar-toggler {
                order: 1;
                border: none;
                padding: 0.5rem;
            }
            
            .navbar-collapse {
                order: 3;
                background-color: white;
                padding: 1rem;
                margin-top: 1rem;
                border-radius: 0.5rem;
                box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.1);
            }
            
            .dropdown-menu {
                position: static !important;
                transform: none !important;
                box-shadow: none;
                border: none;
                background-color: var(--light-yellow);
                margin-left: 1rem;
                margin-top: 0.5rem;
                flex-direction: column !important;
                min-width: auto;
            }
            
            .dropdown-menu li {
                flex: none;
            }
            
            .dropdown-item {
                flex-direction: row !important;
                justify-content: flex-start;
                border-right: none;
                border-bottom: 1px solid #f0f0f0;
                padding: 0.7rem 1.5rem;
            }
            
            .dropdown-item:last-child {
                border-bottom: none;
            }
            
            .dropdown-item i {
                margin-right: 10px;
                margin-bottom: 0;
            }
        }
        
        /* Hide toggler on desktop */
        @media (min-width: 992px) {
            .navbar-toggler {
                display: none;
            }
        }
        </style>
    </head>
    <body>
        <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-light bg-white sticky-top">
        <div class="container navbar-container">
             <a class="navbar-brand" href="BookYourCare.jsp">Book Your Care</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarContent">
                <ul class="navbar-nav">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="searchDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-search-heart"></i>Search Sitters
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="searchDropdown">
                            <li><a class="dropdown-item" href="#" onclick="openSearchModalFromHeader('Groomer')"><i class="bi bi-scissors"></i>Pet Groomers</a></li>
                            <li><a class="dropdown-item" href="#" onclick="openSearchModalFromHeader('Vet')"><i class="bi bi-heart-pulse"></i>Veterinarians</a></li>
                            <li><a class="dropdown-item" href="#" onclick="openSearchModalFromHeader('Daycare')"><i class="bi bi-house"></i>Pet Daycare</a></li>
                            <li><a class="dropdown-item" href="#" onclick="openSearchModalFromHeader('Walker')"><i class="bi bi-bicycle"></i>Dog Walkers</a></li>
                        </ul>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="AboutUs.jsp">
                            <i class="bi bi-info-circle"></i>About Us
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="sitterApp.jsp">
                            <i class="bi bi-person-plus"></i>Become a Sitter
                        </a>
                    </li>
                    <%
                        String val=(String)session.getAttribute("user_email");
                        if(val == null){ %>
                    
                    <li class="nav-item">
                        <a class="nav-link" href="Login.jsp">
                            <i class="bi bi-box-arrow-in-right"></i>login
                        </a>
                    </li>
                    
                    <%
                        }else{
                    %>
                    <li class="nav-item">
                        <a class="nav-link" href="Bookings.jsp">
                            <i class="bi bi-box-arrow-in-right"></i>Bookings
                        </a>
                    </li>
                  <li class="nav-item">
                        <a class="nav-link" href="Logout.jsp">
                            <i class="bi bi-box-arrow-in-right"></i>Logout
                        </a>
                    </li>
                    <%
                        }
                    %>
                </ul>
            </div>
        </div>
    </nav>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
<script>
function openSearchModalFromHeader(serviceType) {
    // Check if we're on the BookYourCare.jsp page
    if (typeof openSearchModal === 'function') {
        // We're on the homepage, use existing modal
        openSearchModal(serviceType);
    } else {
        // We're on a different page, redirect to homepage with service parameter
        window.location.href = 'BookYourCare.jsp?service=' + serviceType + '#search';
    }
}
</script>