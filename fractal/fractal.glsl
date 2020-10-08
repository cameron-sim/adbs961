precision highp float;
precision highp int;

varying vec4 vertTexCoord;

uniform float centerX = -0.7468999810516834;
uniform float centerY = 0.12999999709427357;
uniform float scale = 1.17;
uniform float screen_ratio = 2.0;
uniform float escape = 4.0;
uniform float pxX = 0;
uniform float pxY = 0;
uniform int iterations = 300;
uniform int colour_mode = 0;
uniform int colour_sin = 0;
uniform int colour_smooth = 0;

float julia(float nx, float ny)
{
	float zx = screen_ratio * (nx - .5) * scale + pxX;
	float zy = (ny - .5) * scale + pxY;
	
	float dt = 1.;
	int it;

	for (it = 0; it < iterations; it++)
	{
		float x = (zx * zx - zy * zy) + centerX;
		float y = (zy * zx + zx * zy) + centerY;
		
		dt = x * x + y * y;
		if (dt > escape) break;

		zx = x;
		zy = y;
	}

	float n = float(it);
	return colour_smooth > 0 ? (it < iterations ? n - log2(log2(dt)) + 4. : n) : n;
}

void main()
{
	float c = julia(vertTexCoord.x, vertTexCoord.y) / float(iterations);
	
	switch(colour_sin)
	{
	case 0:
		c *= 3.14159265;
		break;
	case 1:
		c *= 1.57079632;
		break;
	}

	switch (colour_mode)
	{
	case 0:
		gl_FragColor = vec4(pow(sin(c), .5), pow(sin(c), 3), pow(sin(c), 5), 1.);
		break;
	case 1:
		gl_FragColor = vec4(pow(sin(c), 5), pow(sin(c), 3), pow(sin(c), .5), 1.);
		break;
	case 2:
		gl_FragColor = vec4(pow(sin(c), 3), pow(sin(c), .5), pow(sin(c), 5), 1.);
		break;
	}
}
