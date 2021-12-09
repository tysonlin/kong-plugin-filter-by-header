# Kong Plugin Filter By Header

This plugin is used to perform request filtration by the injected internal auth headers

It is designed to be used with native Kong oauth ("x-authenticated-scope") or manually injected headers from other plugins e.g. https://github.com/wshirey/kong-plugin-jwt-claims-headers

## Installation

Kong Dockerfile
```Dockerfile
FROM kong
USER root

COPY kong.conf /etc/kong/

RUN git clone https://github.com/tysonlin/kong-plugin-filter-by-header.git \
    && cd kong-plugin-filter-by-header \
    && luarocks make

USER kong
```

kong.conf
```conf
# enabled plugins
plugins = bundled, filter-by-header
```

## Config

```bash
curl -X POST http://kong-admin:8001/routes/<route-id>/plugins \
  --data "name=filter-by-header" \
  --data "config.header_name=x-scope" \
  --data "config.header_regex=LOGGED_IN"
```

form parameter|required|description
---|---|---
`name`|*required*|The name of the plugin to use, in this case: `filter-by-header`
`header_name`|*required*|Header field name to perform filtration from.
`header_regex`|*required*|A regular expression to perform matching on the above header field name value. Matching function reference: https://github.com/openresty/lua-nginx-module#ngxrefind
`status_code`|*optional*|HTTP status code integer to return on filter out case. Number must be in range 100-599. Defaults to `403`.
`content_type`|*optional*|Content-type header of response on filter out case. Defaults to `application/json;charset=utf-8`.
`body`|*optional*|Raw message body of response on filter out case. Defaults to `"{ \"message\": \"Unauthorized\" }"`.

## Test

### Prerequisites
* Docker
* https://github.com/Kong/kong-pongo#installation

### Test script
```shell
pongo lint
pongo run -o gtest
pongo down
```

## Resources
* https://medium.com/manomano-tech/improve-your-kong-plugin-experience-2e4bad9d6178
* https://medium.com/manomano-tech/kong-plugin-easy-functional-testing-67949957527b
* https://docs.konghq.com/gateway-oss/2.5.x/plugin-development/custom-logic/#plugins-execution-order
* https://konghq.com/blog/custom-lua-plugin-kong-gateway
* https://github.com/openresty/lua-nginx-module