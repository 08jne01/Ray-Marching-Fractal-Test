#include "Camera.h"

Camera::Camera(): pos(0.0), rot(0.0), vel(0.0), angVel(0.0), rotSpeed(0.1), speed(0.1)

{

}

void Camera::cameraTranslate()

{
	glm::mat4 matrix(1.0);
	matrix = glm::rotate(matrix, glm::radians(-rot.z), { 0, 0, 1 });
	matrix = glm::rotate(matrix, glm::radians(-rot.y), { 0, 1, 0 });
	matrix = glm::rotate(matrix, glm::radians(-rot.x), { 1, 0, 0 });

	glm::vec4 vec = matrix * glm::vec4(vel, 1.0);
	pos = { pos.x - speed * vec.x, pos.y - speed * vec.y, pos.z + speed * vec.z };
}

void Camera::cameraRotate()

{
	rot = { rot.x + angVel.x, rot.y + angVel.y, rot.z + angVel.z };
}

void Camera::setVel(int coord, double val)

{
	vel[coord] = val;
}

void Camera::setAngVel(double cursx, double cursy)

{
	glm::vec3 newRot = { rotSpeed*(cursy - defCursY), rotSpeed*(cursx - defCursX), 0.0 };
	//glm::vec3 newRot = {0.1, 0.0, 0.0};
	rot += newRot;
	defCursX = cursx;
	defCursY = cursy;
}

void Camera::update()

{
	cameraTranslate();
	cameraRotate();
}