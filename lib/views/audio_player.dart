import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class AudioPlayerBlock extends StatefulWidget {
  final String audioUrl;

   const AudioPlayerBlock({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerBlockState createState() => _AudioPlayerBlockState();
}

class _AudioPlayerBlockState extends State<AudioPlayerBlock> {
  AudioPlayer audioPlayer = AudioPlayer();
  PlayerState audioPlayerState = PlayerState.stopped;

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
    return  Center(
        child: IconButton(
          icon: Icon(audioPlayerState == PlayerState.playing ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            if (audioPlayerState == PlayerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
      );
  }
}
