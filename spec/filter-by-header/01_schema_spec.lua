local PLUGIN_NAME = "filter-by-header"
local schema_def = require("kong.plugins."..PLUGIN_NAME..".schema")
local v = require("spec.helpers").validate_plugin_config_schema


describe("Plugin: " .. PLUGIN_NAME .. " (schema), ", function()
  it("minimal conf validates", function()
    assert(v({
      header_name = "foo",
      header_regex = "^(LOGGED_IN|BIOMETRIC)$",
    }, schema_def))
  end)
  it("full conf validates", function()
    assert(v({
      header_name = "foo",
      header_regex = "^(LOGGED_IN|BIOMETRIC)$",
      status_code = 403,
      content_type = "application/json",
      body = "{ \"message\": \"Unauthorized\" }",
    }, schema_def))
  end)
  describe("Errors", function()
    it("missing required fields", function()
      local config = {
        status_code = 403,
        content_type = "application/json",
        body = "{ \"message\": \"Unauthorized\" }",
      }
      local ok, _ = v(config, schema_def)
      assert.falsy(ok)
    end)
    it("status_code invalid", function()
      local config = {
        header_name = "foo",
        header_regex = "^(LOGGED_IN|BIOMETRIC)$",
        status_code = 99,
        content_type = "application/json",
        body = "{ \"message\": \"Unauthorized\" }",
      }
      local ok, _ = v(config, schema_def)
      assert.falsy(ok)
    end)
  end)
end)