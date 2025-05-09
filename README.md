<img src="https://github.com/user-attachments/assets/9fc2ac7d-6e12-4620-9a34-a560e4813f37" alt="logo_Tracki" style="width: 20%; height: auto;"/>

# Tracki

## Introduction :bulb:

**Tracki** is a mobile app that enhances the process of discovering food trucks in Riyadh. With Tracki, users can effortlessly find, track, and rate their favorite food trucks, eliminating the difficulties of locating them. Our aim is to improve the food truck experience, making it more accessible and enjoyable for everyone.

## Technology :computer:

The Tracki application is developed using:

- **Programming Language:** Dart, Python
- **Framework:** Flutter
- **Development Tools:** Visual Studio Code, Figma
- **Database & Authentication:** Firebase (Firestore, Firebase Auth, Storage)
- **API Integration:** Google Maps API
- **Project Management:** Jira

## Features :sparkles:

- Food truck location tracking with Google Maps
- Admin dashboard for food truck approval
- Owner dashboard to manage trucks and menus
- Customer-side discovery, reviews, and favorites
- Secure authentication and real-time updates
- Chatbot to assist food truck owners in coming up with new recipes
- Recommender system to suggest food trucks to customers based on their favorites, location, and highest ratings

## Launching Instructions :rocket:

**1. Clone the repository:** :paperclips:

```bash
https://github.com/GhalaAlotaibi/2024-25_GP_9.git
```

**2. Make sure to have the following installed:** :wrench:

- Flutter
- Python
- Android Studio emulator or a physical device :iphone:

**3. Run the application components in order:  :arrow_forward:**

1. First: Run the Recommender System

Navigate to the recommender system folder and run the Python script.

```bash
cd Recommender
pip install -r recommednerReqs.txt
python app.py
```
2. Second: Run the Chatbot

```bash
cd cooking_chatbot
pip install -r requirements.txt
python app.py
```
3. Finally: Run the Mobile Application


Open a new terminal window and run the following commands:

```bash
cd your-project-folder
flutter pub get
flutter run
```

