#!/bin/bash

# Полное решение проблемы автоматического изменения уровня входа микрофона
# Автор: 0xSlaweekq
# Описание: Блокирует автоматическое снижение уровня входа микрофона

set -e

echo "================================================================="
echo "Решение проблемы автоматического изменения уровня входа микрофона"
echo "================================================================="

# Функция для определения активного микрофона
detect_active_microphone() {
    # Сначала пытаемся найти активный микрофон (помеченный звездочкой)
    # Ищем в разделе Filters (для Bluetooth) и Sources
    MIC_ID=$(wpctl status 2>/dev/null | grep -E "^\s+\*.*\[Audio/Source\]" | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')

    if [ -z "$MIC_ID" ] || [ "$MIC_ID" -le 0 ] 2>/dev/null; then
        # Пытаемся найти в разделе Sources (активный)
        MIC_ID=$(wpctl status 2>/dev/null | grep -A 20 "Sources:" | grep -E "^\s+\*" | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')
    fi

    if [ -z "$MIC_ID" ] || [ "$MIC_ID" -le 0 ] 2>/dev/null; then
        # Пытаемся найти Bluetooth микрофон
        MIC_ID=$(wpctl status 2>/dev/null | grep -E "bluez_input\." | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')
    fi

    if [ -z "$MIC_ID" ] || [ "$MIC_ID" -le 0 ] 2>/dev/null; then
        # Пытаемся найти по имени AirPods
        MIC_ID=$(wpctl status 2>/dev/null | grep -i "airpods" | grep -E "Sources:|Filters:" -A 5 | grep -E "^\s+[0-9]+\." | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')
    fi

    if [ -z "$MIC_ID" ] || [ "$MIC_ID" -le 0 ] 2>/dev/null; then
        # Пытаемся найти по старому имени
        MIC_ID=$(wpctl status 2>/dev/null | grep "Headphones Stereo Microphone" | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')
    fi

    # Получаем имя микрофона для отображения
    if [ ! -z "$MIC_ID" ] && [ "$MIC_ID" -gt 0 ] 2>/dev/null; then
        # Сначала пытаемся получить понятное имя через pactl
        MIC_PACTL_NAME=$(wpctl status 2>/dev/null | grep -E "[[:space:]]+$MIC_ID\." | sed -E 's/.*[0-9]+\.\s+([^[:space:]]+).*/\1/' | head -1)

        # Если это Bluetooth устройство, пытаемся получить описание
        if echo "$MIC_PACTL_NAME" | grep -q "bluez"; then
            MIC_NAME=$(pactl list sources 2>/dev/null | grep -A 10 "$MIC_PACTL_NAME" | grep "Description:" | sed 's/.*Description: //' | head -1)
        fi

        # Если не получили описание, используем имя из wpctl
        if [ -z "$MIC_NAME" ]; then
            MIC_NAME=$(wpctl status 2>/dev/null | grep -E "[[:space:]]+$MIC_ID\." | sed -E 's/.*[0-9]+\.\s+([^[:space:]]+).*/\1/' | head -1)
        fi

        # Если все еще пусто, используем ID
        if [ -z "$MIC_NAME" ]; then
            MIC_NAME="ID $MIC_ID"
        fi
    fi

    echo "$MIC_ID|$MIC_NAME"
}

# Функция для фиксации уровня входа
fix_input_level() {
    echo "Фиксация уровня входа микрофона..."

    # Определяем активный микрофон
    MIC_INFO=$(detect_active_microphone)
    MIC_ID=$(echo "$MIC_INFO" | cut -d'|' -f1)
    MIC_NAME=$(echo "$MIC_INFO" | cut -d'|' -f2)

    if [ ! -z "$MIC_ID" ] && [ "$MIC_ID" -gt 0 ] 2>/dev/null; then
        echo "Найден микрофон: $MIC_NAME (ID: $MIC_ID)"

        # Устанавливаем максимальный уровень
        wpctl set-volume "$MIC_ID" 1.0 2>/dev/null
        echo "✓ Уровень установлен на 100%"

        # Убеждаемся что не заглушен
        wpctl set-mute "$MIC_ID" 0 2>/dev/null
        echo "✓ Микрофон включен"
    else
        echo "⚠️  Микрофон не найден по ID, используем общие настройки"
    fi

    # Также через pactl (работает с любым микрофоном, включая Bluetooth)
    pactl set-source-volume @DEFAULT_SOURCE@ 100% 2>/dev/null
    pactl set-source-mute @DEFAULT_SOURCE@ 0 2>/dev/null
    echo "✓ Уровень через PulseAudio установлен"

    # Через ALSA для надежности (только для ALSA устройств)
    amixer -c 1 sset "Capture" 100% 2>/dev/null || echo "⚠️  ALSA настройка недоступна (нормально для Bluetooth)"
}

# Создаем эффективный мониторинг уровня входа
create_level_keeper() {
    echo "Создание хранителя уровня входа микрофона..."

    cat > ~/.local/bin/mic-level-keeper << 'EOF'
#!/bin/bash

# Простой и эффективный хранитель уровня микрофона
# Автор: 0xSlaweekq

LOGFILE="/tmp/mic-level-keeper.log"

# Функция для определения активного микрофона
detect_active_mic() {
    # Сначала пытаемся найти активный микрофон (помеченный звездочкой)
    MIC_ID=$(wpctl status 2>/dev/null | grep -E "^\s+\*.*\[Audio/Source\]" | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')

    if [ -z "$MIC_ID" ] || [ "$MIC_ID" -le 0 ] 2>/dev/null; then
        # Пытаемся найти в разделе Sources (активный)
        MIC_ID=$(wpctl status 2>/dev/null | grep -A 20 "Sources:" | grep -E "^\s+\*" | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')
    fi

    if [ -z "$MIC_ID" ] || [ "$MIC_ID" -le 0 ] 2>/dev/null; then
        # Пытаемся найти Bluetooth микрофон
        MIC_ID=$(wpctl status 2>/dev/null | grep -E "bluez_input\." | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')
    fi

    if [ -z "$MIC_ID" ] || [ "$MIC_ID" -le 0 ] 2>/dev/null; then
        # Пытаемся найти по имени AirPods
        MIC_ID=$(wpctl status 2>/dev/null | grep -i "airpods" | grep -E "Sources:|Filters:" -A 5 | grep -E "^\s+[0-9]+\." | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')
    fi

    if [ -z "$MIC_ID" ] || [ "$MIC_ID" -le 0 ] 2>/dev/null; then
        # Пытаемся найти по старому имени
        MIC_ID=$(wpctl status 2>/dev/null | grep "Headphones Stereo Microphone" | head -1 | sed -E 's/.*[[:space:]]+([0-9]+)\..*/\1/')
    fi

    echo "$MIC_ID"
}

echo "$(date): Starting microphone level keeper" >> "$LOGFILE"

while true; do
    # Находим ID микрофона каждый раз заново (может измениться при перезапуске PipeWire)
    MIC_ID=$(detect_active_mic)

    if [ ! -z "$MIC_ID" ] && [ "$MIC_ID" -gt 0 ] 2>/dev/null; then
        # Получаем текущий уровень
        CURRENT_VOLUME=$(wpctl get-volume "$MIC_ID" 2>/dev/null | awk '{print $2}')

        if [ ! -z "$CURRENT_VOLUME" ]; then
            # Конвертируем в проценты для удобства
            CURRENT_PERCENT=$(echo "$CURRENT_VOLUME * 100" | bc -l 2>/dev/null | cut -d. -f1)

            # Если уровень меньше 95%, восстанавливаем до 100%
            if [ ! -z "$CURRENT_PERCENT" ] && [ "$CURRENT_PERCENT" -lt 95 ] 2>/dev/null; then
                echo "$(date): Level dropped to ${CURRENT_PERCENT}%, restoring to 100%" >> "$LOGFILE"

                # Восстанавливаем уровень тремя способами
                wpctl set-volume "$MIC_ID" 1.0 2>/dev/null
                pactl set-source-volume @DEFAULT_SOURCE@ 100% 2>/dev/null
                amixer -c 1 sset "Capture" 100% 2>/dev/null

                echo "$(date): Level restored to 100%" >> "$LOGFILE"
            fi
        fi
    else
        echo "$(date): Microphone not found, searching..." >> "$LOGFILE"
    fi

    # Проверяем каждые 0.2 секунды для быстрой реакции
    sleep 0.2
done
EOF

    chmod +x ~/.local/bin/mic-level-keeper
    echo "✓ Хранитель уровня создан: ~/.local/bin/mic-level-keeper"
}

# Создаем конфигурацию WirePlumber для блокировки автоматического управления
create_wireplumber_config() {
    echo "Создание конфигурации WirePlumber..."

    mkdir -p ~/.config/wireplumber/main.lua.d

    cat > ~/.config/wireplumber/main.lua.d/99-disable-input-auto-control.lua << 'EOF'
-- Блокировка автоматического управления уровнем входа микрофона
-- Автор: 0xSlaweekq

-- Правила для блокировки автоматического управления уровнем
rule_input_level = {
  matches = {
    {
      { "media.class", "equals", "Audio/Source" },
      { "node.name", "matches", "*Mic*" },
    },
  },
  apply_properties = {
    -- Отключаем автоматическое управление уровнем
    ["audio.auto-gain-control.enable"] = false,
    ["audio.agc.enable"] = false,
    ["device.auto-volume"] = false,
    ["device.auto-level"] = false,
    ["alsa.auto-gain"] = false,

    -- Блокируем изменения громкости
    ["volume.lock"] = true,
    ["volume.auto"] = false,

    -- Фиксируем уровень
    ["volume"] = 1.0,
    ["mute"] = false,
  },
}

table.insert(alsa_monitor.rules, rule_input_level)

-- Мониторинг изменений уровня в реальном времени
local function monitor_input_level()
  for node in nodes_om:iterate() do
    if node.properties["media.class"] == "Audio/Source" and
       node.properties["node.name"] and
       string.match(node.properties["node.name"], "Mic") then

      -- Подключаем обработчик изменений параметров
      node:connect("params-changed", function(node, param_name)
        if param_name == "Props" then
          -- Принудительно восстанавливаем уровень
          node:set_param("Props", Pod.Object {
            "Spa:Pod:Object:Param:Props", "Props",
            volume = 1.0,
            mute = false,
          })
          Log.warning("Input level auto-corrected to 100%")
        end
      end)

      Log.info("Input level monitoring enabled for: " .. node.properties["node.name"])
    end
  end
end

-- Запускаем мониторинг с задержкой
Core.timeout_add(1000, function()
  monitor_input_level()
  return false
end)

-- Мониторинг новых устройств
nodes_om:connect("object-added", function(om, node)
  if node.properties["media.class"] == "Audio/Source" and
     node.properties["node.name"] and
     string.match(node.properties["node.name"], "Mic") then

    Core.timeout_add(500, function()
      -- Устанавливаем фиксированные параметры
      node:set_param("Props", Pod.Object {
        "Spa:Pod:Object:Param:Props", "Props",
        volume = 1.0,
        mute = false,
      })

      -- Подключаем мониторинг
      node:connect("params-changed", function(node, param_name)
        if param_name == "Props" then
          node:set_param("Props", Pod.Object {
            "Spa:Pod:Object:Param:Props", "Props",
            volume = 1.0,
            mute = false,
          })
        end
      end)

      Log.info("New microphone auto-configured: " .. node.properties["node.name"])
      return false
    end)
  end
end)
EOF

    echo "✓ Конфигурация WirePlumber создана"
}

# Создаем systemd сервис для автозапуска
create_systemd_service() {
    echo "Создание systemd сервиса..."

    mkdir -p ~/.config/systemd/user

    cat > ~/.config/systemd/user/mic-level-keeper.service << 'EOF'
[Unit]
Description=Хранитель уровня входа микрофона
After=pipewire.service

[Service]
Type=simple
ExecStart=%h/.local/bin/mic-level-keeper
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
EOF

    # Перезагружаем и включаем сервис
    systemctl --user daemon-reload
    systemctl --user enable mic-level-keeper.service

    echo "✓ Systemd сервис создан и включен"
}

# Функция для запуска мониторинга
start_monitoring() {
    echo "Запуск мониторинга уровня входа..."

    # Останавливаем старые процессы
    pkill -f mic-level-keeper 2>/dev/null || true
    sleep 0.5

    # Запускаем через systemd
    if systemctl --user start mic-level-keeper.service 2>/dev/null; then
        sleep 0.5
        SERVICE_PID=$(systemctl --user show mic-level-keeper.service -p MainPID --value 2>/dev/null)
        if [ ! -z "$SERVICE_PID" ] && [ "$SERVICE_PID" != "0" ]; then
            echo "✓ Мониторинг запущен через systemd (PID: $SERVICE_PID)"
        else
            echo "✓ Мониторинг запущен через systemd"
        fi
    else
        # Fallback: запускаем вручную, если systemd не работает
        ~/.local/bin/mic-level-keeper &
        MONITOR_PID=$!
        echo "$MONITOR_PID" > ~/.local/share/mic-level-keeper.pid
        echo "✓ Мониторинг запущен вручную (PID: $MONITOR_PID)"
    fi
}

# Функция для проверки состояния
check_status() {
    echo "================================================================="
    echo "Статус решения проблемы уровня входа микрофона:"
    echo "================================================================="

    echo "--- Текущий уровень микрофона ---"
    MIC_INFO=$(detect_active_microphone)
    MIC_ID=$(echo "$MIC_INFO" | cut -d'|' -f1)
    MIC_NAME=$(echo "$MIC_INFO" | cut -d'|' -f2)
    if [ ! -z "$MIC_ID" ] && [ "$MIC_ID" -gt 0 ] 2>/dev/null; then
        CURRENT_VOLUME=$(wpctl get-volume "$MIC_ID" 2>/dev/null | awk '{print $2}')
        CURRENT_PERCENT=$(echo "$CURRENT_VOLUME * 100" | bc -l 2>/dev/null | cut -d. -f1)
        echo "Микрофон: $MIC_NAME (ID: $MIC_ID)"
        echo "Текущий уровень: ${CURRENT_PERCENT}%"
    else
        echo "❌ Микрофон не найден"
    fi

    echo -e "\n--- Статус мониторинга ---"
    # Проверяем через systemd сервис
    if systemctl --user is-active mic-level-keeper.service >/dev/null 2>&1; then
        SERVICE_PID=$(systemctl --user show mic-level-keeper.service -p MainPID --value 2>/dev/null)
        if [ ! -z "$SERVICE_PID" ] && [ "$SERVICE_PID" != "0" ]; then
            echo "✅ Мониторинг активен через systemd (PID: $SERVICE_PID)"
        else
            echo "✅ Мониторинг активен через systemd"
        fi
    elif [ -f ~/.local/share/mic-level-keeper.pid ]; then
        pid=$(cat ~/.local/share/mic-level-keeper.pid 2>/dev/null)
        if [ ! -z "$pid" ] && ps -p "$pid" > /dev/null 2>&1; then
            echo "✅ Мониторинг активен вручную (PID: $pid)"
        else
            echo "❌ Мониторинг не активен"
        fi
    else
        echo "❌ Мониторинг не запущен"
    fi

    echo -e "\n--- Системный сервис ---"
    if systemctl --user is-enabled mic-level-keeper.service >/dev/null 2>&1; then
        echo "✅ Автозапуск включен"
        # Проверяем статус более надежно
        SERVICE_STATUS=$(systemctl --user is-active mic-level-keeper.service 2>&1)
        if [ "$SERVICE_STATUS" = "active" ]; then
            echo "✅ Сервис активен"
        else
            echo "⚠️  Сервис неактивен (статус: $SERVICE_STATUS)"
        fi
    else
        echo "❌ Автозапуск отключен"
    fi

    echo -e "\n--- Файлы конфигурации ---"
    if [ -f ~/.local/bin/mic-level-keeper ]; then
        echo "✅ Скрипт мониторинга: ~/.local/bin/mic-level-keeper"
    else
        echo "❌ Скрипт мониторинга отсутствует"
    fi

    if [ -f ~/.config/wireplumber/main.lua.d/99-disable-input-auto-control.lua ]; then
        echo "✅ Конфигурация WirePlumber: ~/.config/wireplumber/main.lua.d/99-disable-input-auto-control.lua"
    else
        echo "❌ Конфигурация WirePlumber отсутствует"
    fi

    if [ -f ~/.config/systemd/user/mic-level-keeper.service ]; then
        echo "✅ Systemd сервис: ~/.config/systemd/user/mic-level-keeper.service"
    else
        echo "❌ Systemd сервис отсутствует"
    fi

    echo -e "\n--- Логи мониторинга ---"
    if [ -f /tmp/mic-level-keeper.log ]; then
        echo "Последние 3 записи:"
        tail -3 /tmp/mic-level-keeper.log
    else
        echo "Логи отсутствуют"
    fi
}

# Основная функция
main() {
    echo "Начинаем полное решение проблемы автоматического уровня входа..."

    # Проверяем права
    if [ "$EUID" -eq 0 ]; then
        echo "⚠️  Не запускайте этот скрипт от root!"
        exit 1
    fi

    # Создаем необходимые директории
    mkdir -p ~/.local/bin ~/.local/share ~/.config/systemd/user ~/.config/wireplumber/main.lua.d

    # Выполняем все этапы
    fix_input_level
    create_level_keeper
    create_wireplumber_config
    create_systemd_service
    start_monitoring

    echo "================================================================="
    echo "✅ Проблема автоматического изменения уровня входа РЕШЕНА!"
    echo "================================================================="
    echo ""
    echo "Что было сделано:"
    echo "1. Создан эффективный мониторинг уровня входа (проверка каждые 0.2 сек)"
    echo "2. Настроен WirePlumber для блокировки автоматического управления"
    echo "3. Создан systemd сервис для автозапуска"
    echo "4. Мониторинг запущен немедленно"
    echo "5. Уровень входа зафиксирован на 100%"
    echo ""
    echo "Управление:"
    echo "  systemctl --user start mic-level-keeper   - запустить"
    echo "  systemctl --user stop mic-level-keeper    - остановить"
    echo "  systemctl --user status mic-level-keeper  - статус"
    echo ""
    echo "Логи: tail -f /tmp/mic-level-keeper.log"
    echo ""
    echo "🎤 Теперь ползунок Input Volume НЕ будет сдвигаться влево!"
    echo "    При снижении уровня он автоматически восстановится до 100%."

    echo ""
    check_status
}

# Проверяем аргументы
case "${1:-}" in
    --status)
        check_status
        exit 0
        ;;
    --stop)
        echo "Остановка мониторинга..."
        # Останавливаем systemd сервис
        if systemctl --user stop mic-level-keeper.service 2>/dev/null; then
            echo "✓ Systemd сервис остановлен"
        else
            echo "⚠️  Systemd сервис не был запущен"
        fi
        # Останавливаем процессы, запущенные вручную (если есть)
        pkill -f mic-level-keeper 2>/dev/null && echo "✓ Ручные процессы остановлены" || true
        rm -f ~/.local/share/mic-level-keeper.pid
        exit 0
        ;;
    --restart)
        echo "Перезапуск мониторинга..."
        systemctl --user restart mic-level-keeper
        echo "✓ Сервис перезапущен"
        exit 0
        ;;
    --test)
        echo "Тестирование восстановления уровня..."
        MIC_INFO=$(detect_active_microphone)
        MIC_ID=$(echo "$MIC_INFO" | cut -d'|' -f1)
        MIC_NAME=$(echo "$MIC_INFO" | cut -d'|' -f2)
        if [ ! -z "$MIC_ID" ] && [ "$MIC_ID" -gt 0 ] 2>/dev/null; then
            echo "Тестируем микрофон: $MIC_NAME (ID: $MIC_ID)"
            echo "Снижаем уровень до 20%..."
            wpctl set-volume "$MIC_ID" 0.2 2>/dev/null
            echo "Ждем 3 секунды восстановления..."
            sleep 3
            CURRENT_VOLUME=$(wpctl get-volume "$MIC_ID" 2>/dev/null | awk '{print $2}')
            CURRENT_PERCENT=$(echo "$CURRENT_VOLUME * 100" | bc -l 2>/dev/null | cut -d. -f1)
            echo "Текущий уровень: ${CURRENT_PERCENT}%"
            if [ ! -z "$CURRENT_PERCENT" ] && [ "$CURRENT_PERCENT" -gt 90 ] 2>/dev/null; then
                echo "✅ Тест ПРОШЕЛ! Уровень восстановился."
            else
                echo "❌ Тест НЕ ПРОШЕЛ! Уровень не восстановился."
            fi
        else
            echo "❌ Микрофон не найден для тестирования"
        fi
        exit 0
        ;;
    --help|-h)
        echo "Использование: $0 [опция]"
        echo ""
        echo "Опции:"
        echo "  (без опций)  - Выполнить полную настройку"
        echo "  --status     - Проверить статус"
        echo "  --stop       - Остановить мониторинг"
        echo "  --restart    - Перезапустить мониторинг"
        echo "  --test       - Протестировать восстановление уровня"
        echo "  --help, -h   - Показать эту справку"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        echo "❌ Неизвестная опция: $1"
        echo "Используйте --help для справки"
        exit 1
        ;;
esac
