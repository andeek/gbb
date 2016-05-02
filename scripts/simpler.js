var simpler = function(selection) {
  selection.each(function(d, i) {
    var width = 960,
        height = 440;

    var blocks = [];
    var neighbors = {};
    var block_neighbors = {};

    var color = d3.scale.category20();

    var force = d3.layout.force()
        .charge(-120)
        .linkDistance(30)
        .size([width, height]);

    var svg = d3.select(this).append("svg")
        .attr("width", width)
        .attr("height", height);

    d3.json("data/got.json", function(error, graph) {
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

      d3.select(this).on("keydown", function() {
        if(d3.event.keyCode == 66) {
          // key stroke = b
          show_blocks_only();
        } else if (d3.event.keyCode == 69) {
          // key stroke = e
          show_new_edges();
        }
      });

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
        d = d3.select(this).node().__data__;
        blocks.push(d);

        graph.nodes.forEach(function(p) {
          blocks.forEach(function(dat) {
            if(neighboring(dat, p) | neighboring(p, dat)) {
              neighbors[p.v_name] = 1;
            }
          });
        });
        node.style("fill", function (o) {
          return blocks.indexOf(o) >= 0 ? "orange" : neighbors[o.v_name] ? "red" : "steelblue";
        });
      }

    function show_blocks_only() {
      node.style("opacity", function (o) {
        return blocks.indexOf(o) >= 0 ? 1 : neighbors[o.v_name] ? 1 : 0.15;
      });

      blocks.forEach(function(dat) {
        block_neighbors[dat.v_name] = {};
        graph.nodes.forEach(function(p) {
          if(neighboring(dat, p) | neighboring(p, dat)) {
            block_neighbors[dat.v_name][p.v_name] = 1;
          }
        });
      });

      var keep_edge = {};
      graph.edges.forEach(function(e) {
        if(blocks.indexOf(e.source) >= 0 | blocks.indexOf(e.target) >= 0) {
          keep_edge["s" + e.source.v_name + "t" + e.target.v_name] = 1;
        }
        blocks.forEach(function(dat) {
          if(block_neighbors[dat.v_name][e.source.v_name] & block_neighbors[dat.v_name][e.target.v_name]) {
            keep_edge["s" + e.source.v_name + "t" + e.target.v_name] = 1;
          }
        });

      });
      link.style("opacity", function(o) {
        return keep_edge["s" + o.source.v_name + "t" + o.target.v_name] ? 1 : 0.15;
      })
    }

    function show_new_edges() {
      var new_edges = [];
      Object.keys(block_neighbors).forEach(function(key1) {
        Object.keys(block_neighbors).forEach(function(key2) {
          if(key1 != key2) {
            Object.keys(block_neighbors[key1]).forEach(function(skey1) {
              Object.keys(block_neighbors[key2]).forEach(function(skey2) {
                new_edges.push({
                  source: graph.nodes.filter(function(d) {return d.v_name == skey1;})[0],
                  target: graph.nodes.filter(function(d) {return d.v_name == skey2;})[0]
                });
                new_edges.push({
                  source: graph.nodes.filter(function(d) {return d.v_name == key1;})[0],
                  target: graph.nodes.filter(function(d) {return d.v_name == skey2;})[0]
                });
              });
            });
            new_edges.push({
              source: graph.nodes.filter(function(d) {return d.v_name == key1;})[0],
              target: graph.nodes.filter(function(d) {return d.v_name == key2;})[0]
            });
          }
        });
      });

      new_edges.forEach(function(edge1, idx1) {
        new_edges.forEach(function(edge2, idx2) {
          if((edge1.target == edge2.source & edge1.source == edge2.target) | (edge1.source == edge1.source & edge1.targe == edge2.target)) {
            new_edges.splice(idx1, 1);
          }
        })
      });
      /*function getRandomSubarray(arr, size) {
          var shuffled = arr.slice(0), i = arr.length, min = i - size, temp, index;
          while (i-- > min) {
              index = Math.floor((i + 1) * Math.random());
              temp = shuffled[index];
              shuffled[index] = shuffled[i];
              shuffled[i] = temp;
          }
          return shuffled.slice(min);
      }
      new_edges = getRandomSubarray(new_edges, new_edges.length*.25);*/

      var pot_link = svg.selectAll(".pot_link")
          .data(new_edges);

      pot_link.enter().append("line")
          .attr("class", "pot_link");

      console.log(new_edges);

      pot_link.attr("x1", function(d) { return d.source.x; })
          .attr("y1", function(d) { return d.source.y; })
          .attr("x2", function(d) { return d.target.x; })
          .attr("y2", function(d) { return d.target.y; })
          .style("stroke-dasharray", ("3, 3"))
          .style("opacity", .5);


    }

    });
  });
};
simpler(d3.select("#simpler"));
