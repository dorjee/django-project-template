# Shell script for creating boilerplate Django project.

# Type the following command, you can change the project name.
# source setup-project.sh project-name

# Set IO colors
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

PROJECT=${1-django-boilerplate}
if [[ ${PROJECT} == "test" ]]; then
  echo "Project name '${PROJECT}' will conflict with Django folder."
  exit 1
fi

echo "${green}>>> Removing ${PROJECT}${reset}"
rm -rf ${PROJECT}

echo "${green}>>> Creating Django project template for ${PROJECT}.${reset}"

VENV=.venv
if [[ -d "${VENV}" && "${VENV}" =~ ^\. ]] ; then
    echo "* Virtual environment ${VENV} already exists."
else
    echo "${green}>>> Creating virtualenv${reset}"
    python3 -m venv ${VENV}
    echo "${green}>>> env is created.${reset}"
fi

echo "${green}>>> Creating Django project.${reset}"
mkdir -p ${PROJECT}/dependencies/local-nginx-config
mkdir -p ${PROJECT}/src

cd ${PROJECT}
touch Dockerfile docker-compose.yml Jenkinsfile README.md \
    ${PROJECT}-api.yml \
    .env .env.template application-version.json \
    dependencies/requirements.txt

# Write to .env.template
echo "${green}>>> Writing default variables to .env.template file.${reset}"
cat <<EOT >> .env.template
# If you are running the container(s) via Docker Compose, make a copy of this template file,
# name the new file ".env" (without the quotation marks), and set the values of the SOURCE_DIR 
# variables in the .env file as appropriate for your environment

SOURCE_DIR=/Path/to/the/project/source/code/directory

# Nginx services-reverse-proxy
# The variable below stores the path to the Nginx config files which make the reverse proxy aware
# of the service
NGINX_SERVICES=/Path/to/dependencies/local-nginx-config

# Django Application
DB_HOST=[DB_HOST]
DB_NAME=[DB_NAME]
DB_USER=[name of the user to connect as, in dev this can be the same as POSTGRES_USER below]
DB_PASSWORD=[password for the DB_USER]

# PostgreSQL Database
POSTGRES_DB=[POSTGRES_DB]
POSTGRES_USER=[this is "postgres" by default/convention]
POSTGRES_PASSWORD=[password for the POSTGRES_USER]
EOT

# Activate virtual environment
sleep 2
echo "${green}>>> Activating the .venv.${reset}"
source ../${VENV}/bin/activate
PS1="(`basename \"$VIRTUAL_ENV\"`)\e[1;34m:/\W\033[00m$ "
sleep 2

# Install selected PyPI packages and append them to requirements file
echo "${green}>>> Installing the Django...${reset}"
pip install django djangorestframework
pip freeze > dependencies/requirements-dev.txt

# Write gitignore file
echo "${green}>>> Writing .gitignore${reset}"
cat <<EOT > .gitignore
# Python related
__pycache__/
*.pyc

# mypy
.mypy_cache

# Unit test / coverage reports
.coverage
.coverage.*
.cache

# Django stuff:
*.log
db.sqlite3

# OS generated files
*.DS_Store

# Docker related
.env

# Test related
.pytest_cache
pytest.ini
mypy.ini

# IDE related
.vscode
EOT

cd src
PROJECT_DIR="${PROJECT//-/_}_api"
APP="${PROJECT//-/_}"

# Create Django project and app
echo "${green}>>> Creating project: '${PROJECT_DIR}'...${reset}"
django-admin.py startproject ${PROJECT_DIR} .

echo "${green}>>> Creating app: '${APP}'...${reset}"
cd ${PROJECT_DIR} && django-admin.py startapp ${APP}

# Go one level up
cd ..

# Migrate
python manage.py makemigrations
python manage.py migrate

# Update settings
echo "${green}>>> Editing '${PROJECT_DIR}/settings.py'${reset}"
sleep 2
sed -i '' '/django.contrib.staticfiles/a\
    '\'rest_framework\','\
    '\'${PROJECT_DIR}.${APP}\','
' ${PROJECT_DIR}/settings.py


DefaultView="$(tr '[:lower:]' '[:upper:]' <<< ${APP:0:1})${APP:1}View"

# Update urls
echo "${green}>>> Updating '${PROJECT_DIR}/urls.py'${reset}"
cat <<EOT > ${PROJECT_DIR}/urls.py
"""${APP} URL Configuration"""

from rest_framework import routers
from django.urls import path, include

from ${PROJECT_DIR}.${APP}.views import ${DefaultView}

router = routers.DefaultRouter()
router.register(r'${APP}', ${DefaultView}, basename='${APP}')

urlpatterns = [
    path('', include((router.urls, '${APP}'), namespace='${APP}')),
]
EOT

# Update views
echo "${green}>>> Updating '${PROJECT_DIR}/${APP}/views.py'${reset}"
cat <<EOT > ${PROJECT_DIR}/${APP}/views.py
from rest_framework import status, viewsets
from rest_framework.response import Response

class ${DefaultView}(viewsets.ViewSet):
    def list(self, request):
        """Just returns a string, for now."""
        return Response("Your first API endpoint!")
EOT

echo "${green}>>> Done${reset}"
sleep 2

# run
python manage.py runserver