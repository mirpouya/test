# Dockerfile for ORB-SLAM3

FROM lmwafer/realsense-ready:2.0-ubuntu18.04


# Install dependencies
RUN apt-get update && \
    apt-get -y upgrade && \
    echo "Installing general usage dependencies ..." && \
    apt-get install -y build-essential apt-file nano pkg-config wget gnupg software-properties-common && \
    apt-file update && \
    echo "Installing OpenCV dependencies ..." && \
    apt-get install -y libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev software-properties-common && \
    echo "Installing Pangolin dependencies ..." && \
    apt-get install -y libglew-dev libboost-dev libboost-thread-dev libboost-filesystem-dev ffmpeg libavutil-dev libpng-dev \
                       libgl1-mesa-dev libegl1-mesa-dev libepoxy-dev python3-dev && \
    echo "Installing Eigen 3 ..." && \
    apt-get install -y libeigen3-dev && \
    rm -rf /var/lib/apt/lists/*

# Install OpenGL and X11 dependencies for GUI and RealSense Viewer
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libx11-xcb1 \
    libxrender1 \
    libxcb1 \
    libxext6 \
    libegl1 \
    libglu1-mesa \
    x11-xserver-utils \
    mesa-utils

# Install CMake >= 3.16
RUN echo "Installing CMake 3.22 from Kitware repo..." && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - && \
    apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' && \
    apt-get update && \
    apt-get install -y cmake



RUN echo "Installing Pangolin..." && \
    mkdir -p /dpds && cd /dpds && \
    wget https://github.com/stevenlovegrove/Pangolin/archive/refs/tags/v0.5.tar.gz && \
    tar -xzf v0.5.tar.gz && \
    rm v0.5.tar.gz && \
    cd Pangolin-0.5 && mkdir build && cd build && \
    cmake .. && cmake --build . &&\
    make install && ldconfig


# Build and install OpenCV
RUN echo "Installing OpenCV..." && \
    cd /dpds && \
    git clone https://github.com/Itseez/opencv.git && \
    git clone https://github.com/Itseez/opencv_contrib.git && \
    cd opencv && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D BUILD_TIFF=ON \
          -D WITH_CUDA=OFF \
          -D ENABLE_AVX=OFF \
          -D WITH_OPENGL=OFF \
          -D WITH_OPENCL=OFF \
          -D WITH_IPP=OFF \
          -D WITH_TBB=ON \
          -D BUILD_TBB=ON \
          -D WITH_EIGEN=ON \
          -D WITH_V4L=OFF \
          -D WITH_VTK=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D OPENCV_GENERATE_PKGCONFIG=ON \
          -D OPENCV_EXTRA_MODULES_PATH=/dpds/opencv_contrib/modules \
          .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Set workspace
WORKDIR /workspace

CMD ["/bin/bash"]
