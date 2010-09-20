var Log = {
    elem: false,
    write: function(text){
        if (!this.elem)
            this.elem = document.getElementById('log');
        this.elem.innerHTML = text;
        this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
    }
};

function addEvent(obj, type, fn) {
    if (obj.addEventListener) obj.addEventListener(type, fn, false);
    else obj.attachEvent('on' + type, fn);
};

var calculated_depth = false;


function init(){
    var infovis = document.getElementById('infovis');
    var w = infovis.offsetWidth, h = infovis.offsetHeight;
    //init canvas
    //Create a new canvas instance.
    var canvas = new Canvas('mycanvas', {
        'injectInto': 'infovis',
        'width': w,
        'height': h,
        //Optional: Add a background canvas
        //that draws some concentric circles.
        'backgroundCanvas': {
            'styles': {
                'strokeStyle': '#444'
            },
            'impl': {
                'init': function(){},
                'plot': function(canvas, ctx){
                    var times = 6, d = 175;
                    var pi2 = Math.PI * 2;
                    for (var i = 1; i <= times; i++) {
                        ctx.beginPath();
                        ctx.arc(0, 0, i * d, 0, pi2, true);
                        ctx.stroke();
                        ctx.closePath();
                    }
                }
            }
        }
    });
    //end
    //init RGraph
    var rgraph = new RGraph(canvas, {
        //Nodes and Edges parameters
        //can be overriden if defined in
        //the JSON input data.

        //This way we can define different node
        //types individually.

        Node: {
            'overridable': true,
             'color': '#cc0000'
        },
        Edge: {
            'overridable': true,
            'color': '#cccc00'
        },

        //Set polar interpolation.
        //Default's linear.
        interpolation: 'polar',

        //Change the transition effect from linear
        //to elastic.
        transition: Trans.linear,
        //Change other animation parameters.
        duration:1750,
        fps: 30,
        //Change father-child distance.
        levelDistance: 175,

        //This method is called right before plotting
        //an edge. This method is useful to change edge styles
        //individually.
        onBeforePlotNode: function(node){
          if (!calculated_depth) {
            var rootNode = rgraph.graph.getNode(rgraph.root);
            Graph.Util.computeLevels(rgraph.graph, rootNode.id);
            calculated_depth = true;
          }

          node.data.$color = "#cccccc";
          if (node._depth == 0) {
            node.data.$color = "#000000";
          } else if (node._depth == 1) {
            node.data.$color = "#777777";
          } else if (node._depth == 2) {
            node.data.$color = "#dddddd";
          }
        },
        onBeforePlotLine: function(adj){
            //Add some random lineWidth to each edge.
            // if (!adj.data.$lineWidth)
            //     adj.data.$lineWidth = Math.random() * 5 + 1;
            var rootNode = rgraph.graph.getNode(rgraph.root);
            var combined_depth = adj.nodeTo._depth + adj.nodeFrom._depth;

            // Default Styles
            adj.data.$lineWidth = 1;
            adj.data.$color = "#cccccc";
//            adj.data.$type = 'line';

            if (combined_depth == 1) {
//              adj.data.$type = 'arrow';
              adj.data.$lineWidth = 2;
              if (adj.nodeTo == rootNode) {
                adj.data.$color = "#CCCC00";
              } else if (adj.nodeFrom == rootNode) {
                adj.data.$color = "#00FFFF";
              }
            } else if (combined_depth == 2) {
              adj.data.$color = "#777777";
            } else if (combined_depth == 3) {
              adj.data.$color = "#dddddd";
            }
        },
        onBeforeCompute: function(node){
            Log.write("Centering " + node.name + "...");

            //Make right column relations list.
            var attr_url = "<a window=\"_blank\" href=\"http://www.opensiteexplorer.org/" + host + escape(encodeURIComponent(node.name)) + "/a\">VALUE</a>";
            document.getElementById('node_name').innerHTML = node.name;
            document.getElementById('node_mozrank').innerHTML = attr_url.replace("VALUE", node.data.mozrank);
            document.getElementById('node_moztrust').innerHTML = attr_url.replace("VALUE", node.data.moztrust);
            document.getElementById('node_page_authority').innerHTML = attr_url.replace("VALUE", node.data.page_authority);

            var html = "<b>Links:</b>";
            html += "<ul>";
            Graph.Util.eachAdjacency(node, function(adj){
                var child = adj.nodeTo;
                html += "<li>" + child.name + "</li>";
            });
            html += "</ul>";
            document.getElementById('inner-details').innerHTML = html;
            calculated_depth = false;
        },

        //Add node click handler and some styles.
        //This method is called only once for each node/label crated.
        onCreateLabel: function(domElement, node){
            domElement.innerHTML = node.name;
            domElement.onclick = function () {
                rgraph.onClick(node.id, { hideLabels: false });
            };
            domElement.onmouseover = function (e) {
              e.target.style.backgroundColor = "#fff";
              e.target.style.zIndex = 100;
            };
            domElement.onmouseout = function (e) {
              e.target.style.backgroundColor = "transparent";
              e.target.style.zIndex = 0;
            };
            var style = domElement.style;
            style.cursor = 'pointer';
            style.color = "#000000";
            style.display = "inline";
            node.data.$color = "#cccccc";
            style.fontSize = "0.8em";
        },
        //This method is called when rendering/moving a label.
        //This is method is useful to make some last minute changes
        //to node labels like adding some position offset.
        onPlaceLabel: function(domElement, node){
            var style = domElement.style;
            var left = parseInt(style.left);
            var w = domElement.offsetWidth;
            style.left = (left - w / 2) + 'px';
            style.fontSize = "0.8em";
            if (node._depth == 0) {
              style.fontSize = "1.2em";
            } else if (node._depth == 1) {
              style.fontSize = "1em";
            }
        },
        onAfterCompute: function(){
            Log.write("");
            calculated_depth = false;
        }

    });
    //load graph.
    rgraph.loadJSON(json, 1);

    //compute positions and plot
    rgraph.refresh();
    //end
    rgraph.controller.onBeforeCompute(rgraph.graph.getNode(rgraph.root));
    rgraph.controller.onAfterCompute();

}