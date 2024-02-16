#  Fall 2023
#  Team Members: Angel Perez, Wesley Newman, Juan Campista    
#  % Effort: 33%, 33%, 33%   
#
#  New vbsme, we removed the stack and freed multiple registers. This implementation does not work at the moment as the new SAD works with the old seach pattern 
#  ... but somethings wrong with the new pattern search, looked over multiple times and I can't find the bug.
#
# ECE369A
# 
########################################################################################################################
### data
########################################################################################################################
.data
# test input
# asize : dimensions of the frame [i, j] and window [k, l]
#         i: number of rows,  j: number of cols
#         k: number of rows,  l: number of cols  
# frame : frame data with i*j number of pixel values
# window: search window with k*l number of pixel values
#
# $v0 is for row / $v1 is for column

# test 1 For the 16X16 frame size and a 8X4 window size
# The result should be 3, 2
asize1:  .word    16, 16, 8, 4    #i, j, k, l
frame1:  .word    7, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
         .word    7, 8, 8, 8, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
         .word    7, 8, 8, 8, 2, 8, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 
         .word    7, 8, 8, 8, 8, 8, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 
         .word    0, 4, 8, 8, 8, 8, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 
         .word    0, 5, 8, 8, 8, 8, 30, 35, 40, 45, 50, 55, 60, 65, 70,  75, 
         .word    0, 6, 8, 8, 8, 8, 36, 42, 48, 54, 60, 66, 72, 78, 84, 90, 
         .word    0, 4, 8, 8, 8, 8, 42, 49, 56, 63, 70, 77, 84, 91, 98, 105, 
         .word    0, 1, 8, 8, 8, 8, 48, 56, 64, 72, 80, 88, 96, 104, 112, 120, 
         .word    0, 1, 8, 8, 8, 8, 54, 63, 72, 81, 90, 99, 108, 117, 126, 135, 
         .word    0, 10, 8, 8, 8, 8, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 
         .word    0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121, 132, 143, 154, 165, 
         .word    9, 9, 9, 9, 48, 60, 72, 84, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 9, 9, 9, 52, 65, 78, 91, 104, 114, 130, 143, 1, 2, 3, 4, 
         .word    9, 9, 9, 9, 56, 70, 84, 98, 112, 126, 140, 154, 2, 3, 4, 5, 
         .word    9, 9, 9, 9, 60, 75, 90, 105, 120, 135, 150, 165, 3, 4, 5, 6 
window1: .word    8, 8, 8, 8, 
         .word    8, 8, 8, 8, 
         .word    8, 8, 8, 8, 
         .word    8, 8, 8, 8, 
         .word    8, 8, 8, 8, 
         .word    8, 8, 8, 8, 
         .word    8, 8, 8, 8, 
         .word    8, 8, 8, 8 


# test 2 For the 32X32 frame and a 8X16 window size
# The result should be 16, 0
asize2:  .word    32, 32, 8, 16    #i, j, k, l
frame2:  .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
         .word    1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8

window2: .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 


# test 3 For the 16X16 frame and a 4X8 window size
# The result should be 12, 0
asize3:  .word    16, 16, 4, 8    #i, j, k, l
frame3:  .word    9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 7, 
         .word    9, 7, 7, 7, 7, 5, 6, 7, 8, 9, 10, 11, 6, 7, 7, 7, 
         .word    9, 7, 7, 7, 7, 3, 12, 14, 16, 18, 20, 6, 6, 7, 7, 7, 
         .word    9, 7, 7, 7, 7, 4, 18, 21, 24, 27, 30, 33, 6, 7, 7, 7, 
         .word    0, 7, 7, 7, 7, 5, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 
         .word    0, 5, 3, 4, 5, 6, 30, 35, 40, 45, 50, 55, 60, 65, 70,  75, 
         .word    0, 6, 12, 18, 24, 30, 36, 42, 48, 54, 60, 66, 72, 78, 84, 90, 
         .word    0, 4, 14, 21, 28, 35, 42, 49, 56, 63, 70, 77, 84, 91, 98, 105, 
         .word    0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88, 96, 104, 112, 120, 
         .word    0, 9, 18, 27, 36, 45, 54, 63, 72, 81, 90, 99, 108, 117, 126, 135, 
         .word    0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 
         .word    0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121, 132, 143, 154, 165, 
         .word    9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3

