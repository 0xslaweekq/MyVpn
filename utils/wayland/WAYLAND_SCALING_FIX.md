# Решение проблемы размытых шрифтов в Wayland GNOME

## Проблема
При использовании дробного масштабирования (125%, 150% и т.д.) в Wayland GNOME на высокоплотных дисплеях (как ваш 2048x1280) шрифты становятся размытыми и нечитаемыми. Это происходит из-за того, что Wayland использует upscaling для дробного масштабирования.

## Конфигурация системы
- **CPU**: Intel i7-12700H (Alder Lake-P)
- **GPU**: NVIDIA GeForce RTX 3070 Ti Laptop + Intel Iris Xe
- **Дисплей**: 2048x1280 (QHD+, ~160 DPI)
- **Внешний монитор**: 1920x1080 (Full HD, ~96 DPI)

## Решения

### 1. Полная оптимизация системы
```bash
./utils/wayland/wayland.sh
```
Этот скрипт:
- Настроит переменные окружения для гибридной графики
- Оптимизирует настройки GNOME Mutter
- Создаст конфигурацию Fontconfig
- Настроит автозапуск оптимизаций

### 2. Тестирование масштабирования
```bash
./utils/wayland/wayland-scaling-test.sh
```
Интерактивный скрипт для подбора оптимальных настроек масштабирования.

## Рекомендуемые настройки

### Вариант 1: Чистое текстовое масштабирование (ЛУЧШИЙ)
```bash
gsettings set org.gnome.desktop.interface scaling-factor 0
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
```

### Вариант 2: Целочисленное масштабирование
```bash
gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.desktop.interface text-scaling-factor 0.8
```

### Обязательные настройки шрифтов
```bash
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
gsettings set org.gnome.desktop.interface font-hinting 'slight'
gsettings set org.gnome.desktop.interface font-rgba-order 'rgb'
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'rt-scheduler']"
```

## Пошаговая инструкция

1. **Запустите основной скрипт оптимизации:**
   ```bash
   sudo ./utils/wayland.sh
   ```

2. **Перезагрузите систему**

3. **Войдите в Wayland сессию** (выберите "GNOME on Wayland" при входе)

4. **Протестируйте масштабирование:**
   ```bash
   ./utils/wayland-scaling-test.sh
   ```

5. **Зафиксируйте оптимальные настройки:**
   ```bash
   echo 'gsettings set org.gnome.desktop.interface scaling-factor 0' >> ~/.bashrc
   echo 'gsettings set org.gnome.desktop.interface text-scaling-factor 1.25' >> ~/.bashrc
   ```

## Дополнительные советы

### Если проблема остается:
1. Попробуйте разные значения `text-scaling-factor`: 1.15, 1.20, 1.30
2. Используйте целочисленное масштабирование (scaling-factor 2)
3. Временно вернитесь к X11 для сравнения

### Проверка качества шрифтов:
- Откройте терминал или текстовый редактор
- Сравните четкость с X11 сессией
- Обратите внимание на мелкий текст в браузере

### Откат изменений:
```bash
gsettings reset org.gnome.desktop.interface scaling-factor
gsettings reset org.gnome.desktop.interface text-scaling-factor
gsettings reset org.gnome.mutter experimental-features
```

## Техническое объяснение

**Почему происходит размытие:**
- Wayland использует upscaling для дробного масштабирования
- Гибридная графика Intel+NVIDIA создает дополнительные сложности
- Высокая плотность пикселей усугубляет проблемы с субпиксельным рендерингом

**Как решают наши оптимизации:**
- `scale-monitor-framebuffer` - улучшает качество масштабирования
- `text-scaling-factor` - масштабирует только текст без растеризации UI
- RGBA сглаживание - оптимизирует субпиксельный рендеринг для LCD
- Настройки i915/NVIDIA - устраняют конфликты между GPU

## Альтернативы

Если Wayland все еще проблематичен:
1. Используйте X11 сессию для работы
2. Рассмотрите другие DE (KDE Plasma лучше работает с масштабированием)
3. Используйте внешний монитор как основной

## Поддержка

Если проблемы остаются, проверьте:
- Версию драйверов NVIDIA
- Обновления GNOME
- Логи: `journalctl -b | grep mutter`
