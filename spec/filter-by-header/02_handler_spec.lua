local helpers = require "spec.helpers"
local PLUGIN_NAME = "filter-by-header"

for _, strategy in helpers.each_strategy() do
  describe("Plugin: " .. PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()
      local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })
      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })
      -- add the plugin to test to the route we created
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {
          header_name = "x-scope",
          header_regex = "^(LOGGED_IN|BIOMETRIC)$",
        },
      }

     -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("Handler test cases, ", function()
      it("passes with expected header 1", function()
        local r = client:get("/request", {
          headers = {
            ["host"] = "test1.com",
            ["x-scope"] = "LOGGED_IN"
          }
        })
        assert.response(r).has.status(200)
      end)

      it("passes with expected header 2", function()
        local r = client:get("/request", {
          headers = {
            ["host"] = "test1.com",
            ["x-scope"] = "BIOMETRIC"
          }
        })
        assert.response(r).has.status(200)
      end)

      it("does not pass with unexpected header 1", function()
        local r = client:get("/request", {
          headers = {
            ["host"] = "test1.com",
            ["x-scope"] = "RANDOM"
          }
        })
        assert.response(r).has.status(403)
      end)

      it("does not pass with unexpected header 2", function()
        local r = client:get("/request", {
          headers = {
            ["host"] = "test1.com",
            ["x-scope"] = "NOT_LOGGED_IN"
          }
        })
        assert.response(r).has.status(403)
      end)

      it("does not pass with unexpected header 3", function()
        local r = client:get("/request", {
          headers = {
            ["host"] = "test1.com",
            ["x-scope"] = "logged_in"
          }
        })
        assert.response(r).has.status(403)
      end)

      it("does not pass with missing header", function()
        local r = client:get("/request", {
          headers = {
            ["host"] = "test1.com"
          }
        })
        assert.response(r).has.status(403)
      end)
    end)

  end)
end