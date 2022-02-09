#!/bin/bash

inputDir=${ARTICLE_DATA_DIR:-$(pwd)/data}
outputDir=${HTML_OUTPUT_DIR:-$(pwd)/html}
indexPath=${INDEX_OUTPUT_PATH:-$outputDir/search.index}

encodaPath=${ENCODA_PATH:-node_modules/.bin/encoda}

# clear directory
rm -R $outputDir/* 2> /dev/null

for publisherFolder in $inputDir/*
do
    publisherId=$(basename "$publisherFolder")
    publisherId="${publisherId/-/.}"
    for articleFolder in $publisherFolder/*
    do
        articleId=$(basename "$articleFolder")
        articleId="${articleId/-/.}"
        articleFile=$articleFolder/$(basename "$articleFolder").xml

        outputArticleFolder="$outputDir/articles/$publisherId/$articleId/"

        mkdir -p $outputArticleFolder

        node generate-article.js $articleFile $outputArticleFolder "$publisherId/$articleId"
        node generate-search-index.js $indexPath $outputDir/articles/$publisherId/$articleId/article.json
    done
done

latestArticlesHtml=""
# generate an index
for publisherFolder in $outputDir/articles/*
do
    for articleFolder in $publisherFolder/*
    do
        # get article summary details
        export title=$(jq -r .title  $articleFolder/article.json)
        export description=$(jq -r .description  $articleFolder/article.json)
        export articleUrl="article.html#${articleFolder#$outputDir/articles/}/"

        authors=$(jq -c -r '.authors[]|{givenName: .givenNames[], familyName:.familyNames[], email:.emails[]}' $articleFolder/article.json)
        authorsHtml=""
        oldIFS="$IFS"
        IFS=$'\n'
        for author in $authors
        do
            export givenName=$(echo "$author"| jq -r '.givenName')
            export familyName=$(echo "$author"| jq -r '.familyName')
            export email=$(echo "$author"| jq -r '.email')

            authorsHtml="$authorsHtml$(lib/mo templates/article-author.html)"
        done
        IFS="$oldIFS"

        export authors="$authorsHtml"

        articleSummaryHtml=$(lib/mo templates/article-summary.html)
        latestArticlesHtml="$latestArticlesHtml $articleSummaryHtml"
    done
done

export latestArticlesHtml
export pageHtml=$(lib/mo templates/index.html)
lib/mo templates/layout.html > $outputDir/index.html

export pageHtml=$(lib/mo templates/article.html)
lib/mo templates/layout.html > $outputDir/article.html
