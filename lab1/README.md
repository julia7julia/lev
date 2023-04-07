# Практическое занятие по написанию плейбука.

>Плейбуки — это базовые компоненты Ansible, которые записывают и исполняют конфигурацию Ansible. Обычно это основной способ автоматизировать набор задач, которые мы хотели бы выполнять на удалённой машине. 

>Vagrant создает виртуальную машину, доступную только в терминальном режиме (через командную строку), при этом сама разработка продолжается на хост-машине, а вот запуск кода на выполнение происходит внутри машины. Другими словами, редактор ставится на вашу основную систему, и код лежит также в ней. Vagrant прозрачно прокидывает код внутрь машины и позволяет его запускать. 

# *Этапы работы:*

## Предварительная подготовка: 

Если необходимо, установите ansible:

    sudo apt install ansible

Уубедитесь, что он корректно установлен:

    ansible --version 

*Ответ системы должен быть:*

    ansible 2.9.25(или другая версия)

##   1. Подготовить стенд на Vagrant

Создать каталог ansible: 

    mkdir ansible

Зайти в папку: 

    cd ansible

В этот каталог скопировать присланные файлы Vagrant. Проверить статус Vagrant: 

    vagrant status

*ответ системы должен быть:*

    nginx not created (virtualbox)

Поднять Vagrant: 

    vagrant up

*Ответ системы должен быть:*

     ... ==> nginx: Setting hostname... 
     ==> nginx: Configuring and enabling network interfaces... 
     ==> nginx: Rsyncing folder: /home/mary/os_lab2/test/ansible/ => /vagrant

Для подключения к хосту nginx нам необходимо будет передать множество параметров - это особенность Vagrant. Узнать эти параметры можно с помощью команды:

    vagrant ssh-config 

Вот основные необходимые нам значения (у всех могут отличаться, учитывайте различия)
    
*Ответ системы должен быть:*

    Host nginx HostName 127.0.0.1 
    User vagrant Port 2222 
    UserKnownHostsFile /dev/null StrictHostKeyChecking no 
    PasswordAuthentication no 
    IdentityFile /home/mary/os_lab2/test/ansible/.vagrant/machines/nginx/virtualbox/private_key 
    IdentitiesOnly yes LogLevel FATAL

Используя эти параметры, создадим свой первый inventory файл с помощью команды nano inventory или в сразу добавим в Visual Studio. Записываем в этот файл данные cat inventory Данные для записи: 

    [webservers] nginx ansible_host=127.0.0.1 
    ansible_port=2222 
    ansible_private_key_file=/home/mary/os_lab2/test/ansible/.vagrant/machines/nginx/virtualbox/private_key

Убедимся, что Ansible может управлять нашим хостом. Сделать это можно с помощью команды: 

    ansible nginx -i inventory -m ping

*Ответ системы должен быть:* 

    nginx | SUCCESS => { "ansible_facts": { "discovered_interpreter_python": 
    "/usr/bin/python" }, "changed": false, "ping": "pong" }
    
Если результат не SUCCESS, то ищите причину в inventory.

##    2. Настроиваем ansible для доступа к стенду

Чтобы не пришлось в дальнейшем каждый раз явно указывать наш инвентори файл в командной строке, создадим файл конфигурации ansible.cfg Для этого в текущем каталоге создадим файл ansible.cfg со следующим содержанием: 

    [defaults] 
    inventory = inventory 
    remote_user = vagrant 
    host_key_checking = False 
    transport = smart

Теперь из inventory можно убрать информацию о пользователе: 

    [webservers] 
    nginx ansible_host=127.0.0.1 
    ansible_port=2222 
    ansible_private_key_file=/home/mary/os_lab2/test/ansible/.vagrant/machines/nginx/virtualbox/private_key

Еще раз убедимся, что управляемый хост доступен, только теперь без явного указания inventory файла: 

    ansible -m ping nginx 
    
*Ответ системы должен быть:*

    nginx | SUCCESS => { "ansible_facts": { "discovered_interpreter_python": "/usr/bin/python" }, 
    "changed": false, "ping": "pong" }

Теперь, когда мы убедились, что у нас все подготовлено - установлен Ansible, поднят хост для теста и Ansible имеет к нему доступ, мы можем конфигурировать наш хост. Для начала воспользуемся Ad-Hoc командами и выполним некоторые удаленные команды на нашем хосте.

