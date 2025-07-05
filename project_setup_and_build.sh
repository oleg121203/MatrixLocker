#!/bin/bash

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

# 4. Вибір симулятора
default_simulator="iPhone 15"
available_simulator=$(xcrun simctl list devices available | grep "$default_simulator" | head -n 1 | awk -F '[()]' '{print $2}')
if [ -z "$available_simulator" ]; then
  echo "\033[0;33m$default_simulator не знайдено, обирається довільний запущений симулятор...\033[0m"
  available_simulator=$(xcrun simctl list devices available | grep -m1 Booted | awk -F '[()]' '{print $2}')
fi

if [ -z "$available_simulator" ]; then
  available_simulator=$(xcrun simctl list devices available | head -n 1 | awk -F '[()]' '{print $2}')
fi

if [ -z "$available_simulator" ]; then
  echo "\033[0;31mНе знайдено жодного доступного симулятора!\033[0m"
  exit 1
fi

# 5. Збірка
if [[ "$PROJECT_FILE" == *.xcworkspace ]]; then
  xcodebuild -workspace "$PROJECT_FILE" -scheme "$SCHEME" -destination "id=$available_simulator" build
else
  xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -destination "id=$available_simulator" build
fi

# 6. Запуск додатку
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -type d -name "*.app" | sort -r | head -n 1)
if [ -z "$APP_PATH" ]; then
  echo "\033[0;31mНе вдалося знайти зібраний .app!\033[0m"
  exit 1
fi

echo "\n--- ЗАПУСК ДОДАТКА У СИМУЛЯТОРІ ---"
xcrun simctl install "$available_simulator" "$APP_PATH"
xcrun simctl launch "$available_simulator" $(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP_PATH/Info.plist")

echo "\033[0;32m\nГотово!\033[0m"
