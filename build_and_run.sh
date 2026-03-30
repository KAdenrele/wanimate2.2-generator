docker build -t wan2_2_auto . && docker run --rm \
                                            --gpus "device=0" \
                                            --ipc=host \
                                            -v /mnt/data/test_dataset/models:/workspace/Wan2.2/Wan2.2-TI2V-5B \
                                            -v /mnt/data/video_clustering/videos/Wanimate:/workspace/Wan2.2/outputs \
                                            wan2_2_auto