#pragma once
#include "Triangle.h"
#include "Camera.h"

class TriangleRenderer

{
public:
	TriangleRenderer(unsigned int shadeprog, Camera& camera);
	void makeBuffers(Triangle t);
	void updateBuffers(Triangle t);
	void setShader(unsigned int shadeprog);
	void setUniforms(Triangle t);
};