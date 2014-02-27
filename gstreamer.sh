# These commands will let me wirelessly stream all sound output from
# my computer to another computer (such as a raspberry pi connected to my
# sound system).  
#
# For example, I can run the spotify app on my computer and hear sound throughi
# my room speakers without touching any wires!
#
# Gstreamer code comes from this page:
# http://stackoverflow.com/questions/14140893/gstreamer-stream-vorbis-encoded-audio-over-network

#
# Pre-requisite: you need another computer, such as a raspberry pi running
# Ubuntu.  This computer must be connected to an audio out.
#
# The other computer must run the `run_server` function
# Your computer then streams its audio out to that server via the command:
# do_while_streaming_audio <some arbitrary code>



get_or_create_null_sink() {
  # Get or or load a "No Sound Output" sink.
  # This function creates or returns a reference to a "Sound Output" that
  # mutes the computer's audio output (ie no speakers).
  new_sink="$(pacmd list-sinks \
        | grep null_sink -B 1 \
        | grep index | cut -f2 -d: |tr -d ' ')"
  if [ -z $new_sink ] ; then 
    pactl load-module module-null-sink sink_name=null_sink 1>&2
    new_sink="$(pacmd list-sinks \
          | grep null_sink -B 1 \
          | grep index | cut -f2 -d: |tr -d ' ')"
  fi
  echo $new_sink
}

unload_null_sink() {
  # this removes the "Sound Output" sink created by get_or_create_null_sink
  # On ubuntu, you can see the effect of this by navigating to the sound
  # control panel
  pactl unload-module module-null-sink
}

connect() {
  # Make a client tcp connection to the server,
  server_ip=$1
  server_port=$2

  gst-launch-0.10 pulsesrc device="null_sink.monitor" ! \
  audio/x-raw-int, endianness="(int)1234", \
    signed="(boolean)true", width="(int)16", \
    depth="(int)16", rate="(int)22000", channels="(int)1" ! \
  audioconvert ! \
  vorbisenc ! \
  oggmux max-delay=50 max-page-delay=50 ! \
  tcpclientsink host=$server_ip port=$server_port || (
  echo "Failed to connect" && return 1)
}

do_while_streaming_audio() {
  # 1. temporarily make the null sink the default (ie mute's computer's audio)
  # 2. stream audio going to the null sink to a tcp socket (to another computer)
  # 3. execute bash given by $@
  # 4. when done, replace default audio again
  server_ip=$([[ -z $SERVER_IP ]] && dig +short mopidy || echo $SERVER_IP)
  server_port=$([[ -z $SERVER_PORT ]] && echo 3000 || echo $SERVER_PORT)
  new_sink=$(get_or_create_null_sink)
  orig_sink=$(pacmd stat|grep -i "Default sink name:"|cut -f4- -d\ )

  trap "pacmd set-default-sink $orig_sink" EXIT
  pacmd set-default-sink $new_sink
  connect $server_ip $server_port || return 1
  $@
}

#do_while_streaming_audio spotify

# this runs on the server
run_server() {
  while true ; do
    gst-launch-0.10 tcpserversrc host=0.0.0.0 port=3000 \
      ! oggdemux \
      ! vorbisdec \
      ! audioconvert \
      ! audio/x-raw-int, endianness="(int)1234", \
        signed="(boolean)true", width="(int)16", \
        depth="(int)16", rate="(int)22000", channels="(int)1" \
      ! alsasink
  done
}
