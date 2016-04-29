//http://bl.ocks.org/mbostock/4062045
//http://stackoverflow.com/questions/23386277/find-targets-target-i-e-friend-of-friend-in-force-directed-graph
//http://www.coppelia.io/2014/06/finding-neighbours-in-a-d3-force-directed-layout-2/

var width = 960,
    height = 440;

var toggle = 0;

var color = d3.scale.category20();

var force = d3.layout.force()
    .charge(-120)
    .linkDistance(30)
    .size([width, height]);

var svg = d3.select("#graph_neighborhoods").append("svg")
    .attr("width", width)
    .attr("height", height);

d3.json("../data/got.json", function(error, graph) {
  if (error) throw error;

  force
      .nodes(graph.nodes)
      .links(graph.edges)
      .start();

  var link = svg.selectAll(".link")
      .data(graph.edges)
    .enter().append("line")
      .attr("class", "link");

  var node = svg.selectAll(".node")
      .data(graph.nodes)
    .enter().append("circle")
      .attr("class", "node")
      .attr("r", 5)
      .style("fill", "steelblue")
      .call(force.drag)
      .on('dblclick', connectedNodes)
      .on('mouseover', function(){
        d3.select(this).transition().duration(300)
            .attr("r", 8);
      })
      .on('mouseout', function(){
        d3.select(this).transition().duration(300)
            .attr("r", 5);
      });

  node.append("title")
      .text(function(d) { return d.v_label; });

  force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node.attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });
  });

  var linkedByIndex = {};
  graph.edges.forEach(function (d) {
      linkedByIndex[d.source.index + "," + d.target.index] = 1;
  });

  function neighboring(a, b) {
      return linkedByIndex[a.index + "," + b.index];
  }

  function connectedNodes() {
    var depth = +$('#choose_d').val();
    console.log(depth);

    if (toggle == 0) {
      var dat = d3.select(this).node().__data__;
      var connected = {};
      if (depth == 2) {
        var friends = graph.nodes.filter(function(o) { return neighboring(dat, o) | neighboring(o, dat); });
        friends.forEach(function(o) {
          connected[o.v_name] = 1;
          // second pass to get second-degree neighbours
          graph.nodes.forEach(function(p) {
            if(neighboring(o, p) | neighboring(p, o)) {
              connected[p.v_name] = 1;
            }
          });
        });
      } else {
        graph.nodes.forEach(function(p) {
          if(neighboring(dat, p) | neighboring(p, dat)) {
            console.log(p)
            connected[p.v_name] = 1;
          }
        });
      }

      console.log(connected);


      node.style("fill", function (o) {
          return dat === o ? "orange" : connected[o.v_name] ? "red" : "steelblue";
      });
      toggle = 1;
    } else {
      node.style("fill", "steelblue");
      toggle = 0;
    }

  }

});