window3: .word    9, 9, 9, 9, 9, 9, 9, 9, 
         .word    9, 9, 9, 9, 9, 9, 9, 9, 
         .word    9, 9, 9, 9, 9, 9, 9, 9, 
         .word    9, 9, 9, 9, 9, 9, 9, 9



# test 4 For the 16X16 frame and a 8X8 window size
# The result should be 8, 3
asize4: .word    16, 16, 8, 8    #i, j, k, l
frame4: .word    9, 19, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 91, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 9, 19, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 9, 91, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    91, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 19, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 91, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    1, 2, 3, 9, 9, 19, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 
         .word    1, 2, 3, 9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 
         .word    1, 2, 3, 9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 
         .word    1, 2, 3, 9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 
         .word    1, 2, 3, 9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 
         .word    1, 2, 3, 9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 
         .word    1, 2, 3, 9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 
         .word    1, 2, 3, 9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0, 
         .word    1, 2, 3, 9, 9, 9, 9, 9, 9, 9, 9, 96, 108, 120, 132, 0

window4:   .word    9, 9, 9, 9, 9, 9, 9, 9, 
            .word    9, 9, 9, 9, 9, 9, 9, 9, 
            .word    9, 9, 9, 9, 9, 9, 9, 9, 
            .word    9, 9, 9, 9, 9, 9, 9, 9, 
            .word    9, 9, 9, 9, 9, 9, 9, 9, 
            .word    9, 9, 9, 9, 9, 9, 9, 9, 
            .word    9, 9, 9, 9, 9, 9, 9, 9, 
            .word    9, 9, 9, 9, 9, 9, 9, 9


# test 5 For the 32X32 frame and a 4X4 window size
# The result should be 17, 16 since the updated SAD location condition is SAD <= currentMinimum (less OR EQUAL)
asize5: .word    32, 32, 4, 4    #i, j, k, l
frame5: .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
         .word    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

window5:   .word    10, 10, 10, 10, 
            .word    10, 10, 10, 10, 
            .word    10, 10, 10, 10, 
            .word    10, 10, 10, 10

newline: .asciiz     "\n" 

window:    
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

########################################################################################################################
### main
########################################################################################################################

.text
.globl main

main: 

    # Start test 1 
    ############################################################
    la      $a0, asize1     # 1st parameter: address of asize1[0]
    la      $a1, frame1     # 2nd parameter: address of frame1[0]
    la      $a2, window1    # 3rd parameter: address of window1[0] 

    jal     vbsme           # call function
    jal     print_result    # print results to console

    ############################################################
    # End of test 1   


    # Start test 2 
    ############################################################
    la      $a0, asize2     # 1st parameter: address of asize2[0]
    la      $a1, frame2     # 2nd parameter: address of frame2[0]
    la      $a2, window2    # 3rd parameter: address of window2[0] 

    jal     vbsme           # call function
    jal     print_result    # print results to console
    ############################################################
    # End of test 2   


    # Start test 3
    ############################################################
    la      $a0, asize3     # 1st parameter: address of asize3[0]
    la      $a1, frame3     # 2nd parameter: address of frame3[0]
    la      $a2, window3    # 3rd parameter: address of window3[0] 

    jal     vbsme           # call function
    jal     print_result    # print results to console 
    ############################################################
    # End of test 3   


    # Start test 4 
    ############################################################
    la      $a0, asize4     # 1st parameter: address of asize4[0]
    la      $a1, frame4     # 2nd parameter: address of frame4[0]
    la      $a2, window4    # 3rd parameter: address of window4[0] 

    jal     vbsme           # call function
    jal     print_result    # print results to console
    ############################################################
    # End of test 4   


    # Start test 5
    ############################################################
    la      $a0, asize5     # 1st parameter: address of asize5[0]
    la      $a1, frame5     # 2nd parameter: address of frame5[0]
    la      $a2, window5    # 3rd parameter: address of window5[0] 

    jal     vbsme           # call function
    jal     print_result    # print results to console
    ############################################################

end_program:                    # remain in infinite loop
  j end_program
