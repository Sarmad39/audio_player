import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audio_player/audio_player.dart';

class AudioPalyerScreen extends StatefulWidget {
  final File? file;
  final String? audioUrl;
  final String? assetAudio;
  const AudioPalyerScreen(
      {this.file, this.audioUrl, this.assetAudio, super.key});

  @override
  State<AudioPalyerScreen> createState() => _AudioPalyerScreenState();
}

class _AudioPalyerScreenState extends State<AudioPalyerScreen> {
  final audioplayer = AudioPlayer();
  String title = 'Current Audio';
  bool isMuted = false;
  bool isFirst = true;
  bool isPlaying = false;
  Duration _totalduration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isFirst) {
      setAudio().then((value) {
        isFirst = false;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    audioplayer.stop();
    audioplayer.dispose();
  }

  Source? _getsource() {
    if (widget.assetAudio != null) {
      title = widget.assetAudio.toString().split('/').last.split('.').first;
      return AssetSource(widget.assetAudio!);
    }
    if (widget.file != null) {
      title = widget.file!.path.split('/').last.split('.').first;
      return DeviceFileSource(widget.file!.path);
    }
    if (widget.audioUrl != null) {
      return UrlSource(widget.audioUrl.toString());
    }
  }

  Future<void> setAudio() async {
    audioplayer.setReleaseMode(ReleaseMode.loop);
    audioplayer.stop();
    final source = _getsource();
    await audioplayer.play(source!);
    setState(() {
      isPlaying = true;
    });
    audioplayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.playing;
      });
    });

    audioplayer.onDurationChanged.listen((event) {
      setState(() {
        _totalduration = event;
      });
    });

    audioplayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

  String _duration(Duration duration) {
    String twoDigiits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigiits(duration.inHours);
    final minutes = twoDigiits(duration.inMinutes.remainder(60));
    final seconds = twoDigiits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Image.network(
              "https://images.unsplash.com/photo-1484704849700-f032a568e944?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80"),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10,
          ),

          //progress bar

          Slider(
              min: 0,
              max: _totalduration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await audioplayer.seek(position);
              }),

          // current and total duration of audio

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_duration(position)),
              Text(_duration(_totalduration)),
            ],
          ),

          // controls to audio player)
          Row(
            children: [
              CircleAvatar(
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () async {
                    if (isPlaying) {
                      await audioplayer.pause();
                    } else {
                      await audioplayer.resume();
                    }
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              CircleAvatar(
                child: IconButton(
                  onPressed: () {
                    audioplayer.seek(position - const Duration(seconds: 5));
                  },
                  icon: const Icon(Icons.replay_5),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              CircleAvatar(
                child: IconButton(
                  onPressed: () {
                    audioplayer.seek(position + const Duration(seconds: 5));
                  },
                  icon: const Icon(Icons.forward_5),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              CircleAvatar(
                child: IconButton(
                    onPressed: () {
                      audioplayer.setVolume(isMuted ? 1 : 0);
                      setState(() {
                        isMuted = !isMuted;
                      });
                    },
                    icon: Icon(isMuted ? Icons.volume_mute : Icons.volume_up)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
