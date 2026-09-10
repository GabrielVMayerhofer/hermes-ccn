FROM nousresearch/hermes-agent:latest

COPY config.yaml /root/.hermes/config.yaml

CMD ["gateway", "run"]