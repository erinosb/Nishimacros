//////////////////////////////////////
///    SELECT YOUR PARAMETERS      ///
//////////////////////////////////////

// DATE:     Started JUNE 22, 2026
// AUTHOR:   Sam Zavislan
// SCRIPT:   260526_quantifyPMregion_SZP.ijm
// PURPOSE:  This script takes as input a folder of .dv microscopy imgage files. Files have 3 or 4 channels and multiple z-projections. 
//           This script then does the following:
//              - Creates a z-projection of a fixed number of slices (user input required to set a start slice for each image)
//              - Rotates the image (user input required)
//              - Cropped to a given rectangle size (user input required to place the rectangle)
// 	            - Color split 
//              - Brightness adjusted by user specified values or optimal values determined from the first image analyzed
//              - Color merge based on user parameters
//              - Scale bar added
//              - Saves .tif, .png, and inverted.png as output
//              - Writes a logfile for each run

// Please change this part to your input and output directories and desired contact sheet file name

// DIRECTORIES: Enter the input directory. This directory must have at least one R3D_D3D.dv files within it, preferably a set

// KLP-18 rep 1

inputDir="/Users/samzavislan/Desktop/test/new_quant_script/01_inputTest";
outputDir="/Users/samzavislan/Desktop/test/new_quant_script/03_output";

// Z-PROJECT: Specify how many z-slices will be selecte for z-projection. Default is 35:
zSliceDepth = 7;

// CHANNELS: How many channels do you have? Default is 4, but 3 can also work. Change this value to 3 if necessary:
channelNo=4;

// COLORS: Specify which channels will be merged into the final composite image.
// Channels are organized in fiji from left [1] to right [4]. 
// Possible channels are: channel1, channel2, channel3, channel4
// Possible colors are: red, green, blue, gray, cyan, magenta, yellow
// Select a channel by adding a color as a value; channels labeled "none" will not be included in the composite.
channel1 = "none";
channel2 = "magenta";
channel3 = "green";
channel4 = "blue";

// MAX/MIN Brightness - OPTIONAL: Set the channel max and min to adjust brightness if you like. Leave at 0 if you want it automatically determined. 
// Automatically determined brightness settings will determine min and max settings that yield a contrast of 0.35 in the first image
// All downstream images will use that same min and max channel setting. 

// Settings determined from first run auto contrast

ch1min = 0;
ch1max = 0;
ch2min = 1067.0039;
ch2max = 7052.6719;
ch3min = 839;
ch3max = 13017.7852;
ch4min = 720.9883;
ch4max = 5039.3008;

//////////////////////////////////////////////
///     PARAMETERS SELECTION COMPLETE      ///
//////////////////////////////////////////////





//////////////////////////////////////////////
///    	      FUNCION SECTION              ///
//////////////////////////////////////////////

// Function to assign the color selector code to the desired color:
function selectColor(channelcolor) {
    if (channelcolor == "red"){
    	colorselect = "c1";
    	return colorselect;
    } else if (channelcolor == "green"){
    	colorselect = "c2";
    	return colorselect;
    } else if (channelcolor == "blue"){
    	colorselect = "c3";
    	return colorselect;
    } else if (channelcolor == "gray"){
    	colorselect = "c4";
    	return colorselect;
    } else if (channelcolor == "cyan"){
    	colorselect = "c5";
    	return colorselect;
    } else if (channelcolor == "magenta"){
    	colorselect = "c6";
    	return colorselect;
    } else if (channelcolor == "yellow"){
    	colorselect = "c7";
    	return colorselect;
    } else {
    	return 0;
    }
}

function messageColorChoice(channelName, channelValue) {
	message="";
	if (channelValue != "none"){
		message= channelName + " will be included in the composite in " + channelValue;
	}   else {
		message="";
	}
	return message;
}

//////////////////////////////////////////////
///      FUNCION SECTION COMPLETE          ///
//////////////////////////////////////////////





//////////////////////////
///    START CODE      ///
//////////////////////////

// Initialize Logfile
print("\\Clear");

// Get todays date:
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
month = month + 1;
todaysDate = d2s(year, 0) + "-" + d2s(month, 0) + "-" + d2s(dayOfMonth, 0);
timeNow  = d2s(hour, 0) + d2s(minute, 0);

// Initialize logfile:
// Choose output directory
parentDir = File.getParent(inputDir);
folderName = File.getName(parentDir);
// Automatically append folder name to "for" + "_" +
logPath = inputDir + "/" + todaysDate + "_" + timeNow + "_" + "logfile" + "_" + "for" + "_" + folderName + ".txt";
// Automatically append folder name to "for" + "_" +
dataPath = inputDir + "/" + todaysDate + "_" + timeNow + "_" + "datafile" + "_" + "for" + "_" + folderName + ".txt";

