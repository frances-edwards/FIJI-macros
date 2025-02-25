macro "mount_images"{

//Get the directory to work in, list all nd files, and make output directory.

	experiment = getDirectory("Choose A File");
	list_files = getFileList(experiment);
	list_nd_files=newArray();
	for (i = 0; i<list_files.length; i++){
		string=list_files[i];
		if (indexOf(string, ".nd") >= 0){
			list_nd_files=Array.concat(list_nd_files,string);
		}
	}
	File.makeDirectory(experiment+"MountedImages");

//Initialise channel info from first nd file, in case LUT choices are the same for all nd files.

	base=substring(list_nd_files[0],0,indexOf(list_nd_files[0],".",0))+"_";
	print(base);
	sublist_files=newArray();
	for (j = 0; j<list_files.length; j++){
		string=list_files[j];
		if (indexOf(string, base) >= 0){
			sublist_files=Array.concat(sublist_files,string);
		}
	}

	channels_first=newArray("Channels");
	for (k = 0; k<sublist_files.length; k++){
		structure=substring(sublist_files[k],lengthOf(base),indexOf(sublist_files[k],".",0));
		structure=split(structure,"_");
		channels_first=Array.concat(channels_first,"_"+structure[0]);
	}
	if (channels_first.length>2){
		channels_first=Array.slice(channels_first,1);
		Array.sort(channels_first);
		unique_channels_first=Array.concat("Channels",channels_first[0]);
		for (l = 1; l<channels_first.length; l++){
			if (channels_first[l]!=channels_first[l-1]){
				unique_channels_first=Array.concat(unique_channels_first,channels_first[l]);
			}
		}
	} else if (channels_first.length==2){
		unique_channels_first=channels_first;
	}

//Ask about choices of LUTs and Projections.

	Dialog.create("Mount Images");
	Dialog.addChoice("LUT Decisions", newArray("I don't care about the LUTs", "I want to choose the LUTs for each nd file", "I want to choose the LUTs once and have it apply to all nd files"));
	Dialog.addChoice("Projection Decisions", newArray("I want to decide about projections for each nd file", "I want to decide about projections once and have it apply to all nd files"));
	Dialog.show();
	LUT_decision=Dialog.getChoice();
	PROJ_decision=Dialog.getChoice();

//Dialog box in case choices apply to all nd files.

	if (LUT_decision=="I don't care about the LUTs"){
		LUTs=1;
		if (PROJ_decision=="I want to decide about projections once and have it apply to all nd files"){
			PROJs=true;
			Dialog.create("Projection Choice");
			Dialog.addCheckbox("Save Projections ?", true);
			Dialog.show();
			Proj=Dialog.getCheckbox();
		} else {
			PROJs=false;
		}
	} else if (LUT_decision=="I want to choose the LUTs once and have it apply to all nd files"){
		LUTs=2;
		if (PROJ_decision=="I want to decide about projections once and have it apply to all nd files"){
			PROJs=true;
			Dialog.create("Choices");
			if (unique_channels_first.length>1){
				for (c = 1; c<unique_channels_first.length; c++){
					Dialog.addChoice("LUT"+c, newArray("Yellow","Magenta", "Cyan","Grays","Red","Green","Blue"));
				} 
			} else {
				Dialog.addChoice("LUT", newArray("Yellow","Magenta", "Cyan","Grays","Red","Green","Blue"));
			}
			Dialog.addCheckbox("Save Projections ?", true);
			Dialog.show();
			Proj=Dialog.getCheckbox();
			LUT_Choice=newArray();
			if (unique_channels_first.length>1){
				for (c = 1; c<unique_channels_first.length; c++){
					LUT_Choice=Array.concat(LUT_Choice,Dialog.getChoice());
				}
			} else {
				LUT_Choice=Array.concat(LUT_Choice,Dialog.getChoice());	
			}
		} else {
			PROJs=false;
			Dialog.create("Choices");
			if (unique_channels_first.length>1){
				for (c = 1; c<unique_channels_first.length; c++){
					Dialog.addChoice("LUT"+c, newArray("Yellow","Magenta", "Cyan","Grays","Red","Green","Blue"));
				} 
			} else {
				Dialog.addChoice("LUT", newArray("Yellow","Magenta", "Cyan","Grays","Red","Green","Blue"));
			}
			Dialog.show();
			LUT_Choice=newArray();
			if (unique_channels_first.length>1){
				for (c = 1; c<unique_channels_first.length; c++){
					LUT_Choice=Array.concat(LUT_Choice,Dialog.getChoice());
				}
			} else {
				LUT_Choice=Array.concat(LUT_Choice,Dialog.getChoice());	
			}
		}
	} else {
		LUTs=3;
		if (PROJ_decision=="I want to decide about projections once and have it apply to all nd files"){
			PROJs=true;
			Dialog.create("Choices");
			Dialog.addCheckbox("Save Projections ?", true);
			Dialog.show();
			Proj=Dialog.getCheckbox();	
		} else {
			PROJs=false;
		}
	}

//Start mounting images, 1 nd file at a time.
		
	for (i = 0; i<list_nd_files.length; i++){
		base=substring(list_nd_files[i],0,indexOf(list_nd_files[i],".",0))+"_";
		print(base);
		sublist_files=newArray();
		for (j = 0; j<list_files.length; j++){
			string=list_files[j];
			if (indexOf(string, base) >= 0){
				sublist_files=Array.concat(sublist_files,string);
			}
		}

		//Get nd file information.
		
		channels=newArray("Channels");
		positions=newArray("Positions");
		timepoints=newArray("Timepoints");
		for (k = 0; k<sublist_files.length; k++){
			structure=substring(sublist_files[k],lengthOf(base),indexOf(sublist_files[k],".",0));
			structure=split(structure,"_");
			if (structure.length==1){
				channels=Array.concat(channels,"_"+structure[0]);
			} else if (structure.length==2){
				channels=Array.concat(channels,"_"+structure[0]);
				positions=Array.concat(positions,"_"+structure[1]);
			} else if (structure.length==3){
				channels=Array.concat(channels,"_"+structure[0]);
				positions=Array.concat(positions,"_"+structure[1]);
				timepoints=Array.concat(timepoints,"_"+structure[2]);
			}
		}

		//Get nd file channel information.
		
		if (channels.length>2){
			channels=Array.slice(channels,1);
			Array.sort(channels);
			unique_channels=Array.concat("Channels",channels[0]);
			for (l = 1; l<channels.length; l++){
				if (channels[l]!=channels[l-1]){
					unique_channels=Array.concat(unique_channels,channels[l]);
				}
			}
			if (unique_channels.length<3){
				unique_channels=newArray("1Channel");
			}
		} else {
			unique_channels=newArray("1Channel");
		}

		//dialog boxes in case some decisions are made for each nd file.

		if (LUTs==3) {
			if (PROJs==false) {
				Dialog.create(base);
					if (unique_channels.length>1){
						for (c = 1; c<unique_channels.length; c++){
							Dialog.addChoice("LUT"+c, newArray("Yellow","Magenta", "Cyan","Grays","Red","Green","Blue"));
						} 
					} else {
						Dialog.addChoice("LUT", newArray("Yellow","Magenta", "Cyan","Grays","Red","Green","Blue"));
					}
				Dialog.addCheckbox("Save Projections ?", true);
				Dialog.show();
				Proj=Dialog.getCheckbox();
				LUT_Choice=newArray();
				if (unique_channels.length>1){
					for (c = 1; c<unique_channels.length; c++){
						LUT_Choice=Array.concat(LUT_Choice,Dialog.getChoice());
					}
				} else {
					LUT_Choice=Array.concat(LUT_Choice,Dialog.getChoice());	
				}
			} else {
				Dialog.create(base);
				if (unique_channels.length>1){
					for (c = 1; c<unique_channels.length; c++){
						Dialog.addChoice("LUT"+c, newArray("Yellow","Magenta", "Cyan","Grays","Red","Green","Blue"));
					} 
				} else {
					Dialog.addChoice("LUT", newArray("Yellow","Magenta", "Cyan","Grays","Red","Green","Blue"));
				}
				Dialog.show();
				LUT_Choice=newArray();
				if (unique_channels.length>1){
					for (c = 1; c<unique_channels.length; c++){
						LUT_Choice=Array.concat(LUT_Choice,Dialog.getChoice());
					}
				} else {
					LUT_Choice=Array.concat(LUT_Choice,Dialog.getChoice());	
				}
			}
		} else {
			if (PROJs==false) {
				Dialog.create(base);
				Dialog.addCheckbox("Save Projections ?", true);
				Dialog.show();
				Proj=Dialog.getCheckbox();
			}
		}

		//Get nd file position and timepoint information.
		
		if (positions.length>2){
			positions=Array.slice(positions,1);
			Array.sort(positions);
			unique_positions=Array.concat("Positions",positions[0]);
			for (l = 1; l<positions.length; l++){
				if (positions[l]!=positions[l-1]){
					unique_positions=Array.concat(unique_positions,positions[l]);
				}
			}
			if (unique_positions.length<3){
				unique_positions=newArray("1Position");
			}
		} else {
			unique_positions=newArray("1Position");
		}
		
		if (timepoints.length>2){
			timepoints=Array.slice(timepoints,1);
			Array.sort(timepoints);
			unique_timepoints=Array.concat("Timepoints",timepoints[0]);
			for (l = 1; l<timepoints.length; l++){
				if (timepoints[l]!=timepoints[l-1]){
					unique_timepoints=Array.concat(unique_timepoints,timepoints[l]);
				}
			}
			if (unique_timepoints.length<3){
				unique_timepoints=newArray("1Timepoint");
			}
		} else {
			unique_timepoints=newArray("1Timepoint");
		}

		//Transform nd file information into strings that can be inserted in Fiji commands.

		if (unique_channels.length==1){
			channel_info=newArray("_"+structure[0]);
		} else {
			channel_info=Array.slice(unique_channels,1);
			merge_choice=newArray("*None*","*None*","*None*","*None*","*None*","*None*","*None*");
			for (w = 0; w<channel_info.length; w++){
				merge_choice[w]=channel_info[w];
			}
		}
		
		if (unique_positions.length==1){
			position_info=newArray("");
		} else {
			position_info=Array.slice(unique_positions,1);
		}
		
		if (unique_timepoints.length==1){
			timepoint_info=1;
		} else {
			timepoint_info=unique_timepoints.length-1;
		}

		//Start mounting images.
		
		
		for (p = 0; p<position_info.length; p++){
			zslices=newArray();
			print(position_info[p]);
			

			//open different channels
			
			for (c = 0; c<channel_info.length; c++){
				channel_info_use=substring(channel_info[c],1);
				run("Image Sequence...", "open=[" + experiment + "] number="+timepoint_info+" file=["+base+channel_info_use+position_info[p]+"] sort");
				rename(channel_info[c]);
				selectWindow(channel_info[c]);
				getDimensions(width,height,chan,slices,frames);
				run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices="+slices/timepoint_info+" frames="+timepoint_info+" display=Color");
				selectWindow(channel_info[c]);
				getDimensions(width,height,chan,slices,frames);
				zslices=Array.concat(zslices,slices);
			}
			unique_zslices=Array.concat(newArray(),zslices[0]);
			for (z = 1; z<zslices.length; z++){
				if (zslices[z]!=zslices[z-1]){
					unique_zslices=Array.concat(unique_zslices,zslices[z]);
				}
			}
			
			if (unique_zslices.length==1){

				//For positions whose channels have same number of zslices.
				
				if (channel_info.length>1){
					run("Merge Channels...", "c1=["+merge_choice[0]+"] c2=["+merge_choice[1]+"] c3=["+merge_choice[2]+"] c4=["+merge_choice[3]+"] c5=["+merge_choice[4]+"] c6=["+merge_choice[5]+"] c7=["+merge_choice[6]+"]" + " create");
					for (w = 0; w<channel_info.length; w++){
						Stack.setChannel(w+1);
						if (LUTs!=1){
							run(LUT_Choice[w]);
						}
					}
					saveAs("Tiff", experiment +"MountedImages/" + "hyperstack_"+base + position_info[p]+ ".tif");
				}
				else {
					for (w = 0; w<channel_info.length; w++){
						Stack.setChannel(w+1);
						if (LUTs!=1){
							run(LUT_Choice[w]);
						}
					}
					saveAs("Tiff", experiment +"MountedImages/" +base + position_info[p]+ ".tif");
				}

				
				if (Proj==1){
					if (slices>1){
						run("Z Project...", "projection=[Max Intensity] all");
						for (y=0; y<channel_info.length; y++){
							Stack.setChannel(y+1);
							resetMinAndMax();
						}
						saveAs("Tiff", experiment +"MountedImages/" + "MAXprojection_"+base + position_info[p]+ ".tif");
						close();
						close();
					} else if (channel_info.length>1) {
						saveAs("Tiff", experiment +"MountedImages/" + "composite_"+base + position_info[p]+ ".tif");
						close();
					} else {
						close();
					}
				} else {
					close();
				}


			} else {

				//For positions whose channels have different number of zslices.
				
				for (c = 0; c<channel_info.length; c++){
					selectWindow(channel_info[c]);
					getDimensions(width,height,chan,slices,frames);
					if (slices>1){
						run("Z Project...", "projection=[Max Intensity] all");
						resetMinAndMax();
						selectWindow(channel_info[c]);
						close();
						rename(channel_info[c]);
					}
				}
				
				if (channel_info.length>1){
					run("Merge Channels...", "c1=["+merge_choice[0]+"] c2=["+merge_choice[1]+"] c3=["+merge_choice[2]+"] c4=["+merge_choice[3]+"] c5=["+merge_choice[4]+"] c6=["+merge_choice[5]+"] c7=["+merge_choice[6]+"] create");
					for (w = 0; w<channel_info.length; w++){
						Stack.setChannel(w+1);
						if (LUTs!=1){
							run(LUT_Choice[w]);
						}
					}	
				}
				saveAs("Tiff", experiment + "MountedImages/" + "MAXprojection_"+base + position_info[p]+ ".tif");
				close();
				
			}
			
		}
			
	}
}