# Recipe App

Flutter app for managing recipes with **SQLite** local database.

## How to Run

```bash
flutter pub get
flutter run
```

## Storage Method

Uses **SQLite** database for persistent local storage:
- Relational database with SQL queries
- Data stored in `recipes.db`
- Supports complex queries and filtering

## Features

- Add, edit, delete recipes
- Filter by recipe type
- Add photos
- Store ingredients and steps
- Data saved locally with SQLite

## Structure

- `models/` - Data models (Recipe, RecipeType)
- `services/` - Database operations with SQL
- `screens/` - UI pages (list, detail, form)
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
```

## Sample Data

App comes with 5 sample recipes:
- Pancakes (Breakfast)
- Caesar Salad (Lunch)  
- Spaghetti Carbonara (Dinner)
- Chocolate Cookies (Dessert)
- Fruit Smoothie (Beverage)

## SQLite vs Hive

This app now uses **SQLite** instead of Hive:
- ✅ More widely known (SQL standard)
- ✅ Better for complex queries
- ✅ Relational database structure
- ✅ Industry standard for mobile apps
