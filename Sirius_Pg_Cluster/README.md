Запускаем Vagrantfile из нужной папки. Перед запуском меняем путь ssh_pub_key на свой, если требуется.

  vagrant up
  
Установка и настройка ПО обеспечивается ansible playbook.
Открываем папку с плейбуком в терминале.

Запустить плейбук:

  ansible-playbook sirius.yml
  
Далее подключиться по ssh к pg1 или pg2:

  vagrant ssh pg2 
Зайти под root правами:

  sudo su
Командв для проверки работоспособности системы:

  patronictl -c /opt/app/patroni/etc/postgresql.yml list
  
Если всё работает:
