<p align="center">
    <img width="100" src="screenshot/logic-builder-logo.png" alt="Logic Builder logo">
</p>

<h1 align="center">Logic Builder</h1>
<p align="center">Friendly 👋 and lightweight 🚀 tool 🔬 to Design digital logic circuits 🧮</p>

<p align="center"><a href="https://github.com/carbonanik/logic_builder#logic-builder"><img src="screenshot/and-gate.gif" width="100%"/></a></p><br/>

## 📋 Table of Contents

- [What is Logic Builder?](#-what-is-logic-builder)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)

## 🤔 What is Logic Builder?

Logic Builder is a cross-platform Flutter application designed to facilitate the creation and visualization of digital logic circuits. Whether you're a student learning digital electronics, an educator teaching logic design, or an engineer prototyping circuits, Logic Builder provides an intuitive canvas for building and testing logic gates and circuits.

The application offers a visual, drag-and-drop interface where users can place logic gates, connect them with wires, and create complex digital circuits. With support for multiple modules and persistent storage, you can organize your work into separate projects and save them for later use.

## ✨ Features

### 🎨 Interactive Canvas
- **Visual Circuit Design**: Drag-and-drop interface for placing and connecting logic components
- **Real-time Wire Drawing**: Draw connections between components with smooth, rounded corners
- **Pan and Zoom**: Navigate large circuits with ease using pan gestures
- **Smart Wire Routing**: Hold Control/Cmd for straight-line wire drawing

### 🔌 Logic Components
- **Basic Gates**: AND, OR, NOT, NAND, NOR gates
- **Input/Output**: Controlled input switches and output displays
- **Custom Modules**: Create and reuse custom circuit modules

### 💾 Project Management
- **Multiple Modules**: Organize circuits into separate modules/projects
- **Persistent Storage**: All circuits are automatically saved using Hive local database
- **Module Grid View**: Easy access to all your saved circuits from a grid interface

### 🎯 User Experience
- **Keyboard Shortcuts**: 
  - `ESC` - Cancel wire drawing or deselect components
  - `Delete` - Remove selected components or wires
  - `Control/Cmd` - Enable straight-line wire mode
- **Component Selection**: Click to select and manipulate components
- **Hover Feedback**: Visual feedback when hovering over connection points

## 🛠 Tech Stack

### Framework & Language
- **Flutter** `>=3.1.2` - Cross-platform UI framework
- **Dart** `>=3.1.2` - Programming language

### State Management
- **Riverpod** `^2.1.3` - Reactive state management with providers
- **Hooks Riverpod** - Hooks integration for cleaner component code

### Data Persistence
- **Hive** `^2.2.3` - Lightweight, fast NoSQL database
- **Hive Flutter** `^1.1.0` - Flutter integration for Hive

### Backend Services
- **Firebase Core** `^2.24.2` - Firebase integration (ready for cloud features)

### Utilities
- **UUID** `^4.2.1` - Unique identifier generation for components and wires
- **Intl** `^0.18.1` - Internationalization support
- **Gap** `^3.0.1` - Spacing widgets for clean UI layouts

## 🏗 Architecture

Logic Builder follows a clean, feature-based architecture with clear separation of concerns:

### Core Modules

#### 1. **Logic Canvas** (`lib/features/logic_canvas/`)
The main circuit design interface with the following layers:

- **Models**: Data structures for components, wires, I/O connections, and modules
  - `DiscreteComponent` - Logic gate representations (AND, OR, NOT, etc.)
  - `Wire` - Connection paths between components
  - `IO` - Input/output connection points
  - `Module` - Container for complete circuits

- **Providers**: Riverpod state management
  - `componentProvider` - Manages component state and operations
  - `wiresProvider` - Handles wire drawing and connections
  - `drawingModeProvider` - Controls current drawing mode
  - `panOffsetProvider` - Manages canvas pan/zoom state

- **Painters**: Custom Flutter painters for rendering
  - `LogicPainter` - Renders logic components
  - `WirePainter` - Draws wires with smooth curves
  - `MousePositionPainter` - Visual cursor feedback

- **Event Handlers**: User interaction management
  - Pointer events (hover, tap, pan)
  - Keyboard shortcuts
  - Wire drawing logic
  - Component selection

#### 2. **Logic Grid** (`lib/features/logic_grid/`)
Module/project management interface:

- Grid view of all saved modules
- Create, rename, and delete modules
- Navigate to canvas for editing

#### 3. **Data Layer** (`lib/features/logic_canvas/data_source/`)
- **Local Storage**: Hive-based persistence
  - `module_store.dart` - Module CRUD operations
  - `module_name_store.dart` - Module metadata management

### Design Patterns

- **Provider Pattern**: Riverpod for dependency injection and state management
- **Notifier Pattern**: `ChangeNotifier` for reactive UI updates
- **Repository Pattern**: Abstracted data access through store classes
- **Factory Pattern**: Component creation through factory functions

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.1.2`
- Dart SDK `>=3.1.2`
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/carbonanik/logic_builder.git
   cd logic_builder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
No additional setup required.

#### iOS
```bash
cd ios
pod install
cd ..
```

#### Web
```bash
flutter run -d chrome
```

#### Desktop (Windows/macOS/Linux)
```bash
flutter run -d windows  # or macos, linux
```

## 📖 Usage

### Creating Your First Circuit

1. **Launch the App**: Start on the grid page showing all modules
2. **Create Module**: Tap the "+" button to create a new circuit module
3. **Add Components**: 
   - Select a logic gate from the toolbar
   - Tap on the canvas to place it
4. **Connect Components**:
   - Click on an output pin (red)
   - Click to add wire waypoints
   - Click on an input pin (blue) to complete the connection
5. **Test Your Circuit**:
   - Toggle input switches to see outputs change
   - Verify your logic design works as expected
6. **Save**: Your work is automatically saved!

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `ESC` | Cancel current operation / Deselect |
| `Delete` | Remove selected component or wire |
| `Control/Cmd` | Enable straight-line wire drawing |
| `Pan Gesture` | Move around the canvas |

### Tips & Tricks

- **Straight Wires**: Hold Control/Cmd while drawing wires for perfectly horizontal or vertical lines
- **Wire Cleanup**: Press ESC to cancel a wire you're currently drawing
- **Component Deletion**: Select a component and press Delete to remove it (connected wires are automatically removed)
- **Organization**: Use multiple modules to organize different circuits or project sections

## 📁 Project Structure

```
logic_builder/
├── lib/
│   ├── features/
│   │   ├── logic_canvas/          # Main circuit design feature
│   │   │   ├── data_source/       # Data persistence layer
│   │   │   ├── models/            # Data models
│   │   │   ├── notifier/          # State notifiers
│   │   │   ├── painter/           # Custom painters
│   │   │   ├── presentation/      # UI components
│   │   │   ├── provider/          # Riverpod providers
│   │   │   └── event_handlers.dart
│   │   ├── logic_grid/            # Module grid view
│   │   │   ├── notifier/
│   │   │   ├── provider/
│   │   │   └── grid_page.dart
│   │   └── providers/             # Global providers
│   └── main.dart                  # App entry point
├── android/                       # Android platform code
├── ios/                          # iOS platform code
├── web/                          # Web platform code
├── windows/                      # Windows platform code
├── linux/                        # Linux platform code
├── macos/                        # macOS platform code
├── screenshot/                   # App screenshots
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow Flutter/Dart best practices
- Maintain the existing architecture patterns
- Add tests for new features
- Update documentation as needed
- Keep commits atomic and well-described

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**carbonanik**
- GitHub: [@carbonanik](https://github.com/carbonanik)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- All contributors and users of Logic Builder

---

<p align="center">Made with ❤️ using Flutter</p>
<p align="center"><a href="#-table-of-contents"><img src="http://randojs.com/images/backToTopButtonTransparentBackground.png" alt="Back to top" height="29"/></a></p>
