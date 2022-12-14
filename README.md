docker-stable-diffusion-webui
=============================

A dockerized, CPU-only, self-contained version of AUTOMATIC1111's Stable Diffusion Web UI.

Unlike other docker images out there, this one includes all necessary dependencies inside and weighs in at 9.7GiB - including the Stable Diffusion v1.4 weights!

Quickstart:

1. Run `docker build -t uberi/stable-diffusion . && docker run --dns 0.0.0.0 --rm -t -p 7860:7860 uberi/stable-diffusion`.
2. The web UI should now be accessible at http://localhost:7860.

Features:

* Relatively small: we use the CPU-only versions of torch and torchvision, and the non-graphical version of OpenCV.
* Self-contained: we pre-download the CLIP model, and retrieve the Stable Diffusion weights from an alternative source that doesn't login-wall the download.
* CPU-only: can be run essentially anywhere, if you're willing to wait longer for the generation to happen.
* Offline: all necessary models for the basic txt2img/img2img/upscale workflow are included in the image already, so we disable DNS to block telemetry (particularly from Gradio, which is used throughout the web UI).

I also usually like to export an archive of the image locally with `docker save -o ../docker-stable-diffusion-webui.tar uberi/stable-diffusion`, so that it can be loaded later and on other computers using `docker load -i ../docker-stable-diffusion-webui.tar`.