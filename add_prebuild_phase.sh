#!/bin/bash

# Скрипт додає pre-build Run Script Phase для запуску prebuild.sh у головний таргет Xcode-проєкту

set -e

# Знайти .xcodeproj
XCODEPROJ=$(find . -maxdepth 1 -name "*.xcodeproj" | head -n 1)
if [ -z "$XCODEPROJ" ]; then
  echo "[PrebuildSetup] Xcode-проєкт не знайдено у поточній папці."
  exit 1
fi
PBXPROJ="$XCODEPROJ/project.pbxproj"

# Згенерувати унікальний ID для build phase:
PHASE_ID=$(LC_CTYPE=C tr -dc A-Z0-9 < /dev/urandom | head -c 24)

# Додати build phase у project.pbxproj
# Знаходимо перший native target (зазвичай це головний app target)
TARGET_ID=$(grep -B3 "isa = PBXNativeTarget" "$PBXPROJ" | grep "^[A-Z0-9]\{24\} " | head -n1 | awk '{print $1}')
TARGET_ID=${TARGET_ID//:/}

if [ -z "$TARGET_ID" ]; then
  echo "[PrebuildSetup] Не знайдено PBXNativeTarget."
  exit 1
fi

# Додати phase до targets buildPhases
# 1. Додаємо новий блок Run Script Phase
# 2. Додаємо цей ідентифікатор у buildPhases таргету

SCRIPT_PHASE="\
		$PHASE_ID /* Prebuild Script */,\
"

# Додаємо саму фазу у кінець файлу (можна зробити краще через парсер, але для простоти)
cat >> "$PBXPROJ" << EOF

$PHASE_ID /* Prebuild Script */ = {
	isa = PBXShellScriptBuildPhase;
	buildActionMask = 2147483647;
	files = (
	);
	inputPaths = (
	);
	name = "Prebuild Script";
	outputPaths = (
	);
	runOnlyForDeploymentPostprocessing = 0;
	shellPath = "/bin/sh";
	shellScript = "bash \\"\\\${PROJECT_DIR}/prebuild.sh\\"";
};
EOF

# Вставляємо посилання у buildPhases
sed -i '' "/$TARGET_ID /{n;/:buildPhases = (/{n;a\\
$SCRIPT_PHASE\
}}" "$PBXPROJ"

echo "[PrebuildSetup] Pre-build фаза додана у проект!"