################### Print Result ####################################
print_result:
    # Printing $v0
    add     $a0, $v0, $zero     # Load $v0 for printing
    li      $v0, 1              # Load the system call numbers
    syscall

    # Print newline.
    la      $a0, newline          # Load value for printing
    li      $v0, 4                # Load the system call numbers
    syscall

    # Printing $v1
    add     $a0, $v1, $zero      # Load $v1 for printing
    li      $v0, 1                # Load the system call numbers
    syscall

    # Print newline.
    la      $a0, newline          # Load value for printing
    li      $v0, 4                # Load the system call numbers
   syscall

    # Print newline.
    la      $a0, newline          # Load value for printing
    li      $v0, 4                # Load the system call numbers
    syscall

    jr      $ra                   #function return

#####################################################################
### vbsme
#####################################################################


# vbsme.s 
# motion estimation is a routine in h.264 video codec that 
# takes about 80% of the execution time of the whole code
# given a frame(2d array, x and y dimensions can be any integer 
# between 16 and 64) where "frame data" is stored under "frame"  
# and a window (2d array of size 4x4, 4x8, 8x4, 8x8, 8x16, 16x8 or 16x16) 
# where "window data" is stored under "window" 
# and size of "window" and "frame" arrays are stored under "asize"

# - initially current sum of difference is set to a very large value
# - move "window" over the "frame" one cell at a time starting with location (0,0)
# - moves are based circular pattern 
# - for each move, function calculates  the sum of absolute difference (SAD) 
#   between the window and the overlapping block on the frame.
# - if the calculated sum of difference is LESS THAN the current sum of difference
#   then the current sum of difference is updated and the coordinate of the top left corner 
#   for that matching block in the frame is recorded. 

# for example SAD of two 4x4 arrays "window" and "block" shown below is 3  
# window         block
# -------       --------
# 1 2 2 3       1 4 2 3  
# 0 0 3 2       0 0 3 2
# 0 0 0 0       0 0 0 0 
# 1 0 0 5       1 0 0 4

# program keeps track of the window position that results 
# with the minimum sum of absolute difference. 
# after scannig the whole frame
# program returns the coordinates of the block with the minimum SAD
# in $v0 (row) and $v1 (col) 


# Sample Inputs and Output shown below:
# Frame:
#
#  0   1   2   3   0   0   0   0   0   0   0   0   0   0   0   0 
#  1   2   3   4   4   5   6   7   8   9  10  11  12  13  14  15 
#  2   3  32   1   2   3  12  14  16  18  20  22  24  26  28  30 
#  3   4   1   2   3   4  18  21  24  27  30  33  36  39  42  45 
#  0   4   2   3   4   5  24  28  32  36  40  44  48  52  56  60 
#  0   5   3   4   5   6  30  35  40  45  50  55  60  65  70  75 
#  0   6  12  18  24  30  36  42  48  54  60  66  72  78  84  90 
#  0   7  14  21  28  35  42  49  56  63  70  77  84  91  98 105 
#  0   8  16  24  32  40  48  56  64  72  80  88  96 104 112 120 
#  0   9  18  27  36  45  54  63  72  81  90  99 108 117 126 135 
#  0  10  20  30  40  50  60  70  80  90 100 110 120 130 140 150 
#  0  11  22  33  44  55  66  77  88  99 110 121 132 143 154 165 
#  0  12  24  36  48  60  72  84  96 108 120 132   0   1   2   3 
#  0  13  26  39  52  65  78  91 104 117 130 143   1   2   3   4 
#  0  14  28  42  56  70  84  98 112 126 140 154   2   3   4   5 
#  0  15  30  45  60  75  90 105 120 135 150 165   3   4   5   6 

# Window:
#  0   1   2   3 
#  1   2   3   4 
#  2   3   4   5 
#  3   4   5   6 

# cord x = 12, cord y = 12 returned in $v0 and $v1 registers


.text
.globl  vbsme

# Your program must follow circular search pattern.  

# Preconditions:
#   1st parameter (a0) address of the first element of the dimension info (address of asize[0])
#   2nd parameter (a1) address of the first element of the frame array (address of frame[0][0])
#   3rd parameter (a2) address of the first element of the window array (address of window[0][0])
# Postconditions:	
#   result (v0) x coordinate of the block in the frame with the minimum SAD
#          (v1) y coordinate of the block in the frame with the minimum SAD


