# MatrixLocker - Швидкі Команди Розробки

## 🚀 Комбінації Клавіш (VS Code)

| Комбінація | Дія |
|------------|-----|
| `F9` | Компіляція проекту |
| `F10` | **Компіляція + Запуск** |
| `Shift + F9` | Чиста компіляція |
| `Ctrl + Alt + R` | Тільки запуск (без компіляції) |
| `⌘ + F9` | Відкрити в Xcode |

> **💡 Головна комбінація: `F10` для швидкого запуску!**

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

## 🔧 Terminal Aliases

Для швидшого доступу додай aliases до свого shell профілю:

```bash
# Завантажити aliases
source matrix_aliases.sh

# Або додати до ~/.zshrc:
echo "source /Users/dev/Documents/NIMDA/MATRIX/matrix_aliases.sh" >> ~/.zshrc
```

### Доступні команди:
- `matrix-build` - Компіляція
- `matrix-clean` - Чиста компіляція  
- `matrix-run` - Швидка компіляція + запуск
- `matrix-run-clean` - Чиста компіляція + запуск
- `matrix-xcode` - Відкрити в Xcode
- `matrix-dir` - Перейти в директорію проекту
- `matrix-status` - Статус проекту
- `matrix-logs` - Відкрити логи
- `matrix-clean-derived` - Очистити кеш
- `matrix-help` - Довідка

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

# Очистити DerivedData при проблемах
rm -rf ~/Library/Developer/Xcode/DerivedData/MatrixLocker-*
```

## ⚡ Найшвидші Способи

| Мета | VS Code | Terminal |
|------|---------|----------|
| Швидка компіляція | `F9` | `matrix-build` |
| **Компіляція + запуск** | **`F10`** | `matrix-run` |
| Чиста компіляція | `Shift + F9` | `matrix-clean` |
| Тільки запуск | `Ctrl + Alt + R` | `matrix-run` |
| Відкрити Xcode | `⌘ + F9` | `matrix-xcode` |

---

**Примітка:** Всі комбінації налаштовані для максимальної продуктивності розробки. Використовуй ту, що найбільше підходить для твого workflow!
