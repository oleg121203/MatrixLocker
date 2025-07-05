#!/bin/bash

# УВАГА: Скрипт не створює дублікати Main.storyboard. Всі зміни в основному storyboard вносьте вручну через Xcode.

# Скрипт для автоматичного налаштування, збірки та запуску вашого Xcode проекту
# Працює для типових проектів Swift/Objective-C
# Зробіть файл виконуваним: chmod +x project_setup_and_build.sh
# Запустіть: ./project_setup_and_build.sh

set -e

# 1. Встановлення залежностей (CocoaPods, SPM, Carthage)
if [ -f "Podfile" ]; then
  echo "Виявлено Podfile. Встановлення CocoaPods залежностей..."
  pod install
fi

if [ -f "Cartfile" ]; then
  echo "Виявлено Cartfile. Встановлення Carthage залежностей..."
  carthage bootstrap --platform iOS
fi

# Swift Package Manager (SPM) залежності встановлюються Xcode автоматично

echo "\n--- Початок збірки проекту ---"

# 2. Збірка проекту (виявлення .xcodeproj або .xcworkspace)
PROJECT_FILE=$(find . -maxdepth 1 -name "*.xcworkspace" -o -name "*.xcodeproj" | head -n 1)
if [ -z "$PROJECT_FILE" ]; then
  echo "\033[0;31mНе знайдено .xcodeproj або .xcworkspace!\033[0m"
  exit 1
fi

# 3. Вибір схеми (Scheme)
if [[ "$PROJECT_FILE" == *.xcworkspace ]]; then
  SCHEME=$(xcodebuild -workspace "$PROJECT_FILE" -list | awk '/Schemes:/,/^$/' | tail -n +2 | head -n 1 | xargs)
  if [ -z "$SCHEME" ]; then
    echo "\033[0;31mСхема не знайдена!\033[0m"
    exit 1
  fi
else
  SCHEME=$(xcodebuild -project "$PROJECT_FILE" -list | awk '/Schemes:/,/^$/' | tail -n +2 | head -n 1 | xargs)
  if [ -z "$SCHEME" ]; then
    echo "\033[0;31mСхема не знайдена!\033[0m"
    exit 1
  fi
fi

# --- Визначення підтримки macOS у схемі (проста перевірка) ---
echo "\nПеревірка підтримки macOS у схемі..."
sdk_list=$(xcodebuild -scheme "$SCHEME" -showdestinations 2>/dev/null | grep "platform=" || true)
if echo "$sdk_list" | grep -q "platform=macOS"; then
  echo "Схема '$SCHEME' підтримує macOS."
else
  echo "\033[0;33mСхема '$SCHEME' не має підтримки macOS, спробуємо збирати з destination platform=macOS.\033[0m"
fi

# --- Усе про симулятори iOS/iPadOS видаляємо або коментуємо ---

# --- Збірка macOS-додатку ---
echo "\n--- Збірка macOS-додатку ---"
if [[ "$PROJECT_FILE" == *.xcworkspace ]]; then
  xcodebuild -workspace "$PROJECT_FILE" -scheme "$SCHEME" -configuration Debug -destination 'platform=macOS' build
else
  xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration Debug -destination 'platform=macOS' build
fi

# --- Запуск macOS-додатку ---
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -type d -name "*.app" | sort -r | head -n 1)
if [ -z "$APP_PATH" ]; then
  echo "\033[0;31mНе вдалося знайти зібраний .app!\033[0m"
  exit 1
fi

echo "\n--- Запуск macOS-додатку ---"
open "$APP_PATH"

echo "\033[0;32m\nГотово!\033[0m"
