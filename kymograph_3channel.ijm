//n_wKymo
// Tt makes a kymograph of a line with width using Max Intensity
//
// - Make a  line, choose the width
// - Run the macro
//

//id = getImageID();
//title = getTitle();

getLine(x1,y1,x2,y2,lineWidth)
xx1 = minOf(x1,x2);
yy1 = minOf(y1,y2);
width = abs(x2-x1);
height = abs(y2-y1);

roiManager("Add");
numROI = roiManager("Count");

//roiManager("Select", numROI - 1);

n=nSlices
//makeRectangle(xx1, yy1, width, height);
run("Duplicate...", "title=dummy duplicate channels=1-3 slices=n");
run("Split Channels");
selectWindow("C1-dummy");
roiManager("Select", numROI - 1);
run("Straighten...", "process");
run("Reslice [/]...", "output=1.000 start=Top avoid");
run("Z Project...", "projection=[Average Intensity]");
//
selectWindow("C2-dummy");
roiManager("Select", numROI - 1);
run("Straighten...", "process");
run("Reslice [/]...", "output=1.000 start=Top avoid");
run("Z Project...", "projection=[Average Intensity]");

selectWindow("C3-dummy");
roiManager("Select", numROI - 1);
run("Straighten...", "process");
run("Reslice [/]...", "output=1.000 start=Top avoid");
run("Z Project...", "projection=[Average Intensity]");

run("Merge Channels...", "c1=C1-dummy c2=C2-dummy c3=C3-dummy create");
run("Merge Channels...", "c1=[AVG_Reslice of C1-dummy-1] c2=[AVG_Reslice of C2-dummy-1] c3=[AVG_Reslice of C3-dummy-1] create ");
selectWindow("Composite");
run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");
selectWindow("C3-dummy-1");
close();
selectWindow("C2-dummy-1");
close();
selectWindow("C1-dummy-1");
close();
//run("Merge Channels...", "c1=C1-Composite-1.tif c5=C2-Composite-1.tif create");
selectWindow("Reslice of C1-dummy-1");
close();
selectWindow("Reslice of C2-dummy-1");
close();
selectWindow("Reslice of C3-dummy-1");
close();
