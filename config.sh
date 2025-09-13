# fix_permissions.sh
#!/bin/bash
echo "Настраиваю права для лог-файлов"
sudo mkdir -p /var/log
sudo touch /var/log/task1_setup.log
sudo chown user1:user1 /var/log/task1_setup.log
sudo chmod 644 /var/log/task1_setup.log
echo "Права настроены"
