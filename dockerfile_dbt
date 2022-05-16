FROM python:3.7
RUN pip install markupsafe==2.0.1 \
    pip install wtforms==2.3.3 && \
    pip install dbt-postgres==1.1.0 && \
    pip install dbt-rpc==0.1.2


RUN mkdir /project
COPY scripts_dbt/ /project/scripts/

RUN chmod +x /project/scripts/init.sh

ENTRYPOINT [ "/project/scripts/init.sh" ]