# Begin subroutine
vbsme:  
    addi      $v0, $zero, 0              # reset $v0 and $V1
    addi      $v1, $zero, 0

# S REGISTER ASSIGNMENTS (s0 - s7): 
  # basisX = $s0 - X coordinate for search pattern
  # basisY = $s1 - Y coordinate for search pattern 
  # xMax = $s2
  # yMax = $s3
  # iterators = [$s4, $s5, $s6], possible temp_variables just use in Wesley's code ~ Angel
  # windowAddress = $s7, gets the empty array of zeros and loads the value of the window built off that x and y position
  
# T REGISTER ASSIGNMENTS (t0 - t9): 
  # ACTUAL temp_variable = $t0, 
  # frame = $t1 - checks which line frame we're on, used to see if we've hit the last frame. Increments by 1 after each SAD calculation, 
  # line = $t2 - used to see which line we're on, increments whenever oddline switches from 0 to 1 or 1 to 0. Only really used for determining line 0 to launch "case_zero" function. After that only used   
  # for debugging purposes to make sure the search pattern is running correctly  
  # midpointX = $t3 
  # midpointY = $t4 
  # Oddline = $t5, convinced we don't need this
  # ACTUAL temp_variable = $t6
  # ACTUAL temp_variable = $t7
  # OldSAD = $t8
  # NewSAD = $t9

# GIVEN VALUES
  # i = 0(a0)
  # j = 4(a0)
  # k = 8(a0)
  # l = 12(a0) 

Loop_Initialize:
 lw     $t6, 4($a0)            # get j
 lw     $t7, 12($a0)           # get l
 sub    $s3, $t6, $t7          # $s2 (yMax) = j-l
 lw     $t6, 0($a0)            # get i
 lw     $t7, 8($a0)            # get k
 sub    $s2, $t6, $t7          # $s3 (xMax) = i-k
 add    $s0, $zero, $zero      # initialize $s0 (basisX) to 0
 add    $s1, $zero, $zero      # initialize $s1 (basisY) to 0
 addi   $t0, $zero, 0          # initialize $t0 to 0
 addi   $t1, $zero, 0          # initialize $t1 (frame) to 0
 addi   $t2, $zero, 0          # initialize $t2 (line) to 0
 addi   $t3, $zero, 0          # initialize $t3 (midpointX) to 0
 addi   $t4, $zero, 0          # initialize $t4 (midpointY) to 0
 addi   $t5, $zero, 2          # initialize $t5 (Oddline) to 2
 addi   $t6, $zero, 0          # initialize $t6 to 0
 addi   $t7, $zero, 0          # initialize $t7 to 0
 addi   $t8, $zero, 500        # inititalize for SAD
 la     $s7, window            # array of zeros for SAD

Variable_Check:
 addi   $s3, $s3, 1            # increment yMax by 1
 addi   $s2, $s2, 1            # increment xMax by 1
 mul    $t7, $s3, $s2          # t7 = yMax * xMax
 addi   $t7, $t7, -1
 slt    $t6, $t7, $t1          # if $t1 (frame) < $t7((xMax+1) * (yMax+1) - 1) , set $t6 to 0
 bne    $t6, $zero, Exit       # if $t6 is not zero, jump to Exit function #beq changed to bne
 j      SADdress_Generation    # jump to SADdress_Generation

Pattern_search:
 beq     $t2, $zero, Case_zero # move to case zero function if $t2 (line) is zero
 andi    $t7, $t2, 1           # set $t7 to 1 if $t2 (line) is odd
 bne     $t7, $zero, Odd       # go to Odd function if $t7 has a value other than zero (or in our case 1)
 j       Even                  # go to Even function because the Odd function call did not trigger


Loop_reset:
 addi    $t1, $t1, 1           # increment frame by 1 -PUT AS LAST THING ON PATTERN SEARCH FUNCTION BEFORE THE LOOP-
 j       Variable_Check        # go back to Variable Check function to either continue the loop or move to Exit/print


