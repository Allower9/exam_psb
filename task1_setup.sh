#!/bin/bash
# ЗАДАНИЕ 1 - exam
# 1. Поменять имя хоста
set -e 

LOGFILE="/var/log/task1_setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo " --- Выполнение скрипта (старт в $(date)) --- "

NEW_HOSTNAME="monitoring-server.local"
if [[ "$(hostname)" != "$NEW_HOSTNAME" ]]; then
	echo "Устанавливаю hostname: $NEW_HOSTNAME "
	hostnamectl set-hostname "$NEW_HOSTNAME"
else
	echo "Hostname уже установлен как $NEW_HOSTNAME"
fi
echo "--------------"
# 2. Установка часового пояса
TIMEZONE="Europe/Moscow"
CURRENT_TZ=$(timedatectl show -p Timezone --value)
if [[ "$CURRENT_TZ" != "$TIMEZONE" ]] ; then
	echo " Устанавливаем таймзону $TIMEZONE"
	sudo timedatectl set-timezone "$TIMEZONE"
else 
	echo "Таймзона уже $TIMEZONE"
fi
echo "--------------"
# 3 работаем с NTP 
if ! timedatectl show -p NTP --value | grep -q "yes"; then
  echo "Включаю NTP синхронизацию"
  sudo timedatectl set-ntp true
  sudo systemctl restart systemd-timesyncd
  echo "NTP включен"
else
  echo "NTP уже включен"
fi
echo "--------------"
date
# 4 Обновление информации о доступности пакетов 
echo "--------------"
if sudo apt-get update -y ; then 
	echo " Кэш успешно обновлен"
else
	echo " Ошибка при обновлении кэша пакетов"

fi
