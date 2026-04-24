# 📋 Task Manager App — Flutter + Back4App (BaaS)

A Flutter-based Task Manager application that uses **Back4App** as a Backend-as-a-Service (BaaS) for cloud storage, real-time sync, and user authentication.

---

## 📸 Screenshots

> Register Screen
<img width="1900" height="900" alt="image" src="https://github.com/user-attachments/assets/3bdde57b-d8f0-4e3d-bf8b-f22062690a5c" />

> Login Screen
<img width="1903" height="906" alt="image" src="https://github.com/user-attachments/assets/69e0cd7e-1910-4b74-9a0d-ec33d0891ea6" />

>Dashboard
<img width="1904" height="915" alt="image" src="https://github.com/user-attachments/assets/2cada49a-af5d-4601-b593-c61318bacb5b" />

>CreateTask
<img width="1912" height="910" alt="image" src="https://github.com/user-attachments/assets/66172f66-3ac7-4bb9-bcdf-2b717178ba31" />

---

## ✨ Features

| Feature | Description |
|--------|-------------|
| 🔐 **User Registration** | Register with student email ID via Back4App auth |
| 🔑 **User Login** | Secure login with session management |
| ✅ **Create Task** | Add tasks with title and description |
| 📋 **Read Tasks** | View all tasks with completion status |
| ✏️ **Update Task** | Edit task details and toggle completion |
| 🗑️ **Delete Task** | Remove tasks with confirmation dialog |
| 🔄 **Real-time Sync** | Data synced with Back4App cloud DB |
| 🚪 **Secure Logout** | Session invalidation on logout |

---

## 🛠️ Technology Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Back4App (Parse Server)
- **Database:** Back4App Cloud Database
- **Authentication:** Parse User Authentication
- **Version Control:** GitHub

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- A Back4App account ([Sign up free](https://www.back4app.com/))

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/task-manager-flutter.git
cd task-manager-flutter
```

### Step 2: Set Up Back4App

1. Go to [back4app.com](https://www.back4app.com/) and create a free account
2. Create a new **Parse App**
3. Go to **App Settings → Security & Keys**
4. Copy your **Application ID** and **Client Key**
5. In Back4App dashboard, go to **Database → Create a class** named `Task` with fields:
   - `title` (String)
   - `description` (String)
   - `isCompleted` (Boolean)

### Step 3: Configure the App

Open `lib/main.dart` and replace the placeholder keys:

```dart
await Parse().initialize(
  'YOUR_BACK4APP_APP_ID',       // ← Paste your Application ID here
  'https://parseapi.back4app.com',
  clientKey: 'YOUR_BACK4APP_CLIENT_KEY', // ← Paste your Client Key here
  autoSendSessionId: true,
);
```

### Step 4: Install Dependencies & Run

```bash
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point & Parse initialization
├── models/
│   └── task_model.dart        # Task data model
├── services/
│   └── task_service.dart      # CRUD operations with Back4App
└── screens/
    ├── login_screen.dart      # Login UI
    ├── register_screen.dart   # Registration UI
    ├── task_list_screen.dart  # Main task list (Read + Delete)
    └── add_edit_task_screen.dart  # Create & Update tasks
```

---

## 📊 CRUD Operation Flow

```
User Action → Flutter UI → TaskService → Back4App (Parse Server) → Cloud DB
                    ↑________________________↓
                         Real-time Sync
```

| Operation | Method | Parse SDK Call |
|-----------|--------|---------------|
| Create | `createTask()` | `ParseObject.save()` |
| Read | `getTasks()` | `QueryBuilder.query()` |
| Update | `updateTask()` | `ParseObject.save()` |
| Delete | `deleteTask()` | `ParseObject.delete()` |

---

## 🔒 Security

- User authentication handled entirely by Back4App
- ACL (Access Control List) set per task — only the task owner can read/write
- Session tokens managed automatically by Parse SDK
- Passwords never stored locally

---

## 🎥 Demo Video

https://drive.google.com/file/d/1IolNusgp4e1djbPXMl8Z6tSoXNKY9kCW/view?usp=sharing

## 📄 License

This project is created for academic purposes as part of the Cross-Platform Application Development course.
