#pragma once
#include <glm/ext.hpp>

struct Triangle

{
	Triangle()

	{

	}

	glm::vec3 pos;
	glm::vec3 rot;
	glm::vec3 vel;

	unsigned int VAO;
	unsigned int VBO;
	unsigned int EBO;
};