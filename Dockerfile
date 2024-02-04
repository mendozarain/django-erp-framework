# pull official base image
FROM python:3.6.3-alpine

# set work directory
RUN apk --update add build-base mysql-dev bash
RUN apk --update add libxml2-dev libxslt-dev libffi-dev gcc musl-dev libgcc openssl-dev curl
RUN apk add jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev
RUN apk --update add gcc python3-dev musl-dev postgresql-dev

WORKDIR /code

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN pip install --upgrade pip

# Install the Django package directly
RUN pip install django-erp-framework

RUN pip install django-compressor==2.4

# Use django-admin to start the project
RUN django-admin startproject project_name

WORKDIR /code/project_name
RUN python manage.py migrate

# Create superuser
RUN echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('test', '', '12345678!')" | python manage.py shell

# Use Gunicorn as the entry point
CMD ["gunicorn", "--bind", ":8000", "--workers", "2", "project_name.wsgi:application"]
