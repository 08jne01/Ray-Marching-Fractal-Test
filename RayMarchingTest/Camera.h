#pragma once
#include <glm/ext.hpp>

class Camera

{
public:

	Camera();
	void cameraTranslate();
	void cameraRotate();
	void setVel(int coord, double val);
	void setAngVel(double cursx, double cursy);
	void update();

	float speed;
	glm::vec3 pos;
	glm::vec3 rot;
	glm::vec3 vel;
	glm::vec3 angVel;

private:
	

	float rotSpeed;
	double defCursX, defCursY;
};