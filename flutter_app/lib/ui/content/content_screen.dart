import 'package:allena/ui/dashboard/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ContentScreen extends StatefulWidget {
  final DashboardModel item;

  const ContentScreen(this.item, {super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/dash_vids/${widget.item.videoName}')
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {
              _controller?.play();
            });
          });
    _controller?.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _controller?.value.isInitialized == true
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
          child: Text(
            widget.item.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Card(
          margin: EdgeInsetsGeometry.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.item.desc,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
