# Домашнее задание к занятию «Helm»

### Цель задания

В тестовой среде Kubernetes необходимо установить и обновить приложения с помощью Helm.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение, например, MicroK8S.
2. Установленный локальный kubectl.
3. Установленный локальный Helm.
4. Редактор YAML-файлов с подключенным репозиторием GitHub.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://helm.sh/docs/intro/install/) по установке Helm. [Helm completion](https://helm.sh/docs/helm/helm_completion/).

------

### Задание 1. Подготовить Helm-чарт для приложения

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
3. В переменных чарта измените образ приложения для изменения версии.

------
### Задание 2. Запустить две версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
3. Продемонстрируйте результат.

---

### Ответ
### Задание 1. Подготовить Helm-чарт для приложения

1. Сгенерировал [Сhart](./netology-13-05/) с nginx

    ![create_helm](./img/create_helm.png)

2. Внутри Chart:
    - [Deployment](./netology-13-05/templates/deployment.yaml)
    - [Service](./netology-13-05/templates/service.yaml)
    - [Ingress](./netology-13-05/templates/ingress.yaml)
    - И даже [ServiceAccount](./netology-13-05/templates/serviceaccount.yaml)

    Установка Chart

    ![install_helm](./img/install_helm.png)


3. Изменил версию приложения
    
    ![change_app_version](./img/change_app_version.png)

---
### Задание 2. Запустить две версии в разных неймспейсах

- Создал namespace'ы командами
    ```bash
    kubectl create namespace app1
    kubectl create namespace app2
    ```
- Затем правил версию Chart и приложения, после чего выполнял команды
    ```bash
    helm install netology-nginx1 ./netology-13-05 --version 0.1.0 --namespace app1
    helm install netology-nginx2 ./netology-13-05 --version 0.2.0 --namespace app1
    helm install netology-nginx3 ./netology-13-05 --version 0.3.0 --namespace app2
    ```
- Результат

    ![diff_app_ver](./img/diff_app_ver.png)

---

### Правила приёма работы

1. Домашняя работа оформляется в своём Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, `helm`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
