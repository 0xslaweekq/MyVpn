#!/bin/bash

echo "=== БЫСТРОЕ ИСПРАВЛЕНИЕ РАЗМЫТЫХ ШРИФТОВ В WAYLAND ==="
echo "Применяю оптимальные настройки для дисплея 2048x1280..."
echo ""

# Проверяем Wayland
if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    echo "⚠️  ВНИМАНИЕ: Вы не в сессии Wayland!"
    echo "Настройки все равно будут применены, но эффект будет виден только в Wayland."
    echo ""
fi

# Применяем оптимальные настройки
echo "🔧 Применяю оптимизированные настройки шрифтов..."

# Основные настройки масштабирования
gsettings set org.gnome.desktop.interface scaling-factor 0
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25

# Оптимизация сглаживания шрифтов
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
gsettings set org.gnome.desktop.interface font-hinting 'slight'
gsettings set org.gnome.desktop.interface font-rgba-order 'rgb'

# Экспериментальные функции Mutter
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'rt-scheduler']"

echo "✅ Настройки применены!"
echo ""
echo "=== РЕЗУЛЬТАТ ==="
echo "Масштаб интерфейса: $(gsettings get org.gnome.desktop.interface scaling-factor)"
echo "Масштаб текста: $(gsettings get org.gnome.desktop.interface text-scaling-factor)"
echo "Сглаживание: $(gsettings get org.gnome.desktop.interface font-antialiasing)"
echo "Экспериментальные функции: $(gsettings get org.gnome.mutter experimental-features)"
echo ""
echo "🎯 ПРОВЕРЬТЕ РЕЗУЛЬТАТ:"
echo "- Откройте терминал или текстовый редактор"
echo "- Сравните четкость шрифтов с X11"
echo "- Если шрифты все еще размытые, попробуйте:"
echo "  gsettings set org.gnome.desktop.interface text-scaling-factor 1.15"
echo "  (или 1.30 для большего размера)"
echo ""
echo "📋 АЛЬТЕРНАТИВНЫЕ ВАРИАНТЫ:"
echo "1. Целочисленное масштабирование:"
echo "   gsettings set org.gnome.desktop.interface scaling-factor 2"
echo "   gsettings set org.gnome.desktop.interface text-scaling-factor 0.8"
echo ""
echo "2. Откат к 100% масштабу:"
echo "   gsettings set org.gnome.desktop.interface scaling-factor 0"
echo "   gsettings set org.gnome.desktop.interface text-scaling-factor 1.0"
