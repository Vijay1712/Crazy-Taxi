from collections import Counter
import numpy as np

filename = input("What is the name of the file to be cleaned? ")
file = open("../../lab8/sprite_bytes/" + filename + ".txt", "r")
outFile = open("../../lab8/sprite_bytes/" + filename + "-cleaned.txt", "w")

for line in file:
    if filename == 'wins':
        if line == 'e0180\n':  # e01800
            outFile.write('0\n')
        elif line == '605cf4\n':  # 605cf4
            outFile.write('1\n')
        elif line == 'fc400\n':  # fc4000
            outFile.write('2\n')
        elif line == 'f1693a\n':  # f1693a
            outFile.write('3\n')
        elif line == 'c8f3f7\n':  # c8f3f7
            outFile.write('4\n')
        elif line == 'c080\n':  # c00800
            outFile.write('5\n')
        elif line == '8c98f8\n':
            outFile.write('6\n')
        elif line == '584cf4\n':
            outFile.write('7\n')
        else:  # background
            outFile.write('8\n')

file.close()
outFile.close()
