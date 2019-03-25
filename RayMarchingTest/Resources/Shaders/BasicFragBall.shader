#version 460 core
#define MAX_STEPS 1000
#define MAX_DIST 1000.
#define SURF_DIST .0001

out vec4 FragColor;

in vec2 fragCoord;

uniform vec2 res;
uniform mat4 cam_rot;
uniform mat4 cam_trans;

vec2 test(vec2 x, vec2 y)

{
	return vec2(x.x - y.x*floor(x.x / y.x), x.y - y.y*floor(x.y / y.y));
}

float GetDist(vec3 p)

{
	
	vec4 s = vec4(0.4, 2.5, 1.0, 0.25);

	//float sphereDist = length(mod(p, 1.0) - s.xyz) - s.w - 0.3;
	vec3 z = p;
	z.xyz = mod(z.xyz, vec3(0.8, 5.0, 2.0));
	//z.xz = test(z.xz, vec2(1.0, 1.0));
	float sphereDist = length(z - s.xyz) - s.w;

	vec4 s2 = vec4(10.0, 11.0, 0.0, 0.5);

	//float sphereDist = length(mod(p, 1.0) - s.xyz) - s.w - 0.3;
	//p.xy = mod(p.xy, 1.0);
	vec3 z2 = p;
	//z.xz = mod(z.xz, 1.0);
	float sphereDist2 = length(z2 - s2.xyz) - s2.w;

	float planeDist = p.y;

	float d = min(min(sphereDist, planeDist), sphereDist2);
	return d;
	

}

float GetDist_frac(vec3 p)

{
	vec3 z = p;
	float dr = 1.0;
	float r = 1.0;
	float bail = 4.0;
	for (int i = 0; i < 8; i++)

	{
		r = length(z);
		if (r > bail) break;

		float theta = acos(z.z / r);
		float phi = atan(z.y, z.x);
		dr = pow(r, 7.0)*8.0*dr + 1.0;

		float zr = pow(r, 8.0);
		theta = theta * 8.0;
		phi = phi * 8.0;

		z = zr * vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z += p;

	}

	//float planeDist = p.y + 5;

	return 0.5*log(r)*r / dr;
	
}

vec2 RayMarch(vec3 ro, vec3 rd)

{
	float dO = 0.;
	float breakout = -1.0;

	for (int i = 0; i < MAX_STEPS; i++)

	{
		vec3 p = ro + rd * dO;
		float ds = GetDist(p);
		dO += ds;
		

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

	return vec2(dO, breakout);
}

vec3 GetNormal(vec3 p)

{
	float d = GetDist(p);
	vec2 e = vec2(SURF_DIST/10., 0);

	vec3 n = d - vec3(
		GetDist(p - e.xyy),
		GetDist(p - e.yxy),
		GetDist(p - e.yyx));
	return normalize(n);
}

float GetLight(vec3 p, float surfCom)

{
	vec3 lightPos = vec3(2, 10, 0);
	vec3 l = normalize(lightPos - p);
	vec3 n = GetNormal(p);
	//0.9 lower for non normal
	float dif = clamp(dot(n, l), 0.01, 1.);
	vec2 d = RayMarch(p + n*SURF_DIST*3., l);
	float occDark = 1.0;
	//0.98 for non normal
	if (surfCom > 5) occDark = pow(0.98, surfCom - 6);
	//float occDark = 0.1;
	//float surfCom = 1.0 / d.y;
	//surfCom = 0.1;
	//dif = 1.0;
	
	dif *= clamp(occDark, 0.01, 1.0);
	

	if (d.x < length(lightPos - p)) dif *= 0.1;


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

	vec2 d = RayMarch(ro, rd);

	vec3 p = ro + rd * d.x;

	float dif = GetLight(p, d.y);

	vec3 n = GetNormal(p);

	vec3 hue = normalize(vec3(0.29, 0.9, 0.48));

	col = vec3(dif);

	if (d.y > MAX_STEPS - 1)

	{
		//col = normalize(hue + 1.2);
	}

	//col = GetNormal(p);
	FragColor = vec4(col, 1.0f);
}