package = "kong-plugin-filter-by-header"
version = "1.0.0-1"

local pluginName = package:match("^kong%-plugin%-(.+)$")

supported_platforms = {"linux", "macosx"}

description = {
  summary = "Kong plugin to filter for request with expected header only",
}
source = {
  url = "https://gitlab.devops.depthcon1.com/cardx/share-data/kong-plugin-filter-by-header.git"
}


dependencies = {
  "lua >= 5.1"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
  }
}