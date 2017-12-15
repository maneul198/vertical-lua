
var restify = require('restify');
var express = require('express')
var fs = require('fs')
var qs = require('querystring')

var server = restify.createServer();

server.get('/', (req, res, next) =>
{
	readStream = fs.createReadStream("libros.json")
	readStream.on('open', function() {
		res.writeHead(200, {});
		readStream.pipe(res);
	});

    	next();
});

server.post('/', (req, res, next) =>
{
	var body = '';
	req.on('data', function(data) {
		body += data;
	});

	req.on('end', function(){
		//var post = qs.parse(body);
		res.end('Done');
		console.log(body);
		var json = body
		fs.writeFile("libros.json", json, (err) => {
			if (err) throw err;
			console.log("Changes saved");
		});
		next();
	});

	console.log("POST recivido");
	//console.log(body);
});

server.listen(8080, function() {
    console.log('%s listening at %s', server.name, server.url);
});
