# MATH HELPER
#
extends Node

# LERP
static func lerp(a, b, f):
	return a + f * (b - a)

# QUART
static func in_quart(t, b, c, d):
	t = t / d
	return c * pow(t, 4) + b

static func out_quart(t, b, c, d):
	t = t / d - 1
	return -c * (pow(t, 4) - 1) + b

static func in_out_quart(t, b, c, d):
	t = t / d * 2
	if t < 1:
		return c / 2 * pow(t, 4) + b
	else:
		t = t - 2
		return -c / 2 * (pow(t, 4) - 2) + b

# CUBIC
static func in_cubic(t, b, c, d):
	t = t / d
	return c * pow(t, 3) + b
	
static func out_cubic(t, b, c, d):
	t = t / d - 1
	return c * (pow(t, 3) + 1) + b

static func in_out_cubic(t, b, c, d):
	t = t / d * 2
	if t < 1:
		return c / 2 * t * t * t + b
	else:
		t = t - 2
		return c / 2 * (t * t * t + 2) + b

# BACK
static func in_back(t, b, c, d, s):
	if s:
		s = 1.70158
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b

static func out_back(t, b, c, d, s):
	if s:
		s = 1.70158
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b

static func in_out_back(t, b, c, d, s):
	if s:
		s = 1.70158
	s = s * 1.525
	t = t / d * 2
	if t < 1:
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	else:
		t = t - 2
	return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b


# ROTATE
static func rotate_around(point, center, radians):
		var c_theta = cos(radians)
		var s_theta = sin(radians)
		return Vector2(c_theta * (point.x - center.x) - s_theta * (point.y - center.y) + center.x,
				s_theta * (point.x - center.x) + c_theta * (point.y - center.y) + center.y)
				