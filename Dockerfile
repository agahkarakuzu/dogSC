FROM simexp/octave:4.2.1_cross_u16

USER root

RUN apt-get update
RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/struct-1.0.14.tar.gz -P /home/octave
RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/general-2.0.0.tar.gz -P /home/octave

RUN octave --eval "cd /home/octave; \
                   more off; \
                   pkg install -auto -global -verbose \
           general-2.0.0.tar.gz \
                   struct-1.0.14"


RUN cd $HOME/work

RUN git clone https://github.com/neuropoly/qMRLab.git

RUN octave --eval "startup;"

USER $NB_USER

# Copy files from github to work dir 

COPY dogSC_data.tar.gz $HOME/work
COPY dogSC.ipynb $HOME/work
COPY bokehCorPlot.ipynb $HOME/work
COPY README.ipynb $HOME/work
COPY ReadFrame.tar.gz $HOME/work
COPY setNifti.m $HOME/work
COPY bkhPlot.gif $HOME/work
COPY corInteract.gif $HOME/work
COPY initOctave.m $HOME/work

WORKDIR $HOME/work
