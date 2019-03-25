#pragma once
#include <glm/ext.hpp>
#include "Camera.h"


glm::mat4 makeModelMatrix(glm::vec3 pos, glm::vec3 rot);
glm::mat4 makeTransMatrix(const Camera& camera);
glm::mat4 makeViewMatrix(const Camera& camera);
glm::mat4 makeProjectionMatrix(int w, int h);