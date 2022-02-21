#!/bin/bash

inputDir=${ARTICLE_DATA_DIR:-$(pwd)/data}
outputDir=${HTML_OUTPUT_DIR:-$(pwd)/html}
indexPath=${INDEX_OUTPUT_PATH:-$outputDir/search.index}

encodaPath=${ENCODA_PATH:-node_modules/.bin/encoda}

echo "generator: clear output directory"
# clear directory
rm -R $outputDir/* 2> /dev/null

echo "generator: Generating HTML and JSON"
for publisherFolder in $inputDir/*
do
    publisherId=$(basename "$publisherFolder")
    # Some bundles come with dots replaced with hyphens
    publisherId="${publisherId/-/.}"

    echo "generator: processing publisher $publisherId"
    for articleFolder in $publisherFolder/*
    do
        articleId=$(basename "$articleFolder")
        # Some bundles come with dots replaced with hyphens
        articleId="${articleId/-/.}"
        articleFile=$articleFolder/$(basename "$articleFolder").xml

        echo "generator: processing article $articleId"

        outputArticleFolder="$outputDir/articles/$publisherId/$articleId/"

        mkdir -p $outputArticleFolder

        echo "generator: generate article html & json for $articleId"
        node generate-article.js $articleFile $outputArticleFolder "$publisherId/$articleId"
        echo "generator: generate search index for $articleId"
        node generate-search-index.js $indexPath $outputDir/articles/$publisherId/$articleId/article.json

        # tidy up and replace URLs to media
        rm -R $outputArticleFolder/article.json.media
        mv $outputArticleFolder/article.html.media $outputArticleFolder/media

        echo "generator: fixing media URLs for $articleId"
        sed -i '' "s#article.html.media#/articles/$publisherId/$articleId/media#g" "$outputArticleFolder/article.html"
        sed -i '' "s#article.json.media#/articles/$publisherId/$articleId/media#g" "$outputArticleFolder/article.json"
    done
done

echo "generator: Generating indexes"
latestArticlesHtml=""
# generate an index
for publisherFolder in $outputDir/articles/*
do
    publisherId=$(basename "$publisherFolder")
    # Some bundles come with dots replaced with hyphens
    publisherId="${publisherId/-/.}"

    for articleFolder in $publisherFolder/*
    do
        # get article summary details
        articleId=$(basename "$articleFolder/articles/")
        # Some bundles come with dots replaced with hyphens
        articleId="${articleId/-/.}"
        articleDio="$publisherId/$articleId"
        echo "generator: Processing json for $articleDio"
        export title=$(jq -r .title  $articleFolder/article.json)
        export description=$(jq -r .description  $articleFolder/article.json)


        export articleUrl="article.html#${articleFolder#$outputDir/articles/}"
        authors=$(jq -c -r '.authors[]|{givenName: .givenNames[], familyName:.familyNames[], email:.emails[]}' $articleFolder/article.json 2> /dev/null|| jq -c -r '.authors[]|{givenName: .givenNames[], familyName:.familyNames[]}' $articleFolder/article.json 2> /dev/null)
        authorsHtml=""
        oldIFS="$IFS"
        IFS=$'\n'
        echo "generator: Generating author HTML for $articleDio"
        for author in $authors
        do
            export givenName=$(echo "$author"| jq -r '.givenName')
            export familyName=$(echo "$author"| jq -r '.familyName')
            export email=$(echo "$author"| jq -r '.email')

            authorsHtml="$authorsHtml$(lib/mo templates/article-author.html)"
        done
        IFS="$oldIFS"

        export authors="$authorsHtml"

        echo "generator: Generating summary HTML for $articleDio"
        articleSummaryHtml=$(lib/mo templates/article-summary.html)
        latestArticlesHtml="$latestArticlesHtml $articleSummaryHtml"
    done
done

echo "generator: Generating index.html"
export latestArticlesHtml
export pageHtml=$(lib/mo templates/index.html)
lib/mo templates/layout.html > $outputDir/index.html

echo "generator: Generating article.html"
export pageHtml=$(lib/mo templates/article.html)
lib/mo templates/layout.html > $outputDir/article.html
