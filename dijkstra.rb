require 'rgl/adjacency'

dg = RGL::DirectedAdjacencyGraph.new
ary = []

def build_tree(dg, ary)
  counter = 0
  File.open('tree.txt', 'r') do |f|
    previous_vertices = []
    vertices = []
    f.each_line do |line|
      next if line.strip.start_with?('#')
      line.split(' ').each do |node|
        dg.add_vertex({counter=>node})
        vertices << {counter=>node}
        ary[counter] = node
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
end

build_tree(dg, ary)
