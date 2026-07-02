//////////////////////////////////////
///    SELECT YOUR PARAMETERS      ///
//////////////////////////////////////

// DATE:     Started May 27, 2026
// AUTHOR:   Erin Osborne Nishimura
// SCRIPT:   260527_quantifyNuclearMembraneRegion.ijm
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

// DIRECTORIES: Enter the input directory. 
//inputDir="/Volumes/NESS/260518_Ambika_Paper/01_FIJI_Quantification/01_N2/250806_set3_imb2_rep1";
//outputDir="/Volumes/NESS/260518_Ambika_Paper/01_FIJI_Quantification/01_N2/250806_set3_imb2_rep1/output";

//inputDir="/Volumes/NESS/260518_Ambika_Paper/01_FIJI_Quantification/01_N2/250806_set3_imb2_rep2";
//outputDir="/Volumes/NESS/260518_Ambika_Paper/01_FIJI_Quantification/01_N2/250806_set3_imb2_rep2/output";

//inputDir="/Volumes/NESS/260518_Ambika_Paper/01_FIJI_Quantification/01_N2/250807_set3_imb2_rep3";
//outputDir="/Volumes/NESS/260518_Ambika_Paper/01_FIJI_Quantification/01_N2/250807_set3_imb2_rep3/output";

inputDir="/Volumes/NESS/260518_Ambika_Paper/01_FIJI_Quantification/01_N2/260527_N2_imb2_set3";
outputDir="/Volumes/NESS/260518_Ambika_Paper/01_FIJI_Quantification/01_N2/260527_N2_imb2_set3/output";



// Z-PROJECT: Specify how many z-slices will be selected for z-projection. Default is 35:
zSliceDepth = 7;

// CHANNELS: How many channels do you have? Default is 4, but 3 can also work. Change this value to 3 if necessary:
channelNo=3;

// SAMPLES: Specify what is being measured in each channel
channel1_sample = "imb-2";
channel2_sample = "set-3";
channel3_sample = "";
channel4_sample = "";


// COLORS: Specify which channels will be merged into the final composite image.
// Channels are organized in fiji from left [1] to right [4]. 
// Possible channels are: channel1, channel2, channel3, channel4
// Possible colors are: red, green, blue, gray, cyan, magenta, yellow
// Select a channel by adding a color as a value; channels labeled "none" will not be included in the composite.
channel1 = "green";
channel2 = "magenta";
channel3 = "blue";
channel4 = "none";

// MAX/MIN Brightness - OPTIONAL: Set the channel max and min to adjust brightness if you like. Leave at 0 if you want it automatically determined. 
// Automatically determined brightness settings will determine min and max settings that yield a contrast of 0.35 in the first image
// All downstream images will use that same min and max channel setting. 
ch1min = 0;
ch1max = 0;
ch2min = 0;
ch2max = 0;
ch3min = 0;
ch3max = 0;
ch4min = 0;
ch4max = 0;

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
logPath = outputDir + "/" + todaysDate + "_" + timeNow + "_" + "logfile.txt";
dataPath = outputDir + "/" + todaysDate + "_" + timeNow + "_" + "datafile.txt";

// Create the output directory
File.makeDirectory(outputDir);

// set the working directory
File.setDefaultDir(inputDir);

// get the list of files in this directory
fileList = getFileList(inputDir);

