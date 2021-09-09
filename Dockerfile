FROM python:stretch

COPY . /app
WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT [ "gunicorn", "-b", ":8080", "main:APP" ]