action = 1;

while(action != 0){
labels = getTitle();
Stack.getStatistics(dummy, dummy, dummy, labelCount);
Stack.getDimensions(stackWidth, stackHeight, channels, slices, frames);
medianImage = replace(labels, "Sphere labels - ", "");
medianImage = replace(medianImage, ".tif", " - 5x5x5 median - 8 bit.tif");
open("E:\\Altan Lab\\Median Filtered Stacks (5x5x5)\\" + medianImage);
run("Merge Channels...", "c1=[" + labels + "] c4=[" + medianImage + "] create keep");
setTool(1);
waitForUser("Draw a circular selection within the middle of the estimated sphere");
getSelectionBounds(x, y, width, height);
radius = (width + height)/4;
xCentroid = x + radius;
yCentroid = y + radius;
Stack.getPosition(dummy, zCentroid, dummy);
action = getNumber("What action is needed - 0 = none, -1 = Remove, 1 = Add", 0);
close("Composite");
close(medianImage);

if(action == -1){
	selectWindow(labels);
	setSlice(zCentroid);
	labelID = getPixel(xCentroid, yCentroid);
	confirmDelete = getBoolean("Delete " + labelID + "?");
	if(confirmDelete){
		run("Macro...", "code=[if (v == " + labelID + ") v = 0;] stack");
		saveAs("Tiff", "E:\\Altan Lab\\Median Filtered Stacks (5x5x5)\\Results\\Edited Labels\\" + labels);
	}
}

if(action == 1){
	run("3D Draw Shape", "size=" + stackWidth + "," + stackHeight + "," + slices + " center=" + xCentroid + "," + yCentroid + "," + zCentroid + " radius=" + radius + "," + radius + "," + radius + " vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy=1.000 res_z=1.000 unit=pix value=65535 display=[New stack]");
	selectWindow("Shape3D");
	run("8-bit");
	run("Divide...", "value=255 stack");
	run("Multiply...", "value=" + labelCount + 1 + " stack");
	imageCalculator("Add create stack", labels,"Shape3D");
	Stack.getStatistics(dummy, dummy, dummy, newLabelCount);
	if(newLabelCount == labelCount + 1){
		close("Shape3D");
		close(labels);
		selectWindow("Result of " + labels);
		getLut(reds, greens, blues);
		reds[labelCount + 1] = 255;
		greens[labelCount + 1] = 255;
		blues[labelCount + 1] = 255;
		setLut(reds, greens, blues);
		saveAs("Tiff", "E:\\Altan Lab\\Median Filtered Stacks (5x5x5)\\Results\\Edited Labels\\" + labels);
	}
	else{
		close("Shape3D");
		close("Result of " + labels);
		selectWindow(labels);
		 exit("Sphere touches an existing sphere so it was not added to the label stack");
	}
}
}