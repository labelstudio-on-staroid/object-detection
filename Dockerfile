FROM wgting96/mmlab:cuda101

RUN apt-get update && apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# clone label studio project and install
RUN git clone https://github.com/heartexlabs/label-studio && \
    cd label-studio && \
    pip install -e .

# uninstall pycocotools and reinstall mmpycocotools.
#RUN pip install -r label-studio/label_studio/ml/examples/mmdetection/requirements.txt && \
RUN pip uninstall pycocotools mmpycocotools -y && \
    pip install mmpycocotools requests==2.22.0

# init ml backend
RUN label-studio-ml init coco-detector --from label-studio/label_studio/ml/examples/mmdetection/mmdetection.py

# copy configs/_base_ dir
RUN git clone https://github.com/open-mmlab/mmdetection.git && \
    cd mmdetection && \
    mv configs/_base_ ../ && \
    cd .. && rm -rf mmdetection

# download config and checkpoint file
RUN mkdir /workspace/configs && mkdir /workspace/checkpoints && \
    curl https://raw.githubusercontent.com/open-mmlab/mmdetection/master/configs/faster_rcnn/faster_rcnn_r50_fpn_1x_coco.py > /workspace/configs/faster_rcnn_r50_fpn_1x_coco.py && \
    curl http://download.openmmlab.com/mmdetection/v2.0/faster_rcnn/faster_rcnn_r50_fpn_1x_coco/faster_rcnn_r50_fpn_1x_coco_20200130-047c8118.pth > /workspace/checkpoints/faster_rcnn_r50_fpn_1x_coco_20200130-047c8118.pth

# run ml backend on 9090
CMD label-studio-ml start coco-detector --with \
    config_file=/workspace/configs/faster_rcnn_r50_fpn_1x_coco.py \
    checkpoint_file=/workspace/checkpoints/faster_rcnn_r50_fpn_1x_coco_20200130-047c8118.pth \
    score_threshold=0.5 \
    device=cpu
