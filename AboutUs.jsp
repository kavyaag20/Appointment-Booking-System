<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us - Book Your Care</title>
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
        /* About Page Content */
        .about-hero {
            background-color: var(--light-yellow);
            padding: 4rem 0;
            text-align: center;
        }
        
        .about-hero h1 {
            color: var(--primary-pink);
            font-size: 2.8rem;
            margin-bottom: 1rem;
        }
        
        .about-hero p {
            font-size: 1.2rem;
            max-width: 800px;
            margin: 0 auto;
        }
        
        .about-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 3rem 2rem;
        }
        
        .about-section {
            margin-bottom: 3rem;
        }
        
        .about-section h2 {
            color: var(--primary-pink);
            font-size: 2rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
        }
        
        .about-section h2 i {
            margin-right: 10px;
            color: var(--primary-yellow);
        }
        
        .mission-values {
            display: flex;
            flex-wrap: wrap;
            gap: 2rem;
            margin-top: 2rem;
        }
        
        .value-card {
            flex: 1;
            min-width: 250px;
            background-color: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            border-top: 4px solid var(--primary-pink);
        }
        
        .value-card h3 {
            color: var(--primary-pink);
            margin-top: 0;
            display: flex;
            align-items: center;
        }
        
        .value-card i {
            margin-right: 10px;
            color: var(--primary-yellow);
        }
        
        .team-section {
            background-color: var(--light-yellow);
            padding: 3rem 0;
        }
        
        .team-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }
        
        .team-members {
            display: flex;
            flex-wrap: wrap;
            gap: 2rem;
            justify-content: center;
        }
        
        .team-member {
            width: 200px;
            text-align: center;
        }
        
        .team-member img {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid var(--primary-yellow);
            margin-bottom: 1rem;
        }
        
        .contact-info {
            background-color: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            margin-top: 2rem;
        }
        
        .contact-item {
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .contact-item i {
            width: 30px;
            color: var(--primary-pink);
            font-size: 1.2rem;
        }
        
        .terms-section {
            margin-top: 3rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
            border: 2px dashed var(--primary-yellow);
            border-radius: 10px;
            padding: 2rem; 
        }
    </style>
</head>
<body>
     <jsp:include page="Header.jsp" />
   <!-- About Hero Section -->
    <section class="about-hero">
        <h1>Our Story</h1>
        <p>Founded in 2023 in Palanpur, Gujarat, we're a team of animal lovers dedicated to providing exceptional care for your furry family members.</p>
    </section>

    <!-- Main About Content -->
    <div class="about-content">
        <section class="about-section">
            <h2><i class="bi bi-heart"></i> Who We Are</h2>
            <p>Book Your Care was born from a simple idea: every pet deserves love, care, and attention when their humans can't be there. Established in the heart of Palanpur, Gujarat in 2023, we've grown from a small team of pet enthusiasts to the region's most trusted pet care service.</p>
            <p>What sets us apart is our genuine passion for animals. We don't just provide services - we build relationships with both pets and their owners, creating a circle of trust and care that extends throughout our community.</p>
            
            <div class="mission-values">
                <div class="value-card">
                    <h3><i class="bi bi-star"></i> Our Mission</h3>
                    <p>To provide compassionate, reliable care that lets pet owners enjoy peace of mind while their beloved animals receive the love and attention they deserve.</p>
                </div>
                <div class="value-card">
                    <h3><i class="bi bi-eye"></i> Our Vision</h3>
                    <p>A world where every pet receives exceptional care, and every pet owner has access to trustworthy, loving service providers.</p>
                </div>
                <div class="value-card">
                    <h3><i class="bi bi-hand-thumbs-up"></i> Our Promise</h3>
                    <p>To treat your pets as if they were our own, with kindness, patience, and the highest standards of care.</p>
                </div>
            </div>
        </section>

        <section class="about-section">
            <h2><i class="bi bi-paw"></i> Why We Do This</h2>
            <p>Our founder, a lifelong animal lover, started Book Your Care after seeing how many pets were left alone for long hours while their owners worked or traveled. We believe animals aren't just pets - they're family members who deserve the same love and attention we give our human loved ones.</p>
            <p>Every service we offer, from dog walking to overnight stays, is designed with one goal in mind: to make your pet's life happier, healthier, and full of love - even when you can't be there.</p>
        </section>
    </div>

    <!-- Team Section -->
    <section class="team-section">
        <div class="team-container">
            <h2 style="text-align: center; color: var(--primary-pink); margin-bottom: 2rem;"><i class="bi bi-people"></i> Meet Our Team</h2>
            <div class="team-members">
                <div class="team-member">
                    <img src="https://randomuser.me/api/portraits/women/32.jpg" alt="Team Member">
                    <h3>Priya Patel</h3>
                    <p>Founder & CEO</p>
                </div>
                
                <div class="team-member">
                    <img src="https://randomuser.me/api/portraits/women/68.jpg" alt="Team Member">
                    <h3>Anjali Desai</h3>
                    <p>Co-Founder</p>
                </div>
               
            </div>
        </div>
    </section>

    <!-- Contact & Terms -->
    <div class="about-content">
        <section class="about-section">
            <h2><i class="bi bi-geo-alt"></i> Our Location</h2>
            <div class="contact-info">
                <div class="contact-item">
                    <i class="bi bi-geo-alt-fill"></i>
                    <p>123 Pet Care Lane, Near Gandhi Park, Palanpur, Gujarat 385001</p>
                </div>
                <div class="contact-item">
                    <i class="bi bi-telephone-fill"></i>
                    <p>+91 22 12345678</p>
                </div>
                <div class="contact-item">
                    <i class="bi bi-envelope-fill"></i>
                    <p>BookYourCare@gmail.com</p>
                </div>
                <div class="contact-item">
                    <i class="bi bi-clock-fill"></i>
                    <p>Open 7 days a week: 7:00 AM - 9:00 PM</p>
                </div>
            </div>
        </section>

        <section class="terms-section" id="terms-policies">
            <h2><i class="bi bi-file-text"></i> Terms & Policies</h2>
            <p><strong>Safety First:</strong> All pets must be up-to-date on vaccinations. We reserve the right to refuse service if we believe a pet may be ill.</p>
            <p><strong>Payment:</strong> Payment is due at time of service. We accept payment in form of UPI and cash.</p>
            <p><strong>Satisfaction Guarantee:</strong> If you're not completely satisfied with our service, we'll make it right or refund 40% your payment.</p>
            <p><strong>Service Duration:</strong>We only provide services for a maximum of 8 hours in terms of daycare,other services have a fixed duration of 1-2 hours. </p>
            <p><strong>Privacy Policy:</strong>We do not share any information related to your pets or the owner publically.Photos and videos would be taken with the consent of the owner.</p>
            <p><strong>Our employees:</strong>Our employees are professionals and form a responsible community.No kind of misbehaviour should be expected from the pet owners and from the employees as well.</p>
            <p><strong>Damage Control:</strong>If any mishap occurs,our employees take full responsibility if the owner is not in sight.</p>
        </section>
    </div>
        <jsp:include page="Footer.jsp" />
</body>
</html>