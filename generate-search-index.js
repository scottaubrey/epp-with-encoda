var argv = require('process').argv;
var fs = require("fs");
var lunr = require("lunr");
const { exit } = require("process");

const articleObj = JSON.parse(fs.readFileSync(argv[3]).toString());
const articleObjs = [articleObj];

const articleDocs = articleObjs.map(function(articleObj) {
    var authors = articleObj.authors.map(function (author) {
        authorString = "";
        authorString += author.givenNames ? author.givenNames.join(" ") : "";
        authorString += author.familyNames ? author.familyNames.join(" ") : "";
        authorString += author.emails ? "<"+author.emails.join("><")+">" : "";
    });

    return {
        "id": "10.34196/ijm.00202",
        "dio": "10.34196/ijm.00202",
        "title": articleObj.title,
        "description": articleObj.description,
        "author": authors,
    };
});


var idx = lunr(function () {
    this.ref('id')
    this.field('title')
    this.field('dio')
    this.field('description')
    this.field('author')

    articleDocs.forEach(function (articleDoc) {
        this.add(articleDoc)
    }, this);
});

var serializedIdx = JSON.stringify(idx)
fs.writeFileSync(argv[2],serializedIdx)
