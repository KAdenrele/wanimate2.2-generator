#!/bin/bash
set -e 

echo "--- Step 1: Downloading the Wan2.2 Model ---"
huggingface-cli download Wan-AI/Wan2.2-T2V-A14B --local-dir ./Wan2.2-T2V-A14B

echo "--- Step 2: Processing Prompts ---"
if [ ! -f "prompts.txt" ]; then
    echo "[!] Error: prompts.txt not found!"
    exit 1
fi

# Make sure the mapped output directory exists
mkdir -p outputs

set +e 

while IFS= read -r prompt || [ -n "$prompt" ]; do
    prompt=$(echo "$prompt" | xargs)

    if [[ -z "$prompt" || "$prompt" == \#* ]]; then
        continue
    fi

    # Create a clean, safe filename from the prompt to check for existence
    SAFE_NAME=$(echo "$prompt" | cut -c 1-50 | tr -dc '[:alnum:]_ ' | tr ' ' '_').mp4

    # Check if the file already exists in the output directory
    if [ -f "outputs/$SAFE_NAME" ]; then
        echo "[*] Video for '$prompt' already exists. Skipping."
        continue
    fi

    echo ""
    echo "[->] Generating video for: '$prompt'"
    
    # Run the generation
    torchrun --nproc_per_node=8 \ 
        generate.py \
        --task t2v-A14B \
        --size 1280*720 \
        --ckpt_dir ./Wan2.2-T2V-A14B \
        --dit_fsdp \
        --t5_fsdp \
        --ulysses_size 8 \
        --prompt "$prompt"
    
    # 1. Find the newest .mp4 file in the current folder
    NEWEST_MP4=$(ls -t *.mp4 2>/dev/null | head -n 1)
    
    if [ -n "$NEWEST_MP4" ]; then
        # Move it into the mapped 'outputs' folder using the name generated earlier
        mv "$NEWEST_MP4" "outputs/$SAFE_NAME"
        echo "[*] Successfully saved to outputs/$SAFE_NAME"
    else
        echo "[!] Warning: Generation finished, but no .mp4 file was found."
    fi

done < prompts.txt

echo "--- Pipeline Complete! ---"