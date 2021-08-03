# ECG-Waveform-Generator

This generator uses bezier curves in GODOT to create values suitable for driving a 10bit or 12bit Digital to Analog converter.

The curve of a PATH2D is tesselated to create an array of XY coordinates.
The missing points are filled to provide a timebase compatible array of coordinates
Y values can be exported in Natural and Inverted forms
The inverted form is also available scaled as an export for use with 10 or 12bit DAC

1: Install GODOT https://godotengine.org/ - min v3.3.2

2: Open project.godot

3: Select "Raw" PATH2d

4: Adjust waveform as required
![image](https://user-images.githubusercontent.com/40808238/127966193-b73fbec6-ef26-4798-9af8-db5c38c0bd9b.png)
5: Run the "ECG_Generator" node with F5 or Play button

6: Verify content
![image](https://user-images.githubusercontent.com/40808238/127967087-0b4547f4-1fee-42ff-a722-d32454e0a650.png)
7: Export Y values
