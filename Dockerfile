FROM continuumio/miniconda3:4.9.2

RUN apt-get update && apt-get install -y curl gcc libgl1-mesa-dev && \
    rm -rf /var/lib/apt/lists/*

# install pytorch 1.7 and cuda 10.1
RUN conda install -y pytorch cudatoolkit=10.1 torchvision -c pytorch

# install mmcv-full
RUN pip install mmcv-full==1.2.4 -f https://download.openmmlab.com/mmcv/dist/cu101/torch1.7.0/index.html

# install mmdetection
RUN mkdir /work && cd work && \
    git clone https://github.com/open-mmlab/mmdetection.git && \
    cd mmdetection && \
    pip install -r requirements/build.txt && \
    pip install -v -e .

# clone label studio project and install
RUN cd /work && git clone https://github.com/heartexlabs/label-studio && \
    cd label-studio && \
    pip install -e .

# uninstall pycocotools and reinstall mmpycocotools.
#RUN pip install -r label-studio/label_studio/ml/examples/mmdetection/requirements.txt && \
RUN pip uninstall pycocotools mmpycocotools -y && \
    pip install mmpycocotools requests==2.22.0

# init ml backend
RUN cd /work && label-studio-ml init coco-detector --from label-studio/label_studio/ml/examples/mmdetection/mmdetection.py

# copy configs/_base_ dir
# RUN git clone https://github.com/open-mmlab/mmdetection.git && \
#    cd mmdetection && \
#    mv configs/_base_ ../ && \
#    cd .. && rm -rf mmdetection

# download config and checkpoint file
RUN mkdir /work/checkpoints && \
    curl http://download.openmmlab.com/mmdetection/v2.0/faster_rcnn/faster_rcnn_r50_fpn_1x_coco/faster_rcnn_r50_fpn_1x_coco_20200130-047c8118.pth > /work/checkpoints/faster_rcnn_r50_fpn_1x_coco_20200130-047c8118.pth

# run ml backend on 9090
CMD label-studio-ml start coco-detector --with \
    config_file=/work/mmdetection/configs/faster_rcnn/faster_rcnn_r50_fpn_1x_coco.py \
    checkpoint_file=/work/checkpoints/faster_rcnn_r50_fpn_1x_coco_20200130-047c8118.pth \
    score_threshold=0.5 \
    device=cpu
