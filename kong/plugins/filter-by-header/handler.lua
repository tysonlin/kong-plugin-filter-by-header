local BasePlugin = require "kong.plugins.base_plugin"
local req_get_headers = ngx.req.get_headers
local ngx_re_find = ngx.re.find

local FilterByHeaderHandler = BasePlugin:extend()

-- This plugin would need to work after kong-plugin-jwt-claims-headers, which does not have proirity set (assume 0)
-- https://github.com/wshirey/kong-plugin-jwt-claims-headers/blob/master/handler.lua
FilterByHeaderHandler.PRIORITY = -1
FilterByHeaderHandler.VERSION = "1.0.0"

function FilterByHeaderHandler:new()
    FilterByHeaderHandler.super.new(self, "filter-by-header")
end

function FilterByHeaderHandler:access(conf)
    FilterByHeaderHandler.super.access(self)

    local header_name = conf.header_name
    local header_regex = conf.header_regex

    local status = conf.status_code
    local out_headers = {
        ["Content-Type"] = conf.content_type
    }
    local content = conf.body

    local headers, err = req_get_headers()
    if err or headers == nil then
        ngx.log(ngx.NOTICE, "filter-by-header response exit: Cannot get headers")
        return kong.response.exit(status, content, out_headers)
    end

    local json = require('cjson')
    local json_string = json.encode(headers)
    ngx.log(ngx.DEBUG, "headers: ", json_string )

    local target_header = headers[header_name]
    if target_header == nil or target_header == '' then
        ngx.log(ngx.NOTICE, "filter-by-header response exit: Cannot find target header")
        return kong.response.exit(status, content, out_headers)
    end

    ngx.log(ngx.DEBUG, "target_header: ", target_header)
    ngx.log(ngx.DEBUG, "header_regex: ", header_regex)

    local from, to, err = ngx_re_find(target_header, header_regex)
    if err or ( from == nil and to == nil ) then
        ngx.log(ngx.NOTICE, "filter-by-header response exit: Cannot find expected regex in target header")
        return kong.response.exit(status, content, out_headers)
    end

    ngx.log(ngx.DEBUG, "Regex matched index from: ", from, "; to: ", to, "; Passing routing...")
end

return FilterByHeaderHandler

