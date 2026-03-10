#!/bin/bash
set -e 

echo "--- Step 1: Downloading the Wan2.2 Model ---"
huggingface-cli download Wan-AI/Wan2.2-TI2V-5B --local-dir ./Wan2.2-TI2V-5B

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

    echo ""
    echo "[->] Generating video for: '$prompt'"
    
    # Run the generation
    python generate.py \
        --task ti2v-5B \
        --size 1280*704 \
        --ckpt_dir ./Wan2.2-TI2V-5B \
        --offload_model True \
        --convert_model_dtype \
        --t5_cpu \
        --prompt "$prompt"

    
    # 1. Find the newest .mp4 file in the current folder
    NEWEST_MP4=$(ls -t *.mp4 2>/dev/null | head -n 1)
    
    if [ -n "$NEWEST_MP4" ]; then
        # 2. Create a clean, safe filename from the prompt (Max 50 chars, no weird symbols)
        SAFE_NAME=$(echo "$prompt" | cut -c 1-50 | tr -dc '[:alnum:]_ ' | tr ' ' '_').mp4
        
        # 3. Move it into the mapped 'outputs' folder
        mv "$NEWEST_MP4" "outputs/$SAFE_NAME"
        echo "[*] Successfully saved to outputs/$SAFE_NAME"
    else
        echo "[!] Warning: Generation finished, but no .mp4 file was found."
    fi

done < prompts.txt

echo "--- Pipeline Complete! ---"