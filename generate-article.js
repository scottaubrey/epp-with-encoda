#!/usr/bin/env node
var encoda = require("@stencila/encoda")
var argv = require('process').argv;

encoda.convert(
    argv[2],
    argv[3]+"/article.html",
    {
        "from" : 'jats',
        "to": 'html',
        "encodeOptions": {
            "isStandalone": true,
            "bundle": true,
            "theme": "skeleton"
        }
    }
).then(() => encoda.convert(
        argv[2],
        argv[3]+"/article.json",
        {
            "from" : 'jats',
            "to": 'json',
            "encodeOptions": {
                "isStandalone": false,
                "bundle": false,
                "theme": "skeleton"
            }
        }
    )
)
