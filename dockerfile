FROM python:3.7
COPY requirements.txt .
RUN pip install -r requirements.txt

RUN mkdir /project
COPY scripts_airflow/ /project/scripts/

RUN chmod +x /project/scripts/init.sh
ENTRYPOINT [ "/project/scripts/init.sh" ]
