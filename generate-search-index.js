var argv = require('process').argv;
var fs = require("fs");
var lunr = require("lunr");
const { exit } = require("process");

console.log(argv);
exit;

const articleObj = JSON.parse(fs.readFileSync(argv[3]).toString());
const articleObjs = [articleObj];

const articleDocs = articleObjs.map(function(articleObj) {
    var authors = articleObj.authors.map((author) => author.givenNames.join(" ")+" "+author.familyNames.join(" ")+" <"+author.emails.join("><")+">");
    // authors = authors.join("\n");

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