Case_zero:
 addi    $s0, $s0, 1           # increment $s0 (basisX) by 1
 addi    $t2, $t2, 1           # increment $t2 (line) by 1
 addi    $t5, $zero, 1         # set $t5 (oddLine) to 1
 j       Loop_reset            # go to Loop_reset, continue normal cycle - NEEDS TO BE LAST LINE IN CASE_ZERO FUNCTION


Even:
 slt     $t6, $zero, $s1         # set $t6 to 1 if zero is less than $s1 (basisY)
 beq     $t6, $zero, even_else1  # go to even_else1 if $t6 is zero
 bne     $t3, $zero, even_else1  # go to even_else1 if $t3 (midpointX) not equal zero
 addi    $s0, $s0, 1             # increment basisX
 addi    $s1, $s1, -1            # decrement basisY
 j       even_midpoint_check     # jump to even_midpoint_check

even_else1:
 beq   $t3, $zero, even_else2    # jump to even_else2 if midpointX != 1 changed from bne $t3, 1, even_else2
 slt   $t6, $s0, $s2             # set $s3 to 1 if $s0 (basisX) < $s2 (xMax)
 beq   $t6, $zero, even_else2    # jump to even_else2 if basisX not less than xMax
 addi  $s0, $s0, 1               # increment basisX
 addi  $s1, $s1, -1              # decrement basisY
 j     even_midpoint_check       # jump to even_midpoint_check

even_else2:
 addi  $t2, $t2, 1               # increment line
 addi  $t5, $zero, 1             # set oddline to 1
 beq   $t3, $zero, evenXAdd      # if $t3 (midpointX) < 0 jump to evenXAdd
 addi  $s1, $s1, 1               # increment basisY
 j     even_midpoint_check       # jump to even_midpointcheck

evenXAdd:
 addi  $s0, $s0, 1               # increment basisX
 j     even_midpoint_check       # jump to even_midpointcheck

even_midpoint_check:
 j     evenXMidCheck             # jump and link evenXMidCheck

EyCheck:
 j     evenYMidCheck             # jump and link evenYMidCheck

Ereset:
 j     Loop_reset                # jump to Loop_reset

evenYMidCheck:
 bne   $s1, $s3, Ereset          # if basisY != yMax, jump to even_midpoint_check
 addi  $t4, $zero, 1             # assign 1 to midpointY
 j     Ereset                    # jump back to even_midpoint_check

evenXMidCheck:
 bne   $s0, $s2, EyCheck         # if basisX != xMax, jump to even_midpoint_check
 addi  $t3, $zero, 1             # assign 1 to midpointX
 j     EyCheck                   # jump back to even_midpoint_check


Odd:
 beq   $s0, $zero, Odd_else1    # jump to Odd_else1 if basisX == 0
 bne   $t4, $zero, Odd_else1    # jump to Odd_else1 if midpointY != 0
 addi  $s1, $s1, 1              # increment basisY
 addi  $s0, $s0, -1             # decrement basisX
 j     odd_midpoint_check       # jump to odd_midpoint_check

Odd_else1:
 addi  $t6, $zero, 1            # assign $t6 to 1 for comparison
 bne   $t4, $t6, Odd_else2      # jump to Odd_else2 if midpointY != 1
 slt   $t7, $s1, $s3            # set $t7 to 1 if basisY < yMax
 beq   $t7, $zero, Odd_else2    # jump to Odd_else2 if basisY not less than yMax
 addi  $s1, $s1, 1              # increment basisY
 addi  $s0, $s0, -1             # decrement basisX
 j     odd_midpoint_check       # jump to odd_midpoint_check

Odd_else2:
 addi  $t2, $t2, 1              # increment line
 addi  $t5, $zero, 2            # set oddLine to 2
 beq   $t4, $zero, OddYAdd      # jump to OddYAdd if midpointY == 0
 addi  $s0, $s0, 1              # increment basisX
 j     odd_midpoint_check       # jump to odd_midpoint_check

OddYAdd:
 addi  $s1, $s1, 1              # increment basisY by 1
 j     odd_midpoint_check       # jump to odd_midpoint_check
 
odd_midpoint_check:
 j     oddYMidCheck             # jump and link oddYMidCheck

oXcheck:
 j     oddXMidCheck             # jump and link oddXMidCheck

