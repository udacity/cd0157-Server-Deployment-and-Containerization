# Docker configure
FROM python:stretch

COPY . /app
WORKDIR /app

RUN pip install --upgrade pip
RUN pip install pyjwt==1.7.1
RUN pip install flask==1.1.2
RUN pip install gunicorn==20.0.4
RUN pip install pytest==6.2.2

ENTRYPOINT ["gunicorn", "-b", ":8080", "main:APP"]

