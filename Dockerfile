FROM python:3
COPY . /app
WORKDIR /app
RUN pip install pip
CMD [ "python", "./app.py" ]