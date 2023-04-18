Запускаем Vagrantfile из нужной папки. Перед запуском меняем путь ssh_pub_key на свой, если требуется.

    vagrant up
  
Установка и настройка ПО обеспечивается ansible playbook.
Открываем папку с плейбуком в терминале.

Запустить плейбук:

    ansible-playbook sirius.yml
  
Если балансировка настроена, то при обновлении страницы 192.168.11.113 будет переключение между серверами:

![](https://github.com/julia7julia/lev/blob/main/lab2_rrobin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202023-04-08%2015-57-26.png)

![](https://github.com/julia7julia/lev/blob/main/lab2_rrobin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202023-04-08%2015-57-35.png)
