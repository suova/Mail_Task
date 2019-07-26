local log =require('log')
local server=require('http.server').new('127.0.0.1', 8080)

box.cfg{
    log='./logs.log'
}

box.once('schema',
        function()
            box.schema.create_space('key_value_store',
                    {
                        format = {
                            { name = 'key';   type = 'string' },
                            { name = 'value'; type = '*' },
                        };
                        if_not_exists=true;
                    }
            )

            box.space.key_value_store:create_index('primary',
                    {
                        type = 'HASH';
                        parts = {1, 'string'};
                        if_not_exists = true;
                    }
            )
        end
)

local function reading_json(req)
    local status, body =pcall(function () return req:json() end)
    log.info("pcall reading json: %s %s ", status, body)
    return body
end

local function invalid_body(req, func, msg)
    local body = reading_json(req)
    local resp = req:render{json = { text = msg }}
    resp.status = 400
    log.info("invalid body with status (%d), function (%s), type of body (%s)", resp.status, func, body)
    return resp
end

local function post(req)
    local body =reading_json(req)

    if type(body)~='table' then
        return invalid_body(req,'post','something wrong with json')
    end

    if body['key']==nil or body['value']==nil then
        return invalid_body(req, 'post', "did't get value or key")
    end

    local key =body['key']
    local copy=box.space.key_value_store:select(key)

    if table.getn(copy)~=0 then
        local resp=req:render{json={text='this key exists'}}
        resp.status=409
        log.info('key exists %s', key)
        return resp
    end

    box.space.key_value_store:insert{key, body['value']}
    local resp=req:render{json={text='pair is created'}}
    resp.status=201

    log.info('created key-value with key %s', key)
    return resp
end

local function get(req)
    local key=req:stash('key')
    local kv=box.space.key_value_store:select{key}

    if table.getn(kv)==0 then
        local resp =req:render{json={text="key doesn't exist"}}
        resp.status=404
        return resp
    end

    log.info('method GET key %s', key)
    local resp=req:render{json={key = kv[1][1], value = kv[1][2]}}
    resp.status=200
    return resp
end

local function put(req)
    local body = reading_json(req)

    if type(body) ~= 'table'  then
        return invalid_body(req, 'put', ' wrong with json')
    end

    if body['value'] == nil then
        return invalid_body(req, 'put', 'miss value')
    end

    local key = req:stash('key')
    if key == nil then
        local resp = req:render{json = { text = 'miss key' }}
        resp.status = 400
        log.info("can't update invalid key: '%s', status (%d) ", resp.status, key)
        return resp
    end

    local key_value = box.space.key_value_store:select{ key }

    if table.getn(key_value) == 0  then
        local resp = req:render{json = { text = "key doesn't exist" }}
        resp.status = 404
        return resp
    end

    log.info("method PUT key: (%s): value: (%s), type of body (%s)" , key, body['value'], type(body))

    box.space.key_value_store:update({ key}, { { '=', 2, body['value']}})

    local resp = req:render{json = { info = "data is updated" }}
    resp.status = 200
    return resp
end

local function delete(req)
    local key=req:stash('key')
    local kv=box.space.key_value_store:select(key)

    if table.getn(kv)==0 then
        local resp=req:render{json={text='key does not exist'}}
        resp.status=404
        return resp
    end

    box.space.key_value_store:delete{key}
    local resp=req:render{json ={text='key is deleted'}}
    resp.status=200
    return resp

end

server:route({ path = '/kv', method = 'POST' }, post)
server:route({ path = '/kv/:key', method = 'GET' }, get)
server:route({ path = '/kv/:key', method = 'PUT' }, put)
server:route({ path = '/kv/:key', method = 'DELETE' }, delete)

server:start()

