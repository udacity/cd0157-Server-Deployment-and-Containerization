# Comment
FROM python:3.7.2-stretch

COPY . /app
WORKDIR /app

RUN pip install --upgrade pip
RUN pip install flask
RUN pip install pyjwt
RUN pip install gunicorn
RUN pip install pytest

ENTRYPOINT ["gunicorn", "-b", "8080", "main:APP"]
# ENTRYPOINT ["echo", "hello world"]

