require 'priority_queue'
require 'rgl/adjacency'

def build_tree(dg, filename)
  counter = 0
  source = nil
  File.open(filename, 'r') do |f|
    previous_vertices = []
    vertices = []
    f.each_line do |line|
      next if line.strip.start_with?('#')
      line.split(' ').each do |node|
        node = - node.to_i
        dg.add_vertex({counter=>node})
        vertices << {counter=>node}
        source = {counter => node} if previous_vertices.empty?
        counter += 1
      end
      tmp = Array.new(vertices)
      previous_vertices.each do |pv|
        dg.add_edge(pv, vertices.shift)
        dg.add_edge(pv, vertices.first)
      end
      previous_vertices = Array.new(tmp)
      vertices = []
    end
  end
  source
end

def bellman_ford(vertices, edges, source)
  distance = Hash.new { 1.0 / 0.0 }
  predecessor = {}
  distance[source] = source.values.first.to_i

  vertices.each do
    edges.each do |e|
      u = e.source
      v = e.target
      w = v.values.first.to_i
      if distance[u] + w < distance[v]
        distance[v] = distance[u] + w
        predecessor[v] = u
      end
    end
  end

  edges.each do |e|
    u = e.source
    v = e.target
    w = v.values.first.to_i
    if distance[u] + w < distance[v]
      p "ERROR: Graph contains a negative-weight cycle"
    end
  end
  -distance.to_a.min_by {|k,v| v}.last
end

dg = RGL::DirectedAdjacencyGraph.new
source = build_tree(dg, 'tree1.txt')
p 'Tree 1:', bellman_ford(dg.vertices, dg.edges, source)

dg = RGL::DirectedAdjacencyGraph.new
source = build_tree(dg, 'tree2.txt')
p 'Tree 2:', bellman_ford(dg.vertices, dg.edges, source)

dg = RGL::DirectedAdjacencyGraph.new
source = build_tree(dg, 'tree.txt')
p 'Tree:',  bellman_ford(dg.vertices, dg.edges, source)
