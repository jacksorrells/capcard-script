#!/bin/bash
# capcard test script

# state
inputFormat=mjpeg
videoSize=480x480
framerate=24
inputSource=/dev/video0
fileName=test
sourceFileName=test
destinationFileName=test

# presets
videoSizes=("480x480" "640x480" "720x720" "1280x720" "1080x1080" "1920x1080")
videoSizeCommands=("480s" "480p" "720s" "720p" "1080s" "1080p")
framerates=("24" "30" "60")

function getVideoSize {
    echo "Please select a video resolution: "
    for ((i = 0; i < ${#videoSizes[@]}; ++i)); do
        index=$(( $i + 1 ))
		echo "$index) ${videoSizes[$i]}"
	done
    read selection
    videoSize=${videoSizes[$selection-1]}
}

function setVideoSize {
    for ((i = 0; i < ${#videoSizeCommands[@]}; ++i)); do
        if [ $1 == ${videoSizeCommands[i]} ]; then
            videoSize=${videoSizes[i]}
        fi
    done
}

function getFramerate {
    echo "Please select a framerate: "
    for ((i = 0; i < ${#framerates[@]}; ++i)); do
        index=$(( $i + 1 ))
		echo "$index) ${framerates[$i]}"
	done
    read selection
    framerate=${framerates[$selection-1]}
}

function setFramerate {
    for ((i = 0; i < ${#framerates[@]}; ++i)); do
        if [ $1 == ${framerates[i]} ]; then
            framerate=${framerates[i]}
        fi
    done
}

function getFileName {
    echo "Please enter a filename: "
    read newFileName
    fileName=$newFileName
}

function getSourceFileName {
    echo "Please enter a source filename: "
    read newFileName
    sourceFileName=$newFileName
}

function getDestinationFileName {
    echo "Please enter a destination filename: "
    read newFileName
    destinationFileName=$newFileName
}

function checkDevices {
    v4l2-ctl --list-devices
}

function checkAudio {
    ffmpeg -sources pulse
}

function showVideo {
    if [ $1 ]; then
        setVideoSize $1
    else 
        getVideoSize
    fi
    
    ffplay -f v4l2 -input_format $inputFormat -video_size $videoSize -framerate $framerate -i $inputSource
}

function playAudio {
    ffplay -f pulse -j default
}

function captureVideo {
    if [ $1 ]; then
        setVideoSize $1
    else 
        getVideoSize
    fi
    
    if [ $2 ]; then
        filename = $2
    else
        getFileName
    fi
    
    
    ffmpeg -f v4l2 -thread_queue_size 1024 -input_format $inputFormat -video_size $videoSize -framerate $framerate -i $inputSource -codec copy "$fileName.avi"
}

function captureAV {
    if [ $1 ]; then
        setVideoSize $1
    else 
        getVideoSize
    fi
    
    if [ $2 ]; then
        filename = $2
    else
        getFileName
    fi
    
    
    ffmpeg -f v4l2 -thread_queue_size 1024 -input_format $inputFormat -video_size $videoSize -framerate $framerate -i $inputSource -f pulse -thread_queue_size 1024 -i default -codec copy "$fileName.avi"
}

function convertAviToMp4 {
    if [ $1 ]; then
        sourceFileName=$1
    else
        getSourceFileName
    fi
    
    if [ $2 ]; then
        destinationFileName=$2
    else
        getDestinationFileName
    fi

    ffmpeg -i $sourceFileName -c:v copy -c:a copy "${destinationFileName}-${videoSize}.mp4"
}

if [ $1 ]; then
	if [ $1 == "check-devices" ]; then
		checkDevices
	fi
    
    if [ $1 == "check-audio" ]; then
        checkAudio
    fi
	
	if [ $1 == "show-video" ]; then
        showVideo $2
	fi
    
    if [ $1 == "play-audio" ]; then
        playAudio
    fi
    
    if [ $1 == "capture-video" ]; then
        captureVideo $2 $3
    fi
    
    if [ $1 == "capture-av" ]; then
        captureAV $2 $3
    fi
    
    if [ $1 == "convert-avi" ]; then
        convertAviToMp4 $2 $3
    fi
    
	if [ $1 == "video-sizes" ]; then
        getVideoSize
	fi
    
    if [ $1 == "framerate" ]; then
        getFramerate
    fi
fi
