# MatrixLocker Development Aliases
# Додай цей вміст до твого ~/.zshrc або ~/.bash_profile

# Швидкі команди для MatrixLocker
alias matrix-build="cd /Users/dev/Documents/NIMDA/MATRIX && xcodebuild -project MatrixLocker.xcodeproj -scheme MatrixLocker build"
alias matrix-clean="cd /Users/dev/Documents/NIMDA/MATRIX && xcodebuild -project MatrixLocker.xcodeproj -scheme MatrixLocker clean build"
alias matrix-run="cd /Users/dev/Documents/NIMDA/MATRIX && ./build_and_run.sh"
alias matrix-run-clean="cd /Users/dev/Documents/NIMDA/MATRIX && ./build_and_run.sh clean"
alias matrix-xcode="cd /Users/dev/Documents/NIMDA/MATRIX && open MatrixLocker.xcodeproj"
alias matrix-dir="cd /Users/dev/Documents/NIMDA/MATRIX"

# Функції для розширених можливостей
matrix-status() {
    cd /Users/dev/Documents/NIMDA/MATRIX
    echo "📁 Current directory: $(pwd)"
    echo "🔗 Git status:"
    git status --short 2>/dev/null || echo "Not a git repository"
    echo "📦 Last build:"
    find /Users/dev/Library/Developer/Xcode/DerivedData -name "MatrixLocker.app" -path "*/Debug/*" -exec ls -la {} \; 2>/dev/null | head -1 || echo "No build found"
}

matrix-logs() {
    echo "📄 Opening Console.app for MatrixLocker logs..."
    open -a Console.app
}

matrix-clean-derived() {
    echo "🧹 Cleaning DerivedData..."
    rm -rf /Users/dev/Library/Developer/Xcode/DerivedData/MatrixLocker-*
    echo "✅ DerivedData cleaned"
}

# Швидкий початок роботи
matrix-help() {
    echo "🔨 MatrixLocker Development Commands:"
    echo "  matrix-build        - Компіляція проекту"
    echo "  matrix-clean        - Чиста компіляція"
    echo "  matrix-run          - Швидка компіляція і запуск"
    echo "  matrix-run-clean    - Чиста компіляція і запуск"
    echo "  matrix-xcode        - Відкрити в Xcode"
    echo "  matrix-dir          - Перейти в директорію проекту"
    echo "  matrix-status       - Показати статус проекту"
    echo "  matrix-logs         - Відкрити логи в Console.app"
    echo "  matrix-clean-derived - Очистити DerivedData"
    echo "  matrix-help         - Показати цю довідку"
}

echo "✅ MatrixLocker aliases loaded! Запусти 'matrix-help' для довідки."
