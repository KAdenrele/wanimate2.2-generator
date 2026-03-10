docker build -t wan2_2_auto . && docker run --rm \
                                            --gpus "device=0" \
                                            --shm-size=8g \
                                            -v /mnt/data/test_dataset/models:/workspace/Wan2.2/Wan2.2-TI2V-5B \
                                            -v /mnt/data/test_dataset/raw/videos/Wan2_2:/workspace/Wan2.2/outputs \
                                            wan2_2_auto