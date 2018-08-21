macro "spindle_kymo"{

open();
name=getInfo("image.filename");
path=File.directory;
open(path+"RoiSet.zip");
run("Split Channels");

n=roiManager("count");
for (i = 0; i < n; i++){
selectWindow("C2-"+name);
roiManager("Select",i);
run("Straighten...", "title=C2-"+name+" line=25");
}
run("Images to Stack", "method=[Copy (center)] name=Stack title=[] use");
saveAs("Tiff", path + "ps_25.tif");
selectWindow("C2-"+name);
close();

for (i = 0; i < n; i++){
selectWindow("C1-"+name);
roiManager("Select",i);
run("Straighten...", "title=C1-"+name+" line=25");
}
run("Images to Stack", "method=[Copy (center)] name=Stack title=[] use");
saveAs("Tiff", path + "ks_25.tif");
selectWindow("C1-"+name);
close();

run("Merge Channels...", "c2=ks_25.tif c6=ps_25.tif create");
saveAs("Tiff", path + "merge_25.tif");

getDimensions(width, height, channels, slices, frames);
run("Make Montage...", "columns=1 rows="+slices+" scale=1 increment=1 border=0 font=12");
saveAs("Tiff", path + "kymo_25.tif");
close();

run("Make Substack...", "channels=1-2 slices=1-"+slices+"-2");
saveAs("Tiff", path + "merge_25_20s.tif");
getDimensions(width, height, channels, slicesbis, framesbis);
run("Make Montage...", "columns=1 rows="+slicesbis+" scale=1 increment=1 border=0 font=12");
saveAs("Tiff", path + "kymo_25_20s.tif");
close();
close();

run("Canvas Size...", "width=161 height=15 position=Center");
saveAs("Tiff", path + "merge_15.tif");
run("Make Montage...", "columns=1 rows="+slices+" scale=1 increment=1 border=0 font=12");
saveAs("Tiff", path + "kymo_15.tif");
close();
close();

}
