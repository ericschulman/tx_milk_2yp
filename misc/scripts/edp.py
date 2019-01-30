import numpy as np
import matplotlib.pyplot as plt
import math



"""returns an EDP function with specified parameters"""
def edp(d,g):
	return (lambda t: d if t % 1 < g else 1)

""" uh"""
def graph(T,d,g):
	p = edp(d,g)
	for i in range (0,T):
		plt.plot([i, i+g ], [p(i), p(i)],'b',linewidth=2)
		plt.plot([i + g, i+1], [p(i+g),p(i+g)],'b',linewidth=2)

		plt.plot([i+g, i+g], [d,1],'b',linestyle='--') #vertical line
		plt.plot([i+1, i+1], [d,1],'b',linestyle='--') #vertical line
	plt.xlabel('Sales Cycle (Normalized to 1)')
	plt.ylabel('Price (Normalized to 1)')
	plt.show()


if __name__ == "__main__":
	graph(4,.5,.5)
	# draw diagonal line from (70, 90) to (90, 200)

	