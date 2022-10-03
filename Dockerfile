# build: docker build -t uberi/stable-diffusion .
# run: docker run -p 7860:7860 uberi/stable-diffusion

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get install -y wget git python3 python3-venv python3-pip

RUN useradd -m dev
USER dev
WORKDIR /home/dev

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && git reset --hard 53a3dc601fb734ce433505b1ca68770919106bad
WORKDIR /home/dev/stable-diffusion-webui

# these models get loaded at runtime when first used - download them now ahead of time so that we have them available
# (determined by looking through the codebase for usages of load_models() from modules/modelloader.py)
# since the official Stable Diffision model weights require signup to download, we found an alternative URL for `sd-v1-4.ckpt` from https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Dependencies
RUN mkdir --parents models/Codeformer models/GFPGAN models/Stable-diffusion
RUN wget --quiet -O models/Codeformer/codeformer-v0.1.0.pth https://github.com/sczhou/CodeFormer/releases/download/v0.1.0/codeformer.pth
RUN wget --quiet -O models/GFPGAN/GFPGANv1.4.pth https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth
RUN wget --quiet -O models/Stable-diffusion/sd-v1-4.ckpt https://drive.yerf.org/wl/?id=EBfTrmcCCUAGaQBXVIj5lJmEhjoP1tgl&mode=grid&download=1

# install special CPU-oriented versions of torch and torchvision, and a non-graphical version of OpenCV - much smaller because they don't include GPU/graphics support
# the version numbers are taken from https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/53a3dc601fb734ce433505b1ca68770919106bad/launch.py#L13
RUN pip3 install torch==1.12.1+cpu torchvision==0.13.1+cpu opencv-python-headless==4.6.0.66 -f https://download.pytorch.org/whl/torch_stable.html

# obtain most of the other dependencies needed for the model to run - this script clones some repos and installs their dependencies, as well as the dependencies of the web UI itself
RUN COMMANDLINE_ARGS="--skip-torch-cuda-test --exit" python3 launch.py

# initialize CLIP since it downloads lots of files from the internet when first used
RUN python3 -c 'from transformers import CLIPTokenizer, CLIPTextModel; version="openai/clip-vit-large-patch14"; CLIPTokenizer.from_pretrained(version); CLIPTextModel.from_pretrained(version)'

EXPOSE 7860

# start the web UI listening on 0.0.0.0:7860, disable half-size floats since we're running on CPUs that generally won't support those
CMD python3 webui.py --listen --no-half --precision full