oReset:
 j     Loop_reset               # jump back to Loop_reset

oddYMidCheck:
 bne   $s1, $s3, oXcheck        # jump back to odd_midpoint_check if basisY != yMax
 addi  $t4, $zero, 1            # assign 1 to midpointY
 j     oXcheck                  # jump back to odd_midpoint_check

oddXMidCheck:
 bne   $s0, $s2, oReset         # jump back to odd_midpoint_check if basisX != xMax
 addi  $t3, $zero, 1            # assign 1 to midpointX
 j     oReset                   # jump back to odd_midpoint_check

# basisX($s0) and basisY($s1) are your x/y coordinates
# Registers: t6 = temp, t7 = temp, t8 = OldSAD, t9 = NewSAD, s4 = b, s5 = m, s6 = a, s7 = winAdd
# for some reason changing the $sp registers in my section removes -1 case from private cases for lab 3
SADdress_Generation:
 add  $s4, $s1, $zero             # b = y, loop row increment
 add  $s5, $zero, $zero           # m = 0, window iterator thru the bytes
 add  $t9, $zero, $zero           # CurrSAD = 0

loopRow:  
 lw   $t7, 8($a0)                 # k, first case 8
 add  $t7 $t7, $s1                # t7 = k + y
 slt  $t6, $s4, $t7               # t5 = b < t7
 beq  $t6, $zero, Return          # if b is not less than l, go to Return
 add  $s6, $s0, $zero             # a = x, loop col increment

loopCol:
 add  $t7, $zero, $zero
 lw   $t7, 12($a0)                # l
 add  $t7 $t7, $s0                # t7 = l + x;
 slt  $t6, $s6, $t7               # t5 = a < t7;
 beq  $t6, $zero, loopRow         # if a is less than k, go to loopRow

# *(win + m) = *(frame + (frow * b) + a);
 add  $t7, $zero, $zero           # clear t7
 add  $t6, $zero, $zero
 lw   $t6, 0($a0)                 # load frow = i
 mul  $t6, $t6, $s4               # i * b
 add  $t6, $s6, $t6               # a + (i * b)
 sll  $t6, $t6, 2                 # byte offset
 add  $t6, $t6, $a1               # frame offset, right side of =
 add  $s7, $s7, $s5               # win + m, left side of =
 lw   $s7, 0($t6)                 # get the data

# SAD = abs(winEval[m/4] - winAdd[m/4]);
 add  $t7, $zero, $zero          # clear t7
 srl  $s5, $s5, 2                # m / 4
 sll  $t7, $s5, 2                # winEval byte offset
 add  $t7, $t7, $a2              # add byte offset to window
 lw   $t7, 0($t7)                # get the data
 sub  $t7, $s7, $t7              # winEval[m/4] - winAdd[m/4]
 slt  $t6, $t7, $zero            # checks if SAD value is negative
 bne  $t6, $zero, isNegative     # if negative get sent to isNegative
 j totalSAD

isNegative:
 addi $t6, $zero, -1
 mul  $t7, $t7, $t6              # This gives us absolute of the SAD

totalSAD:
 add  $t9, $t9, $t7

Loop_SADdress:
 sll  $s5, $s5, 2                # restores m from decimal back to its word, m * 4
 addi $s5, $s5, 4                # m++
 addi $s6, $s6, 1                # a++
 add  $t7, $zero, $zero
 lw   $t7, 12($a0)               # l
 add  $t7 $t7, $s0               # t7 = l + x;
 slt  $t6, $s6, $t7              # t5 = a < t7;
 beq  $t6, $zero, plusB          # if a is less than k, go to plusB
 j loopCol

plusB:
 addi $s4, $s4, 1                # b++
 j loopRow

Return:
 addi $t6, $t6, 0
 slt  $t6, $t8, $t9              # NewSAD < OldSAD (will be changing over time)
 beq  $t6, $zero, updateSAD      # if statement is false get sent to Else
 j Pattern_search                # Window goes to the next step of the frame

updateSAD:
 add  $t8, $zero, $t9            # if statement is true then new min value gets stored
 add  $v0, $zero, $s1
 add  $v1, $zero, $s0
 j Pattern_search                # Window goes to the next step of the frame

Exit:
 jr $ra
