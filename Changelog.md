September 24, 2025  
We created an algorithm that detects fall using Python and libraries like OpenCV and a model YOLOv8n. It included:

- Detecting a fall
- Sending alerts with the help of a Telegram bot to a person that is connected through Telegram ID
- Connecting and testing with a real camera – everything worked

---

November 2, 2025  
We divided our idea into a web version and a mobile application and dropped the Telegram bot notifications.

**Mobile application:**
- Created a basic app that includes dashboard, alerts, contacts, login, register and settings page
- Connected it with the backend part
- Added requirements, model, and database file
- Changed the main algorithm that detects fall (removed Telegram logic, used Flask to link with the front)

**Web:**
- Designed a user-friendly UI for smooth navigation between app sections
- Developed a React + TypeScript web interface (dashboard, alerts, contacts, login, register, settings)
- Built a desktop version of the web app using Electron.js

---

November 29, 2025

**Mobile application** 
- User authentication with secure hashing, login/register UI and per-user state.
- Backend REST API for alerts, contacts, verifications, auth, and fall detection control.
- SQLite/SQLAlchemy data model for users, contacts, alerts, verifications, and FCM tokens.
- New fall detection pipeline: YOLOv8 + Flask, creates DB alerts, hooks for push notifications and emergency contacts, and live video stream to the app with higher accuracy then in previous version.
- Notification system both in backend and Flutter

**Web**
- Fixed key React components (VideoFeed, Dashboard, StatusIndicator, etc.).
- Updated API links and routes so the app communicates correctly with the server.
- Made the interface faster, smoother, and responsive to backend updates.
- Handled macOS camera permissions and security restrictions (TCC).
- Fixed AVFoundation errors that blocked camera access.
- Enabled the system to request and accept camera permission correctly.
- Made the live video stream work inside the browser on macOS something normally very challenging.
