pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- defy, a pcm boombox
-- by bikibird
-- thanks, @luchak and @packbat, for the sound advice
-- thanks, @gabe-8-bit, for help with the oscilloscope and testing
-- thanks, @laz, for testing
left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

function header()
	mode=@(buffer+12)  --playback mode 1 (pcm) or 2 (adpcm)
	visualizer=@(buffer+13)  
	title=chr(peek(buffer+14,50))
	memcpy( 0x0000, buffer+64, 8192 )
	ejected=false
	direction,new_sample, ad_index = 0, 0,0
	step=7
end
function play_pcm()
	if not pause then
		local defy_defy
		while stat(108)<1536 and stat(120) do
			receipt = serial(0x800, buffer, 512)
			defy_defy=chr(peek(buffer,12))
			if (defy_defy=="defydefy    ") then
				serial(0x800,buffer+512,8256-512)
				header()
				return
			end
			if (recording==true) update_audio_string(receipt)
			if (not ejected) serial(0x808,buffer,receipt)	
		end	

	end	
	if recording and not stat(120) and #audio_string > 0 then
		recording=false
		printh(escape_binary_str(audio_string),"@clip")
	end
end
function play_adpcm4()
	if not pause then
		local request
		local sample
		local defy_defy
		while stat(108)<1536 and stat(120) do
			receipt = serial(0x800, buffer, 256)
			defy_defy=chr(peek(buffer,12))
			if (defy_defy=="defydefy    ") then
				serial(0x800,buffer+256,8256-256)
				header()
				return
			end
			for i=0,receipt-1 do
				sample=@(buffer+i)
				if recording then
					if #audio_string < 32000 then
						audio_string..=chr(sample)
					else
						recording=false
						printh(escape_binary_str(audio_string),"@clip")
					end	
				end
				
				poke(audio_buffer+i*2,adpcm((sample&0xf0)>>>4,4),adpcm(sample&0x0f,4))
			end
			if (not ejected) serial(0x808,audio_buffer,receipt*2)	
		end	
	end	
	if recording and not stat(120) and #audio_string > 0 then
		recording=false
		printh(escape_binary_str(audio_string),"@clip")
	end
end
function play_adpcm3()
	if not pause then
		local request
		local sample
		local defy_defy
		local samples
		while stat(108)<1536 and stat(120) do
			receipt = serial(0x800, buffer, 170)
			defy_defy=chr(peek(buffer,12))
			if (defy_defy=="defydefy    ") then
				serial(0x800,buffer+170,8256-170)
				header()
				return
			end
			for i=0,receipt-1 do
				sample=@(buffer+i)
				if recording then
					if #audio_string < 32000 then
						audio_string..=chr(sample)
					else
						recording=false
						printh(escape_binary_str(audio_string),"@clip")
					end	
				end
				poke(audio_buffer+i*3, adpcm((sample>>>5)&0x07,3), adpcm((sample>>>2)&0x07,3), adpcm(sample&0x03,2,true))
			end
			if (not ejected) serial(0x808,audio_buffer,receipt*3)	
		end	
	end	
	if recording and not stat(120) and #audio_string > 0 then
		recording=false
		printh(escape_binary_str(audio_string),"@clip")
	end
end
function play_adpcm2()
	if not pause then
		local request
		local sample
		local defy_defy
		local samples
		while stat(108)<1536 and stat(120) do
			receipt = serial(0x800, buffer, 128)
			defy_defy=chr(peek(buffer,12))
			if (defy_defy=="defydefy    ") then
				serial(0x800,buffer+128,8256-128)
				header()
				return
			end
			for i=0,receipt-1 do
				sample=@(buffer+i)
				if recording then
					if #audio_string < 32000 then
						audio_string..=chr(sample)
					else
						recording=false
						printh(escape_binary_str(audio_string),"@clip")
					end	
				end
				poke(audio_buffer+i*4, adpcm((sample>>>6)&0x03,2), adpcm((sample>>>4)&0x03,2), adpcm((sample>>>2)&0x03,2),	adpcm(sample&0x03,2))
			end
			if (not ejected) serial(0x808,audio_buffer,receipt*4)	
		end	
	end	
	if recording and not stat(120) and #audio_string > 0 then
		recording=false
		printh(escape_binary_str(audio_string),"@clip")
	end
