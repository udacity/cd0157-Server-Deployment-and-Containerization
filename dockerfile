FROM python:stretch

COPY . /main
WORKDIR /main

RUN pip install -r requirements.txt

ENTRYPOINT ["gunicorn","-b",":8080","main:APP"]
