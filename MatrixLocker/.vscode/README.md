# VS Code Configuration for MatrixLocker

## Встановлені налаштування:

### 📁 Workspace
- `MatrixLocker.code-workspace` - основний workspace файл
- Налаштування для Swift розробки
- Рекомендовані розширення

### ⚙️ Settings (.vscode/settings.json)
- Налаштування для Swift файлів
- Виключення системних файлів (.DS_Store, build папки)
- Git налаштування

### 🔨 Tasks (.vscode/tasks.json)
- **Swift: Check Syntax** - перевірка синтаксису поточного файлу
- **Swift: Compile Current File** - компіляція файлу
- **Git: Status** - перевірка статусу git
- **Git: Push to Repository** - відправка змін

### 🐛 Launch (.vscode/launch.json)
- Базові налаштування запуску для проекту

## Як використовувати:

1. **Відкрити workspace:**
   ```bash
   code MatrixLocker.code-workspace
   ```

2. **Запустити task:**
   - `Cmd+Shift+P` → "Tasks: Run Task"
   - Вибрати потрібний task

3. **Перевірити синтаксис:**
   - Відкрити .swift файл
   - `Cmd+Shift+P` → "Tasks: Run Task" → "Swift: Check Syntax"

## Рекомендовані розширення:

- **Swift** - підтримка Swift синтаксису
- **Code Spell Checker** - перевірка орфографії
- **GitLens** - розширені можливості Git

## Корисні команди:

```bash
# Відкрити проект у VS Code
code /Users/dev/Documents/NIMDA/MATRIX/MatrixLocker

# Відкрити workspace
code MatrixLocker.code-workspace

# Перевірити синтаксис файлу
swiftc -parse Controllers/SettingsViewController.swift
```
