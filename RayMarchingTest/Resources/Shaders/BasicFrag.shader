#version 460 core
#define MAX_STEPS 2000
#define MAX_DIST 5000.
#define SURF_DIST .001
#define PI 3.14159

out vec4 FragColor;

in vec2 fragCoord;

uniform vec2 arrows;
uniform vec2 res;
uniform mat4 cam_rot;
uniform mat4 cam_trans;

mat4 rotationMatrix(vec3 axis, float angle)

{
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;

	return mat4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
		oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
		oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
		0.0, 0.0, 0.0, 1.0);
}

float tetra(vec3 p, float  r)

{
	float md = max(max(-p.x - p.y - p.z, p.x + p.y - p.z), max(-p.x + p.y + p.z, p.x - p.y + p.z));
	return (md - r) / sqrt(3.0);
}

float sphere(vec3 p, vec4 n)

{
	return length(p - n.xyz) - n.w;
}

float plane(vec3 p, vec4 n)

{
	return dot(p, n.xyz) + n.w;
}

float box(vec3 p, vec3 b, vec3 pos)

{
	p -= pos;
	vec3 d = abs(p) - b;
	return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

float cube(vec3 p, vec4 b)

{
	p -= b.xyz;
	vec3 d = abs(p) - b.w;
	return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

float cubeCross(vec3 p, vec4 n, float t)

{
	float arm1 = box(p, vec3(n.w, t, t), n.xyz);
	float arm2 = box(p, vec3(t, n.w, t), n.xyz);
	float arm3 = box(p, vec3(t, t, n.w), n.xyz);

	return min(arm1, min(arm2, arm3));
}

vec4 GetDist_old(vec3 p)

{
	vec3 prev = p;
	vec3 z = p;
	float dr = 1.0;
	float r = 1.0;
	float bail = 4.0;
	float bailColor = 1.0;
	for (int i = 0; i < 8; i++)

	{
		r = length(z);
		if (r > bail)

		{
			bailColor = float(i) / 8.0;
			break;
		}
		float theta = acos(z.z / r);
		float phi = atan(z.y, z.x);
		dr = pow(r, 7.0)*8.0*dr + 1.0;

		float zr = pow(r, 8.0);
		theta = theta * 8.0;
		phi = phi * 8.0;

		z = zr * vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z += p;

	}

	vec3 transform = prev - p;
	float c = (length(transform)*3.2) + arrows.y;
	c = bailColor;
	vec3 color = normalize(transform) + vec3(0.1, 0.1, 0.1);

	color.x = (0.8*pow(sin(c*1.5e-1), 2) + 0.2);
	color.y = (0.8*pow(cos(c*1e-5), 2) + 0.2);
	color.z = (0.8*pow(cos(-c*1e-5), 2) + 0.2);

	//color += normalize(transform);

	color = clamp(color, 0.0, 1.0);

	return vec4(color, 0.5*log(r)*r / dr);
}

vec4 GetDist(vec3 p)

{
	vec3 prev = p;
	//p = z;
	float s;
	float r  = 0;

	int n = 0;
	//int its = int(10.*arrows.y + 6);
	int its = 6;


	//int its = 4;
	float size = pow(3., its);
	float scale = 1./3.;
	float d = plane(p + vec3(0., size*scale, 0.), vec4(0, 1, 0, 0.0));
	
	p /= ((arrows.x*arrows.x + 36.)*its + 1.);


	int symPlan = 0;
	
	for (int i = 0; i < symPlan; i++)

	{
		float angle = i*2.*PI / symPlan;
		vec3 mirrorNormal = normalize(vec3(-cos(angle), 0., -sin(angle)));
		p -= 2.0*min(0.0, dot(p, mirrorNormal))*mirrorNormal;
	}
	//float angle = arrows.x;
	

	//vec3 n5 = normalize(vec3(cos(angle), 1, sin(angle)));
	//p -= 2.0*min(0.0, dot(p + vec3(0, 0, 0), n5))*n5;

	

	//0.192
	//0.7 with PI/3 {1, 0, 1}
	
	
	//p += vec3(-1. / 3., 0, -1. / 3.);
	//vec3 n4 = normalize(vec3(cos(angle), 0, 0));
	//p -= 2.0*min(0.0, dot(p + vec3(0, 0, 0), n4))*n4;

	
	/*
	
	while (n < its)

	{
		vec3 n1 = normalize(vec3(1, 1, 0));
		vec3 n2 = normalize(vec3(1, 0, 1));
		vec3 n3 = normalize(vec3(0, 1, 1));
		
		p -= 2.0*min(0.0, dot(p, n2))*n2;
		p -= 2.0*min(0.0, dot(p, n1))*n1;
		p -= 2.0*min(0.0, dot(p, n3))*n3;
		p /= scale;d
		p -= vec3(size);
		n++;
		r += dot(p, p);
	}
	*/

	//float s2 = cube(p, vec4(0.0, 0.0, 0.0, size));

	mat4 rot1 = rotationMatrix(vec3(0, 1, 0), arrows.y);
	//-0.251
	mat4 rot2 = rotationMatrix(normalize(vec3(0, 0, 1)), -arrows.y);
	


	while (n < its)

	{

		//vec3 n1 = normalize(vec3(1, -1, 0));
		//vec3 n2 = normalize(vec3(1, 0, -1));
		//vec3 n3 = normalize(vec3(0, 1, -1));
		//p -= vec3(size);
		//p -= 2.0*min(0.0, dot(p - n1*scale, n1))*n1;
		//p += n1 - n2;
		//p -= 2.0*min(0.0, dot(p, n2))*n2;
		//p += n2 - n3;
		//p -= 2.0*min(0.0, dot(p, n3))*n3;
		//p += n3;

		//p += vec3(size);
		//p /= scale;
		//p -= vec3(size);
		//p /= scale;
		
		vec4 z = rot1 * vec4(p, 1.0);
		//z = rot2 * z;
		p = z.xyz;

		p = abs(p);
		float a = min(p.x - p.y, 0.0);
		p.x -= a;
		p.y += a;
		a = min(p.x - p.z, 0.0);
		p.x -= a;
		p.z += a;
		a = min(p.y - p.z, 0.0);
		p.y -= a;
		p.z += a;
		
		
		
		p /= scale;
		
		p.xy -= 2.0;
		
		vec3 n4 = vec3(0, 0, -1);
		p -= 2.0*min(0.0, dot(p, n4) + 1.)*n4;
		
		n++;
		r += dot(p, p);
	}
	
	//p = abs(p - 1.0) + 1.0;
	//vec3 n1 = normalize(vec3(0, 0, 1));
	//p -= 2.0*min(0.0, dot(0.5*p/scale + n1, n1))*n1;
	//p -= n1;

	
	


	//p += vec3(1.0);

	//p -= 2.0*min(0.0, dot(0.5*p / scale - n1, -n1))*(-n1);
	

	//p.xyz = mod(p.xyz, vec3(4.0, 20.0, 2.0));
	//s = sphere(p/2.0, vec4(1.0, 1.0, 1.0, 1.0))*pow(scale, 10)*2.0;

	//p.x -= 1.0;
	//p.x -= arrows.x;
	//p.x += 1.0;

	//s = tetra(p, size)*pow(scale, its);
	//float s1 = min(min(box(p, vec3(1., 10., 1.), vec3(0.0)), box(p, vec3(10., 1., 1.), vec3(0.0))), box(p, vec3(1., 1., 10.), vec3(0.0)));
	//float s1 = cubeCross(p, vec4(0.0, 0.0, 0.0, size + size*0.1), size/3.);
	
	//vec3 normal = normalize(vec3(0.0, 1.0, 2.0));
	//p -= 2.0*min(0.0, dot(p, normal))*normal;
	//p -= vec3(0.0, 0.0, 10.0);
	//p -= 2.0*min(0.0, dot(p, normal))*normal;
	//float d = plane(p + vec3(0., 0.0, 0.), vec4(0, 1, 0, 0.0));
	//float d = plane(p + vec3(0., 0.0, 0.), vec4(0, 1, 0, 0.0));
	float s1 = cube(p, vec4(0.0, 0.0, 0.0, 1.0));


	//float s2 = sphere(p, vec4(1.0, 1.0, 1.0, 0.25));
	
	//s1 *= pow(scale, its);
	//s = max(s2, -s1)*pow(scale,its);

	//s = s1 * pow(scale, its)*((0.0 + 36.)*its + 1);
	s = s1 * pow(scale, its)*((arrows.x*arrows.x + 36.)*its + 1);
	//s = s1;
	//p = mod(p, arrows.x + 100.0);
	//s = sphere(p, vec4(50.0, 50.0, 50.0, size))*pow(scale, its);

	//p.y -= 2*size;

	vec3 transform = prev - p;
	float c = (length(transform)*3.2) + arrows.y;
	c = r;
	vec3 color = normalize(transform) + vec3(0.1, 0.1, 0.1);

	color.x = (0.8*pow(sin(c*1e-10),2) + 0.2);
	color.y = (0.8*pow(cos(c*1e-5),2) + 0.2);
	color.z =  (0.8*pow(sin(-c*1e-4),2) + 0.2);

	color += normalize(transform);

	color = clamp(color, 0.0, 1.0);

	if (d < s)

	{
		color = vec3(1.0, 1.0, 0.9);
	}
	return vec4(color, min(s,d));
	//return s;
}

vec3 RayMarch(vec3 ro, vec3 rd)

{
	float dO = 0.;
	float breakout = -1.0;
	float minDist = 10.;

	for (int i = 0; i < MAX_STEPS; i++)

	{
		vec3 p = ro + rd * dO;
		float ds = GetDist(p).w;
		dO += ds;
		
		minDist = min(minDist, ds);

		if (ds < SURF_DIST)

		{
			breakout = i;
			break;
		}

		if (dO > MAX_DIST)

		{
			breakout = MAX_STEPS;
			break;
		}
	}

	if (breakout < 0.0) breakout = MAX_STEPS;

	return vec3(dO, breakout, minDist);
}

float vignette(float mag, vec2 uv)

{
	return 1.0 - (pow(uv.x, 2) + pow(uv.y,2))*mag;
}


float RayMarchShadow(vec3 ro, vec3 rd, float length)

{
	float res = 1.0;
	//float dO = SURF_DIST;

	for (float dO = SURF_DIST; dO < length;)

	{
		vec3 p = ro + rd * dO;
		float ds = GetDist(p).w;
		dO += ds;

		if (ds < SURF_DIST)

		{
			res = 0.1;
			return res;
		}

		res = min(res, 200 * ds / dO);
	}

	res = clamp(res, 0.1, 1.0);

	return res;
}

vec3 GetNormal(vec3 p)

{
	float d = GetDist(p).w;
	vec2 e = vec2(SURF_DIST*1, 0);

	vec3 n = d - vec3(
		GetDist(p - e.xyy).w,
		GetDist(p - e.yxy).w,
		GetDist(p - e.yyx).w);
	return normalize(n);
}

float GetLight(vec3 p, float surfCom, vec3 lightPos)

{
	//lightPos = vec3(1, 30, 1);
	vec3 l = normalize(lightPos - p);
	vec3 n = GetNormal(p);
	float lightDist = length(lightPos - p);
	float dif = clamp(dot(n, l), 0.9, 1.);


	dif = min(RayMarchShadow(p + n * SURF_DIST*3.0, l, lightDist), dif);


	float occDark = 1.0;
	//0.98 for non normal
	if (surfCom > 5) occDark = pow(0.98, surfCom - 6);


	
	dif *= clamp(occDark, 0.02, 1.0);


	//vec3 d = RayMarch(p + n * SURF_DIST*2., l);
	

	//if (d.x < length(lightPos - p)) dif *= 0.1;
	//if (d.z < 0.1) dif *= (d.z- 0.1)*2 + 1.0;

	//dif *= clamp( + 1.0, 0.0, 1.0);

	return dif;
}

void main()

{
	float ratio = res.x / res.y;
	vec2 uv = vec2(fragCoord.x, fragCoord.y / ratio);

	vec3 col = vec3(0);
	
	vec3 ro = (cam_trans*vec4(0, 1.0, 0, 1.0)).xyz;
	//vec3 rd = normalize(vec3(uv.x, uv.y - 0.3, 1));
	vec4 cam = cam_rot * vec4(uv.x, uv.y, 1.0, 1.0);
	vec3 rd = normalize(cam.xyz);

	vec3 d = RayMarch(ro, rd);

	vec3 p = ro + rd * d.x;

	vec3 lightPos = vec3(0.0, 3000.0, 800.0);

	

	float dif = GetLight(p, d.y, lightPos);

	

	//dif += GetLight(p, d.y, vec3(100.0, 0.0, 0.0));

	//dif /= 2.0;

	//dif = clamp(dif, 0.0, 1.0);

	//vec3 n = GetNormal(p);

	vec3 hue = normalize(vec3(0.01, 0.05, 0.12) / 2.);

	float dotp = dot(normalize(rd), normalize(lightPos - ro));

	
	//col = vec3(dif);
	col = dif * GetDist(p).xyz;

	if (d.y > MAX_STEPS - 1)

	{
		col = hue;
	}

	else if (d.x > MAX_DIST / 2.0)

	{
		col -= 2.*(col - hue)*pow((d.x - MAX_DIST / 2.) / MAX_DIST, 1);
	}

	if (dotp > 0.999)

	{
		dif += (1 / pow(1 - 0.999, 4))*pow(dotp - 0.999, 4);
		col += dif*vec3(0.9, 0.7, -0.5);
	}


	col *= vignette(0.5, uv.xy);

	clamp(col, 0.0, 1.0);

	//col = GetNormal(p)*dif;
	FragColor = vec4(col, 1.0f);
}