Посмотрим какое ядро установлено на хосте: 

    ansible nginx -m command -a "uname -r" 
    
*Ответ системы должен быть:*

    nginx | CHANGED | rc=0 >> 3.10.0-1127.el7.x86_64
    
Проверим статус сервиса firewalld: 

    ansible nginx -m systemd -a name=firewalld 
    
*Ответ системы должен быть:*

    nginx | SUCCESS => "ansible_facts": { "discovered_interpreter_python": "/usr/bin/python" }, 
    "changed": false, "name": "firewalld", "status": ...

Установим пакет epel-release на наш хост: 

    ansible nginx -m yum -a "name=epel-release state=present" -b 
    
*Ответ системы должен быть:* 

    nginx | CHANGED => "ansible_facts": "discovered_interpreter_python": "/usr/bin/python" ... 
    1/1 \n\nInstalled:\n epel-release.noarch 0:7-11 \n\nComplete!\n"

##    3. Напишем плейбук, который устанавливает NGINX в конфигурации по умолчанию, с применением модуля yum

Создаем Playbook, который будет выполнять установку пакета epel-release. Создаем файл epel.yml со следующим содержимым:

    ---
    - name: Install EPEL Repo
      hosts: webservers
      become: true
      tasks:
        - name: Install EPEL Repo package from standard repo
          yum:
            name: epel-release
            state: present

Внимательно соблюдайте отступы, т. к. YaML очень чувствителен к синтаксису.

После чего запускаем выполнение Playbook: 

    ansible-playbook epel.yml 

*Ответ системы должен быть:*

    PLAY [Install EPEL Repo] ****************************************************

    TASK [Gathering Facts] ****************************************************** ok: [nginx]

    TASK [Install EPEL Repo package from standard repo]     ********************* ok: [nginx]

    PLAY RECAP ****************************************************************** 
    nginx : ok=2 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0 )

Затем выполните команду: 

    ansible nginx -m yum -a "name=epel-release state=absent" -b 
    
*Ответ системы должен быть:* 

    nginx | CHANGED => "ansible_facts": "discovered_interpreter_python": "/usr/bin/python" ... 1/1 
    \n\nRemoved:\n epel-release.noarch 0:7-11 \n\nComplete!\n"

Запускаем Playbook еще раз: 

    ansible-playbook epel.yml 
    
*Ответ системы должен быть:* 

    PLAY [Install EPEL Repo] *********************************************

    TASK [Gathering Facts] *********************************************** ok: [nginx]

    TASK [Install EPEL Repo package from standard repo] ****************** changed: [nginx]

    PLAY RECAP *********************************************************** 
    nginx : ok=2 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0 

##    4. Напишем Playbook для установки NGINX.

За основу возьмем уже созданный плейбук epel.yml. Скопируем этот файл с именем nginx.yml. Добавим в этот новый файл установку пакета nginx. Секция будет выглядеть так:

    ---
    - name: Install EPEL Repo
      hosts: webservers
      become: true
      vars:
        nginx_listen_port: 8080
      tasks:
        - name: Install EPEL Repo package from standard repo
          yum:
            name: epel-release
            state: present
        - name: install nginx from repo
          yum:
            name: nginx
            state: latest
          tags:
            nginx-package
            packages

Обратите внимание - добавили tags. Теперь можно вывести в консоль список тегов и выполнить, например, только часть из задач описанных в плейбуке, а именно установку NGINX. В нашем случае так, например, можно осуществлять его обновление.

Выведем в консоль все теги: 

    ansible-playbook nginx.yml --list-tags

*Ответ системы должен быть:*

    playbook: nginx.yml
    play #1 (webservers): Install 
    EPEL Repo TAGS: [] 
    TASK TAGS: [nginx-configuration, nginx-package packages]

Запустим только установку NGINX, использовав любой из подходящих тегов: 

    ansible-playbook nginx.yml --tag packages 

*Ответ системы должен быть:*

    PLAY [Install EPEL Repo] *****************************************************

    TASK [Gathering Facts] ******************************************************* ok: [nginx]

    PLAY RECAP ******************************************************************* 
    nginx : ok=1 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0 

