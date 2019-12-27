#!/usr/bin/env python

# Import necessary libraries
import os, argparse, glob
from os.path import basename
import cv2
import numpy as np
from tqdm import tqdm

# resized images have 7700 pixels between fudicial points
# corners can be masked by a 350x350 section

# argument parser
def getArgs():

   parser = argparse.ArgumentParser(
    description = '''Find fudicial marks based upon hough transforms.''',
    epilog = '''post bug reports to the github repository''')
    
   parser.add_argument('-f',
                       '--files',
                       help = 'location of a file to process') 
    
   parser.add_argument('-d',
                       '--directory',
                       help = 'location of the data to match',
                       default = '/scratch/cobecore/aerial_photographs/png/path_4/')

   parser.add_argument('-o',
                       '--output_directory',
                       help = 'location where to store the data',
                       default = '/scratch/cobecore/aerial_photographs/auto_crop/path_4/')

   parser.add_argument('-c',
                       '--clahe',
                       help = 'apply CLAHE histogram normalization',
                       default = True)

   parser.add_argument('-w',
                       '--window',
                       help = 'CLAHE window size',
                       default = 32)
                       
   parser.add_argument('-m',
                       '--mask',
                       help = 'corner mask size, will return mask_file.png',
                       default = 350)                       

   parser.add_argument('-b',
                       '--border',
                       help = 'border to retain for evaluation, rest will be set to 0',
                       default = 1000)

   parser.add_argument('-s',
                       '--size',
                       help = 'resize value',
                       default = 7700)
                       
   parser.add_argument('-minr',
                       '--min_radius',
                       help = 'hough min radius value',
                       default = 5)
                       
   parser.add_argument('-maxr',
                       '--max_radius',
                       help = 'hough min radius value',
                       default = 11)
                       
   parser.add_argument('-sm',
                       '--smooth',
                       help = 'smoothing / bluring value',
                       default = 7)
   return parser.parse_args()

if __name__ == '__main__':

  # parse arguments
  args = getArgs()
  
  if args.files is not None:
   files = [args.files]
  else:
   # list image files to be processed
   files = sorted(glob.glob(args.directory + "*.png"))
  
  # loop over all files, align and subdivide and report progress
  with tqdm(total = len(files), dynamic_ncols=True) as pbar:
        for file in files:
                                
                # read in file to reference and crop
                img_orig = cv2.imread(file, 0)
                img = img_orig.copy()

                # if CLAHE is required execute
                if args.clahe == True:
                  clahe = cv2.createCLAHE(clipLimit=1.5,
                   tileGridSize=(args.window,args.window))
                  img_orig = clahe.apply(img_orig)
                                
                border = int(float(args.border) / img_orig.shape[0] * img.shape[0])                
                img[border:img.shape[0]-border,:] = 255
                img[:,border:img.shape[0]-border] = 255
                                
                # bump up contrast
                clahe = cv2.createCLAHE(clipLimit=2,
                   tileGridSize=(15,15))
                img = clahe.apply(img)
                
                # shrink for processing speed to a resolution of
                # ~500x500 pixels
                img  = cv2.resize(img, (0,0),
                 fx = 0.065,
                 fy = 0.065)
                
                img = cv2.medianBlur(img, int(args.smooth))
                img = cv2.adaptiveThreshold(img,
                 255,
                 cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                 cv2.THRESH_BINARY,11,2)
                #ret, img = cv2.threshold(img,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)
                
                # Hough circles finding on small image
                circles = cv2.HoughCircles(img,cv2.HOUGH_GRADIENT,
			    1,100,
                            param1=200,
                            param2=11,
                            minRadius= int(args.min_radius),
                            maxRadius= int(args.max_radius))
                cimg = cv2.cvtColor(img_orig, cv2.COLOR_GRAY2BGR)
                
                # rescale to full resolution
                circles = circles * 15.4

                # visualize circles
                circles = np.uint16(np.around(circles))
                
                for i in circles[0,:]:
                    cv2.circle(cimg,(i[0],i[1]),i[2],(0,255,0), 50)
                    
                # output visualization
                cimg  = cv2.resize(cimg, (300,300))
                
                cv2.imwrite(args.output_directory + "hough_" + basename(file),
                 cimg)
                
                # cut out necessary data from circles array
                # for coordinates transforms                
                src = np.float32(circles[0,:,0:2])
                dist = np.sum(src**2, axis = 1)
                
                tl = src[np.where(dist == min(dist)),:][0]
                br = src[np.where(dist == max(dist)),:][0]
                diag = src[np.where(
                 (dist != min(dist)) &
                 (dist != max(dist))),:][0]
                diag = diag[diag[:,1].argsort()]

                # reshuffle
                src = np.concatenate((tl, diag, br), axis = 0)
                                                
                # set the default locations of the fudicial points
                # and calculate the perspective difference
                dst = np.float32([                
                [0,0],
                [args.size,0],
                [0,args.size],
                [args.size,args.size]
                ])
                                                
                # perspective transformation
                M = cv2.getPerspectiveTransform(src, dst)

                # warp perspective using default linear interpolation
                # and set output resolution fixed
                output = cv2.warpPerspective(img_orig, M, (args.size, args.size))

                # crop further to exclude corners
                #output = output[349:7349, 349:7349]

                # write to file
                cv2.imwrite(args.output_directory + basename(file),
                 output,
                 [cv2.IMWRITE_PNG_COMPRESSION, 0])
                
                # update progress
                pbar.update()

