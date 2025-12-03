# BookYourCare - Appointment Booking System

## Project Description

BookYourCare is a comprehensive web-based appointment booking system designed to simplify the process of scheduling and managing appointments. The application provides a user-friendly interface for customers to book appointments and an admin panel for staff members to manage bookings, view appointments, and oversee system operations.

### Key Features

- **User-Friendly Booking Interface** - Customers can easily browse available time slots and book appointments
- **Admin Dashboard** - Staff can view, manage, and track all bookings
- **Employee Panel** - Employees can manage their schedules and view assigned appointments
- **Search Functionality** - Users can search for specific appointments and services
- **Responsive Design** - Works seamlessly across different devices and browsers
- **Secure Authentication** - Login and logout functionality for admin and employee access
- **Database-Driven** - All data is securely stored in a SQL database

### Technology Stack

- **Frontend**: JSP (Java Server Pages), HTML, CSS, JavaScript
- **Backend**: Java servlets, JSP
- **Database**: SQL (MySQL/SQL Server)
- **Web Server**: Apache Tomcat (or similar Java application server)
- **Configuration**: XML-based deployment descriptors

---

## Installation & Setup

### Prerequisites

Before you begin, ensure you have the following installed:
- **Java Development Kit (JDK)** - Version 8 or higher
- **Apache Tomcat** - Version 9.0 or higher (or any Java application server)
- **MySQL/SQL Server** - For database management
- **Git** - For cloning the repository

### Step 1: Clone the Repository

```bash
git clone https://github.com/kavyaag20/Appointment-Booking-System.git
cd BookYourCare
```

### Step 2: Set Up the Database

1. Open your SQL database management tool (MySQL Workbench, SQL Server Management Studio, etc.)
2. Create a new database:
   ```sql
   CREATE DATABASE project;
   ```
3. Import the database schema from the project:
   - Navigate to the `database/` folder
   - Run the `schema.sql.sql` file:
   ```bash
   mysql -u root -p bookyourcare < database/schema.sql.sql
   ```

### Step 3: Configure Database Connection

1. Open the file: `dbconnect.jsp` (located in the root directory)
2. Update the database connection details:
   ```jsp
   String url = "jdbc:mysql://localhost:3306/project";
   String username = "your_db_username";
   String password = "your_db_password";
   ```
   Replace `your_db_username` and `your_db_password` with your actual database credentials.

### Step 4: Deploy to Tomcat

1. Build the project (if using Maven/Gradle) or prepare the WAR file
2. Copy the project folder to Tomcat's `webapps` directory:
   ```
   C:\Program Files\Apache Software Foundation\Tomcat\webapps\
   ```
   Or on Linux/Mac:
   ```
   /opt/tomcat/webapps/
   ```
3. Start Tomcat:
   - Windows: Run `startup.bat` from Tomcat's `bin` folder
   - Linux/Mac: Run `startup.sh` from Tomcat's `bin` folder

### Step 5: Access the Application

Open your web browser and navigate to:
```
http://localhost:8080/project
```

---

## Project Structure

```
BookYourCare/
├── AdminPanel/              # Admin dashboard pages
├── employee panel/          # Employee management pages
├── images/                  # Static images and assets
├── META-INF/               # Tomcat configuration files
├── WEB-INF/                # Web application configuration
│   ├── beans.xml           # Spring beans configuration (if applicable)
│   └── web.xml             # Deployment descriptor
├── database/               # Database schema
│   └── schema.sql.sql      # SQL script to create tables
├── AboutUs.jsp             # About page
├── BookYourCare.jsp        # Main booking page
├── BookingForm.jsp         # Booking form
├── Bookings.jsp            # View bookings
├── Footer.jsp              # Footer component
├── Header.jsp              # Header component
├── Login.jsp               # Login page
├── Logout.jsp              # Logout handler
├── SearchResults.jsp       # Search results page
├── sitterApp.jsp           # Sitter application page
└── dbconnect.jsp           # Database connection file
```

---

## Features Overview

### For Users
- Browse and search for available appointments
- View appointment details
- Book appointments with preferred time slots
- View booking history
- Application to be an employee
- Logout functionality

### For Admin
- View all bookings and appointments
- View appointment status
- View user information
- Access dashboard with statistics
- Manage employee schedules

### For Employees
- View assigned appointments
- Update appointment status
- View personal schedule
- Manage profile information
- Access pending appointments

---

## Database Schema

The database includes the following key tables:
- **users** - User account information
- **search_bookings** - general table for appointment booking records
- **completed_appointments** - Shows completed appointments
- **employees** - Employee/staff information
- **cancelled_appointments** - shows cancelled appointments
- **admin** - Administrator credentials
- **sitter applications**- holds info of applicants

For detailed schema information, refer to `database/schema.sql`

---

## Configuration

### Tomcat Configuration

Edit `META-INF/context.xml` if needed to configure:
- Database connection pooling
- Session management
- CORS settings

### Web Application Configuration

Edit `WEB-INF/web.xml` to modify:
- Servlet mappings
- Security constraints
- Welcome pages
- Error handlers

---

## Troubleshooting

### Database Connection Issues
- Verify that your database server is running
- Check database credentials in `dbconnect.jsp`
- Ensure the database and tables were created successfully

### Page Not Found (404 Error)
- Verify Tomcat is running properly
- Check that the project is in the `webapps` folder
- Restart Tomcat after deployment

### Login Issues
- Verify admin/employee credentials in the database
- Check that the `admin` table contains valid entries

---

## Contributing

To contribute to this project:
1. Fork the repository
2. Create a new branch for your feature
3. Make your changes and commit
4. Push to your fork
5. Submit a pull request
---

## Contact & Support

For questions, issues, or suggestions, please reach out through:
- GitHub Issues: [GitHub Repository](https://github.com/kavyaag20/Appointment-Booking-System)
- Email: kavyaagrawal020@gmail.com

---

---

**Last Updated**: December 2025  
**Version**: 1.0  
**Author**: Kavya Agrawal
