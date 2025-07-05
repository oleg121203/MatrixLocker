#!/bin/bash

# 1. Автоматичне форматування Swift-коду (вимагатиме встановленого 'swift-format')
echo "[Prebuild] Форматування Swift-коду..."
if command -v swift-format &> /dev/null
then
  swift-format format -r .
else
  echo "[Prebuild] 'swift-format' не знайдено (пропускаємо форматування)"
fi

echo "[Prebuild] Копіювання ресурсів..."
# 2. Копіювання всіх файлів з папки Resources у Bundle (створіть папку Resources, якщо потрібно)
RESOURCES_DIR="$(pwd)/Resources"
BUNDLE_DIR="$(pwd)/BundleResources"

if [ -d "$RESOURCES_DIR" ]; then
  mkdir -p "$BUNDLE_DIR"
  cp -R "$RESOURCES_DIR"/* "$BUNDLE_DIR"/
  echo "[Prebuild] Ресурси скопійовано у BundleResources."
else
  echo "[Prebuild] Папка Resources не знайдена (пропускаємо копіювання)"
fi

echo "[Prebuild] Генерація додаткових ресурсів..."
# 3. Якщо у вас є генератор (наприклад, generate_resources.sh), розкоментуйте рядок нижче
# bash generate_resources.sh

echo "[Prebuild] Скрипт виконано."
