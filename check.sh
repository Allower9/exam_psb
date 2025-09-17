#!/bin/bash
# Скрипт для проверки настроек 
echo "1. Hostname: $(hostname)"
echo "2. Timezone: $(timedatectl show -p Timezone --value)"
echo "3. NTP статус: $(timedatectl show -p NTP --value)"
echo "4. Дата/время: $(date)"
echo "5. NTPSynchronized: $(timedatectl show -p NTPSynchronized --value)"

# проверка на существование SELinux
if [ -f /etc/selinux/config ] || command -v sestatus &> /dev/null; then
    echo "6. SELinux: присутствует в системе"
else
    echo "6. SELinux: отсутствует"
fi

echo "----------"