// Record time
logfile = File.open(logPath);
print("Initiaiting macro: erm1_membrane_quantification_2cell");
File.append("Initiaiting macro: erm1_membrane_quantification_2cell", logPath);
print("\nDate: " + todaysDate);
print("Time: " + timeNow);
File.append("\nDate: " + todaysDate, logPath);
File.append("Time: " + timeNow, logPath);

// Create the output directory
File.makeDirectory(outputDir);

// set the working directory
File.setDefaultDir(inputDir);

// get the list of files in this directory
fileList = getFileList(inputDir);

// Record the input and output directory. 
print("\nInput Directory: " + inputDir);
print("Output Directory: " + outputDir + "\n");
File.append("\nInput Directory: " + inputDir, logPath);
File.append("Output Directory: " + outputDir + "\n", logPath);


// Record the parameters:
msg1=messageColorChoice("Channel 1", channel1);
if ( msg1 != "") {
	print(messageColorChoice("Channel 1", channel1));
	File.append(messageColorChoice("Channel 1", channel1), logPath);
}
msg2=messageColorChoice("Channel 2", channel2);
if ( msg2 != "") {
	print(messageColorChoice("Channel 2", channel2));
	File.append(messageColorChoice("Channel 2", channel2), logPath);
}
msg3=messageColorChoice("Channel 3", channel3);
if ( msg3 != "") {
	print(messageColorChoice("Channel 3", channel3));
	File.append(messageColorChoice("Channel 3", channel3), logPath);
}
msg4=messageColorChoice("Channel 4", channel4);
if ( msg4 != "") {
	print(messageColorChoice("Channel 4", channel4));
	File.append(messageColorChoice("Channel 4", channel4), logPath);
}

// restrict list to R3D_D3D.dv files
dv_array = newArray(0);

// Save .dv files in a dv_array:
for (i=0; i<fileList.length; i++) {
    if(endsWith(fileList[i], "R3D.dv"))
    {
    	dv_array = Array.concat(dv_array, fileList[i]);
    }
}

// Print the list of dv files to process:
print("\nWill process the following DV files:");
File.append("\nWill process the following DV files:", logPath);
for (i=0; i<dv_array.length; i++) {
    print("\t" + dv_array[i]);
    File.append("\t" + dv_array[i], logPath);
}

