Запускаем Vagrantfile из нужной папки. Перед запуском меняем путь ssh_pub_key на свой, если требуется.

    vagrant up
  
Установка и настройка ПО обеспечивается ansible playbook.
Открываем папку с плейбуком в терминале.

Запустить плейбук:

    ansible-playbook sirius.yml
  
Если балансировка настроена, то при обновлении страницы 192.168.11.123 будет переключение между серверами:

![](https://github.com/julia7julia/lev/blob/main/lab3_haproxy/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202023-04-10%2016-38-18.png)

Зайти в pg1 и pg2
  
Если репликация работает, то информация будет одинаковой на pg1 и pg2:

![](https://github.com/julia7julia/lev/blob/main/lab3_haproxy/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202023-04-12%2014-33-08.png)

