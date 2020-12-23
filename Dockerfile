FROM python:3.7.2-stretch

COPY . /app
WORKDIR /app

RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt


ENTRYPOINT ["gunicorn", "-b", ":8080", "main:APP"]

