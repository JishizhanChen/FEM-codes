# -*- coding: utf-8 -*-

from odbAccess import openOdb

# Replace with your ODB file path and output file path
odbPath = 'C:/Users/Documents/MATLAB/job1.odb'
outputFilePath = 'D:/LE.txt'

# Open ODB file
odb = openOdb(path=odbPath)
lastStep = odb.steps[odb.steps.keys()[-1]]
lastFrame = lastStep.frames[-1]

# Check if 'E' field output exists
if 'E' in lastFrame.fieldOutputs:
    eField = lastFrame.fieldOutputs['E']
    
    # Obtain SET-1 node collection
    set1Nodes = odb.rootAssembly.nodeSets['SET-1']
    
    # Obtain SET-1 data from 'E' field output
    eFieldSet1 = eField.getSubset(region=set1Nodes)
    
    # Open output file
    outputFile = open(outputFilePath, 'w')
    outputFile.write('Node Label, E11, E22, E33, E12, E13, E23\n')
    
    # Iterate over the values in SET-1 and write to the file
    for value in eFieldSet1.values:
        if value.nodeLabel is not None:
            outputFile.write('%d, %s\n' % (value.nodeLabel, ', '.join(str(e) for e in value.data)))
        else:
            print("Warning: Found a value with None as nodeLabel in SET-1.")
    
    outputFile.close()

odb.close()


