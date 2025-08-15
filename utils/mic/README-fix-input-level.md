# Решение проблемы автоматического изменения уровня входа микрофона

## 🎤 Описание проблемы

В Ubuntu с PipeWire микрофон может автоматически снижать уровень входа когда вы:

-   Кашляете
-   Громко говорите
-   Производите резкие звуки

Результат: ползунок "Input Volume" сдвигается влево, и собеседники перестают вас слышать.

## ✅ Решение

Скрипт `fix-input-level.sh` полностью решает эту проблему.

### 🛠️ Что делает скрипт:

1. **Мониторинг** - проверяет уровень каждые 0.2 секунды
2. **Мгновенное восстановление** - при снижении ниже 95% сразу восстанавливает до 100%
3. **Множественная защита** - использует wpctl, pactl и amixer одновременно
4. **Конфигурация WirePlumber** - блокирует автоматическое управление на системном уровне
5. **Автозапуск** - systemd сервис запускается при загрузке системы

## 🚀 Использование

### Полная настройка (один раз)

```bash
./Linux/fix-input-level.sh
```

### Управление

```bash
# Проверить статус
./Linux/fix-input-level.sh --status

# Перезапустить мониторинг
./Linux/fix-input-level.sh --restart

# Остановить мониторинг
./Linux/fix-input-level.sh --stop

# Протестировать восстановление
./Linux/fix-input-level.sh --test
```

### Управление через systemd

```bash
# Статус сервиса
systemctl --user status mic-level-keeper

# Перезапуск
systemctl --user restart mic-level-keeper

# Остановка
systemctl --user stop mic-level-keeper

# Запуск
systemctl --user start mic-level-keeper
```

## 📊 Мониторинг

### Логи

```bash
# Смотреть логи в реальном времени
tail -f /tmp/mic-level-keeper.log

# Последние записи
tail -10 /tmp/mic-level-keeper.log
```

### Проверка работы

```bash
# Проверить текущий уровень микрофона
wpctl get-volume 55

# Принудительно снизить для теста
wpctl set-volume 55 0.3

# Подождать 1-2 секунды и проверить восстановление
wpctl get-volume 55
```

## 📁 Созданные файлы

### Основные компоненты

-   `~/.local/bin/mic-level-keeper` - основной мониторинг
-   `~/.config/systemd/user/mic-level-keeper.service` - автозапуск
-   `~/.config/wireplumber/main.lua.d/99-disable-input-auto-control.lua` - блокировка WirePlumber

### Логи и состояние

-   `/tmp/mic-level-keeper.log` - логи мониторинга
-   `~/.local/share/mic-level-keeper.pid` - PID процесса

## 🔧 Диагностика

### Проблема: Мониторинг не работает

```bash
# Проверить статус
./Linux/fix-input-level.sh --status

# Перезапустить
./Linux/fix-input-level.sh --restart

# Проверить логи
tail -5 /tmp/mic-level-keeper.log
```

### Проблема: Уровень все еще снижается

```bash
# Протестировать восстановление
./Linux/fix-input-level.sh --test

# Если тест не проходит, переустановить
./Linux/fix-input-level.sh
```

### Проблема: Сервис не запускается

```bash
# Перезагрузить systemd
systemctl --user daemon-reload

# Включить сервис
systemctl --user enable mic-level-keeper.service

# Запустить
systemctl --user start mic-level-keeper.service
```

## ⚡ Результат

После настройки:

-   ✅ Ползунок "Input Volume" остается на месте
-   ✅ При снижении автоматически восстанавливается за 0.2-0.4 секунды
-   ✅ Собеседники стабильно вас слышат
-   ✅ Работает после перезагрузки системы
-   ✅ Не влияет на другие функции (эхоподавление, шумоподавление)

## 🆘 Поддержка

При проблемах:

1. Запустите: `./Linux/fix-input-level.sh --status`
2. Проверьте логи: `tail -10 /tmp/mic-level-keeper.log`
3. Протестируйте: `./Linux/fix-input-level.sh --test`

---

## 📝 Разница со скриптом micro.sh

-   **`micro.sh`** - базовые настройки микрофона, НЕ решает проблему автоматического уровня
-   **`fix-input-level.sh`** - полное решение проблемы автоматического изменения уровня входа

**Для решения проблемы с ползунком используйте ТОЛЬКО `fix-input-level.sh`!**

---

**Автор:** 0xSlaweekq **Версия:** 2.0 **Дата:** 2025
