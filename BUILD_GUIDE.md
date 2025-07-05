# MatrixLocker - Швидкі Команди Розробки

## 🚀 Комбінації Клавіш (VS Code)

| Комбінація | Дія |
|------------|-----|
| `⌘ + Shift + B` | Компіляція проекту |
| `⌘ + Shift + R` | Компіляція + Запуск |
| `⌘ + Shift + C` | Чиста компіляція |
| `⌘ + Shift + X` | Відкрити в Xcode |

## 🛠 Доступні Tasks (VS Code)

Відкрий Command Palette (`⌘ + Shift + P`) і набери "Tasks: Run Task":

- **Build MatrixLocker** - Звичайна компіляція
- **Clean Build MatrixLocker** - Чиста компіляція (з очищенням)  
- **Run MatrixLocker** - Запуск додатку
- **Build and Run MatrixLocker** - Компіляція + Запуск
- **Open in Xcode** - Відкрити проект в Xcode

## 📜 Shell Скрипти

### Швидка компіляція і запуск:
```bash
./build_and_run.sh
```

### Чиста компіляція і запуск:
```bash
./build_and_run.sh clean
```

## 🔧 Ручні Команди

### Компіляція:
```bash
cd /Users/dev/Documents/NIMDA/MATRIX
xcodebuild -project MatrixLocker.xcodeproj -scheme MatrixLocker build
```

### Чиста компіляція:
```bash
xcodebuild -project MatrixLocker.xcodeproj -scheme MatrixLocker clean build
```

### Запуск:
```bash
open /Users/dev/Library/Developer/Xcode/DerivedData/MatrixLocker-*/Build/Products/Debug/MatrixLocker.app
```

## 📝 Налагодження

Для налагодження використовуй Xcode або додаткові інструменти:

```bash
# Відкрити в Xcode
open MatrixLocker.xcodeproj

# Перевірити логи
Console.app
```

---

**Примітка:** Всі комбінації налаштовані для максимальної продуктивності розробки. Використовуй ту, що найбільше підходить для твого workflow!
