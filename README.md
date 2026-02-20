# Student Ride Sharing System

> A university-focused ride sharing system built as a collaborative team project to provide a secure and organized transportation solution for students.

---

## Project Overview

Student Ride Sharing System is a modular multi-application platform designed for campus transportation.

The system includes:

- Student Mobile App
- Driver Mobile App
- Admin Web Dashboard
- Shared Core Module

This project was developed collaboratively as a team-based software engineering project.

---

## Team Project

This project was built by a team of developers as part of a collaborative software engineering effort.

### My Role – Driver App Lead Developer

I was responsible for designing and implementing the Driver Application, including:

- Driver authentication flow  
- Ride request handling logic (Accept / Reject)  
- Ride state management  
- Integration with shared core logic  
- Ensuring clean and scalable architecture

The driver app was built with a focus on:

- Real-time ride updates  
- Clear and intuitive user experience  
- Modular and maintainable code structure

---

## Architecture

```text
student-ride-sharing-app/
│
├── student_app/      # Student-facing mobile app
├── driver_app/       # Driver mobile app (My responsibility)
├── web_dashboard/    # Admin management panel
├── shared_core/      # Shared models & business logic

```

### Architectural Highlights

- Monorepo modular structure  
- Shared business logic between applications  
- Clear separation of concerns (UI / Logic / Core)  
- Designed for scalability and maintainability  

---

## Tech Stack

- Flutter (Dart) – Mobile Applications  
- Firebase – Authentication and Database

---

## Driver App – Key Features (My Contribution)

- Secure Driver Login  
- Ride Request Notifications  
- Accept / Reject Ride Flow  
- Clean UI/UX
- Linking the driver with a student
---

## Screens & UI

### Login & Signup screens

<img width="2200" height="1500" alt="8" src="https://github.com/user-attachments/assets/11f2b1c9-fb38-475f-a0a0-d8d2c8049364" />

---
### Available Rides & Current ride screens

<img width="2200" height="1500" alt="9" src="https://github.com/user-attachments/assets/b64f1b78-3d38-400d-8fc5-432fd85c51aa" />

---
### Accepting Ride screen

<img width="2200" height="1500" alt="10" src="https://github.com/user-attachments/assets/15a92575-ecd6-44f9-8573-1e67b174957f" />

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/CS-Abdulaziz/student-ride-sharing-app.git
cd student-ride-sharing-app
```

### 2.Install dependencies

For each Flutter app:

```bash
flutter pub get
```

```bash
flutter run
```
---

### Author

- Abdulaziz Khamis
- Computer Science Student
- AI and Software Engineering Enthusiast

