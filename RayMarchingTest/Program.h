#pragma once
#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <glm/ext.hpp>
#include "Matrix.h"
#include "Camera.h"
#include "EventHandler.h"
#include "BasicShader.h"

class Program

{
public:

	Program(int w, int h);
	int mainLoop();

	static void framebuffer_size_callback(GLFWwindow* window, int w, int h);
	static void key_callback(GLFWwindow* window, int button, int scancode, int action, int mods);
	static void cursor_position_callback(GLFWwindow* window, double xpos, double ypos);
	static void mouse_button_callback(GLFWwindow* window, int button, int action, int mods);


private:
	GLFWwindow* window;
	Camera camera;
	EventHandler eventHandler;
	int width, height;
};