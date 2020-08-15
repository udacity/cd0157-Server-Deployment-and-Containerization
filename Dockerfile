FROM python:stretch

RUN mkdir /app

COPY main.py /app
copy requirements.txt /app

WORKDIR /app

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

ENTRYPOINT ["gunicorn", "-b", ":8080", "main:APP"]