# https://hub.docker.com/r/cwaffles/openpose
FROM ubuntu:latest

#get deps
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
python3-dev python3-pip git g++ wget make libprotobuf-dev protobuf-compiler libopencv-dev \
libgoogle-glog-dev libboost-all-dev libatlas-base-dev python3-setuptools

#for python api
RUN pip3 install --upgrade pip
RUN pip3 install numpy opencv-python tqdm scipy matplotlib

#replace cmake as old version has CUDA variable bugs
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.tar.gz && \
    tar xzf cmake-3.16.0-Linux-x86_64.tar.gz -C /opt && \
    rm cmake-3.16.0-Linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.16.0-Linux-x86_64/bin:${PATH}"

#get openpose
WORKDIR /openpose
RUN git clone --depth 1 https://github.com/CMU-Perceptual-Computing-Lab/openpose.git .

#build it
WORKDIR /openpose/build
RUN cmake -DBUILD_EXAMPLES=ON -DGPU_MODE=CPU_ONLY .. && make -j `nproc`

WORKDIR /openpose/build

CMD mkdir scripts
#CMD mkdir scripts/output

WORKDIR /openpose

RUN pip3 install h5py

CMD /bin/bash -c "cd /openpose/build/examples/openpose/ && find /data -type f -printf '%P' -exec ./openpose.bin --video /data/{} --write_json /data/output/json/{}/ --display 0 --write_video /data/output/vids/{}.avi \;"
