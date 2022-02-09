#!/bin/bash

inputDir=${ARTICLE_DATA_DIR:-$(pwd)/data}
outputDir=${HTML_OUTPUT_DIR:-$(pwd)/html}

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

        node generate-article.js $articleFile $outputArticleFolder $articleId
    done
done

latestArticlesHtml=""
# generate an index
for publisherFolder in $outputDir/articles/*
do
    for articleFolder in $publisherFolder/*
    do
        # get article summary details
        export title=$(jq -r .title  $outputDir/articles/10.34196/ijm.00202/article.json)
        export description=$(jq -r .description  $outputDir/articles/10.34196/ijm.00202/article.json)
        export articleUrl="${articleFolder#$outputDir}/"

        authors=$(jq -c -r '.authors[]|{givenName: .givenNames[], familyName:.familyNames[], email:.emails[]}' $outputDir/articles/10.34196/ijm.00202/article.json)
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
lib/mo templates/index.html > $outputDir/index.html
