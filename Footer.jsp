<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <style>
    footer a:hover {
        color: #3498db !important;
        text-decoration: underline !important;
    }
    .bi-twitter-x {
        position: relative;
        top: -1px;
    }
    footer {
        font-size: 0.95rem;
        border-top: 1px solid #e9ecef;
    }
    .logo-container {
        padding: 10px;
        display: flex;
        align-items: center;
        height: 100%;
    }
    
     /* Footer */
        footer {
            background-color: var(--light-yellow);
            padding: 3rem 0 2rem;
            color: var(--primary-pink);
        }
        
        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }
        
        .social-section {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .social-title {
            font-weight: 600;
            margin-bottom: 1rem;
            font-size: 1.2rem;
        }
        
        .social-icons {
            display: flex;
            justify-content: center;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .social-icons a {
            color: var(--primary-pink);
            font-size: 1.8rem;
            text-decoration: none;
            transition: color 0.2s;
        }
        
        .social-icons a:hover {
            color: var(--primary-yellow);
        }
        
        .contact-info {
            text-align: center;
            margin-bottom: 2rem;
            line-height: 1.8;
        }
        
        .footer-links {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .footer-links a {
            color: var(--primary-pink);
            text-decoration: none;
            font-weight: 600;
            font-size: 1rem;
            transition: color 0.2s;
        }
        
        .footer-links a:hover {
            color: var(--primary-yellow);
        }
        
        .copyright {
            text-align: center;
            font-size: 0.9rem;
            opacity: 0.8;
        }
</style>
    </head>
    <body>
    
    <footer class="py-4" style="background-color: #f8f9fa; color: #495057;">
    <div class="container">
        <div class="row g-4 align-items-center">
            <!-- Column 1: Logo Section -->
            <div class="col-md-3">
                <div class="logo-container">
                    <img src="images/pinklogo.png" class="img-fluid">
                </div>
            </div>

            <!-- Column 2: Social Media -->
            <div class="col-md-3">
                <ul class="list-unstyled">
                    <li class="h6 mb-3" style="color: #2c3e50;">Connect With Us</li>
                    <li class="mb-2">
                        <a href="#" class="text-decoration-none" style="color: #6c757d;">
                            <i class="bi bi-instagram me-2" style="color: #e4405f;"></i>Instagram
                        </a>
                    </li>
                    <li class="mb-2">
                        <a href="#" class="text-decoration-none" style="color: #6c757d;">
                            <i class="bi bi-facebook me-2" style="color: #1877f2;"></i>Facebook
                        </a>
                    </li>
                    <li>
                        <a href="#" class="text-decoration-none" style="color: #6c757d;">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16" class="bi bi-twitter-x me-2" style="color: #000000;">
                                <path d="M12.6.75h2.454l-5.36 6.142L16 15.25h-4.937l-3.867-5.07-4.425 5.07H.316l5.733-6.57L0 .75h5.063l3.495 4.633L12.601.75Zm-.86 13.028h1.36L4.323 2.145H2.865l8.875 11.633Z"/>
                            </svg>
                            X
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Column 3: Contact Info -->
            <div class="col-md-3">
                <ul class="list-unstyled">
                    <li class="h6 mb-3" style="color: #2c3e50;">Contact Us</li>
                    <li class="mb-2">
                        <i class="bi bi-envelope me-2" style="color: #6c757d;"></i>
                        <span style="color: #6c757d;">bookyourcare@gmail.com</span>
                    </li>
                    <li class="mb-2">
                        <i class="bi bi-telephone me-2" style="color: #6c757d;"></i>
                        <span style="color: #6c757d;">+91 22 12345678</span>
                    </li>
                    <li>
                        <i class="bi bi-geo-alt-fill me-2" style="color: #6c757d;"></i>
                        <span style="color: #6c757d;">123 Pet Care Lane, Gujarat</span>
                    </li>
                </ul>
            </div>

            <!-- Column 4: Quick Links -->
            <div class="col-md-3">
                <ul class="list-unstyled">
                    <li class="h6 mb-3" style="color: #2c3e50;">Quick Links</li>
                    <li class="mb-2"><a href="BookYourCare.jsp#searchblock" class="text-decoration-none" style="color: #6c757d;">Search Sitters</a></li>
                    <li class="mb-2"><a href="AboutUs.jsp" class="text-decoration-none" style="color: #6c757d;">About Us</a></li>
                    <li class="mb-2"><a href="sitterApp.jsp" class="text-decoration-none" style="color: #6c757d;">Become a Sitter</a></li>
                    <li><a href="Login.jsp" class="text-decoration-none" style="color: #6c757d;">Login</a></li>
                </ul>
            </div>
        </div>

        <!-- Copyright -->
        <div class="row mt-4">
            <div class="col-12 text-center">
                <p class="mb-0 small" style="color: #6c757d;">&copy; 2023 Book Your Care. All rights reserved.</p>
            </div>
        </div>
    </div>
    </footer>
    </body>
</html>
