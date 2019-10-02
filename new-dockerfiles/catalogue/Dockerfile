FROM weaveworksdemos/catalogue:0.3.5

WORKDIR /
COPY --chown=myuser:mygroup images/ /images/
# RUN	sudo chown -R myuser:mygroup  /images

CMD ["/app", "-port=80"]
EXPOSE 80