import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class AudioPlayerBlock extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerBlock({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerBlockState createState() => _AudioPlayerBlockState();
}

class _AudioPlayerBlockState extends State<AudioPlayerBlock> {
  AudioPlayer audioPlayer = AudioPlayer();
  PlayerState audioPlayerState = PlayerState.stopped;
  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "00:00";
  bool isplaying = false;
  bool audioplayed = false;

  @override
  void initState() {
    super.initState();
    audioPlayer.onDurationChanged.listen((Duration d) {
      //get the duration of audio
      maxduration = d.inMilliseconds;
      setState(() {});
    });

    audioPlayer.onPositionChanged.listen((Duration p) {
      currentpos = p.inMilliseconds; //get the current position of playing audio

      //generating the duration label
      int shours = Duration(milliseconds: currentpos).inHours;
      int sminutes = Duration(milliseconds: currentpos).inMinutes;
      int sseconds = Duration(milliseconds: currentpos).inSeconds;

      int rhours = shours;
      int rminutes = sminutes - (shours * 60);
      int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

      currentpostlabel = "$rhours:$rminutes:$rseconds";

      setState(() {
        //refresh the UI
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  Future play() async {
    await audioPlayer.play(UrlSource(widget.audioUrl));
    setState(() {
      audioPlayerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      audioPlayerState = PlayerState.paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        IconButton(
          icon: Icon(audioPlayerState == PlayerState.playing
              ? Icons.pause
              : Icons.play_arrow),
          onPressed: () {
            if (audioPlayerState == PlayerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: ProgressBar(
          progress: Duration(milliseconds: currentpos),
          total: Duration(milliseconds: maxduration),
          onSeek: (duration) {
            audioPlayer.seek(duration);
          },
        ),
          ),
      ]),
    );
  }
}
