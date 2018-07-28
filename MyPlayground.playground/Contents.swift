import HelpKit



let equation = CGQuadEquation(xy(-1, 0.3), xy(0, 0), c3: xy(1, 0.5))

print(equation.solve(for: 30))

