# 🔧 Як правильно відкрити MatrixLocker у VS Code

## ❌ Проблема:
VS Code показує "MATRIX" замість "MatrixLocker"

## ✅ Рішення:

### Варіант 1: Через Workspace файл (Рекомендований)
```bash
# Перейти в папку проекту
cd /Users/dev/Documents/NIMDA/MATRIX/MatrixLocker

# Відкрити workspace файл
code MatrixLocker.code-workspace
```

### Варіант 2: Через папку проекту
```bash
# Відкрити тільки папку MatrixLocker
code /Users/dev/Documents/NIMDA/MATRIX/MatrixLocker
```

### Варіант 3: З командної панелі VS Code
1. Відкрити VS Code
2. `Cmd+Shift+P` → "File: Open Workspace from File..."
3. Вибрати `MatrixLocker.code-workspace`

## 🎯 Що отримаємо:

### ✅ Правильна назва проекту
- У VS Code буде показуватися "MatrixLocker"
- Правильний git репозиторій: `oleg121203/MatrixLocker`

### ⚙️ Налаштовані інструменти
- **Tasks для Swift:** перевірка синтаксису, компіляція
- **Git операції:** status, push
- **Правильні налаштування** для Swift файлів

### 🔨 Доступні команди
- `Cmd+Shift+P` → "Tasks: Run Task"
  - Swift: Check Syntax
  - Swift: Compile Current File
  - Git: Status
  - Git: Push to Repository

## 📁 Структура проекту у VS Code:
```
MatrixLocker/
├── 📁 Controllers/
├── 📁 Models/
├── 📁 Utils/
├── 📁 Views/
├── 📁 Assets.xcassets/
├── 📁 .vscode/
├── 📄 AppDelegate.swift
├── 📄 Main.storyboard
├── 📄 README.md
└── 📄 MatrixLocker.code-workspace
```

## 🚀 Швидкий старт:
1. Відкрити `MatrixLocker.code-workspace`
2. Натиснути `Cmd+Shift+P`
3. Запустити "Tasks: Run Task" → "Swift: Check Syntax"
4. Вибрати будь-який .swift файл для перевірки

---
**Тепер VS Code правильно покаже MatrixLocker як назву проекту!** 🎉
