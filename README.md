# SmartCity.Registry


#### Dataset

```javascript
const Dataset = {
    "id": "",                  // UUID
    "business": {              // Project Open Data Metadata Schema v1.1
        "dataTitle": "",       // user friendly (dataTitle)
        "description": "",
        "keywords": [""],
        "modifiedDate": "",
        "orgTitle": "",        // user friendly (orgTitle)
        "contactName": "",
        "contactEmail": "",
        "license": "",
        "rights": "",
        "homepage": ""
    },
    "technical": {
        "dataName": "",        // ~r/[a-zA-Z_]+$/
        "orgName": "",         // ~r/[a-zA-Z_]+$/
        "systemName": "",      // ${orgName}__${dataName},
        "stream": true,        //DEPRECATED - See sourceType
        "schema": [
            {
                "name": "",
                "type": "",
                "description": ""
            }
        ],
        "sourceUrl": "",
        "sourceFormat": "",
        "sourceType": "",     // remote|stream|batch
        "cadence": "",
        "queryParams": {
            "key1": "",
            "key2": ""
        },
        "transformations": [], // ?
        "validations": [],     // ?
        "headers": {
            "header1": "",
            "header2": ""
        }
    }
}
```


## Installation

This package is [available in Hex](https://hex.pm/docs/publish) under the `smartcolumbus_os` organization, the package can be installed
by adding `smart_city_registry` to your list of dependencies in `mix.exs` as follows:

```elixir
def deps do
  [
    {:smart_city_registry, "~> 2.2.0", organization: "smartcolumbus_os"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://smartcolumbus_os.hexdocs.pm/smart_city_registry](https://smartcolumbus_os.hexdocs.pm/scos_ex/api-reference.html).

## Contributing

Make your changes and run `docker build .`. This is exactly what our CI will do. The build process runs these commands:

```bash
mix deps.get
mix test
mix format --check-formatted
mix credo
```
