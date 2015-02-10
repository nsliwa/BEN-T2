Team B.E.N. - Flipped Classroom2

Nicole Sliwa
Ender Barillas
Bre’Shard Busby

For thought:

1) It shouldn’t be a continuous line graph, it should be discretized bar graph. This is usually see with an equalizer. Colors should be changed depending on magnitude.

2) Simply change the constant values kEquilizerBufferLength and kChunkSize. The first constant is equal to the number of points on the graph and the second constant is equal to  floor((kBufferLength/2)/kEquilizerBufferLength)

3) It is not very complicated. We would have to create an AudioFileReader object. Instantiate it, giving it the path to the sound file, play the AudioFileReader object, then do setInputBlock, followed by the code to fill up the ringBuffer. Then the rest will take care of itself. To have the sound file actually playing, we would have to also make a setOutputBlock block. 

4) To make sure that the player is memory conscious and not constantly allocating and deallocating resources, especially in an application that you know is going to be mainly using that resource.