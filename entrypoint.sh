#!/bin/sh

# Проверяем наличие файла со снимком данных
if [ ! -f /var/lib/tarantool/dl_address.snapshot ]; then
    tarantool import_data.lua
fi

# Запускаем HTTP-сервер
tarantool http_server.lua
