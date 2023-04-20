FROM tarantool/tarantool

WORKDIR /opt/tarantool

COPY docker/tarantool/import_data.lua .
COPY docker/tarantool/http_server.lua .
COPY docker/tarantool/entrypoint.sh .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/bin/sh", "/opt/tarantool/entrypoint.sh"]
