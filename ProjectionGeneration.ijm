macro "mount_video"{

experiment = getDirectory("Choose Experiment");
list = getFileList(experiment);

Dialog.create("Mount Videos");
Dialog.addNumber("Number of Fluorescence Channels", 2);
Dialog.addNumber("Number of z slices", 4);
Dialog.addCheckbox("DIC frame ?", false);
Dialog.addChoice("Projection Type", newArray("Max Intensity", "Average"));
Dialog.addChoice("Treat Channel 1", newArray("None", "Bleach Correct", "Smooth"));
Dialog.addChoice("Treat Channel 2", newArray("None", "Bleach Correct", "Smooth"));
Dialog.addChoice("Merge", newArray("None","Raw Projections", "Treated Projections"));
Dialog.addChoice("Merge LUT1", newArray("Green","Magenta", "Cyan"));
Dialog.addChoice("Merge LUT2", newArray("Green","Magenta", "Cyan"));
Dialog.show();
nbChannels = Dialog.getNumber();
nbSlices = Dialog.getNumber();;
DIC=Dialog.getCheckbox();
ProjType = Dialog.getChoice();
Treat1 = Dialog.getChoice();;
Treat2 = Dialog.getChoice();;;
Merge = Dialog.getChoice();;;;
MergeLUT1 = Dialog.getChoice();;;;;
MergeLUT2 = Dialog.getChoice();;;;;;

function Treat(Choice,Channel) {
	if (Choice=="Bleach Correct"){
		run("Duplicate...", "duplicate");
		run("Bleach Correction", "correction=[Exponential Fit]");
		saveAs("Tiff", experiment + list[i] + "PROJ/" + name + Channel + ProjType + "BleachCorr" + ".tif");
	} else if (Choice=="Smooth"){
		run("Duplicate...", "duplicate");
		run("Smooth", "stack");
		saveAs("Tiff", experiment + list[i] + "PROJ/" + name + Channel + ProjType + "Smooth" + ".tif");
	} else{
	}
}

function DefineMergeLUT(Choice){
	if (Choice=="Green"){
		Ch="c2";
	} else if (Choice=="Magenta"){
		Ch="c6";
	} else {
		Ch="c5";
	}
	return Ch;
}
ch1=DefineMergeLUT(MergeLUT1);
ch2=DefineMergeLUT(MergeLUT2);
	

for (i = 0; i < list.length; i++){
	File.makeDirectory(experiment + list[i] + "PROJ/");
	run("Image Sequence...", "open=[" + experiment + list[i] + "Images brutes/" + "] number=[] starting=1 increment=1 scale=100 file=[] sort");
	name = substring(list[i],0,lastIndexOf(list[i],"/"));
	getDimensions(width, height, channels, slices, frames);

	if (DIC){
		times=slices/(1+nbChannels*nbSlices);
		run("Make Substack...", "delete slices="+ times*nbChannels*nbSlices+1 + "-" + slices);
		saveAs("Tiff", experiment + list[i] + "PROJ/" + name + "_trans.tif");
		run("Close");
	} else{
		times=slices/(nbChannels*nbSlices);
	}
	
	run("Grouped Z Project...", "projection=[" + ProjType + "] group=" + nbSlices);
	rename("PROJ");

	if (nbChannels==1){
		saveAs("Tiff", experiment + list[i] + "PROJ/" + name + ProjType + ".tif");
		Treat(Treat1,"Channel1");
	} else{
		run("Stack Splitter", "number=2");
		selectWindow("PROJ");
		close();
		selectWindow("stk_0001_PROJ");
		saveAs("Tiff", experiment + list[i] + "PROJ/" + name + "Channel1" + ProjType + ".tif");
		c1r = getTitle();
		c1t = getTitle();
		Treat(Treat1,"Channel1");
		c1t = getTitle();
		selectWindow("stk_0002_PROJ");
		saveAs("Tiff", experiment + list[i] + "PROJ/" + name + "Channel2" + ProjType + ".tif");
		c2r = getTitle();
		c2t = getTitle();
		Treat(Treat2,"Channel2");
		c2t = getTitle();
		
	}

	if (Merge=="Raw Projections"){
		run("Merge Channels...", ch1+"=["+c1r+"]"+ ch2+"=["+c2r+"]" + "create");
		selectWindow("Composite");
		saveAs("Tiff", experiment + list[i] + "PROJ/" + name + "_merge.tif");
	} else if (Merge=="Treated Projections"){
		run("Merge Channels...", ch1+"=["+c1t+"]"+ ch2+"=["+c2t+"]" + "create");
		selectWindow("Composite");
		saveAs("Tiff", experiment + list[i] + "PROJ/" + name + "_merge.tif");
	}
	
	run("Close All");
	

}
}
