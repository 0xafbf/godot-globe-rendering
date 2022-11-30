
import math

def lat(y):
	return 2 * math.atan(math.exp(y * math.pi)) - math.pi * 0.5

def lat2(y):
	return lat(y) / math.tau * 360

print(lat2(0))
print(lat2(0.25))
print(lat2(0.5))
print(lat2(0.75))
print(lat2(1))