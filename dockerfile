FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-devel

RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone https://github.com/Wan-Video/Wan2.2.git
WORKDIR /workspace/Wan2.2

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir decord
RUN pip install --no-cache-dir "huggingface_hub[cli]"


COPY prompts.txt .
COPY run_pipeline.sh .


RUN chmod +x run_pipeline.sh


CMD ["./run_pipeline.sh"]