end
function play_adpcm1()
	if not pause then
		local request
		local sample
		local defy_defy
		local samples
		while stat(108)<1536 and stat(120) do
			receipt = serial(0x800, buffer, 64)
			defy_defy=chr(peek(buffer,12))
			if (defy_defy=="defydefy    ") then
				serial(0x800,buffer+64,8256-64)
				header()
				return
			end
			for i=0,receipt-1 do
				sample=@(buffer+i)
				if recording then
					if #audio_string < 32000 then
						audio_string..=chr(sample)
					else
						recording=false
						printh(escape_binary_str(audio_string),"@clip")
					end	
				end
				poke(audio_buffer+i*8, adpcm((sample>>>7)&1,1), adpcm((sample>>>6)&1,1), adpcm((sample>>>5)&1,1), adpcm((sample>>>4)&1,1), adpcm((sample>>>3)&1,1), adpcm((sample>>>2)&1,1), adpcm((sample>>>1)&1,1),adpcm(sample&1,1))
			end
			if (not ejected) serial(0x808,audio_buffer,receipt*8)	
		end	
	end	
	if recording and not stat(120) and #audio_string > 0 then
		recording=false
		printh(escape_binary_str(audio_string),"@clip")
	end
end

function record()  --add lossy vs lossless options
	audio_string=""
	recording=true
end
function escape_binary_str(s)  --https://www.lexaloffle.com/bbs/?tid=38692
	local out=""
	for i=1,#s do
	 local c  = sub(s,i,i)
	 local nc = ord(s,i+1)
	 local pr = (nc and nc>=48 and nc<=57) and "00" or ""
	 local v=c
	 if(c=="\"") v="\\\""
	 if(c=="\'") v="\\\'"
	 if(c=="\\") v="\\\\"
	 if(ord(c)==0) v="\\"..pr.."0"
	 if(ord(c)==10) v="\\n"
	 if(ord(c)==13) v="\\r"
	 out..= v	 
	end
	return out
end

