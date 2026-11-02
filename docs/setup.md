# Capture and observation notes

## Record the game and its audio

These notes describe the setup used for the recorded session. The JSON in `config/` is a reference, not an importable OBS scene collection.

1. Create a dedicated OBS profile and scene collection for the game.
2. Set the canvas and output to 1280 x 720, 30 fps.
3. Disable global desktop audio and microphone inputs.
4. Add one Game Capture source, set it to capture a specific window, and select Balatro.
5. Enable that source's application audio capture. Turn cursor capture off.
6. Fit the game image to the canvas and inspect the preview. The window title bar, desktop, and recording controls should be outside the captured image.
7. Record to MKV using the H.264 encoder available on the machine and stereo AAC. The session used OBS NVENC, quality `Small`, preset `p1`.
8. Start recording before play and stop after the result screen. This run used no time limit.

Keep the active game in front while playing. The recording application can stay behind it.

## Observe and act

Use the supported computer-use interface in its persistent session. Bind the intended game window, read a fresh screenshot, choose the move, and send the input through the supported tool. Re-read the screen after the game has responded.

Deterministic clicks selecting cards from the same visible hand can be batched. A new hand or a changed window requires a fresh observation. Animation frames are not a settled hand.

### What went wrong in this session

Native screenshots initially showed old Balatro frames in Borderless mode. Looking at the recording preview confirmed that the game itself had advanced. A temporary helper extracted recent images from the active MKV, but its buffering delay made decisions slower.

Changing Balatro to Windowed mode made subsequent direct native screenshots update correctly in this session. Rebind the game window after changing display mode, because the operating-system window identifier can change. This is an observed workaround, not a general diagnosis of every screenshot problem.

The fallback frame helper deliberately seeks roughly eight seconds behind the recording's creation time, with an additional three-second wait. It requires an actively growing MKV and a recording folder containing the current take. It does not verify that an extracted image reflects the latest click. Check the visible response before making another decision.

### Encoding note

The session's installed FFmpeg build could not use NVENC because its required API version exceeded the installed GPU driver's version. OBS recording with NVENC succeeded separately. The phone-copy utility therefore uses the software `libx264` encoder with four threads.

## Reproduction limits

- This is a single tutorial-seed run, not a random-seed performance evaluation.
- The scripts handle media processing. They do not select Balatro cards or control the game.
- The repository does not include a standalone gameplay agent or the installed computer-use runtime.
- The 2:33:08 recording includes setup, slow early play, shopping, and capture troubleshooting. No model-speed benchmark was conducted.
- The phone copy uses reduced resolution, frame rate, and audio bitrate. The original-quality MP4 is available in the same release as two binary parts.
