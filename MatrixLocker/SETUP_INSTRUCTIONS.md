# MatrixLocker Setup Instructions

## Нові кнопки управління в налаштуваннях

Після останніх змін були додані нові кнопки управління в вікно налаштувань:

### Кнопки які потрібно додати в Interface Builder:

#### Matrix Tab:
1. **Lock Screen Now Button** (`lockScreenNowButton`)
   - Title: "🔒 Lock Screen Now"
   - Action: `lockScreenNowClicked:`
   - Target: Settings View Controller

2. **Test Matrix Screensaver Button** (`testMatrixButton`)
   - Title: "🧪 Test Matrix Screensaver"
   - Action: `testMatrixClicked:`
   - Target: Settings View Controller

3. **Start/Stop Monitoring Button** (`startStopButton`)
   - Title: "▶️ Start Monitoring" (динамічно змінюється)
   - Action: `startStopClicked:`
   - Target: Settings View Controller

### Підключення Outlets:
В SettingsViewController додані наступні outlets:
```swift
@IBOutlet weak var lockScreenNowButton: NSButton?
@IBOutlet weak var testMatrixButton: NSButton?
@IBOutlet weak var startStopButton: NSButton?
```

### Функціональність:
1. **Lock Screen Now** - миттєво активує екран блокування
2. **Test Matrix Screensaver** - показує тестове вікно з ефектом матриці (натисніть ESC для виходу)
3. **Start/Stop Monitoring** - перемикає автоматичне моніторування активності

### Розташування:
Рекомендується розмістити кнопки в Matrix Tab під налаштуваннями звуків у вигляді горизонтального стеку або окремої секції "Control".

## Для запуску оновленого додатка:

1. Відкрийте проект в Xcode
2. Додайте кнопки у Main.storyboard згідно з інструкціями вище
3. Підключіть outlets та actions
4. Зберіть та запустіть проект

## Тестування:

1. Відкрийте налаштування
2. Перейдіть на вкладку "Matrix"
3. Протестуйте кожну з нових кнопок:
   - Lock Screen Now повинен миттєво заблокувати екран
   - Test Matrix повинен показати тестове вікно (ESC для виходу)
   - Start/Stop повинен перемикати моніторування

## Дебагінг:

Якщо кнопки не працюють:
1. Перевірте, що outlets підключені правильно
2. Перевірте, що actions вказують на правильні методи
3. Подивіться в консоль на повідомлення з тегом "🔄"
