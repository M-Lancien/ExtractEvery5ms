######################################################
# extract_acoustic_every5ms.praat
# v4
# This script extracts 
# - F0
# - Intensity
# - HNR
# - Formants 1 to 4
# Every 5ms
#
# Author:  Mélanie Lancien 09-2022
######################################################

form Extract_acoustic_parameters
	text textgrids_folder C:\Users\33665\sniffle\buckeye\TextGrid
	text wavefiles_folder C:\Users\33665\sniffle\buckeye\wav
	text regexp_for_filtering_files *.wav
	text results_file C:\Users\33665\sniffle\buckeye\
	#comment Index of the tier with labels to be processed
	#positive reference_tier 2
	#comment Index of the other interval tier from which labels should be extracted (0 = none, -1 = all interval tiers)
	#integer secondary_tier -1
	boolean Extract_F0 1
	boolean Extract_HNR 1
	boolean Extract_intensity 1
	boolean Extract_formants 1
	boolean Extract_CoG 1
	boolean Extract_VoiceReport 1
	#boolean Extract_left_and_right_context 0
	#comment Extract values every X s
	real extract_values_every 0.005
	#comment Speakers gender (used to parameterize formants extraction)
	optionmenu speakers_gender: 1
	option F
	option M
	#positive offset_for_acoustic_parameters_extraction_milliseconds 5
endform

# Clear info window
clearinfo

 

# Get the list of wav in the specified folder that match the regular expression
flist = Create Strings as file list: "filelist", "'wavefiles_folder$'/'regexp_for_filtering_files$'"
nfiles = Get number of strings

 

# The rest of the results file header will be written only when processing the first textgrid
header_written = 0
 



# Loop every selected textgrid
for ifile to nfiles
	# Get its name, display it in 'info' windows and read it
	selectObject: flist
	sound$ = Get string: ifile
	appendInfoLine: "Processing file ", sound$, "..."
	current_sound = Read from file: "'wavefiles_folder$'/'sound$'"
	
	filename$=results_file$+sound$-".wav"+".txt"

	# Write the results file header
	writeFile: filename$, "name_file", tab$, "start_time", tab$, "end_time"
	#if extract_left_and_right_context
	#	appendFile: results_file$, tab$, "previousLabel", tab$, "followingLabel"
	#endif
	#appendFile: filename$, newline$
	if extract_F0
		appendFile:filename$, tab$, "mean_F0(Hz)"
	 
	endif
	if extract_HNR
		appendFile: filename$, tab$, "mean_HNR(dB)" 
	 
	endif
	if extract_intensity
		appendFile: filename$, tab$, "mean_intensity(dB)" 
	 
	endif
	if extract_formants
		appendFile: filename$, tab$, "mean_F1(Hz)"
		appendFile: filename$, tab$, "mean_F2(Hz)" 
		appendFile: filename$, tab$, "mean_F3(Hz)" 
		appendFile: filename$, tab$, "mean_F4(Hz)" 
	 
	
	if extract_VoiceReport
		appendFile: filename$, tab$, "Jitter", tab$, "Shimmer"
	endif

	if extract_CoG
		appendFile:filename$, tab$, "CoG", tab$, "Kurtosis", "Skweness"





	 
	endif

	#appendFile: results_file$, sound$, tab$
	selectObject: current_sound 
	sound_lenght = Get total duration
	start_sound = Get start time
	#start_sound= start_sound + 0.005
	appendInfoLine: sound_lenght 
	 
	
	repeat
	#start_sound = Get start time
	
	end_time=start_sound + extract_values_every
	#Extract part: start_sound, end_time, "rectangular", 1, "yes"
	#part_name = selected("Sound")
	#select 'part_name'
	#current_sound =  part_name
	 
	appendFile: filename$, newline$, sound$, tab$
	 
	
	#appendInfoLine: end_time
	appendFile: filename$, start_sound , tab$, end_time
	
	selectObject: current_sound 
	current_pitch = To Pitch: 0.025, 50, 400
	mean_f0 = Get value at time: end_time, "Hertz","Linear"
	appendFile: filename$, tab$, mean_f0
		
	#removeObject: current_pitch
	 

	selectObject: current_sound 	 
	current_HNR = To Harmonicity (cc): 0.005, 50, 0.1, 1
 	mean_HNR = Get value at time: end_time, "cubic"
	appendFile: filename$, tab$, mean_HNR
		
	removeObject: current_HNR
 

	 
	selectObject: current_sound 
	current_intensity = To Intensity: 100, 0, "yes"
	mean_intensity=Get value at time: end_time, "cubic"						            
	#mean_intensity = Get value at time: end_time, "dB"
	appendFile: filename$, tab$, mean_intensity
	
	removeObject: current_intensity
 
	

	 
	selectObject: current_sound 
		if (speakers_gender$ = "M")
		current_formant = To Formant (burg): 0, 5, 5000, 0.025, 50
		else
		current_formant = To Formant (burg): 0, 5, 5500, 0.025, 50
		endif
		mean_f1 =  Get value at time... 1 end_time Hertz Linear
		appendFile: filename$, tab$, mean_f1
			
		mean_f2 = Get value at time... 2 end_time Hertz Linear
		appendFile: filename$, tab$, mean_f2
			
						
		mean_f3 = Get value at time... 3 end_time Hertz Linear
		appendFile: filename$, tab$, mean_f3

						
		mean_f4 = Get value at time... 4 end_time Hertz Linear
		appendFile: filename$, tab$, mean_f4

		endif
			
	
		removeObject: current_formant


################################ Voice report : in progress
		
 		selectObject: current_sound
		plusObject: current_pitch
		current_pointproc =  To PointProcess (cc)
		#selectObject: current_sound
		#plusObject: current_pitch
		#plusObject: current_pointproc   
 		#voiceReport$ = Voice report: start_sound,end_time , 75, 500, 1.3, 1.6, 0.03, 0.45
		 

################################ COG, 

################################ spectral tilt : nothing done yet

###################################################################################################

start_sound=start_sound+extract_values_every
#appendInfoLine: start_sound
end_time=end_time+extract_values_every
#appendInfoLine: end_time

 
until end_time>sound_lenght

appendInfoLine: "end"
 
endfor
