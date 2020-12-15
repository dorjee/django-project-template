## Generates Django boilerplate project

This script generates Django boilerplate project.

### What does it do?
- Creates project directory for a named project (default project name: django-boilerplate)
- Sets up virtual environment
- Installs:
    - Django
    - djangorestframework
- Starts `project` and `app`
- Updates:
    - settings.py
    - urls.py
    - views.py
- Runs project

### Usage
```bash
$ source setup-project.sh <project name>
or 
$ ./setup-project.sh <project name>
or
$ ./setup-project.sh
```

### An example below creates a working developers project.
```bash
$ source setup-project.sh developers
```

### Resulting project directory structure
Following is the directory structure for `developers` project.
```bash
developers/
├── Dockerfile
├── Jenkinsfile
├── README.md
├── application-version.json
├── dependencies
│   ├── local-nginx-config
│   ├── requirements-dev.txt
│   └── requirements.txt
├── developers-api.yml
├── docker-compose.yml
└── src
    ├── db.sqlite3
    ├── developers_api
    │   ├── __init__.py
    │   ├── asgi.py
    │   ├── developers
    │   │   ├── __init__.py
    │   │   ├── admin.py
    │   │   ├── apps.py
    │   │   ├── migrations
    │   │   │   └── __init__.py
    │   │   ├── models.py
    │   │   ├── tests.py
    │   │   └── views.py
    │   ├── settings.py
    │   ├── urls.py
    │   └── wsgi.py
    └── manage.py

6 directories, 22 files
```
