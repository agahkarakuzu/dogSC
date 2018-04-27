FROM agahkarakuzu/qmrlab



COPY dogSC_data.tar.gz .
COPY dogSC.ipynb .
COPY bokehCorPlot.ipynb .
COPY README.ipynb .
COPY ReadFrame.tar.gz .
COPY setNifti.m .
COPY bkhPlot.gif .
COPY corInteract.gif .
COPY initOctave.m .

