FROM rocm/dev-ubuntu-22.04:6.2-complete

RUN apt-get update && \
    apt-get install -y \
    git \
    bat \
    btop \
    cmake \
    vim \
    wget \
    curl \
    zsh \
    tar \
    python3 \
    locales \
    build-essential && \
    rm -rf /var/lib/apt/lists/*




# install git-lfs
# https://github.com/git-lfs/git-lfs?tab=readme-ov-file#installing
# https://github.com/text2cinemagraph/text2cinemagraph/issues/1

# ADD GGUF TOOLS
# ADD COMPUTATIONAL GRAPH SCRIPT TO UTILS!

SHELL ["/bin/zsh", "-c"]

# install omnitrace
RUN wget https://github.com/ROCm/omnitrace/releases/download/v1.11.4/omnitrace-1.11.4-ubuntu-22.04-ROCm-60200-PAPI-OMPT-Python3.sh && \
    chmod +x omnitrace-1.11.4-ubuntu-22.04-ROCm-60200-PAPI-OMPT-Python3.sh && \
    mkdir /opt/omnitrace

RUN ./omnitrace-1.11.4-ubuntu-22.04-ROCm-60200-PAPI-OMPT-Python3.sh --prefix=/opt/omnitrace --exclude-subdir && \
    chmod +x /opt/omnitrace/share/omnitrace/setup-env.sh && \
    rm omnitrace-1.11.4-ubuntu-22.04-ROCm-60200-PAPI-OMPT-Python3.sh

# setup omnitrace env
RUN echo 'source /opt/omnitrace/share/omnitrace/setup-env.sh' >> .zshrc && \
    echo 'export LD_LIBRARY_PATH=/opt/rocm/lib:${LD_LIBRARY_PATH}' >> .zshrc && \
    echo "export HIP_VISIBLE_DEVICES=0,1" >> .zshrc

# install omniperf
RUN wget https://github.com/ROCm/omniperf/releases/download/v2.1.0/omniperf-v2.1.0.tar.gz && \
    tar xfz omniperf-v2.1.0.tar.gz && \
    cd omniperf-2.1.0/ && \
    export INSTALL_DIR=/opt && \
    python3 -m pip install -t /opt/python-libs -r requirements.txt && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/2.0.1 \
        -DPYTHON_DEPS=/opt/python-libs \
        -DMOD_INSTALL_PATH=/opt/modulefiles .. && \
    make install

# setup omniperf env
RUN echo 'export PATH=/opt/2.0.1/bin:$PATH' >> .zshrc && \
    echo 'export PYTHONPATH=/opt/python-libs' >> .zshrc && \
    locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Update the default locale
RUN update-locale LANG=en_US.UTF-8

WORKDIR /app

RUN python3 -m venv venv && . venv/bin/activate

# clone llama.cpp and install python packages
RUN git clone https://github.com/ggerganov/llama.cpp.git && \
    cd llama.cpp && \
    python3 -m pip install -r llama.cpp/requirements.txt

# oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

CMD ["/bin/zsh", "-c", "source venv/bin/activate"]