// Record time
logfile = File.open(logPath);
print("Initiaiting macro: 260527_quantifyNuclearMembraneRegion.ijm");
File.append("Initiaiting macro: 260527_quantifyNuclearMembraneRegion.ijm", logPath);
print("\nDate: " + todaysDate);
print("Time: " + timeNow);
File.append("\nDate: " + todaysDate, logPath);
File.append("Time: " + timeNow, logPath);

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
    setMinAndMax(ch1min, ch1max);
    print("\t--Setting Channel1 min: " + ch1min);
	File.append("\t--Setting Channel1 min: " + ch1min, logPath);
    print("\t--Setting Channel1 max: " + ch1max);
	File.append("\t--Setting Channel1 max: " + ch1max, logPath);

    // Set brightness in channel2
    Stack.setChannel(2);
    setMinAndMax(ch2min, ch2max);
    print("\t--Setting Channel2 min: " + ch2min);
	File.append("\t--Setting Channel2 min: " + ch2min, logPath);
    print("\t--Setting Channe2 max: " + ch2max);
	File.append("\t--Setting Channe2 max: " + ch2max, logPath);
    
    // Rotate the image as per user specifications
    print("\t--Starting Rotation");  
    File.append("\t--Starting Rotation", logPath);
    
    waitForUser("Action Required", "Using the next dialog box, rotate the image so that anterior is to the left and posterior to the right. Click OK to begin.");
    run("Rotate... ");
    myangle = getValue("rotation.angle");
    
    // Report rotation
    print("\t--Rotation complete. Rotated by " + myangle + " angle");
	File.append("\t--Rotation complete. Rotated by " + myangle + " angle", logPath);
    
    // Set rectangle
    print("\t--Get Region of Interest (ROI) Selection"); 
    File.append("\t--Get Region of Interest (ROI) Selection", logPath);
	makeRectangle(323, 524, 117, 46);
	waitForUser("Action Required", "Move the rectangle to capture the membrane in the middle. Click OK to measure.");
	
	// Report selection bounds
	getSelectionBounds(x, y, width, height);
    print("\t--Selection of ROI complete with coordinates: " + x + ", " + y + ", " + width + ", " + height); 
    File.append("\t--Selection of ROI complete with coordinates: " + x + ", " + y + ", " + width + ", " + height, logPath);
	
	// Get values from Ch01
    print("\t--Select Channel 01"); 
    File.append("\t--Select Channel 01", logPath);
	Stack.setChannel(1);
	roiManager("Add");
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
		buffer = "file\tchannel\tsample\t";
		for (j=0; j<xarray.length; j++) {
			buffer = buffer + xarray[j] + "\t";
		}
		File.append(buffer, dataPath);
	}
	
	// Save ch1 values
    print("\t--Reporting Channel 01 values: " + channel1_sample); 
    File.append("\t--Reporting Channel 01 values: " + channel1_sample, logPath);
	buffer = "";
	buffer = dv_array[i] + "\tch1\t" + channel1_sample + "\t";
	for (j=0; j<xarray.length; j++) {
    	buffer = buffer + yarray[j] + "\t";
	}
	File.append(buffer, dataPath);

	// Close plot
	selectWindow(getTitle());
	close();
	
    print("\t--Select Channel 02"); 
    File.append("\t--Select Channel 02", logPath);
    
	if (method == "Sum Slices"){
		selectWindow("SUM_" + dv_array[i]);
	} else if ( method == "Max"){
		selectWindow("MAX_" + dv_array[i]);		
	} else if ( method == "Average"){
		selectWindow("AVERAGE_" + dv_array[i]);		
	}

	Stack.setChannel(2);
	makeRectangle(x, y, width, height);

	roiManager("Add");
	run("Plot Profile");

	ch2xarray = newArray(0);
	ch2yarray = newArray(0);
	Plot.getValues(ch2xarray, ch2yarray);
	
	buffer = "";

	// Save ch2 values
    print("\t--Reporting Channel 02 values: " + channel2_sample); 
    File.append("\t--Reporting Channel 02 values: " + channel2_sample, logPath);
	buffer = "";
	buffer = dv_array[i] + "\tch2\t" + channel2_sample + "\t";
	for (j=0; j<ch2yarray.length; j++) {
    	buffer = buffer + ch2yarray[j] + "\t";
	}
	File.append(buffer, dataPath);


    
   
    // close file
    close(dv_array[i]);

	// Close plot
	selectWindow(getTitle());
	close();
	
    // close files 
    //selectWindow(dv_array[i]);
    //close();
    
}

exit("end of script");

//////////////////////////
///    END CODE        ///
//////////////////////////
