# AudioRecorder
Record audio only when you are talking

1. Simple iOS application, that records audio from microphone to file. 
- Application have Start/Stop recording buttons.
- Audio file should be WAVE.
2. Implemented "smart sound recognition": 
- automatically start listening to audio stream from microphone on launch, and recognize the relatively loud sequence (some phrase), and save only the part of audio stream that has the phrase. (without silence before and after a phrase).
3. Add waveform audio visualisation using 3-rd party EZAudio open source framework.
