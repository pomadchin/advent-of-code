# pip install sympy
import sympy

def pt2(f): 
  stones = [tuple(map(int, line.replace("@", ",").split(","))) for line in f]

  xr, yr, zr, vxr, vyr, vzr = sympy.symbols("xr, yr, zr, vxr, vyr, vzr")

  equations = []
  results = []
  for i, (sx, sy, sz, vx, vy, vz) in enumerate(stones):
      equations.append((xr - sx) * (vy - vyr) - (yr - sy) * (vx - vxr))
      equations.append((yr - sy) * (vz - vzr) - (zr - sz) * (vy - vyr))
      if i < 2:
          continue
      results = [s for s in sympy.solve(equations) if all(x % 1 == 0 for x in s.values())]
      if len(results) == 1:
          break
    
  res = results[0]

  return res[xr] + res[yr] + res[zr]

print(pt2(open("example1.txt")))
print(pt2(open("input1.txt")))