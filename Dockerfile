# source image
FROM python:stretch

# copy files to image
COPY . /app

# work directory for other commands
WORKDIR /app

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 8080

# main excecutable command
ENTRYPOINT ["gunicorn", "-b", ":8080", "main:APP"]