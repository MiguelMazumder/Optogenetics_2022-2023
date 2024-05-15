# Project Overview
This project involves the development of an optical system to produce illumination patterns that activate split recombinases, thus creating light-responsive genetic switches. It combines optical hardware design, software development, and various molecular biology techniques to achieve its objectives.

## Components
1. Optical Hardware System

- Designed to produce specific spatial illumination patterns.
- Includes detailed setup and calibration procedures.
  
2. GUI Software

- Developed to optimize illumination patterns.
- Facilitates data analysis for prototype optimization.
- User-friendly interface for configuring and controlling the optical system.

3. Molecular Biology Techniques

- DNA Transfection: Detailed protocols for transfecting HEK cells.
- Cell Culture: Maintenance and preparation of HEK cells for experiments.
- Microscopy and Quantitative Image Analysis

4. Procedures for imaging GFP and analyzing TRITC data.
   
- Quantitative methods for image analysis to assess the effectiveness of the genetic switches.
  
5. Flow Cytometry

- Protocols for sample preparation and analysis using flow cytometry.
  
6. Performance Analysis

- Methods for evaluating the results of wet lab experiments.
- Criteria for assessing the performance of light-responsive genetic switches.
- 
### Getting Started
1. Setup Optical Hardware

- Follow the detailed setup guide to assemble and calibrate the optical hardware system.

2. Install GUI Software

- Download and install the software on your computer.
- Follow the user manual to configure the settings and optimize illumination patterns.
  
3. Prepare Biological Samples

- Transfect HEK cells with the required DNA constructs.
- Culture cells under appropriate conditions.
  
4. Conduct Experiments

- Use the optical system to produce illumination patterns on the transfected HEK cells.
- Perform microscopy to image GFP and analyze TRITC data.
- Utilize flow cytometry to analyze cell samples.
  
5. Data Analysis and Optimization

- Use the GUI software for data analysis.
- Optimize the illumination patterns based on the analysis results.
- Assess the performance of the genetic switches through quantitative analysis.
  
### Contact Information
For any questions or support, please contact Miguel Mazumder at miguelfm@bu.edu

### Acknowledgements
Special thanks to Dr. Kilstinger and Dr. Wong from the Boston University Wong Lab who assisted in the development and testing of this project.

This repository contains code to stitch images taken from the GEN5 Cytation Plate Reader. The code allows for image processing, well detection, stitching of images into a grid format, and subsequent pattern generation for illumination experiments.

## GEN5 Cytation Plate Reader Square Tile Stitching Code

Place the Python file directly in the desired folder to stitch images or specify the directory in the script.

### Parameters:
- `CUR_DIR`: Directory containing the images.
- `STITCH_DIR`: Directory where the stitched images will be saved.

## Code Overview

### Functions:
1. `findfiltersandwells(directory)`
   - **Description**: Finds wells and image filters in the directory based on the TIFF files present.
   - **Returns**: Unique wells and filters.

2. `load_stitch_images(unique_wells, filter_types, directory_files, stitch_directory, original_directory)`
   - **Description**: Loads and stitches images for each well and filter type.
   - **Returns**: Found images.

3. `find_images_with_type(dir_files, image_type, well_pos)`
   - **Description**: Finds all files that contain the specified image type and well position.

4. `stitch_images(curr_images)`
   - **Description**: Stitches images horizontally and in order.
   - **Returns**: Horizontal canvas, grid shape, and image shape.

5. `horizontal_2_grid(horizontal_stitch, grid_shape, img_shape)`
   - **Description**: Converts horizontal stitching to grid stitch.
   - **Returns**: Final grid image.

6. `switch_and_write(input_image, img_type, well_location, stitch_folder, original_folder)`
   - **Description**: Switches between stitch and original folder to write the TIFF file.

### Execution:
1. Change the directory to the current working directory.
2. List all files in the current directory.
3. Create a directory for stitched images if it doesn't exist, otherwise delete the existing one and create a new one.
4. Find wells and filters in the directory.
5. Load and stitch images for each well and filter type.
6. Write the stitched images to the specified directory.

## GEN5 Cytation Plate Pattern Generation

### Goals:
- Reduce pixels to the correct amount on a tablet (1920x1080).
- Allow for single plate or double plate (24 for now).
- Custom time slots for each well.
- Enable turning on certain parts again (e.g., photomasks).
- Add red and blue light alternatives.

### User Input:
- Parameters for image resolution.
- Well positions and start/stop times for illumination.

### Functions:
1. `base_img(pxX, pxY, rows, cols)`
   - **Description**: Sets up the base image for the specified well configuration.

2. `findoverlap(start_stop_times)`
   - **Description**: Finds the overlap of time to construct pattern frames.

3. `create_unique_frames(illuminate_overlap, well_position)`
   - **Description**: Creates unique frames based on overlap of illumination times.

4. `write_video(time_store, framerate, well, wellDiam, unique_frames, xval, yval)`
   - **Description**: Writes the video pattern based on the time store and frame rate.

5. `create_pattern(well, wellDiam, current_pattern, xval, yval)`
   - **Description**: Creates a pattern for the current illumination setup.

6. `userinput_temp()`
   - **Description**: Takes basic user input for illumination time durations and well locations.

7. `create_checkbox_figure(rows, cols)`
   - **Description**: Creates a checkbox grid for user input on well positions.

8. `saveCheckboxState(~, ~, checkboxes)`
   - **Description**: Saves the state of the checkboxes.

9. `mytemps(image_in)`
   - **Description**: Allows user to select and crop images for patterns.

## Notes:
- Ensure the required libraries (`os`, `numpy`, `tifffile`) are installed.
- Place the script in the directory with the images or specify the path in `CUR_DIR`.
- Adjust parameters as needed based on the specific setup.

## Example Usage

```python
CUR_DIR = r'path\to\your\directory'