function adpcm(sample,bits) --http://www.cs.columbia.edu/~hgs/audio/dvi/IMA_ADPCM.pdf, but adapted for 8 bit unsigned
	local index_table = {[0]=-1,-1,-1,-1,2,4,6,8,-1,-1,-1,-1,2,4,6,8}
	local step_table ={7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97, 107, 118,130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767}
	if bits >1 then	
		local delta=0
		local temp_step =step
		local sign = sample &(1<<(bits-1)) --hi bit of sample convert to 4 bit
		local magnitude =(sample & (sign-1))<<(4-bits)  -- convert sample to 4 bit
		sign <<=(4-bits) -- convert sign to 4 bit 8==negative 0== positive
		local mask = 4
		for i=1,3 do
			if (magnitude & mask >0) then
				delta+=temp_step
			end
			mask >>>= 1
			temp_step >>>= 1	
		end
		if sign> 0 then  -- negative magnitude
			if new_sample < -32768+delta then 
				new_sample = -32768
			else	
				new_sample-=delta
			end
		else  -- positive magnitude
			if new_sample >32767-delta then
				new_sample =32767
			else
				new_sample +=delta
			end
		end	
		ad_index += index_table[sign+magnitude]
	else --1-bit
		if sample==1 then  -- negative
			if new_sample < -32768+step then 
				new_sample = -32768
			else	
				new_sample-=step
			end
		else  -- positive 
			if new_sample >32767-step then
				new_sample =32767
			else
				new_sample +=step
			end
		end	
		if sample==direction then --if direction same, try larger step. if changed, try smaller step
			ad_index+=1
		else
			ad_index-=1
			direction =sample
		end	
	end	
	if ad_index < 1 then 
		ad_index = 1
	elseif (ad_index > #step_table) then
		ad_index = #step_table
	end	
	step = step_table[ad_index]
	return new_sample\256+128
end

function update_audio_string(receipt)
	if #audio_string < 32000 then
		for i=0,receipt-1 do
			audio_string..=chr(@(buffer+i))
		end
	else
		recording=false
		printh(escape_binary_str(audio_string),"@clip")
	end	
end	

visualizers=
{
	function() -- Wait for file
		cls()
		print ("\^pdrop defy file",10,50,11)
		print ("\^p     here",10,70,11)
		print ("https://bikibird.itch.io/defy",7,120,3)
	end,
	function() --Cover Art
		cls()
		spr(0,0,0,16,16)	
	end,
	function() --Oscillocope
		cls()
		for i=0,127 do
			cursamp=128-(peek(modes[mode].buffer+(i*4))/2)
			if i==0 then
				pset(i,cursamp,11)
			else
				line(i-1,prvsamp,i,cursamp,11)
				pset(i,cursamp,11)
			end
			prvsamp=cursamp
		end
	end,
	function() --Bubble
		local hi=@(modes[mode].buffer)
		local lo=hi
		local sample
		for i=2,183 do
			sample=@(modes[mode].buffer+i)
			if (sample>hi) hi=sample
			if (sample<lo) lo=sample 
		end
		local r=35+sqrt(hi-lo)
		cls()
		local rsquare=r*r
		local ysquare,newx
		local x,y=r,0
		local delta
		while (y<=x) do
			tline(63-x,63+y,63+x,63+y,1,16*y/r,7/x)
			tline(63-x,63-y,63+x,63-y,1,16*y/r,7/x)
			tline(63-y,63+x,63+y,63+x,1,16*x/r,7/y)
			tline(63-y,64-x,63+y,64-x,1,16*x/r,7/y)
			y+=1
			ysquare=y*y
			newx=x+1
			if (newx)*(newx)+(ysquare) <= rsquare then
				x=newx
			else
				if (x)*(x)+(ysquare) <= rsquare then
				else
					x-=1
				end   
			end
		end
	end
}
function _init()
	audio_buffer=0x8000
	buffer=0x8800
	pause=false
	mode=1
	previous=0
	audio_string=""
	index=0
	new_sample,ad_index = 0,0
	direction=1
	step = 7
	visualizer=1
	modes={{playback=play_pcm,buffer=buffer,format="8-bit"},{playback=play_adpcm4,buffer=audio_buffer,format="4-bit"},{playback=play_adpcm3,buffer=audio_buffer,format="2.6-bit"},{playback=play_adpcm2,buffer=audio_buffer,format="2-bit"},{playback=play_adpcm1,buffer=audio_buffer,format="1-bit"}}
	title="no title"
end	
_update=function()
	if btnp(fire1) then
		pause = not pause
	elseif btnp(fire2) then	
		record()
	elseif btnp(left)	then
		cls()
		visualizer-=1
		if (visualizer==1) visualizer=#visualizers
	elseif btnp(right) then
		cls()
		visualizer+=1
		if (visualizer>#visualizers) visualizer=2
	elseif btnp(up) then  -- eject
		visualizer=1
		ejected=true
		recording=false	
	elseif btnp(down) then
		meta = not meta
	end
	modes[mode].playback()
end
_draw=function()
	visualizers[visualizer]()
	if (pause and not ejected) print("\f8\#6paused",50,50)
	if (recording) print("\f8\#6recording",45,60)
	if meta then
		print ("\f8\#6"..modes[mode].format,0,0)
		print ("\f8\#6"..title,0,122)
	end
end
--[[	Defy auido string library (think of the binary string as a piece of audio tape,)
		defy_load"my audio string"  --clips are automatically assigned a number starting at 1.
		defy_cue(clip_number,start,endpoint,looping)  --start,endpiont, and looping are optional.
		defy_play_lossy() -- plays lossy clip 
		defy_play_lossless() -- plays lossless clip

		Typical use:
		function _init()
			defy_load"my audio string" --clip 1
			defy_load"another audio string" --clip 2
		end
		function _update()
			if (btnp(4)) then
				defy_cue(1)  -- cues clip 1 for play from beginning to end, no looping.
			end
			defy_play[4]() --plays cued 4-bit clip.  continuously call play in update function. 
			-- defy_play[8]() --plays cued 8-bit clip	
			-- defy_play[3]() --plays cued 2.6-bit clip	
			-- defy_play[2]() --plays cued 2-bit clip	
			-- defy_play[1]() --plays cued 1-bit clip	
		end
]]	
do  --defy audio string library by bikibird
	local buffer=0x8000  -- required all formats
	local clips={}  -- required all formats
	local cued  -- required all formats

	-- locals required for 4, 2.6, 2, and 1 bit formats below
	
	local step, new_sample, ad_index,c,direction 
	local index_table = {[0]=-1,-1,-1,-1,2,4,6,8,-1,-1,-1,-1,2,4,6,8} 
	local step_table ={7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97, 107, 118,130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767}
	local adpcm=function(sample,bits) --adapted from http://www.cs.columbia.edu/~hgs/audio/dvi/IMA_ADPCM.pdf
		if bits >1 then	
			local delta=0
			local temp_step =step
			local sign = sample &(1<<(bits-1)) --hi bit of sample convert to 4 bit
			local magnitude =(sample & (sign-1))<<(4-bits)  -- convert sample to 4 bit
			sign <<=(4-bits) -- convert sign to 4 bit 8==negative 0== positive
			local mask = 4
			for i=1,3 do
				if (magnitude & mask >0) then
					delta+=temp_step
				end
				mask >>>= 1
				temp_step >>>= 1	
			end
			if sign> 0 then  -- negative magnitude
				if new_sample < -32768+delta then 
					new_sample = -32768
				else	
					new_sample-=delta
				end
			else  -- positive magnitude
				if new_sample >32767-delta then
					new_sample =32767
				else
					new_sample +=delta
				end
			end	
			ad_index += index_table[sign+magnitude]
		else --1-bit
			if sample==1 then  -- negative
				if new_sample < -32768+step then 
					new_sample = -32768
				else	
					new_sample-=step
				end
			else  -- positive 
				if new_sample >32767-step then
					new_sample =32767
				else
					new_sample +=step
				end
			end	
			if sample==direction then --if direction same, try larger step. if changed, try smaller step
				ad_index+=1
			else
				ad_index-=1
				direction =sample
			end	
		end	
		if ad_index < 1 then 
			ad_index = 1
		elseif (ad_index > #step_table) then
			ad_index = #step_table
		end	
		step = step_table[ad_index]
		return new_sample\256+128
	end	
	defy_load=function(clip) -- required all formats
		add(clips,{clip=clip,start=1,endpoint=#clip, index=1, loop=false, done=false}) 
	end
	local cued=false -- required all formats
	defy_cue=function(clip_number,start,endpoint,looping)  --required all formats
		clips[clip_number].start=start or clips[clip_number].start
		clips[clip_number].index=clips[clip_number].start
		clips[clip_number].endpoint=endpoint or #clips[clip_number].clip
		clips[clip_number].loop=looping or false
		clips[clip_number].done=false
		step, new_sample, ad_index,delta,direction=7,0,0,0,0
		cued=clip_number
	end	
	defy_play=
	{	
		[8]=function()  -- 8 bit format
			if cued and not clips[cued].done then
				while stat(108)<1536 do
					for i=0,511 do
						poke (buffer+i,ord(clips[cued].clip,clips[cued].index))
						clips[cued].index+=1
						if (clips[cued].index>clips[cued].endpoint) then
							if (clips[cued].loop) then
								clips[cued].index=clips[cued].start
							else
								serial(0x808,buffer,i+1)
								clips[cued].done=true
								return
							end
						end
					end
					serial(0x808,buffer,512)
				end
			end
		end,
		[4]=function() -- 4 bit format
			if cued and not clips[cued].done then
				while stat(108)<1536 do
					for i=0,255 do
						c=ord(clips[cued].clip,clips[cued].index)
						poke (buffer+i*2,adpcm((c&0xf0)>>>4,4),adpcm(c&0x0f,4))
						clips[cued].index+=1
						if (clips[cued].index>clips[cued].endpoint) then
							if (clips[cued].loop) then
								clips[cued].index=clips[cued].start
							else
								serial(0x808,buffer,i+1)
								clips[cued].done=true
								return 
							end
						end
					end
					serial(0x808,buffer,512)
				end
			end
		end,
		[3]=function() -- 3 bit format
			if cued and not clips[cued].done then
				while stat(108)<1536 do
					for i=0,170 do
						c=ord(clips[cued].clip,clips[cued].index)
						poke(buffer+i*3, adpcm((c>>>5)&0x07,3), adpcm((c>>>2)&0x07,3), adpcm(c&0x03,2,true))
						clips[cued].index+=1
						if (clips[cued].index>clips[cued].endpoint) then
							if (clips[cued].loop) then
								clips[cued].index=clips[cued].start
							else
								serial(0x808,buffer,i+1)
								clips[cued].done=true
								return 
							end
						end
					end
					serial(0x808,buffer,510)
				end
			end
		end,
		[2]=function() -- 2 bit format
			if cued and not clips[cued].done then
				while stat(108)<1536 do
					for i=0,128 do
						c=ord(clips[cued].clip,clips[cued].index)
						poke(buffer+i*4, adpcm((c>>>6)&0x03,2), adpcm((c>>>4)&0x03,2), adpcm((c>>>2)&0x03,2), adpcm(c&0x03,2))
						clips[cued].index+=1
						if (clips[cued].index>clips[cued].endpoint) then
							if (clips[cued].loop) then
								clips[cued].index=clips[cued].start
							else
								serial(0x808,buffer,i+1)
								clips[cued].done=true
								return 
							end
						end
					end
					serial(0x808,buffer,512)
				end
			end
		end,
		[1]=function() -- 1 bit format
			if cued and not clips[cued].done then
				while stat(108)<1536 do
					for i=0,64 do
						c=ord(clips[cued].clip,clips[cued].index)
						poke(buffer+i*8, adpcm((c>>>7)&1,1), adpcm((c>>>6)&1,1), adpcm((c>>>5)&1,1), adpcm((c>>>4)&1,1), adpcm((c>>>3)&1,1), adpcm((c>>>2)&1,1), adpcm((c>>>1)&1,1),adpcm(c&1,1))
						clips[cued].index+=1
						if (clips[cued].index>clips[cued].endpoint) then
							if (clips[cued].loop) then
								clips[cued].index=clips[cued].start
							else
								serial(0x808,buffer,i+1)
								clips[cued].done=true
								return 
							end
						end
					end
					serial(0x808,buffer,512)
				end
			end
		end
	}	
	function eject()  -- required all formats
		clips[cued].done=true
	end
end
__map__
100102030405060708090a0b0c0d0e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
101112131415161718191a1b1c1d1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
202122232425262728292a2b2c2d2e2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
303132333435363738393a3b3c3d3e3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404142434445464748494a4b4c4d4e4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505152535455565758595a5b5c5d5e5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606162636465666768696a6b6c6d6e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
707172737475767778797a7b7c7d7e7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
808182838485868788898a8b8c8d8e8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
909192939495969798999a9b9c9d9e9f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7a8a9aaabacadaeaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b8b9babbbcbdbebf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c4c5c6c7c8c9cacbcccdcecf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d4d5d6d7d8d9dadbdcdddedf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1e2e3e4e5e6e7e8e9eaebecedeeef00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00000000000000000000000000000
00b000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000b00000000000000000000000000000
00b000000000000000b0000000000000000000000000000000000000000000000000000b00000000000000000000000000b00000000000000000000000000000
00b000000000b00000b0000000000000000000000000b00000000000000000000000000b00000000000000000000000000bb0000000000000000000000000000
00bb00000000b00000b0000000b000000000b0000000b00000b00000000000000000000b00000000000000000000000000bb0000000000000000000000000000
00bb000000b0b00000b0000000b000000000b0000000b00000b00000000000000000000b000000000000000000b0000000bb00000000000000b0000000000000
0b0bb00000b0b00000b0000000b0b0000000b0000000b00000b00000000000000000000b000000b00000000000b0b00000bb00000000000000b0000000000000
0b0bb0000bb0b0000bb0000000b0b0b00000b0000000b00000b000b0000000000000000b00000bb00000000000bbb00000bb0000000b000000b0000000000000
0b0bb0000bb0b0000bb0000000b0b0b00000b0000000b00000b000b0000000000000000b00b00bb00000000000bbb00000bb0000000b000000bb000b00b00000
0b0bb0000bbbb0000bb000000bb0b0b00000b0000000b00000b000b00000b0000000000b00bb0bb0000000b000bbb00000bb000000bb000b0b0b000b00b00000
0b0bb000b00bb0000b0b00000b0bb0b000b0b0000000b00000bb00b00000b00000b000bb00bb0b0b000000b000b0b0000b0b000000bb000b0b0b000b00b00000
0b0bb000b00bb0000b0b00000b0bb0b000bbb000000bb00000bb00b00000b00000b0b0bb00bb0b0b000000b000b00b000b0b000000bb000b0b0b00bb00b00000
0b00b000b00bb0000b0b00000b0bb0b000bbb000000bb0b000bbb0b00000b00000bbb0bb00bbb00b00b00bb000b00b000b0b000000bb00bb0b0b00bb00bb0000
0b00b000b00bb0000b0bb0000b0bb0b00bbbb000000b0bb000bbb0b000b0b00000bb0bb0b0b0b00b00b00b0b00b00b000b0b000000bb00bb0b0b00bb00bb0000
0b00b0b0b00bb0000b0bb0b00b0bb0b00b0bb000000b0bb00b0bb0b000b0b00000bb0bb0b0b0b00b00bb0b0b00b00b0b0b00b00b00bb00bb0b0b00bb0b0b000b
bb00b0bb0000b0b0b00bb0b00b00b0b00b0bb000000b0bb00b00b0b000b0b00000b00bb0b0b0b00b00bb0b0b0b000b0b0b00b00b00b0bb0b0b0b00b0bb0b000b
0000b0bb0000b0b0b00bb0b0b0000bb00b0bb00000bb0bb00b00b0bb00b0b0000b0000b0b0b0000b00bb0b0b0b0000bb0b00b00b00b0bb0b0b00b0b0bb0b000b
00000bbb0000b0b0b00bb0b0b0000bb00b0bb00000bb0bb00b00bb0b0bbbb0000b0000b0bb00000b00bb0b0b0b00000b0b00b0bb00b0bb0b0b00bb00bb0b00b0
00000bbb00000bb0b00bb0bbb0000b0b0b000b0000b00b0b0b00bb0b0bbb0b000b000000bb00000b00b0b000bb00000b0b00b0bb0b00bb00bb00bb00bb0b00b0
00000bb000000bbbb000b0bbb0000b0b0b000bb000b00b0b0b00bb0b0b0b0bb00b000000bb00000b0b00b000bb00000b0b00b0bb0b00b000b000bb00bb0b00b0
00000bb000000bbb0000b0bb00000b0bb0000bb000b00b0b0b000b0b0b0b0bbb0b000000bb000000bb00b000bb00000b0b00bb0b0b00b000b000bb00b00b00b0
00000b0000000bbb0000b0b000000b0bb0000bb000b00b0b0b000b0b0b0b0bbb0b000000bb000000bb000000bb000000bb00bb00bb00b000b000b0000000bb00
00000b0000000bb00000b0b000000b0bb0000bbb0b000b0b0b000b0b0b0b0bbb0b000000bb000000bb0000000b000000bb00b000bb000000b00000000000bb00
00000b0000000bb00000b0b000000b0bb0000bbb0b00000b0b000b0b0b0b0b0b0b0000000b000000bb0000000b000000b0000000bb000000b00000000000bb00
00000b0000000b0000000bb000000b0bb0000bbb0b00000b0b000b0b0b000b0b0b0000000b000000bb00000000000000b0000000bb000000b00000000000bb00
00000b0000000b0000000b0000000b0bb0000b0b0b00000b0b000b0bb0000b00b000000000000000bb00000000000000b0000000bb000000b00000000000b000
00000b0000000b0000000b000000000bb0000b0b0b000000bb000b0bb0000b00b0000000000000000000000000000000b0000000b0000000b000000000000000
00000b0000000b0000000b000000000b00000b0b0b000000b0000000b0000000b000000000000000000000000000000000000000000000000000000000000000
0000000000000b0000000b000000000b00000b0b0b000000b0000000b0000000b000000000000000000000000000000000000000000000000000000000000000
0000000000000b0000000b000000000000000b00bb000000b0000000b00000000000000000000000000000000000000000000000000000000000000000000000
0000000000000b0000000b000000000000000b00bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000b0000000b000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000b000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000b000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000