-- импортируем модуль http.server
local http_server = require('http.server')
-- импортируем модуль JSON
local json = require('json')

-- создаем HTTP-сервер на порту 8080
local server = http_server.new('0.0.0.0', 8080)

-- обработчик GET-запросов на /search
server:route({path = '/search', method = 'GET'}, function(req)
    -- получаем параметры запроса
    local query = req:param('query')


    -- выполняем поиск по индексу
    local results = box.space.dl_address.index.idx_dl_address_fulltext:select({{query}})

    -- возвращаем результаты в формате JSON
    return {status = 200, headers = {['Content-Type'] = 'application/json'}, body = json.encode(results)}
end)

-- запускаем сервер
server:start()