// cycle through the images in the directory
for (i=0; i<dv_array.length; i++) {
	
	// Get file name 
    full_dv = inputDir + "/" + dv_array[i];
    
    // Report 
    print("\nNow processing file:\t" + dv_array[i]);
    File.append("\nNow processing file:\t" + dv_array[i], logPath);
    
    // Open the .dv file
    run("Bio-Formats Importer", "open=full_dv");
    
    // set the zoom
    run("Set... ", "zoom=75 x=512 y=512");
    
    // Enhance the contrast
    run("Enhance Contrast", "saturated=0.35");
    Stack.setChannel(2);
    run("Enhance Contrast", "saturated=0.35");
    Stack.setChannel(3);
    run("Enhance Contrast", "saturated=0.35");
    if (channelNo == 4) {
    	Stack.setChannel(4);
    	run("Enhance Contrast", "saturated=0.35");
    }
    
    // Z project
    print("\t--Starting Z-projection");
    File.append("\t--Starting Z-projection", logPath);
    
    // Get Z slices
    getDimensions(width, height, channels, slices, frames);
    print("\t--There are " + slices + " slices");
    File.append("\t--There are " + slices + " slices", logPath);
    
    // Wait for user to determine a good Z-range:
    waitForUser("Action Required", "By default, 7 slices will be selected for Z-projection. \nPlease look through the image and select the middle slice. \nClick OK when ready.");
    
    // Create a dialog box for user input
    Dialog.create("Specify Z Projection Range");
    Dialog.addNumber("Start slice:", 1);
    Dialog.addString("Projection Method (e.g., Max, Average):", "Sum Slices");
    Dialog.show();

    // Get the user input values
    midSlice = Dialog.getNumber();
    startSlice = midSlice - 3;
    stopSlice = midSlice + 3;
    method = Dialog.getString();
    SliceDepth = stopSlice - startSlice;
    
    // Determine whether to take 35 slices or the maximum number of slices
    print("\t--Splice Depth is: " + zSliceDepth);
    File.append("\t--Splice Depth is: " + zSliceDepth, logPath);
    
    // Run the Z Project function with user-defined parameters
    run("Z Project...", "start=" + startSlice + " stop=" + stopSlice + " projection=[" + method + "]");

    // set the zoom
    run("Set... ", "zoom=75 x=512 y=512");
    
    // Report Z Projection
    print("\t--Z-projection complete from " + startSlice + " to " + stopSlice + " using " + method + " method.");
	File.append("\t--Z-projection complete from " + startSlice + " to " + stopSlice + " using " + method + " method.", logPath);
	
    // Set brightness - if this is the first run through the loop and no channel max/min are set, determin a max/min to use:
    // Set the max and min thresholds
    if (i == 0){
    	print("\t--Evaluating Min and Max Thresholds");
    	File.append("\t--Evaluating Min and Max Thresholds", logPath);
		if (channel2 != "none"){
    	    if (ch2min == 0){
    			Stack.setChannel(2);
    			run("Enhance Contrast", "saturated=0.35");
    			getMinAndMax(min, max);
    			ch2min = min;
    			print("\t--Setting ch2min:" + ch2min);
    			File.append("\t--Setting ch2min:" + ch2min, logPath);
    		}
    		if (ch2max == 0){
    			Stack.setChannel(2);
    			run("Enhance Contrast", "saturated=0.35");
    			getMinAndMax(min, max);
    			ch2max = max;
    			print("\t--Setting ch2max:" + ch2max);
    			File.append("\t--Setting ch2max:" + ch2max, logPath);
    		}
		}
		if (channel3 != "none"){
    	    if (ch3min == 0){
    			Stack.setChannel(3);
    			run("Enhance Contrast", "saturated=0.35");
    			getMinAndMax(min, max);
    			ch3min = min;
    			print("\t--Setting ch3min:" + ch3min);
    			File.append("\t--Setting ch3min:" + ch3min, logPath);
    		}
    		if (ch3max == 0){
    			Stack.setChannel(3);
    			run("Enhance Contrast", "saturated=0.35");
    			getMinAndMax(min, max);
    			ch3max = max;
    			print("\t--Setting ch3max:" + ch3max);
    			File.append("\t--Setting ch3max:" + ch3max, logPath);
    		}
		}
		if (channel4 != "none"){
    	    if (ch4min == 0){
    			Stack.setChannel(4);
    			run("Enhance Contrast", "saturated=0.35");
    			getMinAndMax(min, max);
    			ch4min = min;
    			print("\t--Setting ch4min:" + ch4min);
    			File.append("\t--Setting ch4min:" + ch4min, logPath);
    		}
    		if (ch4max == 0){
    			Stack.setChannel(4);
    			run("Enhance Contrast", "saturated=0.35");
    			getMinAndMax(min, max);
    			ch4max = max;
    			print("\t--Setting ch4max:" + ch4max);
    			File.append("\t--Setting ch4max:" + ch4max, logPath);
    		}
		}
	}
    

    // Set brightness in channel1
    Stack.setChannel(1);
    setMinAndMax(ch2min, ch2max);
    print("Note - channel1 settings must match Channel2 settings for max and min brightness");
    File.append("Note - channel1 settings must match Channel2 settings for max and min brightness", logPath);
    print("\t--Setting Channel1 min: " + ch2min);
	File.append("\t--Setting Channel1 min: " + ch2min, logPath);
    print("\t--Setting Channel1 max: " + ch2max);
	File.append("\t--Setting Channel1 max: " + ch2max, logPath);

    // Set brightness in channel2
    Stack.setChannel(2);
    setMinAndMax(ch2min, ch2max);
    print("\t--Setting Channel2 min: " + ch2min);
	File.append("\t--Setting Channel2 min: " + ch2min, logPath);
    print("\t--Setting Channe2 max: " + ch2max);
	File.append("\t--Setting Channe2 max: " + ch2max, logPath);
    
    // Determine AP axis from user-clicked anterior/posterior points
    // (image pixel data is never rotated - only the rectangle SELECTION is rotated,
    // so raw intensity values are preserved exactly, unaffected by interpolation)
    print("\t--Starting AP axis determination");  
    File.append("\t--Starting AP axis determination", logPath);
    
    // This whole block (point-clicking through rectangle placement) repeats until
    // the user confirms the rectangle looks right. Only this block redoes - Z-projection
    // and brightness settings above are NOT reset between redo attempts.
    apConfirmed = false;
    redoAttempt = 0;
    do {
    	redoAttempt = redoAttempt + 1;
    	if (redoAttempt > 1) {
    		print("\t--Redo attempt #" + redoAttempt + " for AP points/rectangle");
    		File.append("\t--Redo attempt #" + redoAttempt + " for AP points/rectangle", logPath);
    	}
    	
    	setTool("multipoint");
    	waitForUser("Action Required", "Using the Point tool, click ONCE on the anterior tip of the embryo, then ONCE on the posterior tip (2 points total, in that order). Click OK when both points are placed.");
    	
    	getSelectionCoordinates(apXpoints, apYpoints);
    	if (apXpoints.length != 2) {
    		exit("Expected exactly 2 points (anterior, posterior) but got " + apXpoints.length + ". Please re-run and place exactly 2 points.");
    	}
    	
    	anteriorX = apXpoints[0];
    	anteriorY = apYpoints[0];
    	posteriorX = apXpoints[1];
    	posteriorY = apYpoints[1];
    	
    	// Angle of the AP axis, for logging only (not used to build the rectangle below,
    	// which is built directly from the two clicked points via makeRotatedRectangle)
    	myangle = atan2(posteriorY - anteriorY, posteriorX - anteriorX) * 180 / PI;
    	
    	// Report angle and clicked points
    	print("\t--Anterior point: " + anteriorX + ", " + anteriorY);
    	File.append("\t--Anterior point: " + anteriorX + ", " + anteriorY, logPath);
    	print("\t--Posterior point: " + posteriorX + ", " + posteriorY);
    	File.append("\t--Posterior point: " + posteriorX + ", " + posteriorY, logPath);
    	print("\t--AP axis angle: " + myangle + " degrees (image pixel data not rotated)");
    	File.append("\t--AP axis angle: " + myangle + " degrees (image pixel data not rotated)", logPath);
    	
    	// Build a rotated rectangle SELECTION (not a rotated image) with the same
    	// dimensions as the original fixed rectangle (333 x 69), centered on the AP
    	// axis defined by the two clicked points. makeRotatedRectangle(x1,y1,x2,y2,width)
    	// takes a centerline from (x1,y1) to (x2,y2) as the rectangle's LONG axis, and
    	// 'width' as the perpendicular (short) dimension - so the centerline length
    	// must equal the original long dimension (333) and width must equal the
    	// original short dimension (69), regardless of how far apart the two clicked
    	// points actually are.
    	print("\t--Get Region of Interest (ROI) Selection"); 
    	File.append("\t--Get Region of Interest (ROI) Selection", logPath);
    	rectLength = 333; // long dimension, same as original rectangle width
    	rectThickness = 69; // short dimension, same as original rectangle height
    	
    	// Unit vector along the AP axis (from anterior to posterior)
    	apDeltaX = posteriorX - anteriorX;
    	apDeltaY = posteriorY - anteriorY;
    	apDist = sqrt(apDeltaX*apDeltaX + apDeltaY*apDeltaY);
    	apUnitX = apDeltaX / apDist;
    	apUnitY = apDeltaY / apDist;
    	
    	// Centerline of length rectLength, centered at the midpoint of the two clicked points,
    	// oriented along the AP axis
    	midX = (anteriorX + posteriorX) / 2;
    	midY = (anteriorY + posteriorY) / 2;
    	lineX1 = midX - (rectLength/2) * apUnitX;
    	lineY1 = midY - (rectLength/2) * apUnitY;
    	lineX2 = midX + (rectLength/2) * apUnitX;
    	lineY2 = midY + (rectLength/2) * apUnitY;
    	
    	makeRotatedRectangle(lineX1, lineY1, lineX2, lineY2, rectThickness);
    	waitForUser("Action Required", "Move the rotated rectangle to capture the membrane in the middle. Click OK to measure.");
    	
    	// Report selection bounds
    	// NOTE: getSelectionBounds returns the axis-aligned BOUNDING BOX of the rotated
    	// rectangle, not its true length/thickness. The rectangle's actual dimensions remain
    	// rectLength x rectThickness (333 x 69) regardless of rotation; bounding-box x/y/width/height
    	// below are logged for reference only and should not be interpreted as the rectangle's
    	// own dimensions when myangle is not a multiple of 90.
    	getSelectionBounds(x, y, width, height);
    	print("\t--Selection of ROI complete. Rectangle dimensions: " + rectLength + " x " + rectThickness + ", AP angle " + myangle + " degrees. Bounding box: " + x + ", " + y + ", " + width + ", " + height); 
    	File.append("\t--Selection of ROI complete. Rectangle dimensions: " + rectLength + " x " + rectThickness + ", AP angle " + myangle + " degrees. Bounding box: " + x + ", " + y + ", " + width + ", " + height, logPath);
    	
    	// Confirm before proceeding. "Cancel" exits the whole macro (getBoolean default
    	// behavior); "No" redoes the point-clicking and rectangle placement above;
    	// "Yes" continues on to saving/measurement below.
    	apConfirmed = getBoolean("Does the rectangle look correctly placed and oriented along the AP axis?", "Yes, continue", "No, redo points/rectangle");
    	if (!apConfirmed) {
    		print("\t--User requested redo of AP points/rectangle");
    		File.append("\t--User requested redo of AP points/rectangle", logPath);
    	}
    } while (!apConfirmed);
    

	// Save a .tif of the full image with the rotated ROI box drawn on it as an overlay.
	// run("Add Selection...") burns the rectangle into the image's overlay (does not
	// change pixel values). saveAs() renames the active window to match the saved
	// filename, so the original title is restored immediately after via rename(),
	// since the SUM_/MAX_/AVERAGE_ title is needed further down for Plot Profile.
	print("\t--Saving ROI overlay image (.tif)");
	File.append("\t--Saving ROI overlay image (.tif)", logPath);
	
	originalTitle = getTitle();
	run("Add Selection...");
	baseName = File.getNameWithoutExtension(dv_array[i]);
	tifOutPath = outputDir + "/" + baseName + "_ROI.tif";
	saveAs("Tiff", tifOutPath);
	rename(originalTitle);
	print("\t--Saved: " + tifOutPath);
	File.append("\t--Saved: " + tifOutPath, logPath);
	
	// Get values from Ch02
    print("\t--Select Channel 02"); 
    File.append("\t--Select Channel 02", logPath);
	Stack.setChannel(2);
	roiManager("Add");
	ch2RoiIndex = roiManager("count") - 1; // index of the rotated rectangle just added, valid regardless of how many ROIs have accumulated across loop iterations
	run("Plot Profile");
	
	xarray = newArray(0);
	yarray = newArray(0);
	Plot.getValues(xarray, yarray);
	
	buffer = "";

	// Now you can iterate over the arrays and save the data in the datafile
	//File.close(logfile);
	//datafile = File.open(dataPath);
	
	// Save distances if this is the first loop
	if (i == 0){
		buffer = "file\tchannel\t";
		for (j=0; j<xarray.length; j++) {
			buffer = buffer + xarray[j] + "\t";
		}
		File.append(buffer, dataPath);
	}
	
	// Save ch2 values
	buffer = "";
	buffer = dv_array[i] + "\tch2\t";
	for (j=0; j<yarray.length; j++) {
    	buffer = buffer + yarray[j] + "\t";
	}
	File.append(buffer, dataPath);

	// Close plot
	selectWindow(getTitle());
	close();
	
    print("\t--Select Channel 01"); 
    File.append("\t--Select Channel 01", logPath);
    
	if (method == "Sum Slices"){
		selectWindow("SUM_" + dv_array[i]);
	} else if ( method == "Max"){
		selectWindow("MAX_" + dv_array[i]);		
	} else if ( method == "Average"){
		selectWindow("AVERAGE_" + dv_array[i]);		
	}

	// Re-select the SAME rotated rectangle ROI used for Channel 2 (captured as
	// ch2RoiIndex above), rather than rebuilding from x,y,width,height, since those
	// are only the axis-aligned bounding box of the rotated rectangle and would NOT
	// reproduce the rotated selection if myangle is not a multiple of 90.
	// IMPORTANT: roiManager("Select", ...) restores the ROI's remembered stack
	// position - since this ROI was first added while Channel 2 was active, selecting
	// it silently switches the window back to Channel 2. Stack.setChannel(1) MUST run
	// AFTER this select (not before), or Plot Profile below ends up measuring Channel 2
	// again instead of Channel 1, producing a duplicate of the ch2 row in the datafile.
	roiManager("Select", ch2RoiIndex);
	Stack.setChannel(1);

	roiManager("Add");
	run("Plot Profile");

	ch1xarray = newArray(0);
	ch1yarray = newArray(0);
	Plot.getValues(ch1xarray, ch1yarray);
	
	buffer = "";

	// Save ch1 values
	buffer = "";
	buffer = dv_array[i] + "\tch1\t";
	for (j=0; j<ch1yarray.length; j++) {
    	buffer = buffer + ch1yarray[j] + "\t";
	}
	File.append(buffer, dataPath);

	// Close plot
	selectWindow(getTitle());
	close();
	
    // close files 
    selectWindow(dv_array[i]);
    close();
    
}

exit("end of script");

//////////////////////////
///    END CODE        ///
//////////////////////////
