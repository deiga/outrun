var _ = require('underscore-node');
var Graph = require('graph').Graph;
var fs = require('fs');
var lazy = require('lazy');

function build_directed_graph(filename, callback) {
  var source;
  var counter = 0;
  var previous_vertices = [];
  lazy(fs.createReadStream(filename))
    .on('end', function() {
      callback(source);
    })
    .lines
    .forEach(function(line) {
      line = line.toString();
      if (line.trim().lastIndexOf('#', 0) === 0) return;
      foo = handle_line(counter, line, previous_vertices);
      previous_vertices = foo[0];
      counter = foo[1];
      source = foo[2] || source;
    });
}

function handle_line(counter, line, previous_vertices) {
  var source = null;
  var nodes = line.split(' ');
  var vertex_label = {};
  var vertices = nodes.map(function(label) { return new Array((counter++).toString(), -label); });
  var ret_vertices = vertices.slice(0);
  if (previous_vertices.length === 0) source = vertices[0];
  previous_vertices.forEach(function(pvertex) {
    var vertex = vertices.shift();
    dg.dir(pvertex, vertex);
    dg.dir(pvertex, vertices[0]);
  });
  return [ret_vertices, counter, source];
}

function longest_path(source) {
  var distance = {};
  distance[source] = parseInt(_.last(source), 10);
  _.each(dg._vertices.slice(0), function(v) {
    if (safe_get(distance, v) !== Infinity) {
      var adj = typeof dg.adj(v) !== 'undefined' ? dg.adj(v) : {};
      _.each(_.keys(adj), function(av) {
        av = av.split(',');
        var new_distance = safe_get(distance, v) + parseInt(_.last(av), 10);
        if (safe_get(distance, av) > new_distance) distance[av] = new_distance;
      });
    }
  });
  formatted_dist = _.map(distance, function(d,v) {return new Object([v, d]);});
  console.log((_.min(formatted_dist, function(obj) { return _.last(obj); })));
}

function safe_get(obj, key) {
  var val = obj[key];
  return typeof val !== 'undefined' ? val : Infinity;
}

// dg = new Graph();
// build_directed_graph('../tree1.txt', function(source) {
//   console.log('Tree1');
//   longest_path(source);
// });

// dg = new Graph();
// build_directed_graph('../tree2.txt', function(source) {
//   console.log('Tree2');
//   longest_path(source);
// });

// dg = new Graph();
// build_directed_graph('../tree3.txt', function(source) {
//   console.log('Tree3');
//   longest_path(source);
// });

dg = new Graph();
build_directed_graph('../tree.txt', function(source) {
  console.log('Tree');
  longest_path(source);
});

// dg = new Graph();
// build_directed_graph('../tree4.txt', function(source) {
//   console.log('Tree4');
//   longest_path(source);
// });

// dg = new Graph();
// build_directed_graph('../triangle.txt', function(source) {
//   console.log('Triangle');
//   longest_path(source);
// });