##    5. Подготовим шаблон jinja2 новой конфигурации для nginx, чтобы сервис слушал на нестандартном порту 8080. 
    
В шаблоне для номера порта использовать переменные ansible.

Создадим файл шаблона для конфига NGINX, имя файла nginx.conf.j2. Обратите внимание, что в шаблоне используется переменная, которую в дальнейшем надо где-то определить. Данные для записи: 

    events {
     worker_connections 1024;
    }

    http {
     server {
       listen {{ nginx_listen_port }} default_server;
       server_name default_server;
       root /usr/share/nginx/html;
       location / {
       }
     }
    }

Добавим в playbook задачу, которая копирует подготовленный шаблон на хост. Также в плейбук добавлено определение переменной в секции vars. Для этого в nginx.yml введем следующее:

    ---
    - name: Install EPEL Repo
      hosts: webservers
      become: true
      vars:
        nginx_listen_port: 8080
      tasks:
        - name: Install EPEL Repo package from standard repo
          yum:
            name: epel-release
            state: present
        - name: install nginx from repo
          yum:
            name: nginx
            state: latest
          tags:
            nginx-package
            packages
        - name: Create config file from template
          template:
            src: nginx.conf.j2
            dest: /etc/nginx/nginx.conf
         notify:
            - restart nginx
          tags:
            nginx-configuration

Запускаем playbook: 

    ansible-playbook nginx.yml 
    
*Ответ системы должен быть:*

    PLAY [Install EPEL Repo] ************************************************************

    TASK [Gathering Facts] ************************************************************** ok: [nginx]

    TASK [Install EPEL Repo package from standard repo] ********************************* ok: [nginx]

    TASK [install nginx from repo] ****************************************************** changed: [nginx]

    TASK [Create config file from template] ********************************************* changed: [nginx]

    PLAY RECAP ************************************************************************** 
    nginx : ok=4 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0

Добавить секции handler и notify для рестарта nginx не при любом старте playbook, а только при изменения в конфигурации. Для этого в nginx.yml введем следующее:

    ---
    - name: Install EPEL Repo
      hosts: webservers
      become: true
      vars:
        nginx_listen_port: 8080
      tasks:
        - name: Install EPEL Repo package from standard repo
          yum:
            name: epel-release
            state: present
        - name: install nginx from repo
          yum:
            name: nginx
            state: latest
          tags:
            nginx-package
            packages
        - name: Create config file from template
          template:
            src: nginx.conf.j2
            dest: /etc/nginx/nginx.conf
          notify:
            - restart nginx
          tags:
            nginx-configuration
      handlers:
        - name: restart nginx
          systemd:
            name: nginx
            state: restarted
            enabled: yes

Запускаем playbook: 

    ansible-playbook nginx.yml 
    
*Ответ системы должен быть:*

     PLAY [Install EPEL Repo] *********************************

    TASK [Gathering Facts] ************************************ ok: [nginx]

    TASK [Install EPEL Repo package from standard repo] ******* ok: [nginx]

    TASK [install nginx from repo] **************************** ok: [nginx]

    TASK [Create config file from template] ******************* ok: [nginx]

    PLAY RECAP *************************************************
    nginx : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0 

Чтобы проверить работу NGINX на нестандартном порту, нам надо выяснить IP адрес, который получила виртуальная машина при создании vagrant-ом Это можно сделать командой: 

    vagrant ssh -c "ip addr show" 
    
*Ответ системы должен быть:* 

    ... 
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 
    1500 qdisc pfifo_fast state UP group default 
    qlen 1000 link/ether 08:00:27:1c:63:58 brd ff:ff:ff:ff:ff:ff 
    inet 192.168.11.150/24 
    brd 192.168.11.255 scope global noprefixroute eth1 
    ...

В полученном выводе найдите описание сетевых интерфейсов. Первый интерфейс — локальный loopback, второй — автоматически добавленный вагрантом, предназначеный для интерконнекта ядра вагранта к виртуальной машине и не доступен снаружи виртуалки. А третий как раз публичный и к нему можно обращаться.

##    6. Проверка

Затем в браузере открываем страницу: 

http://192.168.11.150:8080/

Верный вид страницы:

![screen]([/home/mary/lev/lab1/scr.png](https://github.com/julia7julia/lev/blob/main/lab1/scr.png))


