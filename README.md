# Recipe App

Flutter app for managing recipes with **SQLite** local database and **authentication**.

## Features

- 🔐 **User Authentication** - Login/logout with encrypted passwords
- 📝 **Recipe Management** - Add, edit, delete recipes
- 🔍 **Filter by Type** - Filter recipes by category
- 📸 **Photo Support** - Add photos to recipes
- 💾 **Local Storage** - SQLite database for persistence
- 🔒 **Session Persistence** - Stay logged in until logout

## How to Run

```bash
flutter pub get
flutter run
```

## Login Credentials

**Demo Account:**
- Username: `admin`
- Password: `admin123`

## Storage Method

Uses **SQLite** database for persistent local storage:
- Relational database with SQL queries
- Data stored in `recipes.db`
- Supports complex queries and filtering
- User authentication with encrypted passwords

## Authentication

- **Password Encryption**: SHA-256 hashing with salt
- **Session Management**: Persistent sessions using shared_preferences
- **Auto-login**: Session persists across app restarts until logout

## Features

- Add, edit, delete recipes
- Filter by recipe type
- Add photos
- Store ingredients and steps
- Data saved locally with SQLite
- Secure login/logout

## Structure

- `models/` - Data models (Recipe, RecipeType, User)
- `services/` - Database operations and authentication
- `screens/` - UI pages (login, list, detail, form)
- `widgets/` - Reusable components

## Database Schema

```sql
CREATE TABLE recipes (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  typeId INTEGER NOT NULL,
  typeName TEXT NOT NULL,
  imgPath TEXT,
  ingredients TEXT NOT NULL,
  steps TEXT NOT NULL,
  createdAt INTEGER NOT NULL
)

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  passwordHash TEXT NOT NULL,
  salt TEXT NOT NULL,
  createdAt INTEGER NOT NULL)
```

## Sample Data

App comes with 5 sample recipes:
- Pancakes (Breakfast)
- Caesar Salad (Lunch)  
- Spaghetti Carbonara (Dinner)
- Chocolate Cookies (Dessert) - with photo
- Fruit Smoothie (Beverage) - with photo
