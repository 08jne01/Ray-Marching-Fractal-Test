#include "Matrix.h"

glm::mat4 makeModelMatrix(glm::vec3 pos, glm::vec3 rot)

{
	glm::mat4 matrix(1.0);
	matrix = glm::translate(matrix, pos);
	matrix = glm::rotate(matrix, glm::radians(rot.x), { 1, 0, 0 });
	matrix = glm::rotate(matrix, glm::radians(rot.y), { 0, 1, 0 });
	matrix = glm::rotate(matrix, glm::radians(rot.z), { 0, 0, 1 });

	return matrix;
}

glm::mat4 makeTransMatrix(const Camera& camera)

{
	glm::mat4 matrix(1.0);
	matrix = glm::translate(matrix, camera.pos);
	return matrix;
}

glm::mat4 makeViewMatrix(const Camera& camera)

{
	glm::mat4 matrix(1.0);
	matrix = glm::rotate(matrix, glm::radians(camera.rot.z), { 0, 0, 1 });
	matrix = glm::rotate(matrix, glm::radians(camera.rot.y), { 0, 1, 0 });
	matrix = glm::rotate(matrix, glm::radians(camera.rot.x), { 1, 0, 0 });
	//matrix = glm::translate(matrix, camera.pos);
	return matrix;
}

glm::mat4 makeProjectionMatrix(int w, int h)

{
	float x = (float)w;
	float y = (float)h;
	float fov = glm::radians(90.0);
	//return glm::ortho(-1.0, 1.0, -1.0, 1.0);
	return glm::perspective(fov, x / y, 0.1f, 2000.0f);
}