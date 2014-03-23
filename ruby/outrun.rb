require 'priority_queue'
require 'rgl/adjacency'
require 'logger'

LOG = Logger.new(STDOUT)

# Builds a directed graph from a given file
#
# @param dg [DirectedAdjacencyGraph] The Graph object to populate
# @param filename [String] The file path to the file to parse
# @return [Hash] The source of the generated Graph
def build_directed_graph(dg, filename)
  counter = 0
  source = nil
  File.open(filename, 'r') do |f|
    previous_vertices = []
    f.each_line do |line|
      next if line.strip.start_with?('#')
      vertices, source, counter = handle_line(line, counter, source,  dg, previous_vertices.empty?)
      tmp = Array.new(vertices)
      add_edges(previous_vertices, vertices, dg)
      previous_vertices = Array.new(tmp)
    end
  end
  source
end

def handle_line(line, counter, source, dg, previous_vertices_empty)
  vertices = []
  line.split(' ').each do |node|
    node = - node.to_i
    vertex_label = { counter => node }
    dg.add_vertex(vertex_label)
    vertices << vertex_label
    source = vertex_label if previous_vertices_empty
    counter += 1
  end
  [vertices, source, counter]
end

def add_edges(previous_vertices, vertices, dg)
  previous_vertices.each do |pv|
    dg.add_edge(pv, vertices.shift)
    dg.add_edge(pv, vertices.first)
  end
end

# Calculates the longest path in a DAG with Bellman-Ford -algorith
# by negative weighted vertices
#
# @param dg [DirectedAdjacencyGraph] The Graph to traverse
# @param source [Hash] The source vertex of the Graph
# @return [Fixnum] The size of the largest path
def negative_bellman_ford(dg, source)
  distance = Hash.new { 1.0 / 0.0 }
  predecessor = {}
  distance[source] = source.values.first.to_i

  bf_traverse_vertices(dg, distance, predecessor)
  detect_negative_weight_cycle(dg.edges, distance)
  -distance.to_a.min_by { |k, v| v }.last
end

def bf_traverse_vertices(dg, distance, predecessor)
  dg.vertices.each do
    dg.edges.each do |e|
      u = e.source
      v = e.target
      w = v.values.first.to_i
      if distance[u] + w < distance[v]
        distance[v] = distance[u] + w
        predecessor[v] = u
      end
    end
  end
end

def detect_negative_weight_cycle(edges, distance)
  edges.each do |e|
    u = e.source
    v = e.target
    w = v.values.first.to_i
    if distance[u] + w < distance[v]
      LOG.error 'Graph contains a negative-weight cycle'
    end
  end
end

# Calculates the longest path in a DAG by toposorting
# and then traversing adjacent vertices, using negative weighted vertices
#
# @param source [Hash] The source vertex of the Graph
# @param dg [DirectedAdjacencyGraph] The Graph to traverse
# @return [Fixnum] The size of the largest path
def longest_path(source, dg)
  distance = Hash.new(Float::INFINITY)
  distance[source] = source.values.first.to_i
  traverse_vertices(dg.vertices, distance, dg)
  distance.to_a.min_by { |k, v| v }
end

def traverse_vertices(vertices, distance, dg)
  unless vertices.empty?
    v = vertices.shift
    if distance[v] != Float::INFINITY
      find_longer_distance_in_neighbours(dg.adjacent_vertices(v), distance, v)
    end
    traverse_vertices(vertices, distance, dg)
  end
end

def find_longer_distance_in_neighbours(adjacent_vertices, distance, v)
  unless adjacent_vertices.empty?
    av = adjacent_vertices.shift
    new_dist = distance[v] + av.values.first.to_i
    distance[av] = new_dist if distance[av] > new_dist
    find_longer_distance_in_neighbours(adjacent_vertices, distance, v)
  end
end

if Dir.pwd.end_with?('outrun/ruby')
  Dir.chdir '..'
end

dg = RGL::DirectedAdjacencyGraph.new
source = build_directed_graph(dg, 'tree1.txt')
bf = negative_bellman_ford(dg, source)
lp = longest_path(source, dg)
LOG.info "Longest path for 'Tree 1': bf: #{bf} - lp: #{lp}"

dg = RGL::DirectedAdjacencyGraph.new
source = build_directed_graph(dg, 'tree2.txt')
bf = negative_bellman_ford(dg, source)
lp = longest_path(source, dg)
LOG.info "Longest path for 'Tree 2': bf: #{bf} - lp: #{lp}"

dg = RGL::DirectedAdjacencyGraph.new
source = build_directed_graph(dg, 'tree3.txt')
bf = negative_bellman_ford(dg, source)
lp = longest_path(source, dg)
LOG.info "Longest path for 'Tree 3': bf: #{bf} - lp: #{lp}"

dg = RGL::DirectedAdjacencyGraph.new
source = build_directed_graph(dg, 'tree.txt')
lp = longest_path(source, dg)
LOG.info "Longest path for 'Tree': #{lp}"

dg = RGL::DirectedAdjacencyGraph.new
source = build_directed_graph(dg, 'tree4.txt')
lp = longest_path(source, dg)
LOG.info "Longest path for 'Tree4': #{lp}"

dg = RGL::DirectedAdjacencyGraph.new
source = build_directed_graph(dg, 'triangle.txt')
lp = longest_path(source, dg)
LOG.info "Longest path for 'Triangle': #{lp}"
