from collections import defaultdict
import networkx as nx

def pt1(f): 
  G = nx.DiGraph()
  E = defaultdict(set)

  for line in f:
      left, right = line.split(":")
      for node in right.strip().split():
          G.add_edge(left, node, capacity=1.0)
          G.add_edge(node, left, capacity=1.0)
          E[left].add(node)
          E[node].add(left)

  for x in [list(E.keys())[0]]:
    for y in E.keys():
      if x!=y:
        cut_value, (L, R) = nx.minimum_cut(G, x, y)
        if cut_value == 3:
          return len(L) * len(R)

print(pt1(open("example1.txt")))
print(pt1(open("input1.txt")))
