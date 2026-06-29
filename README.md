# Student Ride Sharing System

> A university-focused ride sharing system built as a collaborative software engineering project to provide a secure and organized transportation solution for students.

---

## 📌 Project Overview

Student Ride Sharing System is a modular, multi-application platform designed for campus transportation.

The comprehensive system includes:
* **Admin Web Dashboard (My Contribution)**
* Student Mobile App (Team Contribution)
* Driver Mobile App (Team Contribution)
* Shared Core Module

This project was developed collaboratively as a team-based software engineering effort to build a scalable and organized ecosystem.

---

## 👨‍💻 My Role – Full Stack Developer (Admin Dashboard)

In this collaborative project, I was responsible for the end-to-end development of the **Admin Web Dashboard** as a Full Stack Developer, utilizing **Django** for the backend and managing the database via **Firebase**.

My core responsibilities included:
* **Full Stack Development:** Designing and building both the frontend interface and the backend logic for the web dashboard.
* **Database Management:** Integrating Firebase to manage and structure data for users (students, drivers) and rides in real-time.
* **System Administration:** Creating a seamless, dark-themed interface for monitoring and controlling system operations securely.
* **Clean Architecture:** Ensuring scalable, maintainable, and clean code integration with the rest of the system.

---

## 🏗️ Architecture

```text
student-ride-sharing-app/
│
├── web_dashboard/      # Admin Full Stack Web Panel (My responsibility)
├── student_app/        # Student-facing mobile app
├── driver_app/         # Driver mobile app 
├── shared_core/        # Shared models & business logic

```

### Architectural Highlights
* **Monorepo Modular Structure:** Organizes the entire system components in one place.
* **Clean Code & Scalability:** Backend structured to handle data efficiently and support system growth.
* **Clear Separation of Concerns:** Distinct boundaries between the UI (Flutter apps), the Web Dashboard, and the shared Database.
---

## 🛠️ Tech Stack

### Web Dashboard (My Work)
* **Framework:** Python, Django
* **Frontend:** HTML, CSS
* **Database:** Firebase (Realtime Database / Firestore integration)

### Mobile Apps (Team's Work)
* **Framework:** Flutter (Dart)
* **Backend-as-a-Service:** Firebase

---

## 🚀 Admin Dashboard – Key Features (My Contribution)

* **Centralized Management:** Full control over registered students, drivers, and ride statuses.
* **Database Administration:** Direct and user-friendly interface for managing data seamlessly.
* **Secure Access:** Protected admin login and session management.
* **System Oversight:** Tracking active, completed, and canceled rides in real-time.

> **Note:** The mobile application screens for students and drivers were developed by my teammates as part of our collaborative effort.

---

## 🖥️ Admin Dashboard Screens (My Work)

---

## 🖥️ Admin Dashboard Screens (My Work)

### Secure Admin Login
<img width="1000" alt="Admin Login" src="<img width="1280" height="687" alt="Secure Admin Login" src="https://github.com/user-attachments/assets/241ef3b4-2594-490a-acb2-5effc5f414cc" />
" />

---
### Main Overview Dashboard
<img width="1000" alt="Main Dashboard" src="<img width="1280" height="682" alt="Main Overview Dashboard" src="https://github.com/user-attachments/assets/c39a828f-67f1-40c2-9b67-180bfab642e3" />
" />

---
### Drivers Management & Details
<img width="1000" alt="Drivers List" src="<img width="1280" height="684" alt="Drivers Management   Details" src="https://github.com/user-attachments/assets/211923d9-431e-4a76-a5d7-ca6dcf482f40" />
" />
<img width="1000" alt="Driver Details Modal" src="<img width="1280" height="685" alt="Drivers Management   Details 2" src="https://github.com/user-attachments/assets/4c1ff148-a999-49aa-9b07-ea307ffd8d21" />
" />

---
### Users & Rides Tracking
<img width="1000" alt="Users List" src="<img width="1280" height="687" alt="Users Management" src="https://github.com/user-attachments/assets/ec019366-778a-48ac-bdd3-d5db0c9557eb" />
" />
<img width="1000" alt="Rides Tracking" src="<img width="1280" height="684" alt="Rides Tracking" src="https://github.com/user-attachments/assets/edd8a0d7-0949-4e6d-ab63-5ffbe96dda39" />
" />

---
### Complaints & Support System
<img width="1000" alt="Complaints Management" src="<img width="1280" height="686" alt="Complaints" src="https://github.com/user-attachments/assets/10be86dc-1000-45c6-924f-a233bcbb59dc" />
" />
<img width="1000" alt="Support Ticket Resolution" src="<img width="1280" height="685" alt="Support" src="https://github.com/user-attachments/assets/02b26e8a-9a15-4827-b9ab-180f8e6ec7cc" />
" />

---

## 💻 Getting Started

### 1. Clone the repository
```bash
git clone [https://github.com/OmarCsY/student-ride-sharing-app.git](https://github.com/OmarCsY/student-ride-sharing-app.git)
cd student-ride-sharing-app
```
### 2. Setup the Admin Dashboard (Django)
Navigate to the dashboard directory and run the server:
```bash
cd web_dashboard
pip install -r requirements.txt
python manage.py runserver
```
### 3. Setup the Mobile Apps (Flutter)
For the driver or student app, navigate to their respective directories:
```bash
cd driver_app  # or cd student_app
flutter pub get
flutter run
```
---

## 👨‍🎓 Author

**Omar Al-Ali**
* Computer Science Student
* Full Stack Developer & AI Enthusiast
