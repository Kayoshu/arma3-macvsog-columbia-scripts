class COLSOG {
	class Faces
	{
		file ="functions\player";
		class faces {};
	};
	class Triangulate
	{
		file ="functions\triangulate";
		// 1 will execute the function for each player downloading the mission.
		class triangulate {postInit = 1;};
	};
}