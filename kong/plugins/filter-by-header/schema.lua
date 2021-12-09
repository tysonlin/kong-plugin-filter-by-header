local typedefs = require "kong.db.schema.typedefs"

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")


local schema = {
    name = plugin_name,
    fields = {
      { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
      { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
            { header_name = { type = "string", required = true } },
            { header_regex = { type = "string", required = true } },
            { status_code = {
              type = "integer",
              default = 403,
              between = { 100, 599 },
            }, },
            { content_type = { type = "string", default = "application/json;charset=utf-8" }, },
            { body = { type = "string", default = "{ \"message\": \"Unauthorized\" }" }, },
          }
        }
      }
    }
}

return schema