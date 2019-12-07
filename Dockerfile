FROM python:stretch

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN pip install -r requirements.txt


EXPOSE 8000
ENTRYPOINT ["gunicorn", "-b", ":8000", "main:APP"]
