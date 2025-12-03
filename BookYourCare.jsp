<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@ include file="dbconnect.jsp" %>
<%
// Check if user is logged in
String userEmail = (String) session.getAttribute("user_email");
Integer userId = (Integer) session.getAttribute("user_id");
boolean isLoggedIn = userEmail != null && !userEmail.isEmpty() && userId != null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Your Care - Pet Sitting Services</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-pink: #e83e8c;
            --primary-yellow: #ffc107;
            --light-yellow: #fff9e6;
            --dark-text: #333333;
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            background-color: white;
            color: var(--dark-text);
            line-height: 1.6;
            margin: 0;
            padding: 0;
        }
        
        /* Slideshow */
        .slideshow-container {
            position: relative;
            width: 100%;
            height: 70vh;
            overflow: hidden;
            margin-bottom: 3rem;
        }
        
        .slide {
            position: absolute;
            width: 100%;
            height: 100%;
            opacity: 0;
            transition: opacity 1.5s ease-in-out;
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: white;
        }
        
        .slide.active {
            opacity: 1;
        }
        
        .slide-content {
            max-width: 800px;
            padding: 0 2rem;
        }
        
        .slide h2 {
            font-size: 2.8rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 5px rgba(0,0,0,0.5);
        }
        
        .slide p {
            font-size: 1.4rem;
            margin-bottom: 1.5rem;
            text-shadow: 1px 1px 3px rgba(0,0,0,0.5);
        }
        
        .slide-nav {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            color: white;
            border: none;
            font-size: 2.5rem;
            cursor: pointer;
            z-index: 10;
            transition: all 0.3s;
            opacity: 0.7;
        }
        
        .slide-nav:hover {
            opacity: 1;
            transform: translateY(-50%) scale(1.1);
        }
        
        .prev {
            left: 20px;
        }
        
        .next {
            right: 20px;
        }
        /* Services Grid */
        .section-title {
            color: var(--primary-pink);
            font-weight: 700;
            margin-bottom: 2.5rem;
            text-align: center;
            font-size: 2.3rem;
        }
        
        .service-grid {
            padding: 4rem 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .service-card {
            height: 100%;
            padding: 2.5rem 1.5rem;
            text-align: center;
            border-radius: 12px;
            color: var(--primary-pink);
            border: 2px solid var(--primary-yellow);
            margin: 0 0.5rem;
            background-color: white;
            transition: all 0.3s;
            cursor: pointer;
        }
        
        .service-card:hover {
            background-color: var(--light-yellow);
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        }
        
        .service-card i {
            font-size: 2.8rem;
            color: var(--primary-yellow);
            margin-bottom: 1.2rem;
        }
        
        .service-card h3 {
            margin: 0;
            font-weight: 600;
            font-size: 1.5rem;
        }
        
        .form-label {
            font-weight: 600;
            color: var(--dark-text);
        }
        
        /* Form Styles */
        .form-control, .form-select {
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            padding: 10px 15px;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--primary-yellow);
            box-shadow: 0 0 0 0.25rem rgba(255, 193, 7, 0.25);
        }

        .btn-search {
            background-color: var(--primary-pink);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 8px;
            font-weight: 600;
            width: 100%;
            margin-top: 1rem;
            transition: all 0.3s;
        }

        .btn-search:hover {
            background-color: #d62d7b;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(232, 62, 140, 0.3);
        }

        .city-error {
            display: none;
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
        
        .invalid-feedback {
            display: none;
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }

        .is-invalid {
            border-color: #dc3545 !important;
        }

        /* Reviews Section */
                .review-section {
                    background-color: var(--light-yellow);
                    padding: 4rem 0;
                }

                .review-container {
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 0 2rem;
                }

                .review-card {
                    padding: 2.5rem;
                    text-align: center;
                    height: 100%;
                    background-color: white;
                    border-radius: 8px;
                    margin: 0.5rem;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    min-height: 350px;
                    max-width: 500px;
                    margin: 0 auto;
                }

                .review-text {
                    font-style: italic;
                    font-size: 1.3rem;
                    color: var(--primary-pink);
                    margin-bottom: 1.8rem;
                    line-height: 1.8;
                }

                .review-author {
                    font-weight: 600;
                    font-size: 1.1rem;
                    margin-top: auto;
                }

                /* Person icon styling */
                .review-icon {
                    font-size: 5.5rem;
                    color: var(--primary-pink);
                    margin-bottom: 1.5rem;
                }
        /* Steps Section */
        .steps-section {
            padding: 4rem 0;
        }
        
        .steps-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }
        
        .step-card {
            padding: 2.5rem 2rem;
            text-align: center;
            height: 100%;
            border-radius: 12px;
            background-color: var(--light-yellow);
            color: var(--primary-pink);
            transition: all 0.3s;
        }
        
        .step-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        }
        
        .step-icon {
            font-size: 3rem;
            margin-bottom: 1.5rem;
            color: var(--primary-yellow);
        }
        
        .step-card h3 {
            font-size: 1.6rem;
            margin-bottom: 1.2rem;
        }
        
        .step-card p {
            font-size: 1.1rem;
        }
        
        /* Footer Popup */
        .footer-popup {
            background-color: var(--primary-pink);
            color: white;
            padding: 1.5rem 2rem;
            text-align: center;
            display: none;
            position: relative;
        }
        
        .close-popup {
            position: absolute;
            top: 10px;
            right: 15px;
            cursor: pointer;
            font-size: 1.2rem;
            color: white;
        }
        
        /* Search Modal */
        .search-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.7);
            z-index: 1000;
            overflow-y: auto;
        }
        
        .search-content {
            background-color: white;
            margin: 5% auto;
            padding: 2rem;
            border-radius: 10px;
            max-width: 600px;
            position: relative;
        }
        
        .close-modal {
            position: absolute;
            top: 15px;
            right: 20px;
            font-size: 1.8rem;
            cursor: pointer;
            color: var(--primary-pink);
        }
        
        .search-title {
            color: var(--primary-pink);
            margin-bottom: 1.5rem;
            text-align: center;
        }
        .btn-primary
        {
            background-color: var(--primary-pink) !important;
        }
        
        .booking-note {
            background-color: #e7f3ff;
            border-left: 4px solid #2196f3;
            padding: 1rem;
            margin: 1rem 0;
            border-radius: 4px;
        }

        /* Login Prompt Modal */
        .login-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.8);
            z-index: 1500;
            overflow-y: auto;
        }
        
        .login-content {
            background-color: white;
            margin: 10% auto;
            padding: 2.5rem;
            border-radius: 15px;
            max-width: 500px;
            position: relative;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        
        .login-close {
            position: absolute;
            top: 15px;
            right: 20px;
            font-size: 1.8rem;
            cursor: pointer;
            color: var(--primary-pink);
        }
        
        .login-icon {
            font-size: 4rem;
            color: var(--primary-pink);
            margin-bottom: 1.5rem;
        }
        
        .login-title {
            color: var(--primary-pink);
            margin-bottom: 1rem;
            font-size: 1.8rem;
        }
        
        .login-message {
            color: #666;
            margin-bottom: 2rem;
            font-size: 1.1rem;
        }
        
        .login-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
        }
        
        .btn-login-modal {
            background-color: var(--primary-pink);
            color: white;
            border: none;
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .btn-login-modal:hover {
            background-color: #d62d7b;
            color: white;
            text-decoration: none;
            transform: translateY(-2px);
        }
        
        .btn-signup-modal {
            background-color: var(--primary-yellow);
            color: var(--dark-text);
            border: none;
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .btn-signup-modal:hover {
            background-color: #ffcd3c;
            color: var(--dark-text);
            text-decoration: none;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <jsp:include page="Header.jsp" />
    
    <!-- Slideshow -->
    <div class="slideshow-container">
        <button class="slide-nav prev" onclick="prevSlide()">&#10094;</button>
        <button class="slide-nav next" onclick="nextSlide()">&#10095;</button>
        
        <div class="slide active" style="background-image: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.3)),url('images/home.png');;">
            <div class="slide-content">
                <h2>Premium Pet Care Services</h2>
                <p>Find trusted caregivers for your furry family members</p>
                <a href="#" class="btn btn-primary">Search Now</a>
            </div>
        </div>
        <div class="slide" style="background-image: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.3)), url('images/groomer.png');">
            <div class="slide-content">
                <h2>Professional Pet Grooming</h2>
                <p>Keep your pet looking and feeling their best</p>
                <a href="#" class="btn btn-primary">View Groomers</a>
            </div>
        </div>
        <div class="slide" style="background-image: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.3)), url('images/vet.png');">
            <div class="slide-content">
                <h2>Daily Dog Walking</h2>
                <p>Keep your dog happy and healthy with regular exercise</p>
                <a href="#" class="btn btn-primary">Find Walkers</a>
            </div>
        </div>
    </div>

    <!-- Service Grid Section -->
    <section class="container p-5"  id="searchblock">
        <h2 class="text-center mb-5" style="color: var(--primary-pink);">Our Services</h2>
        <div class="row p-3">
            <div class="col-md-6">
                <div class="service-card" onclick="openSearchModal('Groomer')">
                    <i class="bi bi-scissors"></i>
                    <h3>Groomer</h3>
                    <p>Professional grooming services to keep your pet looking their best</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="service-card" onclick="openSearchModal('Vet')">
                    <i class="bi bi-heart-pulse"></i>
                    <h3>Vet</h3>
                    <p>Qualified veterinary care when your pet needs it most</p>
                </div>
            </div>
        </div>
        <div class="row p-3">
            <div class="col-md-6">
                <div class="service-card" onclick="openSearchModal('Daycare')">
                    <i class="bi bi-house"></i>
                    <h3>Daycare</h3>
                    <p>Safe and fun daytime care for your pet</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="service-card" onclick="openSearchModal('Walker')">
                    <i class="bi bi-bicycle"></i>
                    <h3>Walker</h3>
                    <p>Regular exercise to keep your pet happy and healthy</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Search Modal -->
    <div id="searchModal" class="search-modal">
        <div class="search-content">
            <span class="close-modal" onclick="closeSearchModal()">&times;</span>
            <h2 class="search-title">Find Service Provider</h2>
            <form id="searchForm" method="GET" action="SearchResults.jsp">
                <input type="hidden" id="serviceType" name="serviceType">
                
                <div class="mb-3">
                    <label for="petType" class="form-label">Choose Pet</label>
                    <select class="form-select" id="petType" name="petType" required>
                        <option value="" selected disabled>Sorry fur-friends, we're a dogs-only service!</option>
                        <option value="dog">Dog</option>
                    </select>
                </div>
                
                <div class="mb-3">
                    <label for="address" class="form-label">Address</label>
                    <input type="text" class="form-control" id="address" name="address" required>
                </div>
                        
                <div class="mb-3">
                    <label for="pincode" class="form-label">Pincode</label>
                    <input type="text" class="form-control" id="pincode" name="pincode" value="385001" readonly style="background-color: #f8f9fa;">
                    <small class="text-muted">We currently serve Palanpur area only</small>
                </div>
                
                <div class="mb-3">
                    <label for="time" class="form-label">Preferred Time</label>
                    <select class="form-select" id="time" name="time" required>
                        <option value="" selected disabled>Select time</option>
                        <option value="morning">Morning (8AM - 12PM)</option>
                        <option value="afternoon">Afternoon (12PM - 4PM)</option>
                        <option value="evening">Evening (4PM - 8PM)</option>
                    </select>
                </div>
                
                <div class="mb-3">
                    <label for="phone" class="form-label">Phone Number</label>
                    <input type="tel" class="form-control" id="phone" name="phone" pattern="[0-9]{10}" required>
                    <div id="phoneError" class="invalid-feedback">
                        Please enter a 10-digit phone number
                    </div>
                </div>
                
                <!-- Important Note -->
                <div class="booking-note">
                    <i class="bi bi-info-circle text-info me-2"></i>
                    <strong class="text-info">Note:</strong> 
                    This search will show you available service providers in your area. You can then contact them directly to book services.
                </div>
                
                <div class="d-grid">
                    <button type="submit" class="btn-search">
                        <i class="bi bi-search me-2"></i>Search Providers
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Login Prompt Modal -->
    <div id="loginModal" class="login-modal">
        <div class="login-content">
            <span class="login-close" onclick="closeLoginModal()">&times;</span>
            <div class="login-icon">
                <i class="bi bi-lock-fill"></i>
            </div>
            <h3 class="login-title">Login Required</h3>
            <p class="login-message">
                Please log in to your account to search and book pet care services with our trusted providers.
            </p>
            <div class="login-buttons">
                <a href="Login.jsp" class="btn-login-modal">
                    <i class="bi bi-box-arrow-in-right me-2"></i>Login
                </a>
                <a href="Register.jsp" class="btn-signup-modal">
                    <i class="bi bi-person-plus me-2"></i>Sign Up
                </a>
            </div>
        </div>
    </div>

    <!-- Reviews Section -->
   <!-- Reviews Section with Database Integration -->
<%
// Fetch reviews from database
String reviewQuery = "SELECT owner_name, review, rating FROM bookings WHERE review IS NOT NULL AND review != '' AND rating IS NOT NULL ORDER BY created_at DESC LIMIT 2";
Statement reviewStmt = null;
ResultSet reviewRs = null;
java.util.List<java.util.Map<String, Object>> reviews = new java.util.ArrayList<>();

try {
    reviewStmt = conn.createStatement();
    reviewRs = reviewStmt.executeQuery(reviewQuery);
    
    while(reviewRs.next()) {
        java.util.Map<String, Object> review = new java.util.HashMap<>();
        review.put("owner_name", reviewRs.getString("owner_name"));
        review.put("review", reviewRs.getString("review"));
        review.put("rating", reviewRs.getInt("rating"));
        reviews.add(review);
    }
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(reviewRs != null) reviewRs.close();
    if(reviewStmt != null) reviewStmt.close();
}
%>

<section class="review-section">
    <div class="review-container">
        <h2 class="section-title">Happy Pets & Owners</h2>
        <div class="row">
            <%
            if(reviews.size() > 0) {
                // Display reviews from database
                for(int i = 0; i < Math.min(reviews.size(), 4); i++) {
                    java.util.Map<String, Object> review = reviews.get(i);
                    String ownerName = (String) review.get("owner_name");
                    String reviewText = (String) review.get("review");
                    Integer rating = (Integer) review.get("rating");
            %>
            <div class="col-md-6 mb-4">
                <div class="review-card">
                    <!-- Person Icon instead of profile image -->
                    <div class="review-icon">
                        <i class="bi bi-person-circle"></i>
                    </div>
                    <p class="review-text">"<%= reviewText %>"</p>
                    <div>
                        <div class="rating">
                            <%
                            // Display star rating
                            for(int star = 1; star <= 5; star++) {
                                if(star <= rating) {
                            %>
                                <i class="bi bi-star-fill text-warning"></i>
                            <%
                                } else {
                            %>
                                <i class="bi bi-star text-warning"></i>
                            <%
                                }
                            }
                            %>
                        </div>
                        <p class="review-author">- <%= ownerName %></p>
                    </div>
                </div>
            </div>
            <%
                }
            } else {
                // Display default reviews if no reviews in database
            %>
            <div class="col-md-6 mb-4">
                <div class="review-card">
                    <div class="review-icon">
                        <i class="bi bi-person-circle"></i>
                    </div>
                    <p class="review-text">"Book Your Care saved me so many times when I had to travel for work. I know my sheru is in good hands with their professional sitters!"</p>
                    <div>
                        <div class="rating">
                            <i class="bi bi-star-fill text-warning"></i>
                            <i class="bi bi-star-fill text-warning"></i>
                            <i class="bi bi-star-fill text-warning"></i>
                            <i class="bi bi-star-fill text-warning"></i>
                            <i class="bi bi-star-fill text-warning"></i>
                        </div>
                        <p class="review-author">- Nandita Joshi</p>
                    </div>
                </div>
            </div>
            <div class="col-md-6 mb-4">
                <div class="review-card">
                    <div class="review-icon">
                        <i class="bi bi-person-circle"></i>
                    </div>
                    <p class="review-text">"The sitters are professional and caring. My dog Bella gets so excited every time her walker comes! Highly recommended service."</p>
                    <div>
                        <div class="rating">
                            <i class="bi bi-star-fill text-warning"></i>
                            <i class="bi bi-star-fill text-warning"></i>
                            <i class="bi bi-star-fill text-warning"></i>
                            <i class="bi bi-star-fill text-warning"></i>
                            <i class="bi bi-star-half text-warning"></i>
                        </div>
                        <p class="review-author">- Noor Khan</p>
                    </div>
                </div>
            </div>
            <%
            }
            %>
        </div>
    </div>
</section>
    <!-- Steps Section -->
    <section class="steps-section">
        <div class="steps-container">
            <h2 class="section-title">How It Works</h2>
            <div class="row">
                <div class="col-md-4">
                    <div class="step-card">
                        <div class="step-icon">
                            <i class="bi bi-search"></i>
                        </div>
                        <h3>Search</h3>
                        <p>Find the perfect sitter in your area with our easy-to-use search tool that filters by service, availability, and ratings.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="step-card">
                        <div class="step-icon">
                            <i class="bi bi-calendar-heart"></i>
                        </div>
                        <h3>Book</h3>
                        <p>Book our trusted service providers according to your requirements!</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="step-card">
                        <div class="step-icon">
                            <i class="bi bi-emoji-smile"></i>
                        </div>
                        <h3>Relax</h3>
                        <p>Enjoy peace of mind knowing your pet is in good hands with our vetted, experienced caregivers.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer Popup -->
    <div class="footer-popup" id="footerPopup">
        <span class="close-popup" onclick="document.getElementById('footerPopup').style.display='none'">&times;</span>
        <p><i class="bi bi-info-circle me-2"></i> Finding the right pet care provider is totally free on our website. Connect with trusted professionals in your area!</p>
    </div>
    
    <jsp:include page="Footer.jsp" />
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Store the selected service type
        let selectedServiceType = '';
        
        // Check if user is logged in (from JSP)
        const isLoggedIn = <%= isLoggedIn %>;
        
        // Slideshow functionality
        let currentSlide = 0;
        const slides = document.querySelectorAll('.slide');
        
        function showSlide(n) {
            slides.forEach(slide => slide.classList.remove('active'));
            currentSlide = (n + slides.length) % slides.length;
            slides[currentSlide].classList.add('active');
        }
        
        function nextSlide() {
            showSlide(currentSlide + 1);
        }
        
        function prevSlide() {
            showSlide(currentSlide - 1);
        }
        
        // Change slide every 5 seconds
        let slideInterval = setInterval(nextSlide, 5000);
        
        // Pause on hover
        const slideshow = document.querySelector('.slideshow-container');
        slideshow.addEventListener('mouseenter', () => clearInterval(slideInterval));
        slideshow.addEventListener('mouseleave', () => {
            clearInterval(slideInterval);
            slideInterval = setInterval(nextSlide, 5000);
        });
        
        // Show footer popup when scrolling near footer
        window.addEventListener('scroll', function() {
            const footerPopup = document.getElementById('footerPopup');
            const footer = document.querySelector('footer');
            if (footer) {
                const footerPosition = footer.getBoundingClientRect().top;
                const screenPosition = window.innerHeight / 1.5;
                
                if(footerPosition < screenPosition) {
                    footerPopup.style.display = 'block';
                }
            }
        });
        
        // Search Modal Functions
        function openSearchModal(serviceType) {
            // Check if user is logged in first
            if (!isLoggedIn) {
                showLoginModal();
                return;
            }
            
            selectedServiceType = serviceType;
            document.getElementById('serviceType').value = serviceType;
            document.getElementById('searchModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
            
            // Update modal title
            document.querySelector('.search-title').textContent = `Find ${serviceType} Service`;
        }
        
        function closeSearchModal() {
            document.getElementById('searchModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        
        // Login Modal Functions
        function showLoginModal() {
            document.getElementById('loginModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        
        function closeLoginModal() {
            document.getElementById('loginModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        
        // Close modal when clicking outside of it
        window.onclick = function(event) {
            const searchModal = document.getElementById('searchModal');
            const loginModal = document.getElementById('loginModal');
            
            if (event.target === searchModal) {
                closeSearchModal();
            }
            if (event.target === loginModal) {
                closeLoginModal();
            }
        }
        
        // Phone number validation
        document.getElementById('phone').addEventListener('input', function() {
            const phone = this.value;
            const phoneError = document.getElementById('phoneError');
            
            if (!/^\d{10}$/.test(phone)) {
                this.classList.add('is-invalid');
                phoneError.style.display = 'block';
            } else {
                this.classList.remove('is-invalid');
                phoneError.style.display = 'none';
            }
        });
        
        // Form submission validation
        document.getElementById('searchForm').addEventListener('submit', function(e) {
            // Double-check login status before form submission
            if (!isLoggedIn) {
                e.preventDefault();
                showLoginModal();
                return false;
            }
            
            const phone = document.getElementById('phone').value;
            
            if (!/^\d{10}$/.test(phone)) {
                e.preventDefault();
                alert('Please enter a valid 10-digit phone number');
                return false;
            }
            
            // Form will submit normally and redirect to SearchResults.jsp
        });
        
        // Make slideshow buttons also trigger login check
        document.querySelectorAll('.slide .btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                
                // Check if user is logged in first
                if (!isLoggedIn) {
                    showLoginModal();
                    return;
                }
                
                // If logged in, open search modal with generic service
                openSearchModal('Any Service');
            });
        });
        // Add this JavaScript to your BookYourCare.jsp at the end of the existing script section

// Check for service parameter in URL and auto-open modal
            document.addEventListener('DOMContentLoaded', function() {
                const urlParams = new URLSearchParams(window.location.search);
                const serviceParam = urlParams.get('service');

                if (serviceParam) {
                    // Small delay to ensure page is fully loaded
                    setTimeout(() => {
                        openSearchModal(serviceParam);
                    }, 500);
                }
            });

            // Update existing openSearchModal function to handle login check
            function openSearchModal(serviceType) {
                // Check if user is logged in first
                if (!isLoggedIn) {
                    showLoginModal();
                    return;
                }

                selectedServiceType = serviceType;
                document.getElementById('serviceType').value = serviceType;
                document.getElementById('searchModal').style.display = 'block';
                document.body.style.overflow = 'hidden';

                // Update modal title
                document.querySelector('.search-title').textContent = `Find ${serviceType} Service`;
            }
    </script>
</body>
</html>