# epp-with-encoda

## Description

This is a proof-of-concept to statically generate both JSON and HTML representations of JATS XML articles bundles.

The projects generates a static HTML tree that can be served from any static http server, and also a Dockerfile to generate the files and run nginx to serve them.

## Dependencies

- [Stencila Encoda](https://github.com/stencila/encoda) is the core tool to generate the article output.
- [Mo](https://github.com/tests-always-included/mo) is used to generate HTML templates using only bash
- [jq](https://github.com/stedolan/jq) is used to querying the article JSON to generate HTML indexes.

## Getting started.

Prerequisites:
- NodeJs, npm
- jq

Run `npm install` to install encoda, then run `./generate-static-articles.sh` to generate a tree under `html`
You can then serve the folder using your favourite HTTP server (or open in your browser locally, though links will not work as they assume the `html` directory is the root)

You can also set an outdir via the `HTML_OUTPUT_DIR` environment variable.

Alternatively, build and run the docker container:
```
docker build . -t epp-poc-nginx
docker run --rm -p 8000:80 epp-poc-nginx
```

and open http://localhost:8000

## Further ideas

- This has a bunch of hard-coded assumptions (theme, article bundling, etc) - those need to be broken
- image transformations for figures, etc.
- Whilst it's neat that using only a handful of tools we can statically generate an article viewing site, a static site generator would be better.
- Even better - building a viewer built around a framework such as react or vue would probably be better.
- generate a search index
