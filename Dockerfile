FROM simexp/octave:4.2.1_cross_u16

ENV qMRLab_ROOT /usr/local/qmr
ENV qMRLab_SANDBOX_ROOT /sandbox
ENV qMRLab_SANDBOX ${qMRLab_SANDBOX_ROOT}/home
ENV HOME ${qMRLab_SANDBOX}


RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/struct-1.0.14.tar.gz -P /home/octave
RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/general-2.0.0.tar.gz -P /home/octave

RUN octave --eval "cd /home/octave; \
                   more off; \
                   pkg install -auto -global -verbose \
                   general-2.0.0.tar.gz \
                   struct-1.0.14"

RUN mkdir ${qMRLab_ROOT}
RUN mkdir -p ${qMRLab_SANDBOX} && chmod -R 777 ${qMRLab_SANDBOX_ROOT}
WORKDIR ${qMRLab_SANDBOX}


RUN git clone https://github.com/neuropoly/qMRLab.git

RUN octave --eval "cd qMRLab; \
                   startup;"


COPY dogSC_data.tar.gz .
COPY dogSC.ipynb .
COPY bokehCorPlot.ipynb .
COPY README.ipynb .
COPY ReadFrame.tar.gz .
COPY setNifti.m .
COPY bkhPlot.gif .
COPY corInteract.gif .
COPY initOctave.m .
USER $NB_USER
