box.cfg {}
--box.schema.space.drop('dl_address')
--local inspect = require('inspect')

local function main()
    if not box.space.dl_address then
        create_schema()
    end

    if not (box.space.dl_address:count() > 0) then
        local dl_address = box.space.dl_address

        local res = get_from_pg()

        -- импортируем данные в Tarantool
        for i,row in ipairs(res[1]) do
            --print(string.format('row  %s:  %s',i, inspect(row)))

            if row.osm_id ~= nil then
                dl_address:insert({
                    row.osm_id,
                    row.city,
                    row.housenumber,
                    row.street,
                    row.street_ol,
                    row.street_old,
                    row.street_old_ol,
                    row.geometry,
                })
            end
        end
        print('AFTER FOREACH')
        print(box.space.dl_address:count())
        -- Создаем снимок данных и сохраняем его в том Docker
        --box.snapshot()
    end
end

function create_schema()
    local dl_address = box.schema.space.create('dl_address')

    dl_address:format({
        { name = 'osm_id', type = 'unsigned' },
        { name = 'city', type = 'string', is_nullable = true },
        { name = 'housenumber', type = 'string' },
        { name = 'street', type = 'string' },
        { name = 'street_ol', type = 'string', is_nullable = true },
        { name = 'street_old', type = 'string', is_nullable = true },
        { name = 'street_old_ol', type = 'string', is_nullable = true },
        { name = 'geometry', type = 'any' },
    })

    dl_address:create_index('pk', {
        type = 'hash',
        parts = { 1, 'unsigned' },
    })

    dl_address:create_index('idx_dl_address_fulltext', {
        parts = {
            { field = 2 }, -- city
            { field = 3 }, -- housenumber
            { field = 4 }, -- street
            { field = 5 }, -- street_ol
            { field = 6 }, -- street_old
            { field = 7 }, -- street_old_ol
        },
    })
end

function get_from_pg()
    local url = os.getenv('DATABASE_URL')

    local db_url = string.gsub(url, "postgres://", "")
    local user_pass, host_db = string.match(db_url, "(.*)@(.*)")
    local user, password = string.match(user_pass, "(.*):(.*)")
    local host, database = string.match(host_db, "(.*)/(.*)")

    -- импортируем модуль pg
    local pg = require('pg')

    local сonn_obj = {
        host = host,
        port = 5432,
        database = database,
        user = user,
        password = password
    }

    --print(inspect(сonn_obj))

    local conn, msg = pg.connect(сonn_obj)
    if conn == nil then error(msg) end

    -- выполняем запрос к PostgreSQL
    local res = conn:execute('SELECT osm_id,city,housenumber,street,street_ol,street_old,street_old_ol,geometry FROM dl_address limit 10')

    --print(inspect(res))
   return res
end

main()



