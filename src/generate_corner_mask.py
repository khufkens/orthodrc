#!/usr/bin/env python

# Import necessary libraries
import cv2, argparse
import numpy as np

# Generates corner mask in the current working directory

# argument parser
def getArgs():

   parser = argparse.ArgumentParser(
    description = '''Create corner mask.''',
    epilog = '''post bug reports to the github repository''')

   parser.add_argument('-s',
                       '--size',
                       help = 'resize value',
                       default = 7700)

   parser.add_argument('-m',
                       '--mask',
                       help = 'corner mask size, will return mask_file.png',
                       default = 350)
   
   return parser.parse_args()        

if __name__ == '__main__':

  # parse arguments
  args = getArgs()
    
  # First create the image with alpha channel
  mask = np.full((args.size, args.size), 0)
                
  # set start and end columns of data columns
  start = args.mask
  end = args.size - args.mask
  mask[start:end,:] = 255
  mask[:,start:end] = 255
  
  # set correct type
  mask = mask.astype(np.uint8)
  
  # write mask to file
  cv2.imwrite("mask_file.png",
              mask,
              [cv2.IMWRITE_PNG_COMPRESSION, 0])
