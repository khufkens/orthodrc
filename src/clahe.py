#!/usr/bin/env python

import numpy as np
import cv2
import argparse

# argument parser
def getArgs():

   parser = argparse.ArgumentParser(
    description = '''Applies local histogram equalization to an image''')

   parser.add_argument('-i',
                       '--input',
                       help = 'input file')

   parser.add_argument('-o',
                       '--output',
                       help = 'where to store the file')
                       
   parser.add_argument('-w',
                       '--windowsize',
                       help = 'window size for analysis',
                       default = 32)
                       
   parser.add_argument('-c',
                       '--cliplimit',
                       help = 'clip limit',
                       default = 1.5)
                       
   return parser.parse_args()


# main routine
if __name__ == '__main__':
  
  # parse arguments
  args = getArgs()

  # read input image
  img = cv2.imread(args.input,0)

  # create a CLAHE object (Arguments are optional).
  clahe = cv2.createCLAHE(clipLimit = float(args.cliplimit),
   tileGridSize = (int(args.windowsize),int(args.windowsize)))
  cl1 = clahe.apply(img)
  
  # write output to file
  cv2.imwrite(args.output,cl1)
