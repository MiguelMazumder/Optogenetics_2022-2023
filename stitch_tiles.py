"""
GEN5 Cytation Plate Reader Square Tile Stitching Code by Migi Mazumder
"""
import os
import numpy as np
import tifffile as tf
'''Place python file directly in desired folder to stitch images or specify directory down below'''
#CUR_DIR = os.getcwd() already correct file just continue from here (i.e press play)
CUR_DIR = r'C:\Users\17038\Downloads\Temp_downloads\redlight_stitches_2ndcontrol'
os.chdir(CUR_DIR)
ALL_FILES = os.listdir(CUR_DIR)
STITCH_DIR = CUR_DIR + r'\\Stitches'
# Check if the folder already exists
if os.path.exists(STITCH_DIR):
    print(f" {STITCH_DIR} already exists\n")
else:
    os.makedirs(STITCH_DIR)
    print(f"Created '{STITCH_DIR}' successfully\n")
def findfiltersandwells(directory):
    '''Find wells and image filters in directory based off tif files present'''
    tif_files = [file for file in os.listdir(directory) if file.lower().endswith('.tif')]
    well_locs = []
    imaging_filters = []
    for tif_file in tif_files:
        file_name = os.path.splitext(tif_file)[0]  # Remove the file extension
        name_parts = file_name.split('_') # Split the file name based on underscores
        well_locs.append(name_parts[0]) # Append 1st string that contains well location
        imaging_filters.append(name_parts[4]) # Append 4th string that contains image filter type
    unique_wells = set(well_locs)
    unique_filters = set(imaging_filters)
    return unique_wells, unique_filters
def load_stitch_images (unique_wells,filter_types,directory_files,stitch_directory,original_directory):
    '''Loop through available wells and filter types to find images and stitch together'''
    for well in unique_wells:
        for imagetype in filter_types:
            # Find images that match the filter type and well location
            foundimages=find_images_with_type(directory_files,imagetype,well)
            # Stitch found images into a horizontal tile canvas because python sucks and can't reshape properly
            horizontal_canvas,grid_shape,img_shape= stitch_images(foundimages)
            # Stitch horizontal tile canvas into a square tile canvas
            grid_image = horizontal_2_grid(horizontal_canvas,grid_shape,img_shape)
            # Write square stitch image to new tif file
            switch_and_write(grid_image,imagetype,well,stitch_directory,original_directory)
    return foundimages # Returns found images just for trouble shooting
def find_images_with_type(dir_files,image_type,well_pos):
    '''Append all files that contains image_type (TRITC, GFP, BF), for a specific well (well_pos)'''
    files_image_type = []
    # Loop through directory to find if it contains the image type and well position
    for file_name in dir_files:
        if image_type in file_name and well_pos in file_name:
            files_image_type.append(file_name)
    return files_image_type
def stitch_images(curr_images):
    '''Stitch images horizontally and in order'''
    num_images = len(curr_images)
    square_shape = int(np.sqrt(num_images))
    dim_tile_array = tf.imread(curr_images[0])
    dim_img = dim_tile_array.shape[0]
    canvas = np.zeros(dim_tile_array.shape)
    split_array = [string.split('_') for string in curr_images]
    sorted_array = sorted(split_array, key=lambda x: int(x[3]))
    joined_data = ['_'.join(lst) for lst in sorted_array]
    for i in range(0,num_images):
        numpy_image = tf.imread(joined_data[i])
        if i==0:
            canvas=numpy_image
        else:
            canvas = np.hstack((canvas, numpy_image))
    return canvas,square_shape,dim_img
def horizontal_2_grid(horizontal_stitch,grid_shape,img_shape):
    '''convert horizontal stitching to grid stitch'''
    final_grid=np.zeros((grid_shape*img_shape,grid_shape*img_shape))
    for i in range(0,grid_shape):
        final_grid[i*img_shape:i*img_shape+img_shape,:]=horizontal_stitch[:,i*img_shape*grid_shape:i*img_shape*grid_shape+img_shape*grid_shape]
    int_final_grid = (np.rint(final_grid)).astype(int)
    return int_final_grid
def switch_and_write(input_image,img_type,well_location,stitch_folder,original_folder):
    '''Switch between stitch and original folder to write tif file'''
    os.chdir(stitch_folder)
    tf.imwrite(stitch_folder+r'\\'+well_location+'_'+img_type+'_stitch.tif', input_image)
    print(f"{well_location}_{img_type}_stitch.tif file written successfully.")
    os.chdir(original_folder)
[wells, filters] = findfiltersandwells(CUR_DIR)
found_images = load_stitch_images (wells,filters,ALL_FILES,STITCH_DIR,CUR_DIR)
