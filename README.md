# Isanzure

**Isanzure** is a centralized ticket booking application designed specifically for bus travel in Rwanda. The primary goal is to provide a seamless, mobile-optimized, and highly intuitive platform for passengers to book their journeys, agencies to manage their fleets, and operators to coordinate routes.

## 🎯 Project Goals

- **Centralized Booking:** A single unified platform for passengers to discover and book tickets across multiple bus agencies in Rwanda.
- **Mobile-Optimized:** A premium, fluid mobile experience built with Flutter, focusing on gamification and seamless UX.
- **Ease of Use:** Simplified workflows for user authentication (OTP-based), intuitive route discovery, and frictionless booking.
- **Agency Management:** Tools for bus agencies to manage their schedules, fleets, and bookings in real-time.

## 🛠️ Technology Stack

- **Frontend (Mobile App):** Flutter (Dart) using the Provider architecture for state management.
- **Backend (API Services):** Python (Flask) providing a robust RESTful API.
- **Database:** PostgreSQL (with `psycopg2` connection pooling) ensuring data integrity and fast queries.
- **Authentication:** JWT-based stateless authentication with OTP email verification.

## 📁 Project Structure

- `/isanzure_mobile` - The Flutter mobile application source code.
- `/backend` - The Python Flask backend application, database repositories, and email templates.
- `/documentation` - Extended project documentation (API specs, diagrams).

## 🚀 Getting Started

### Backend Setup
1. Navigate to the `backend` directory.
2. Install dependencies: `pip install -r requirements.txt` (or equivalent).
3. Copy `.env.example` to `.env` and fill in your database/email credentials.
4. Run the development server: `python run.py`.

### Mobile App Setup
1. Navigate to the `isanzure_mobile` directory.
2. Get dependencies: `flutter pub get`.
3. Ensure you have an emulator running or device connected.
4. Run the app: `flutter run`.

---
*This documentation is a living document and will be constantly updated as the project evolves.*
