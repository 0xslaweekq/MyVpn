#!/bin/bash

echo "=== Тестировщик масштабирования Wayland для устранения размытых шрифтов ==="
echo "Этот скрипт поможет найти оптимальные настройки для вашего дисплея 2048x1280"
echo ""

# Проверяем, что мы в Wayland
if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    echo "ОШИБКА: Вы не в сессии Wayland!"
    echo "Перезайдите в систему и выберите 'GNOME on Wayland'"
    exit 1
fi

# Функция для применения настроек и показа результата
apply_settings() {
    local scaling=$1
    local text_scaling=$2
    local description=$3

    echo "=== $description ==="
    echo "Применяю: scaling-factor=$scaling, text-scaling-factor=$text_scaling"

    gsettings set org.gnome.desktop.interface scaling-factor $scaling
    gsettings set org.gnome.desktop.interface text-scaling-factor $text_scaling

    # Немного ждем применения настроек
    sleep 2

    echo "Настройки применены. Проверьте четкость шрифтов в браузере или текстовом редакторе."
    echo "Нажмите Enter для продолжения..."
    read
}

# Показываем текущие настройки
echo "ТЕКУЩИЕ НАСТРОЙКИ:"
echo "Scaling factor: $(gsettings get org.gnome.desktop.interface scaling-factor)"
echo "Text scaling factor: $(gsettings get org.gnome.desktop.interface text-scaling-factor)"
echo "Experimental features: $(gsettings get org.gnome.mutter experimental-features)"
echo ""

echo "Выберите вариант тестирования:"
echo "1) Метод 1: Чистое текстовое масштабирование (рекомендуется)"
echo "2) Метод 2: Автоматическое определение + текстовое масштабирование"
echo "3) Метод 3: Целочисленное масштабирование 2x + уменьшение текста"
echo "4) Метод 4: Отключение всего масштабирования"
echo "5) Сброс к исходным настройкам"
echo "6) Расширенные настройки шрифтов"
echo "7) Выход"
echo ""

while true; do
    read -p "Введите номер (1-7): " choice

    case $choice in
        1)
            apply_settings 0 1.25 "Чистое текстовое масштабирование 125%"
            ;;
        2)
            apply_settings 0 1.15 "Автоматическое + умеренное текстовое масштабирование"
            ;;
        3)
            apply_settings 2 0.8 "Целочисленное масштабирование 200% + уменьшение текста"
            ;;
        4)
            apply_settings 0 1.0 "Без масштабирования (100%)"
            ;;
        5)
            echo "Сброс к настройкам по умолчанию..."
            gsettings reset org.gnome.desktop.interface scaling-factor
            gsettings reset org.gnome.desktop.interface text-scaling-factor
            echo "Настройки сброшены."
            ;;
        6)
            echo "=== Расширенные настройки шрифтов ==="
            echo "Применяю оптимизированные настройки сглаживания..."

            # Применяем лучшие настройки для высокоплотных дисплеев
            gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
            gsettings set org.gnome.desktop.interface font-hinting 'slight'
            gsettings set org.gnome.desktop.interface font-rgba-order 'rgb'

            # Дополнительные настройки Mutter
            gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'rt-scheduler']"

            echo "Расширенные настройки применены."
            echo "Попробуйте теперь варианты 1-3 для масштабирования."
            ;;
        7)
            echo "Выход из программы."
            break
            ;;
        *)
            echo "Неверный выбор. Попробуйте снова."
            ;;
    esac

    if [ $choice -ne 5 ] && [ $choice -ne 6 ] && [ $choice -ne 7 ]; then
        echo ""
        echo "Хотите попробовать другой вариант? (y/n)"
        read -r continue_test
        if [[ $continue_test != "y" && $continue_test != "Y" ]]; then
            break
        fi
        echo ""
    fi
done

echo ""
echo "=== ИТОГОВЫЕ РЕКОМЕНДАЦИИ ==="
echo ""
echo "Для дисплея 2048x1280 (~160 DPI) лучше всего работает:"
echo "1. Метод 1: scaling-factor=0, text-scaling-factor=1.25"
echo "2. Если метод 1 не подходит, попробуйте метод 3"
echo ""
echo "После выбора оптимального варианта, зафиксируйте настройки:"
echo "echo 'gsettings set org.gnome.desktop.interface scaling-factor 0' >> ~/.bashrc"
echo "echo 'gsettings set org.gnome.desktop.interface text-scaling-factor 1.25' >> ~/.bashrc"
echo ""
echo "Чтобы применить настройки при каждом входе в систему."
